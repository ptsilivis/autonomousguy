# AUTOSAR COM Stack — Layer-by-Layer Reference

Comprehensive reference for debugging the AUTOSAR Classic COM stack (CanDrv → CanIf → PduR → Com → RTE → SWC), TX and RX directions. Use alongside the SKILL.md COM-stack mode for fast layer-walk lookups.

## RX path (top-down from bus to SWC)

```
Can_Hw                            (hardware FIFO / mailbox)
  → Can_RxIndication              (CanDrv ISR)
  → CanIf_RxIndication            (CanIf RX dispatch)
  → PduR_CanIfRxIndication        (PduR routing)
  → Com_RxIndication              (Com signal unpack)
  → Rte_Write_*                   (RTE to SWC)
```

### Layer responsibilities

| Layer  | Owns                                                         | EB Tresos containers                          |
|--------|--------------------------------------------------------------|-----------------------------------------------|
| CanDrv | Hardware filters, mailbox config, baudrate, controller state | `CanHardwareObject`, `CanController`          |
| CanIf  | PDU dispatching, user upper-layer routing                    | `CanIfRxPduCfg`, `CanIfTxPduCfg`, `CanIfRxPduCanIdMask` |
| PduR   | Routing table (CanIf ↔ Com / TP)                             | `PduRRoutingPath`, `PduRSrcPdu`, `PduRDestPdu` |
| Com    | Signal pack/unpack, scaling, init, timeout                   | `ComIPdu`, `ComSignal`, `ComTimeoutNotification` |

## TX path (top-down from SWC to bus)

```
Rte_Write_*                       (SWC)
  → Com_SendSignal                (Com signal pack)
  → Com_TriggerIPduSend            (Com → PduR)
  → PduR_ComTransmit              (PduR routing)
  → CanIf_Transmit                (CanIf → hw)
  → Can_Write                     (CanDrv)
  → Can_Hw                        (hardware mailbox / FIFO)
```

## Symptom → first layer to suspect

| Symptom                                                  | First suspect       |
|----------------------------------------------------------|---------------------|
| No signal at all (always init value)                     | CanDrv (filters, controller state) |
| Wrong value (constant, but wrong)                        | Com (byte order, scaling, start bit) |
| Sometimes correct, sometimes init                        | CanIf RX buffer overflow / Com main-function task overrun |
| Correct after ignition cycle, then drifts to init        | Com `ComTimeout` firing |
| Signal in CAN trace but SWC sees init                    | CanIf filter / PduR routing |
| SWC writes, nothing on bus (TX)                          | `Com_SendSignal` return + `Com_MainFunctionTx` |
| TX intermittent                                          | `ComTxModeMode`, `ComMinimumDelayTime`, CanIf mailbox congestion |

## RX layer-walk checklist (when frame IS on bus but SWC sees nothing)

### CanDrv
- Controller `CAN_CS_STARTED`? `CanIf_GetControllerMode`.
- Hardware filter mask: `CanHardwareObject` → `CanHwObjectCount`, `CanIdValue`, `CanIdMask`. **Common bug**: mask requires bits the actual ID doesn't have.
- `Can_MainFunction_Read` actually being called? Default 1 ms; if its OS task is overrun or disabled, RX frames sit in the mailbox until overwritten.

### CanIf
- `CanIfRxPduCfg`: entry exists for this CAN ID + Controller + HRH?
- `CanIfRxPduCanIdMask` / `CanIfRxPduCanIdRange`: runtime CAN ID matches?
- `CanIfUserRxIndicationUL` must be `PDUR` (not `CDD` or `NONE`).
- If `CanIfPublicReadRxPduDataApi` is enabled and PduR uses polled read, confirm PduR is calling `CanIf_ReadRxPduData`.

### PduR
- `PduRRoutingPath` for this Rx PDU has destination `PDUR_COM`.
- `PduRSrcPdu` references the CanIf Rx PDU; `PduRDestPdu` references the Com Rx PDU.
- If routing is to a TP module instead (CanTp / FrTp), the frame won't reach Com.

