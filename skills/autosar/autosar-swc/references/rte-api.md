# AUTOSAR Classic RTE API & Port-Interface Reference

Reference for AUTOSAR Classic Platform RTE APIs, port-interface ComSpecs, runnable activation events, and platform/application data types. Use alongside the SKILL.md autosar-swc modes when you need the canonical naming or a quick lookup for a specific API.

## RTE API naming convention

All RTE APIs follow: `Rte_<access>_<portName>_<elementOrOperation>()`.

| `<access>` | Used for                                          | Example                                              |
|------------|---------------------------------------------------|------------------------------------------------------|
| `Read`     | S/R receiver, explicit access                     | `Rte_Read_RBattVoltage_Voltage_mV(&v)`              |
| `Write`    | S/R sender, explicit access                       | `Rte_Write_PLowVoltageWarning_Active(TRUE)`          |
| `IRead`    | S/R receiver, implicit access (data copied to local DEH at runnable start) | `v = Rte_IRead_MainRunnable_RBattVoltage_Voltage_mV()` |
| `IWrite`   | S/R sender, implicit access                       | `Rte_IWrite_MainRunnable_PLowVoltageWarning_Active(TRUE)` |
| `Call`     | C/S client operation invocation                   | `Rte_Call_RNvMService_ReadBlock(blockId, &buf)`     |
| `Result`   | C/S client async operation result                 | `Rte_Result_RNvMService_ReadBlock(&status)`         |
| `Receive`  | S/R receiver, queued (event semantics)            | `Rte_Receive_REvent_Type(&evt)`                      |
| `Send`     | S/R sender, queued                                 | `Rte_Send_PEvent_Type(evt)`                          |
| `Mode`     | Mode switch current mode read                     | `Rte_Mode_RWindowMode_currentMode()`                 |
| `Switch`   | Mode switch issue                                  | `Rte_Switch_PWindowMode_mode(WINDOW_MOVING_UP)`      |
| `Enter`/`Exit` | ExclusiveArea critical section               | `Rte_Enter_EA_CoolantState() / Rte_Exit_EA_CoolantState()` |
| `Trigger`  | Trigger an InterRunnableTriggerEvent              | `Rte_Trigger_PMyTrigger()`                           |
| `Feedback` | TX confirmation from a sender                     | `Rte_Feedback_PCanSignal_Value()`                    |

Naming convention for the port: `P<InterfaceName>` for provided, `R<InterfaceName>` for required.

## Port interface types

### SenderReceiver (S/R)

Used for continuous or periodic data streams (sensor values, status flags, calculated outputs).

