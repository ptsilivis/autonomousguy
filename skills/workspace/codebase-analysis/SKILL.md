---
name: Codebase Analysis
short: Scan a workspace and produce a per-component CODEBASE_MAP.md with SWRs, interfaces, dependencies, and RTE APIs
description: "First-run skill that walks the entire repository, identifies all features and AUTOSAR SWCs, and for each one documents: (a) referenced Software Requirement IDs found in source comments, headers, requirement docs, or traceability files (SW-REQ-*, REQ-*, FSR-*, SYS-REQ-*); (b) port interfaces (S/R, C/S, Mode Switch, Parameter) with direction and DataElement / Operation names; (c) dependencies on other SWCs and BSW modules (Com, NvM, Dem, Dcm, IoHwAb, Os); (d) the concrete RTE API calls each SWC makes (Rte_Read_*, Rte_Write_*, Rte_Call_*, Rte_IRead_*, Rte_IWrite_*, Rte_Enter_/Exit_*). Also captures repository structure, ASIL zones, signal flow, and architectural concerns. Writes findings to .autonomousguy/CODEBASE_MAP.md so every subsequent skill can reference it without re-reading the codebase."
category: workspace
tags: [onboarding, analysis, autosar, swc, bsw, swr, traceability, rte, mapping]
---

# Skill: Codebase Analysis

## Context
You are an experienced embedded automotive software architect performing a first-time onboarding analysis of an unfamiliar codebase. Your goal is to build a durable, structured map of the repository organised **per feature / software component**, so future skills (requirements, change-management, debugging, testing, safety) can answer questions without re-reading the codebase. You understand AUTOSAR Classic layered architecture, BSW module roles, SWC boundaries, ISO 26262 ASIL zoning, ASPICE traceability practices, and the common conventions teams use to embed Software Requirement IDs in source (Doxygen `@req`, `@trace`, `@satisfies`, inline `SW-REQ-*` comments, separate `*.trace` / `*.csv` files, DOORS export sidecars).

## Instructions

### 1. Discover repository structure
- List source directories, identify the build system (CMake, Makefile, EB Tresos project), and locate ARXML, DBC, configuration, and requirement / traceability files (`*.req`, `*.csv`, `traceability*`, `requirements*`, `doc/`, DOORS / Polarion exports).
- Note the AUTOSAR toolchain in use (EB Tresos / DaVinci) and any AUTOSAR release version.

### 2. Identify features and Software Components
- A **feature** is a coherent piece of functionality (e.g., "Battery Cell Monitoring", "Window Lift", "Anti-Pinch"). Group SWCs that collaborate on the same feature.
- For each SWC: name, type (Application / Sensor-Actuator / Service / CDD / Composition), source / header files, runnables and likely activation events.

### 3. Per-component documentation — for each SWC, capture all of:

#### 3a. Software Requirement IDs
Scan source comments, headers, separate trace files, and requirement docs for any of these patterns and attribute them to the SWC that implements them:
- `SW-REQ-<MOD>-NNN`, `SWR-NNN`, `REQ-NNN`, `FSR-NNN`, `TSR-NNN`, `SYS-REQ-NNN`
- Doxygen / structured tags: `@req`, `@trace`, `@satisfies`, `@implements`, `@requirement`
- Markdown / inline link patterns: `Requirement: SW-REQ-…`, `Implements SW-REQ-…`
- Sidecar files: `*.trace`, `requirements.csv`, `swr_map.json`, DOORS/Polarion exports

For each found ID, record the source location (file:line or document path) so future skills can verify.

#### 3b. Port interfaces
Enumerate every port the SWC defines or consumes:
- Direction: **P** (provided) / **R** (required) / **PR** (combined)
- Type: **S/R** (SenderReceiver), **C/S** (ClientServer), **Mode** (ModeSwitch), **Param** (Parameter)
- Interface short-name and the DataElement(s) or Operation(s) involved
- Source: ARXML if available, otherwise inferred from RTE API call sites

#### 3c. Dependencies
Two flavours:
- **SWC-to-SWC** — derived from S/R or C/S connections (in the composition / ARXML). Record direction: "this SWC consumes signal X from `OtherSWC`" or "this SWC provides signal Y to `OtherSWC`".
- **SWC-to-BSW** — BSW modules the SWC calls (Com, NvM, Dem, Dcm, IoHwAb, Os, MemIf, Fee), with the specific APIs invoked.

