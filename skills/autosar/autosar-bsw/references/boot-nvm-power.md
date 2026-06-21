# Boot, NVM & power - reference

Depth for the **Boot, NVM & power** mode of the AUTOSAR BSW skill. Classic AUTOSAR (CP) focus.
ASCII only, no em dashes. Consult the relevant sub-area; do not load the whole file unless needed.

---

## 1. Boot / startup

### 1a. Bare-metal startup

Reset vector -> startup code -> C runtime -> `main`:

1. Reset vector points to the startup routine (often `Reset_Handler`).
2. Set the initial stack pointer; configure the clock tree (PLL, flash wait states) so the rest of
   init runs at the intended frequency.
3. Copy initialised data (`.data`) from flash to RAM; zero the `.bss` section.
4. Run C++ static constructors if any (`.init_array`).
5. Call `main` (or the AUTOSAR `EcuM_Init` path).

Common faults: `.bss` not zeroed (random initial state), `.data` copy skipped (initialised globals
read as garbage), wrong startup file for the silicon variant, vector table not at the address the
core expects (VTOR misconfigured).

### 1b. Classic AUTOSAR startup (EcuM / BswM)

Phase order:

- `EcuM_Init` -> `StartPreOS` sequence: init MCU/MCAL drivers needed before the OS (Mcu, Port, Dio,
  Gpt, Wdg + WdgM init, BSW scheduler basics).
- `StartOS` (the OS starts, tasks begin scheduling).
- `StartPostOS` sequence: `NvM_ReadAll`, communication stack init (CanIf, Com, PduR, ComM, Nm),
  Dem/Dcm init, then RTE start and SWC init runnables.

Driver init order must follow the dependency chain MCAL -> ECU abstraction -> BSW services -> RTE ->
SWC. A module initialised out of order (e.g. Com before its PDU config, or a SWC reading NvM data
before `NvM_ReadAll` finished) is the usual root cause of startup defects.

BswM arbitrates modes from rules (condition -> action list). It coordinates startup, wakeup,
shutdown, and partial networking actions.

### 1c. Bootloader and reprogramming (UDS flash download)

Typical UDS sequence for a flash update (ISO 14229 + ISO 15765 transport):

1. `0x10 02` - switch to programming session (often via `0x10 03` extended first).
2. `0x27` - security access (request seed, send computed key).
3. `0x31` - RoutineControl: erase memory / check programming preconditions.
4. `0x34` - RequestDownload (memory address + size, compression/encryption format).
5. `0x36` - TransferData (repeated blocks, block sequence counter).
6. `0x37` - RequestTransferExit.
7. `0x31` - RoutineControl: check memory / verify checksum or signature.
8. `0x11 01` - ECU reset; jump to the new application.

Design points:
- Dual-bank / A-B layout lets the old image stay valid until the new one is verified.
- An application-validity marker (and CRC or signature over the app) gates the bootloader's
  jump-to-application decision; never jump to an unverified image.
- Keep the bootloader minimal and independently updatable only with great care (a bricked
  bootloader is unrecoverable in the field).

---

## 2. NVM storage stack

### 2a. NvM block descriptor options

- `NvMBlockManagementType`: `NVM_BLOCK_NATIVE` (one copy), `NVM_BLOCK_REDUNDANT` (two copies, survives
  one corrupted instance), `NVM_BLOCK_DATASET` (indexed set, e.g. per-variant calibration).
- CRC: `NvMBlockUseCrc` + `NvMCrcType` (CRC16/CRC32) detects torn or corrupted writes on read.
- Write policy: immediate (`NvM_WriteBlock` flushed promptly) vs deferred (queued, flushed by
  `NvM_WriteAll` or the main function). Deferred trades latency for throughput - the source of many
  "lost after power cut" bugs.
- `NvMWriteBlockOnce`: TRUE for write-once data (e.g. end-of-line VIN); FALSE for values that change.
- `NvMSelectBlockForWriteAll`: TRUE to include the block in the `NvM_WriteAll` sweep.
- Default value: applied on first-ever init (or after a failed CRC with no redundant copy).

### 2b. Fee / Ea over MemIf

NvM does not touch flash directly. It goes NvM -> MemIf -> Fee (flash EEPROM emulation) or Ea
(EEPROM abstraction) -> the flash/EEPROM driver. Fee/Ea manage logical blocks over physical
sectors, including sector switching when a sector fills.

### 2c. Wear leveling

Flash sectors have a finite erase-cycle budget. Strategies: rotate writes across sectors, coalesce
writes (avoid writing unchanged blocks), and budget the erase count against vehicle lifetime
(e.g. N writes/day x 15 years must stay under the endurance rating with margin). Watch write
amplification - a small logical write can trigger a full sector erase + copy.

### 2d. Sequencing

- Startup: `NvM_ReadAll` populates RAM mirrors; consumers must wait for completion.
- Runtime: `NvM_WriteBlock` (single) / `NvM_MainFunction` services the job queue.
- Shutdown: `NvM_WriteAll` flushes all selected blocks; poll `NvM_GetStatus() == NVM_IDLE` or use
  the job-end notification before cutting power.

---

## 3. Power / state management

### 3a. EcuM sleep / wakeup state machine

`RUN` -> (GoSleep requested) -> run shutdown/sleep prep (including `NvM_WriteAll`) -> `SLEEP`
(MCU low-power, selected wakeup sources armed) -> wakeup event -> wakeup validation -> back to `RUN`.

Wakeup sources (CAN, LIN, local pin, timer) must be configured and validated; a spurious wakeup
that fails validation should return the ECU to sleep rather than fully starting up.

### 3b. Partial networking (PN)

Partial Network Clusters (PNC) let parts of the network sleep while others stay awake. A
PN-capable CAN transceiver wakes only on a configured wakeup frame. ComM and Nm coordinate which
PNCs are active; the transceiver stays in a selective wake mode otherwise. Saves quiescent current.

### 3c. Ordered shutdown

BswM runs a shutdown action list. The critical ordering rule: complete `NvM_WriteAll` (and confirm
`NVM_IDLE`) BEFORE commanding the transceiver to Sleep and the MCU to low-power. If sleep is entered
while deferred NvM jobs are still queued, the data is lost on power-down. Confirm worst-case
WriteAll time fits the board hold-up time after ignition-off.

### 3d. Low-power MCU modes

SLEEP / STOP / STANDBY (names vary by silicon) trade wake latency and retained state against
current draw. Combine with clock gating and peripheral power-down. Verify which RAM/registers are
retained in the chosen mode so post-wake state is correct.
