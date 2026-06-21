# Communication protocol - reference

Depth for the **Communication protocol** mode of the AUTOSAR BSW skill. Classic AUTOSAR (CP) focus,
with SOME/IP and DoIP that also appear on Adaptive. ASCII only, no em dashes. Consult the relevant
sub-area; do not load the whole file unless needed.

---

## 1. On-board buses

### 1a. CAN and CAN FD

Frame and signal layout:
- A signal is defined by start bit, bit length, byte order, factor, offset, and value range.
- Byte order: DBC `@1+` = Intel / little-endian, `@0+` = Motorola / big-endian. AUTOSAR Com
  `ComSignalEndianness` must match the DBC, and `ComBitPosition` follows the AUTOSAR convention
  (which differs from DBC start-bit numbering for Motorola signals - a frequent defect).
- Classic CAN: up to 8 data bytes, DLC 0..8.
- CAN FD: payload up to 64 bytes; DLC values 9..15 map to lengths 12,16,20,24,32,48,64. Bit Rate
  Switch (BRS) raises the data-phase bit rate; the arbitration phase stays at the nominal rate.
- Transmit modes: cyclic (fixed period), on-change (event), or mixed (cyclic + on-change).
- E2E protection (counter + CRC, AUTOSAR E2E profiles) for safety-relevant signals: the receiver
  checks the counter sequence and CRC and applies a timeout/fault reaction.

### 1b. LIN

- Schedule table: the master runs frame slots on a fixed schedule; each slot is a frame header the
  master sends, with a configured slot delay.
- Master/slave: the master sends the header; a configured responder (master or a slave) sends the
  response bytes.
- Checksum: classic (data only) vs enhanced (data + PID); both ends must agree.
- Response timeout and the LIN error handling (no-response, checksum error, framing) feed the LIN
  status and any diagnostic reaction.

---

## 2. Transport and routing

### 2a. CanTp (ISO 15765-2) segmentation

For payloads larger than a single frame (> 7 data bytes classic, > 63 CAN FD, accounting for the
PCI byte):
- Single Frame (SF) for short messages.
- First Frame (FF) starts a multi-frame message and declares total length.
- Flow Control (FC) from the receiver: ClearToSend / Wait / Overflow, plus Block Size (BS = frames
  between FCs) and STmin (minimum separation time between consecutive frames).
- Consecutive Frames (CF) carry the remaining data with a rolling sequence number.
- Timeouts: N_As / N_Ar (sender/receiver frame transmission), N_Bs (wait for FC), N_Cr (wait for
  CF). A timeout aborts the segmented transfer.

### 2b. PduR routing

- Routing path types: signal routing, PDU (I-PDU) routing, and TP routing for segmented data.
- Gateway routing forwards PDUs between channels (e.g. CAN to CAN, CAN to Ethernet) with optional
  gateway-on-the-fly for large TP messages.
- PduR also routes between the bus interface and upper layers (Com, Dcm) - a missing routing path
  is a common reason a frame is on the bus but never reaches the SWC or the diagnostic stack.

---

## 3. Network management (ComM / Nm) and partial networking

- ComM: channels and users. A user requests FULL_COMMUNICATION or NO_COMMUNICATION; ComM aggregates
  requests per channel and asks Nm to keep the bus awake or release it.
- Nm coordinated state machine: Repeat Message State -> Normal Operation State -> Ready Sleep State
  -> Bus Sleep State. Nm messages keep all nodes awake together and coordinate a synchronized sleep
  so no node is left talking to a sleeping bus.
- Partial Networking (PN): Partial Network Clusters (PNC) allow subsets of the network to sleep
  while others run. A PN-capable transceiver wakes only on a configured wakeup frame. See the power
  handling in `boot-nvm-power.md` for the transceiver/EcuM side.

---

## 4. Diagnostics over the bus (UDS / Dcm / Dem)

### 4a. UDS service handler - NRC check order

Validate every request in this order and return the first failing NRC:
1. message length -> NRC 0x13 (incorrectMessageLengthOrInvalidFormat)
2. service supported -> NRC 0x11 (serviceNotSupported)
3. sub-function supported -> NRC 0x12 (subFunctionNotSupported), or 0x7E in active session
4. session valid -> NRC 0x7F (serviceNotSupportedInActiveSession)
5. security unlocked -> NRC 0x33 (securityAccessDenied)
6. request in range -> NRC 0x31 (requestOutOfRange)
7. conditions correct -> NRC 0x22 (conditionsNotCorrect)
On success, the positive response SID is request SID + 0x40.

Common services: 0x10 (session control), 0x11 (ECU reset), 0x14/0x19 (clear/read DTC), 0x22/0x2E
(read/write DID), 0x27 (security access), 0x28 (communication control), 0x2F (IO control), 0x31
(routine control), 0x34-0x37 (download/transfer), 0x3E (tester present), 0x85 (control DTC setting).

In AUTOSAR these are implemented as Dcm callouts; Dcm handles session/security/response framing and
pending (0x78) responses for async operations. Do not parse UDS outside the Dcm framework.

### 4b. DTC status byte (ISO 14229-1)

Bit 0 testFailed, bit 1 testFailedThisOperationCycle, bit 2 pendingDTC, bit 3 confirmedDTC,
bit 4 testNotCompletedSinceLastClear, bit 5 testFailedSinceLastClear,
bit 6 testNotCompletedThisOperationCycle, bit 7 warningIndicatorRequested (MIL).
Never manipulate these bits directly. Report faults via Dem (`Dem_SetEventStatus` /
`Dem_ReportErrorStatus`); Dem manages the transitions per the configured debounce, operation
cycles, and aging. (Dcm/Dem configuration is in the BSW configuration mode.)

---

## 5. Service-oriented Ethernet

### 5a. SOME/IP

Message format fields: Message ID (Service ID + Method/Event ID), Length, Request ID (Client ID +
Session ID), Protocol Version, Interface Version, Message Type (REQUEST, REQUEST_NO_RETURN,
NOTIFICATION, RESPONSE, ERROR), Return Code. Serialization packs parameters per the service
interface, big-endian by default, with configured alignment and length fields for dynamic data.

Service Discovery (SOME/IP-SD):
- Provider sends OfferService (service + instance + endpoint, with a TTL).
- Consumer sends FindService (optional) and SubscribeEventgroup (eventgroup + its own endpoint).
- Provider replies SubscribeEventgroupAck (or Nack). Only then are eventgroup events delivered.
- Events are delivered unicast or multicast; multicast requires the consumer to join the group.
- TTL must be renewed; TTL 0 means stop offering/subscribing.

### 5b. DoIP (ISO 13400)

- Vehicle announcement / VehicleIdentificationRequest-Response to discover the ECU on IP.
- Routing activation handshake: RoutingActivationRequest (source address, activation type) ->
  RoutingActivationResponse (response code, logical addresses). UDS diagnostics only flow after a
  successful activation.
- UDS is then tunneled in DoIP diagnostic messages (with source/target logical addresses) over TCP.
- On Classic this rides SoAd plus the SOME/IP / DoIP modules; on Adaptive the equivalent service
  communication is provided by ara::com - state which platform applies.