#### 3d. RTE interfaces (actual API surface)
The concrete list of RTE calls each SWC makes, as found in the C source:
- `Rte_Read_<port>_<element>` / `Rte_IRead_<runnable>_<port>_<element>`
- `Rte_Write_<port>_<element>` / `Rte_IWrite_<runnable>_<port>_<element>`
- `Rte_Call_<port>_<operation>` / `Rte_Result_<port>_<operation>`
- `Rte_Receive_<port>_<element>` / `Rte_Send_<port>_<element>`
- `Rte_Mode_<port>` / `Rte_Switch_<port>_<mode>`
- `Rte_Enter_<area>` / `Rte_Exit_<area>`
- `Rte_Trigger_<port>` / `Rte_Feedback_<port>`

This is the runtime contract — preserve the full list so traceability, integration review, and change-impact skills can use it.

### 4. Cross-cutting maps
- **BSW module usage** — which BSW modules are called and by which SWCs.
- **Signal flow** — plain-text box-and-arrow diagram inside a fenced code block, from hardware inputs → SWCs → outputs (actuators, CAN, DTCs). No external rendering (Mermaid, PlantUML) so the map renders identically in every viewer and in raw text.
- **ASIL zones** — locate ASIL annotations (comments, pragmas, linker scripts, memory section names) and map SWCs / modules to their partition.

### 5. Architectural concerns
Flag findings worth attention:
- Direct hardware register access in Application / Service SWCs (MCAL abstraction violation).
- Shared mutable globals between runnables or ISR/runnable without ExclusiveArea.
- Missing ARXML for SWCs whose RTE calls suggest ports.
- SWCs with no SWR references (untraced).
- ASIL-tagged SWCs without a Safety Goal trace.
- Inconsistent naming (mixing C99 `_t` types with AUTOSAR platform types in SWC code).

### 6. Write the map
Output the full analysis to `.autonomousguy/CODEBASE_MAP.md` using the structure below. Print a one-screen summary to the console.

## Input expected
- Access to the full repository (run from the workspace root).
- Optionally: a brief description of the ECU's main function, target hardware, AUTOSAR toolchain in use, and any external requirements tool (DOORS / Polarion / Jama) so the SWR-discovery step can look for that tool's sidecar exports.

## Output format

Write `.autonomousguy/CODEBASE_MAP.md` with this structure:

~~~markdown
# Codebase Map — <Project Name>
Generated: <date>

## ECU Overview
[One paragraph: ECU function, target MCU, AUTOSAR toolchain, ASIL level, requirements toolchain if any]

## Repository Structure
[Key directories and their roles, including where SWRs / traceability data live]

## Features
- **<FeatureName>** — owning SWCs: <SWC list>
- **<FeatureName>** — owning SWCs: <SWC list>

---

## Per-Component Detail

### Feature: <FeatureName>

#### Component: <SWCName>
- **Type**: Application / Sensor-Actuator / Service / CDD / Composition
- **Source files**: `<file.c>`, `<file.h>`
- **Runnables**: `<SWC>_Init` (InitEvent), `<SWC>_MainRunnable` (TimingEvent, 10 ms), …
- **ASIL**: QM / A / B / C / D

##### Software Requirements (SWRs)
| Requirement ID | Source                          | Notes                       |
|----------------|----------------------------------|-----------------------------|
| SW-REQ-<MOD>-001 | `BatMon_App.c:42` (`@req`)     | Implemented in MainRunnable |
| FSR-001        | `requirements/batmon.md`         | Traced via `@satisfies` tag |
| …              | …                                | …                           |

##### Port Interfaces
| Port Name | Dir | Type | Interface         | DataElement / Operation | Source         |
|-----------|-----|------|-------------------|--------------------------|----------------|
| RBattVoltage | R | S/R  | BattVoltageIf     | Voltage_mV               | ARXML / line N |
| PLowVoltageWarning | P | S/R | LowVoltageWarningIf | Active              | ARXML / line N |
| RNvMService | R   | C/S  | NvMService        | ReadBlock, WriteBlock    | RTE call site  |
| …         | …   | …    | …                 | …                        | …              |

##### Dependencies
**SWC-to-SWC** (from composition / ARXML):
- Consumes `Voltage_mV` from `BattVoltage_SensorSWC` via `BattVoltageIf`
- Provides `Active` to `DisplayCtrl_AppSWC` via `LowVoltageWarningIf`

**SWC-to-BSW**:
- **Com** — `Rte_Write_PLowVoltageWarning_Active` (indirect via RTE → Com)
- **Dem** — `Rte_Call_RDemService_SetEventStatus`
- **NvM** — `Rte_Call_RNvMService_ReadBlock` (for calibration)