### Com
- `ComIPdu` exists for the routed PDU; `ComIPduDirection = RECEIVE`.
- `ComSignal`: `ComBitPosition`, `ComBitSize`, `ComSignalEndianness` (`BIG_ENDIAN` / `LITTLE_ENDIAN` — must match DBC `@1+` vs `@0+`), `ComSignalType`, `ComInitValue`.
- `ComNotification` callback fires? Add a counter. If yes, problem is downstream (RTE/SWC). If no, upstream.
- `ComTimeoutNotification` / `ComFirstTimeout`: confirm timeout isn't triggering before first valid frame, replacing the value with `ComInitValue`.

## TX layer-walk checklist (when SWC writes but bus shows nothing)

### SWC / RTE
- Did the SWC actually call `Rte_Write_*`? Check return code.
- Confirm `Com_SendSignal` was reached (DET, breakpoint, callout).

### Com
- `ComIPdu` `ComIPduDirection = SEND`.
- `ComTxModeMode`: `PERIODIC`, `DIRECT`, or `MIXED`.
  - `DIRECT` requires `ComTxModeNumberOfRepetitions ≥ 1` after `Com_SendSignal`.
  - `PERIODIC` requires `Com_MainFunctionTx` to be running.
- `ComMinimumDelayTime`: two `Com_SendSignal` calls within this window are merged.
- `ComTxIPduUnusedAreasDefault`: non-zero defaults can corrupt unused bits.

### PduR
- `PduRRoutingPath` exists for the Com Tx PDU with destination `PDUR_CANIF`.

### CanIf
- `CanIfTxPduCfg` exists, references correct `CanHardwareObject` (HTH).
- `CanIfTxPduUserTxConfirmationUL = PDUR` so the confirmation closes the Com loop.
- Mailbox congestion: if `Can_Write` returns `CAN_BUSY` and the BSW retry strategy isn't configured, transmissions silently drop.

### CanDrv
- Bus-off state (`CanIf_GetControllerMode` → `CANIF_CS_STOPPED` indicates bus-off recovery).
- Controller not started, baudrate mismatch.

## Probe / instrumentation patterns

- DET hooks: enable `CANIF_DEV_ERROR_DETECT` and `COM_DEV_ERROR_DETECT`; route `Det_ReportError` to a trace buffer.
- Counters in `ComNotification`, `CanIf_RxIndication` user callback.
- For RX: temporarily map the signal to a debug output port or NvM trace block.
- For TX: capture the bus with the same CAN tool that proved the frame was missing.

## Common configuration anti-patterns

- CanIf Rx PDU uses a CAN ID mask that excludes the runtime ID (0x1FFFFFFF mask applied to an 11-bit ID, or vice versa).
- Com `ComSignalEndianness` mismatched with DBC: `@1+` is `LITTLE_ENDIAN` (Intel), `@0+` is `BIG_ENDIAN` (Motorola).
- `ComBitPosition` interpreted differently by sender and receiver — the DBC tool and AUTOSAR generator may number bits in opposite directions for Motorola signals.
- `Com_MainFunctionRx` and `Com_MainFunctionTx` mapped to different OS tasks with different priorities — starvation risk.
- `ComFilterAlgorithm` other than `ALWAYS` silently dropping values that don't match the filter (`MASKED_NEW_DIFFERS_X` is the classic gotcha).

## Bus-level pre-check (always step 1)

Never debug the stack before confirming what's on the wire:
- **RX**: capture with CANalyzer / BusMaster / candump / PCAN-View. Confirm expected CAN ID, DLC matches PDU length, cycle time within tolerance.
- **TX**: same capture. If your ECU should be transmitting and the frame isn't on the bus, before debugging the stack confirm hardware: bus terminated (60 Ω), transceiver not in Sleep, CAN_H/CAN_L not swapped, no bus-off state.