**Sender ComSpec**:
- `InitValue` — value transmitted before the runnable produces its first real output. Use a value that downstream consumers can recognise as "not yet valid" (often the same as the receiver's init).

**Receiver ComSpec**:
- `InitValue` — what the receiver reads if no message has arrived (e.g., before init, after timeout).
- `AliveTimeout` — for safety-relevant signals, max time without an update before the receiver applies the InitValue. `0` disables. Typically `2× sender period` for ASIL-tagged signals.
- `HandleOutOfRange` — what the receiver does if the sender writes outside the data type range.

### ClientServer (C/S)

Used for request/response (NvM read/write, diagnostic request, calibration trigger).

- Synchronous: server runs in caller context (return immediately).
- Asynchronous: server runs in its own context; client uses `Rte_Result_*` to poll.
- Operations carry `IN` / `OUT` / `INOUT` arguments and a `Std_ReturnType` (`E_OK`/`E_NOT_OK`) plus optional ApplicationErrors.

### Mode Switch

Used for mode-dependent runnable activation. ModeDeclarationGroup defines the set of modes; mode-switching SWC issues `Rte_Switch_*`; receiving runnables can be activated by `OnEntry`/`OnExit` events or guarded by `DisabledModeRef`.

### Parameter

Used for calibration data — runtime-readable but normally fixed at integration. Provided by a ParameterSWC or mapped to a NvM block.

## Runnable activation events

| Event                      | When the runnable fires                                  | Notes                                    |
|----------------------------|----------------------------------------------------------|------------------------------------------|
| `InitEvent`                 | Once during SWC startup                                  | Use for one-shot init only               |
| `TimingEvent`               | Periodically with a configured period (e.g., 10 ms)      | Most common for periodic algorithms      |
| `DataReceivedEvent`         | A new value arrives on an S/R receiver port              | For event-driven processing              |
| `DataReceivedErrorEvent`    | A receive error occurred (timeout, range violation)      | Safety reaction hook                     |
| `DataSendCompletedEvent`    | An S/R send completed (confirmation)                     | TX feedback handler                      |
| `OperationInvokedEvent`     | A C/S server operation is invoked                        | Implements the server side               |
| `AsynchronousServerCallReturnsEvent` | An async C/S call completes                     | Client-side completion handler           |
| `SwcModeSwitchEvent`        | The mode of a referenced ModeDeclarationGroup changes    | Use with `OnEntry` / `OnExit` specifier  |
| `ModeSwitchedAckEvent`      | Acknowledgement of a mode switch                         | Mode-coordination handshake              |
| `BackgroundEvent`           | When no other runnable is ready (lowest priority)        | Use sparingly                            |
| `InterRunnableTriggerEvent` | One runnable triggers another within the same SWC        | Lightweight intra-SWC dispatch           |

## ExclusiveArea

Protects shared variables accessed by multiple runnables (or a runnable + ISR).

Declaration: `<EXCLUSIVE-AREA><SHORT-NAME>EA_MyArea</SHORT-NAME></EXCLUSIVE-AREA>` in the SWC InternalBehavior.

Usage:
```c
Rte_Enter_EA_MyArea();
/* critical section */
Rte_Exit_EA_MyArea();
```

The RTE generator maps each ExclusiveArea to an `OsResource` (or interrupt-disable region, depending on `RteExclusiveAreaImplMechanism` config). Two runnables both calling `Rte_Enter_EA_MyArea()` are guaranteed mutual exclusion.

## AUTOSAR platform types vs C99

| Use case                            | AUTOSAR Classic       | C99 `<stdint.h>` (do NOT mix in SWC code) |
|-------------------------------------|-----------------------|--------------------------------------------|
| 8-bit unsigned                       | `uint8`              | `uint8_t`                                  |
| 16-bit unsigned                      | `uint16`             | `uint16_t`                                 |
| 32-bit unsigned                      | `uint32`             | `uint32_t`                                 |
| 8-bit signed                         | `sint8`              | `int8_t`                                   |
| 16-bit signed                        | `sint16`             | `int16_t`                                  |
| 32-bit signed                        | `sint32`             | `int32_t`                                  |
| Boolean                              | `boolean` (`TRUE`/`FALSE`) | `bool` or `int`                       |
| Float                                | `float32`            | `float`                                    |
| Double                               | `float64`            | `double`                                   |

**Convention:** platform types have **no `_t` suffix**. ApplicationDataTypes (project-defined semantic typedefs over a platform type) conventionally **do** use `_t` (e.g., `BatMon_Voltage_mV_t`).

`Std_ReturnType` from `Std_Types.h`: `E_OK` (0), `E_NOT_OK` (1), or application-specific extensions (0x02–0x3F reserved for AUTOSAR; >= 0x40 for user errors).

## SWC type quick reference

| SWC type           | Allowed to                                              | Forbidden                                |
|--------------------|---------------------------------------------------------|------------------------------------------|
| Application        | RTE access only                                          | Direct BSW, direct MCAL, register access |
| Sensor/Actuator    | RTE + IoHwAb (which bridges to MCAL)                     | Direct MCAL or register access           |
| Service            | RTE + the wrapped BSW module (NvM, Dem, Dcm, Com)         | Direct MCAL or register access           |
| Complex Device Driver | Direct MCAL or register access (with documented rationale) | RTE access from other SWCs only via ports |
| Composition        | Groups other SWCs; no behaviour of its own               | No runnables                             |

## MCAL abstraction rule

Application and Service SWCs **must not** access hardware registers or call MCAL APIs directly. All hardware interaction routes through:
- **IoHwAb** (I/O Hardware Abstraction) for sensors and actuators (Dio, Adc, Pwm, Spi via wrapper).
- **BSW modules** for communication (Com), persistence (NvM), diagnostics (Dem, Dcm), and OS (Os).

A Complex Device Driver (CDD) is the only SWC type allowed direct MCAL access, and only when the documented rationale (timing, custom protocol, etc.) shows IoHwAb is insufficient.

## ARXML element quick reference

| Element                                | Purpose                                                    |
|----------------------------------------|------------------------------------------------------------|
| `APPLICATION-SW-COMPONENT-TYPE`        | Application SWC type definition                            |
| `SENSOR-ACTUATOR-SW-COMPONENT-TYPE`    | Sensor/Actuator SWC type definition                        |
| `SERVICE-SW-COMPONENT-TYPE`            | Service SWC type definition                                |
| `COMPLEX-DEVICE-DRIVER-SW-COMPONENT-TYPE` | CDD definition                                          |
| `COMPOSITION-SW-COMPONENT-TYPE`        | Composition wrapping other SWCs                            |
| `P-PORT-PROTOTYPE`                     | Provided port                                              |
| `R-PORT-PROTOTYPE`                     | Required port                                              |
| `PR-PORT-PROTOTYPE`                    | Combined provided + required (rare)                        |
| `SENDER-RECEIVER-INTERFACE`            | S/R interface definition                                   |
| `CLIENT-SERVER-INTERFACE`              | C/S interface definition                                   |
| `MODE-SWITCH-INTERFACE`                | Mode switch interface                                      |
| `PARAMETER-INTERFACE`                  | Calibration parameter interface                            |
| `VARIABLE-DATA-PROTOTYPE`              | S/R DataElement                                            |
| `CLIENT-SERVER-OPERATION`              | C/S Operation                                              |
| `SWC-INTERNAL-BEHAVIOR`                | Runnables + events + ExclusiveAreas inside the SWC          |
| `RUNNABLE-ENTITY`                      | One runnable                                                |
| `TIMING-EVENT`                         | Periodic activation                                         |
| `INIT-EVENT`                           | Init-time activation                                        |
| `DATA-RECEIVED-EVENT`                  | Trigger on S/R receiver new data                            |
| `EXCLUSIVE-AREA`                       | Mutex region                                                |
| `ASSEMBLY-SW-CONNECTOR`                | Connects two SWC prototypes' ports in a composition         |
| `DELEGATION-SW-CONNECTOR`              | Delegates a composition port to an inner SWC port           |