##### RTE Interfaces (actual API surface)
| RTE API                                              | Direction | Used In                | Notes                |
|------------------------------------------------------|-----------|-------------------------|----------------------|
| `Rte_Read_RBattVoltage_Voltage_mV`                   | Receive   | `BatMon_App.c:55`       | Explicit S/R         |
| `Rte_Write_PLowVoltageWarning_Active`                | Send      | `BatMon_App.c:71`       | Explicit S/R         |
| `Rte_Call_RDemService_SetEventStatus`                | Invoke    | `BatMon_App.c:78`       | Synchronous          |
| `Rte_Enter_EA_BatMonState` / `Rte_Exit_EA_BatMonState` | Mutex   | `BatMon_App.c:62, 88`   | Protects filter state |
| …                                                    | …         | …                       | …                    |

(Repeat the `#### Component: …` block for every SWC in the feature, then repeat the `### Feature: …` block for every feature.)

---

## Cross-Cutting Maps

### BSW Module Usage
| BSW Module | Used By SWCs | Key APIs Called |
|------------|--------------|------------------|
| Com        | …            | …                |
| Dem        | …            | …                |
| NvM        | …            | …                |
| …          | …            | …                |

### Signal Flow

Plain-text box-and-arrow notation. Boxes are `[SWC / module]`. Arrows are `──signal──>` where `signal` is the DataElement, Operation, or BSW API. Use multi-line arrows for fan-out / fan-in.

```
[Sensor / ADC]        ──────────────────> [SensorActSWC]
[SensorActSWC]        ──Voltage_mV──────> [BatMon_AppSWC]
[BatMon_AppSWC]       ──Active──────────> [DisplayCtrl_AppSWC]
[BatMon_AppSWC]       ──SetEventStatus──> [Dem]
[BatMon_AppSWC]       ──CAN signal──────> [Com]
```

### ASIL Zone Map
| Zone        | ASIL | SWCs / Modules           | Memory Section |
|-------------|------|--------------------------|----------------|
| Battery monitor | B  | BatMon_AppSWC, BattVoltage_SensorSWC | `.text.asilB` |
| Display     | QM   | DisplayCtrl_AppSWC       | `.text.qm`     |

## Architectural Concerns
1. [CRITICAL] …
2. [MAJOR] …
3. [INFO] …
~~~

## Example

**Input:** Repository for a Body Control Unit (BCU). CMake build, EB Tresos, AUTOSAR Classic 4.3, ARM Cortex-M MCU. Requirements managed in DOORS, exported as `requirements/bcu.csv`. Highest ASIL on the ECU: B (brake lights, per SG-BRAKELT-01).

**Output (excerpt written to `.autonomousguy/CODEBASE_MAP.md`):**

~~~markdown
# Codebase Map — BCU_ECU
Generated: 2026-06-17

## ECU Overview
Body Control Unit for a passenger vehicle. Hosts exterior lighting (low beam, high beam,
brake, turn indicators), interior lighting, central locking, and wiper control. Target:
ARM Cortex-M class MCU. AUTOSAR Classic 4.3, EB Tresos 26. Highest ASIL: B (brake lights
allocated to SG-BRAKELT-01 — driver-visible brake indication). Requirements in DOORS,
exported as `requirements/bcu.csv`.

## Features
- **Exterior Lights**
  - sub-feature: **Low Beam Light**       — owning SWCs: LowBeam_AppSWC
  - sub-feature: **High Beam Light**      — owning SWCs: HighBeam_AppSWC
  - sub-feature: **Brake Lights (ASIL B)**— owning SWCs: BrakeLight_AppSWC
  - shared SWCs (all sub-features): LightSwitch_SensorSWC, LightOutput_ActuatorSWC, LightDiag_ServiceSWC

---

## Per-Component Detail

### Feature: Exterior Lights / Low Beam Light

#### Component: LowBeam_AppSWC
- **Type**: Application
- **Source files**: `LowBeam_App.c`, `LowBeam_App.h`
- **Runnables**: `LowBeam_App_Init` (InitEvent), `LowBeam_App_MainRunnable` (TimingEvent, 20 ms)
- **ASIL**: QM

##### Software Requirements (SWRs)
| Requirement ID      | Source                                | Notes                                              |
|---------------------|----------------------------------------|----------------------------------------------------|
| SW-REQ-LOWBEAM-001  | `LowBeam_App.c:24` (`@req`)           | Activate low beam when switch position = ON / AUTO |
| SW-REQ-LOWBEAM-002  | `LowBeam_App.c:48` (`@req`)           | Auto-on when ambient light < 200 lux for ≥ 2 s     |
| SW-REQ-LOWBEAM-003  | `LowBeam_App.c:71` (`@implements`)    | Disable when high beam active to prevent double-on |
| SYS-REQ-LIGHT-014   | `requirements/bcu.csv` row 14          | DOORS link via SWR-001                             |

##### Port Interfaces
| Port Name          | Dir | Type | Interface           | DataElement / Operation | Source         |
|--------------------|-----|------|---------------------|--------------------------|----------------|
| RSwitchPosition    | R   | S/R  | LightSwitchIf       | Position                 | ARXML          |
| RAmbientLight_lux  | R   | S/R  | AmbientLightIf      | Illuminance_lux          | ARXML          |
| RHighBeamActive    | R   | S/R  | HighBeamStateIf     | Active                   | ARXML          |
| PLowBeamRequest    | P   | S/R  | LowBeamRequestIf    | Active                   | ARXML          |

##### Dependencies
**SWC-to-SWC**:
- Consumes `Position` from `LightSwitch_SensorSWC` via `LightSwitchIf`.
- Consumes `Illuminance_lux` from `AmbientLight_SensorSWC` via `AmbientLightIf`.
- Consumes `Active` from `HighBeam_AppSWC` via `HighBeamStateIf`.
- Provides `Active` to `LightOutput_ActuatorSWC` via `LowBeamRequestIf`.

**SWC-to-BSW**:
- None directly (no BSW calls; all I/O goes through the actuator SWC).

##### RTE Interfaces
| RTE API                                         | Direction | Used In                  | Notes              |
|-------------------------------------------------|-----------|--------------------------|--------------------|
| `Rte_Read_RSwitchPosition_Position`             | Receive   | `LowBeam_App.c:58`       | Explicit S/R       |
| `Rte_Read_RAmbientLight_lux_Illuminance_lux`    | Receive   | `LowBeam_App.c:62`       | Explicit S/R       |
| `Rte_Read_RHighBeamActive_Active`               | Receive   | `LowBeam_App.c:66`       | Explicit S/R       |
| `Rte_Write_PLowBeamRequest_Active`              | Send      | `LowBeam_App.c:104`      | Explicit S/R       |

---

### Feature: Exterior Lights / High Beam Light

#### Component: HighBeam_AppSWC
- **Type**: Application
- **Source files**: `HighBeam_App.c`, `HighBeam_App.h`
- **Runnables**: `HighBeam_App_Init` (InitEvent), `HighBeam_App_MainRunnable` (TimingEvent, 20 ms)
- **ASIL**: QM

##### Software Requirements (SWRs)
| Requirement ID       | Source                              | Notes                                             |
|----------------------|--------------------------------------|---------------------------------------------------|
| SW-REQ-HIBEAM-001    | `HighBeam_App.c:26` (`@req`)        | Activate high beam on stalk push (latched)        |
| SW-REQ-HIBEAM-002    | `HighBeam_App.c:52` (`@req`)        | Deactivate on second stalk push or low beam off   |
| SW-REQ-HIBEAM-003    | `HighBeam_App.c:78` (`@req`)        | Flash-to-pass: 500 ms pulse on stalk pull         |
| SW-REQ-HIBEAM-004    | `HighBeam_App.c:95` (`@implements`) | Auto-suppress above vehicle speed signal valid    |
| SYS-REQ-LIGHT-021    | `requirements/bcu.csv` row 21        | DOORS link via SWR-001                            |

##### Port Interfaces
| Port Name           | Dir | Type | Interface           | DataElement / Operation | Source         |
|---------------------|-----|------|---------------------|--------------------------|----------------|
| RSwitchPosition     | R   | S/R  | LightSwitchIf       | Position                 | ARXML          |
| RStalkEvent         | R   | S/R  | StalkEventIf        | Event                    | ARXML          |
| RVehicleSpeed_kph   | R   | S/R  | VehicleSpeedIf      | Speed_kph                | ARXML          |
| PHighBeamRequest    | P   | S/R  | HighBeamRequestIf   | Active                   | ARXML          |
| PHighBeamActive     | P   | S/R  | HighBeamStateIf     | Active                   | ARXML          |

##### Dependencies
**SWC-to-SWC**:
- Consumes `Position` from `LightSwitch_SensorSWC` via `LightSwitchIf`.
- Consumes `Event` from `LightSwitch_SensorSWC` via `StalkEventIf`.
- Consumes `Speed_kph` from external `VehicleSpeed_GwSWC` via `VehicleSpeedIf` (CAN gateway).
- Provides `Active` to `LightOutput_ActuatorSWC` via `HighBeamRequestIf`.
- Provides `Active` to `LowBeam_AppSWC` via `HighBeamStateIf`.

**SWC-to-BSW**:
- None directly.

##### RTE Interfaces
| RTE API                                              | Direction | Used In                 | Notes              |
|------------------------------------------------------|-----------|--------------------------|--------------------|
| `Rte_Read_RSwitchPosition_Position`                  | Receive   | `HighBeam_App.c:64`     | Explicit S/R       |
| `Rte_Read_RStalkEvent_Event`                         | Receive   | `HighBeam_App.c:70`     | Explicit S/R       |
| `Rte_Read_RVehicleSpeed_kph_Speed_kph`               | Receive   | `HighBeam_App.c:103`    | Explicit S/R       |
| `Rte_Write_PHighBeamRequest_Active`                  | Send      | `HighBeam_App.c:118`    | Explicit S/R       |
| `Rte_Write_PHighBeamActive_Active`                   | Send      | `HighBeam_App.c:120`    | State broadcast    |

---

### Feature: Exterior Lights / Brake Lights (ASIL B)

#### Component: BrakeLight_AppSWC
- **Type**: Application
- **Source files**: `BrakeLight_App.c`, `BrakeLight_App.h`
- **Runnables**: `BrakeLight_App_Init` (InitEvent), `BrakeLight_App_MainRunnable` (TimingEvent, 10 ms)
- **ASIL**: B

##### Software Requirements (SWRs)
| Requirement ID         | Source                                 | Notes                                                       |
|------------------------|----------------------------------------|-------------------------------------------------------------|
| SW-REQ-BRAKELT-001     | `BrakeLight_App.c:30` (`@req`)        | Activate brake lights when brake pedal pressed              |
| SW-REQ-BRAKELT-002     | `BrakeLight_App.c:56` (`@req`)        | FTTI ≤ 100 ms from pedal switch active to light request out |
| SW-REQ-BRAKELT-003     | `BrakeLight_App.c:78` (`@implements`) | Plausibility check vs CAN brake pressure signal             |
| SW-REQ-BRAKELT-004     | `BrakeLight_App.c:115` (`@req`)       | Fault reaction: force-on if input plausibility fails        |
| FSR-BRAKELT-001        | `requirements/bcu.csv` row 47         | Functional Safety Requirement from SG-BRAKELT-01            |
| SG-BRAKELT-01          | `BrakeLight_App.h:9` (`@trace`)       | Safety Goal: "BCU shall activate brake lights within 100 ms of brake pedal application" |

##### Port Interfaces
| Port Name              | Dir | Type | Interface              | DataElement / Operation | Source         |
|------------------------|-----|------|------------------------|--------------------------|----------------|
| RBrakePedal_Switch     | R   | S/R  | BrakePedalSwitchIf     | Pressed                  | ARXML          |
| RBrakePressure_bar     | R   | S/R  | BrakePressureIf        | Pressure_dbar            | ARXML          |
| PBrakeLightRequest     | P   | S/R  | BrakeLightRequestIf    | Active                   | ARXML          |
| PBrakeLightFaultStatus | P   | S/R  | BrakeLightFaultIf      | FaultActive              | ARXML          |
| RDemSetEvent           | R   | C/S  | Dem_SetEventStatusIf   | SetEventStatus           | ARXML / RTE    |

##### Dependencies
**SWC-to-SWC**:
- Consumes `Pressed` from `BrakePedal_SensorSWC` via `BrakePedalSwitchIf`.
- Consumes `Pressure_dbar` from `BrakePressure_GwSWC` (CAN gateway from ESP) via `BrakePressureIf`.
- Provides `Active` to `LightOutput_ActuatorSWC` via `BrakeLightRequestIf`.
- Provides `FaultActive` to `LightDiag_ServiceSWC` via `BrakeLightFaultIf`.

**SWC-to-BSW**:
- **Dem** — `Rte_Call_RDemSetEvent_SetEventStatus` for `DEM_EVENT_BRAKELT_PLAUSIBILITY`.

##### RTE Interfaces
| RTE API                                                  | Direction | Used In                    | Notes                              |
|----------------------------------------------------------|-----------|----------------------------|------------------------------------|
| `Rte_Read_RBrakePedal_Switch_Pressed`                    | Receive   | `BrakeLight_App.c:88`      | Explicit S/R, primary input        |
| `Rte_Read_RBrakePressure_bar_Pressure_dbar`              | Receive   | `BrakeLight_App.c:92`      | Plausibility cross-check input     |
| `Rte_Write_PBrakeLightRequest_Active`                    | Send      | `BrakeLight_App.c:131`     | Explicit S/R                       |
| `Rte_Write_PBrakeLightFaultStatus_FaultActive`           | Send      | `BrakeLight_App.c:138`     | Explicit S/R                       |
| `Rte_Call_RDemSetEvent_SetEventStatus`                   | Invoke    | `BrakeLight_App.c:141`     | Synchronous, ASIL-B event          |
| `Rte_Enter_EA_BrakeLightState` / `Rte_Exit_EA_BrakeLightState` | Mutex | `BrakeLight_App.c:84, 144` | Protects debounce state from diag read |

---

### Feature: Exterior Lights / Shared Components

#### Component: LightSwitch_SensorSWC
- **Type**: Sensor/Actuator
- **Source files**: `LightSwitch_SA.c`, `LightSwitch_SA.h`
- **Runnables**: `SA_Init`, `SA_MainRunnable` (TimingEvent, 20 ms)
- **ASIL**: QM

##### Software Requirements (SWRs)
| Requirement ID         | Source                                | Notes                                         |
|------------------------|----------------------------------------|-----------------------------------------------|
| SW-REQ-LIGHTSW-001     | `LightSwitch_SA.c:18` (`@req`)        | Map Dio pattern → Position enum (OFF/AUTO/LOW)|
| SW-REQ-LIGHTSW-002     | `LightSwitch_SA.c:44` (`@req`)        | Debounce 40 ms (2 consecutive scans)          |
| SW-REQ-LIGHTSW-003     | `LightSwitch_SA.c:71` (`@implements`) | Stalk pull/push edge → StalkEvent             |

##### Port Interfaces
| Port Name        | Dir | Type | Interface       | DataElement / Operation | Source         |
|------------------|-----|------|-----------------|--------------------------|----------------|
| PSwitchPosition  | P   | S/R  | LightSwitchIf   | Position                 | ARXML          |
| PStalkEvent      | P   | S/R  | StalkEventIf    | Event                    | ARXML          |
| RDio_ReadChannel | R   | C/S  | IoHwAbDioIf     | ReadChannel              | ARXML          |

##### Dependencies
**SWC-to-SWC**: Provides `Position` to `LowBeam_AppSWC`, `HighBeam_AppSWC`; `Event` to `HighBeam_AppSWC`.
**SWC-to-BSW**: **IoHwAb** — `Rte_Call_RDio_ReadChannel_ReadChannel`.

##### RTE Interfaces
| RTE API                                       | Direction | Used In                | Notes        |
|-----------------------------------------------|-----------|-------------------------|--------------|
| `Rte_Call_RDio_ReadChannel_ReadChannel`        | Invoke    | `LightSwitch_SA.c:62`  | Synchronous  |
| `Rte_Write_PSwitchPosition_Position`           | Send      | `LightSwitch_SA.c:88`  | Explicit S/R |
| `Rte_Write_PStalkEvent_Event`                  | Send      | `LightSwitch_SA.c:94`  | Explicit S/R |

#### Component: LightOutput_ActuatorSWC
- **Type**: Sensor/Actuator
- **Source files**: `LightOutput_SA.c`, `LightOutput_SA.h`
- **Runnables**: `SA_Init`, `SA_MainRunnable` (TimingEvent, 10 ms)
- **ASIL**: B (inherits from BrakeLightRequest path; ASIL decomposition not claimed)

##### Software Requirements (SWRs)
| Requirement ID         | Source                                | Notes                                                    |
|------------------------|----------------------------------------|----------------------------------------------------------|
| SW-REQ-LIGHTOUT-001    | `LightOutput_SA.c:22` (`@req`)        | Drive Pwm/Dio outputs from Low/High/Brake request inputs |
| SW-REQ-LIGHTOUT-002    | `LightOutput_SA.c:64` (`@req`)        | Read current sense; flag bulb-out                        |
| SW-REQ-LIGHTOUT-003    | `LightOutput_SA.c:91` (`@implements`) | Latency budget ≤ 10 ms (one task period) per FSR-BRAKELT-001|

##### Port Interfaces
| Port Name                | Dir | Type | Interface              | DataElement / Operation | Source         |
|--------------------------|-----|------|------------------------|--------------------------|----------------|
| RLowBeamRequest          | R   | S/R  | LowBeamRequestIf       | Active                   | ARXML          |
| RHighBeamRequest         | R   | S/R  | HighBeamRequestIf      | Active                   | ARXML          |
| RBrakeLightRequest       | R   | S/R  | BrakeLightRequestIf    | Active                   | ARXML          |
| PBulbStatus              | P   | S/R  | BulbStatusIf            | OutBitfield              | ARXML          |
| RDio_WriteChannel        | R   | C/S  | IoHwAbDioIf            | WriteChannel             | ARXML          |
| RAdc_ReadCurrentSense    | R   | C/S  | IoHwAbAdcIf            | ReadChannel              | ARXML          |

##### Dependencies
**SWC-to-SWC**: Consumes from `LowBeam_AppSWC`, `HighBeam_AppSWC`, `BrakeLight_AppSWC`. Provides `OutBitfield` to `LightDiag_ServiceSWC`.
**SWC-to-BSW**: **IoHwAb** — Dio writes for bulb drives, ADC reads for current sense.

##### RTE Interfaces
| RTE API                                              | Direction | Used In                  | Notes                  |
|------------------------------------------------------|-----------|--------------------------|------------------------|
| `Rte_Read_RLowBeamRequest_Active`                    | Receive   | `LightOutput_SA.c:104`   | Explicit S/R           |
| `Rte_Read_RHighBeamRequest_Active`                   | Receive   | `LightOutput_SA.c:108`   | Explicit S/R           |
| `Rte_Read_RBrakeLightRequest_Active`                 | Receive   | `LightOutput_SA.c:112`   | Explicit S/R, ASIL-B   |
| `Rte_Call_RDio_WriteChannel_WriteChannel`            | Invoke    | `LightOutput_SA.c:128,134,140` | Per output bit  |
| `Rte_Call_RAdc_ReadCurrentSense_ReadChannel`         | Invoke    | `LightOutput_SA.c:160`   | Bulb-out detection     |
| `Rte_Write_PBulbStatus_OutBitfield`                  | Send      | `LightOutput_SA.c:178`   | Explicit S/R           |

#### Component: LightDiag_ServiceSWC
- **Type**: Service
- **Source files**: `LightDiag_Svc.c`, `LightDiag_Svc.h`
- **Runnables**: `Svc_Init`, `Svc_MonitorRunnable` (TimingEvent, 100 ms)
- **ASIL**: QM (bulb-out DTCs are non-safety) — except `DEM_EVENT_BRAKELT_BULB_OUT` which inherits ASIL-B

##### Software Requirements (SWRs)
| Requirement ID       | Source                              | Notes                                                |
|----------------------|--------------------------------------|------------------------------------------------------|
| SW-REQ-LIGHTDIAG-001 | `LightDiag_Svc.c:20` (`@req`)        | Report bulb-out per circuit via Dem                  |
| SW-REQ-LIGHTDIAG-002 | `LightDiag_Svc.c:48` (`@req`)        | Debounce 3-of-5 reads before raising DTC             |
| SW-REQ-LIGHTDIAG-003 | `LightDiag_Svc.c:71` (`@implements`) | Brake-light bulb DTC requires NvM persistence (ASIL-B)|

##### Port Interfaces
| Port Name              | Dir | Type | Interface              | DataElement / Operation | Source         |
|------------------------|-----|------|------------------------|--------------------------|----------------|
| RBulbStatus            | R   | S/R  | BulbStatusIf           | OutBitfield              | ARXML          |
| RBrakeLightFaultStatus | R   | S/R  | BrakeLightFaultIf      | FaultActive              | ARXML          |
| RDemSetEvent           | R   | C/S  | Dem_SetEventStatusIf   | SetEventStatus           | ARXML / RTE    |

##### Dependencies
**SWC-to-SWC**: Consumes from `LightOutput_ActuatorSWC`, `BrakeLight_AppSWC`.
**SWC-to-BSW**: **Dem** (set event status for bulb-out and plausibility DTCs).

##### RTE Interfaces
| RTE API                                          | Direction | Used In                  | Notes                    |
|--------------------------------------------------|-----------|--------------------------|--------------------------|
| `Rte_Read_RBulbStatus_OutBitfield`               | Receive   | `LightDiag_Svc.c:88`     | Explicit S/R             |
| `Rte_Read_RBrakeLightFaultStatus_FaultActive`    | Receive   | `LightDiag_Svc.c:92`     | Explicit S/R             |
| `Rte_Call_RDemSetEvent_SetEventStatus`           | Invoke    | `LightDiag_Svc.c:110,118,124` | One call per DTC ID |

---

## Cross-Cutting Maps

### BSW Module Usage
| BSW Module | Used By SWCs                                           | Key APIs Called                                                  |
|------------|--------------------------------------------------------|-------------------------------------------------------------------|
| IoHwAb     | LightSwitch_SensorSWC, LightOutput_ActuatorSWC          | `Rte_Call_RDio_ReadChannel`, `Rte_Call_RDio_WriteChannel`, `Rte_Call_RAdc_ReadCurrentSense` |
| Dem        | BrakeLight_AppSWC, LightDiag_ServiceSWC                | `Rte_Call_RDemSetEvent_SetEventStatus`                            |
| Com        | (indirect — `VehicleSpeed_GwSWC`, `BrakePressure_GwSWC` consume CAN signals; not detailed here) | (via PduR/Com routing) |

### Signal Flow

```
INPUTS
[Dio inputs]               ──────────────────────> [LightSwitch_SensorSWC]
[Brake pedal switch]       ──────────────────────> [BrakePedal_SensorSWC]
[CAN: ESP brake pressure]  ──────────────────────> [BrakePressure_GwSWC]
[CAN: vehicle speed]       ──────────────────────> [VehicleSpeed_GwSWC]

SWITCH / INPUT DISTRIBUTION
[LightSwitch_SensorSWC]    ──Position────────────> [LowBeam_AppSWC]
[LightSwitch_SensorSWC]    ──Position, StalkEvent─> [HighBeam_AppSWC]
[VehicleSpeed_GwSWC]       ──Speed_kph───────────> [HighBeam_AppSWC]
[HighBeam_AppSWC]          ──HighBeamState.Active─> [LowBeam_AppSWC]   (suppress low beam when high active)

BRAKE LIGHT CHAIN (ASIL B)
[BrakePedal_SensorSWC]     ──Pressed─────────────> [BrakeLight_AppSWC]
[BrakePressure_GwSWC]      ──Pressure_dbar───────> [BrakeLight_AppSWC]   (plausibility cross-check)

REQUEST AGGREGATION
[LowBeam_AppSWC]           ──LowBeamRequest──┐
[HighBeam_AppSWC]          ──HighBeamRequest──┼──> [LightOutput_ActuatorSWC]
[BrakeLight_AppSWC]        ──BrakeLightRequest┘

ACTUATION
[LightOutput_ActuatorSWC]  ──Dio_WriteChannel───> [Bulb outputs]
[LightOutput_ActuatorSWC]  ──Adc_ReadChannel────> (current sense, internal)

DIAGNOSTICS
[LightOutput_ActuatorSWC]  ──BulbStatus.OutBitfield─> [LightDiag_ServiceSWC]
[BrakeLight_AppSWC]        ──FaultActive──────────> [LightDiag_ServiceSWC]
[LightDiag_ServiceSWC]     ──Dem_SetEventStatus──> [Dem]
[BrakeLight_AppSWC]        ──Dem_SetEventStatus──> [Dem]   (ASIL-B event, direct)
```

### ASIL Zone Map
| Zone                    | ASIL | SWCs                                            | Memory Section |
|-------------------------|------|--------------------------------------------------|----------------|
| Brake lights (safety)   | B    | BrakeLight_AppSWC, LightOutput_ActuatorSWC (mixed) | `.text.asilB`  |
| Low / high beam         | QM   | LowBeam_AppSWC, HighBeam_AppSWC, LightSwitch_SensorSWC | `.text.qm` |
| Diagnostic              | B/QM | LightDiag_ServiceSWC (brake DTC = B, others = QM) | `.text.asilB` (brake-related), `.text.qm` (others) |

## Architectural Concerns
1. **[CRITICAL]** `BrakeLight_App.c:131` writes `Rte_Write_PBrakeLightRequest_Active` while `LightOutput_ActuatorSWC` runs at the same 10 ms period in a different OS task. End-to-end FTTI is at risk of exceeding 100 ms (SW-REQ-BRAKELT-002) if both tasks land on the same priority without task-chaining; verify in OS configuration.
2. **[MAJOR]** `LightOutput_ActuatorSWC` is mixed-ASIL (brake = B, low/high = QM) but lives in a single OS-Application. Either (a) split into two SWCs by ASIL, or (b) confirm Freedom-from-Interference via memory-protection and Dependent Failure Analysis (ISO 26262-9 §5).
3. **[MAJOR]** `s_BrakeLight_DebounceCount` accessed from `BrakeLight_App_MainRunnable` and the diagnostic read path (`LightDiag_Svc.c:92`) — `EA_BrakeLightState` is declared but only entered on the writer side; the reader needs the same `Rte_Enter_EA_BrakeLightState` wrap.
4. **[INFO]** `HighBeam_AppSWC` requirement SW-REQ-HIBEAM-004 ("auto-suppress above vehicle speed signal valid") has no test case referenced in `requirements/bcu.csv` — flag to the traceability skill.
5. **[INFO]** `LightDiag_ServiceSWC` Dem event IDs are referenced by macro name but their numeric assignment lives in `Dem_Cfg.h` (generated). After regeneration the macro list should be cross-checked.
~~~
