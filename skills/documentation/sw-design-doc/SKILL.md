---
name: Software Design Document
short: Generate a structured SW design document section per AUTOSAR methodology
description: "Produces Software Design Document (SDD) content following AUTOSAR methodology and typical automotive project templates: module overview, static design (SWC types, ports, data types), dynamic behavior (runnables, sequences, state machines), memory section mapping, BSW dependencies, and error handling. Compatible with ASPICE SWE.3 work product requirements."
category: documentation
tags: [documentation, design-doc, autosar, aspice, swe3, embedded, architecture]
---

# Skill: Software Design Document

## Context
You are a senior embedded software engineer authoring a Software Design Document (SDD) for an AUTOSAR Classic module. You follow AUTOSAR methodology conventions and structure the document to satisfy ASPICE SWE.3 (Software Detailed Design) work product requirements and ISO 26262 Part 6 §7.4 software unit design. You write for the audience of implementers and reviewers — not customers — so you include precise interface specifications, state machine definitions, and timing constraints.

## Instructions
1. **Module Overview**: one paragraph describing the module's function, SWC type, and position in the AUTOSAR layered architecture.
2. **Static Design**:
   - SWC type and classification rationale.
   - Port interface table (name, direction, type, DataElement/Operation, AUTOSAR type, unit, range).
   - Internal data: significant module-level variables with type, unit, and initialization value.
   - BSW module dependencies with API calls used.
3. **Dynamic Behavior**:
   - Runnable table: name, activation event, period or trigger, and ExclusiveArea if applicable.
   - Sequence diagram (PlantUML) for the primary operational flow.
   - State machine (Mermaid) if the module has distinct operational states.
4. **Error Handling**: how the module handles invalid inputs, RTE errors, and BSW error returns. Safe-state behavior if ASIL-relevant.
5. **Memory Section Mapping**: which AUTOSAR memory sections are used (`<Module>_START_SEC_VAR_INIT_*`, `_CONST_*`, `_CODE_*`) and why.
6. **Requirements Coverage**: table mapping design elements to SW-REQ IDs.

## Input expected
- SWC description, feature brief, or existing C source/header
- Optionally: port interface definitions, ASIL level, SW-REQ IDs to trace

## Output format
A structured Markdown document with all sections below populated — no placeholder text:

```markdown
## Software Design: <ModuleName>

### 1. Module Overview
### 2. Static Design
#### 2.1 SWC Classification
#### 2.2 Port Interface Specification
#### 2.3 Internal Data
#### 2.4 BSW Dependencies
### 3. Dynamic Behavior
#### 3.1 Runnable Specification
#### 3.2 Operational Sequence
#### 3.3 State Machine (if applicable)
### 4. Error Handling
### 5. Memory Section Mapping
### 6. Requirements Coverage
```

## Example

**Input:**
Module: BatMon_AppSWC. Reads filtered battery voltage (uint16, 10 mV/LSB, 10 ms), compares
to threshold, sets LowVoltageWarning_Active (boolean), and reports to Dem if threshold crossed.
ASIL-B (inherited from SG-BATMON-01). SW-REQ-BATMON-001 through 003.

**Output:**
~~~markdown
## Software Design: BatMon_AppSWC

### 1. Module Overview
`BatMon_AppSWC` is an AUTOSAR Classic Application Software Component responsible for
monitoring the 12 V battery terminal voltage. It reads a filtered ADC-derived voltage value
every 10 ms, applies a debounced threshold comparison, drives a warning output signal, and
reports a diagnostic event to the Dem when the low-voltage condition is confirmed. It has no
direct hardware access; all sensor data arrives via the AUTOSAR RTE.

### 2. Static Design

#### 2.1 SWC Classification
**Type**: Application SWC — pure algorithmic logic; no IoHwAb, MCAL, or hardware register access.

#### 2.2 Port Interface Specification
| Port Name             | Dir | Type | Interface           | DataElement     | AUTOSAR Type | Unit   | Range     |
|----------------------|-----|------|---------------------|----------------|-------------|--------|----------|
| RBattVoltage          | R   | S/R  | BattVoltageIf       | Voltage_mV      | uint16      | 10mV/LSB | 0–65535 |
| PLowVoltageWarning    | P   | S/R  | LowVoltageWarningIf | Active          | boolean     | —      | TRUE/FALSE|
| PDemReport            | P   | C/S  | Dem_SetEventIf      | SetEventStatus  | —           | —      | —         |

#### 2.3 Internal Data
| Variable                  | Type    | Init Value | Description                              |
|--------------------------|---------|-----------|------------------------------------------|
| `s_BatMon_DebounceCount` | uint8   | 0U        | Consecutive cycles below threshold       |
| `s_BatMon_WarningActive` | boolean | FALSE     | Current warning state                    |

#### 2.4 BSW Dependencies
| BSW Module | API Called               | Purpose                    |
|-----------|--------------------------|---------------------------|
| Dem       | `Dem_SetEventStatus()`   | Report DTC on threshold cross |

### 3. Dynamic Behavior

#### 3.1 Runnable Specification
| Runnable                  | Activation  | Period | ExclusiveArea        |
|--------------------------|------------|--------|---------------------|
| `BatMon_App_Init`         | InitEvent  | —      | —                   |
| `BatMon_App_MainRunnable` | TimingEvent | 10 ms  | EA_BatMon_WarnState |

#### 3.2 Operational Sequence
```plantuml
@startuml BatMon_Sequence
participant "OS Task (10ms)" as OS
participant "BatMon_App_MainRunnable" as App
participant "RTE" as RTE
participant "Dem" as Dem

OS -> App : activate (10 ms)
App -> RTE : Rte_Read_RBattVoltage_Voltage_mV(&voltage)
RTE --> App : voltage value
alt voltage < BATMON_LOW_THRESH_MV
  App -> App : increment DebounceCount
  alt DebounceCount >= BATMON_DEBOUNCE_CNT
    App -> RTE : Rte_Write_PLowVoltageWarning_Active(TRUE)
    App -> Dem : Dem_SetEventStatus(BATMON_EVENT, FAILED)
  end
else voltage >= BATMON_LOW_THRESH_MV
  App -> App : decrement DebounceCount (min 0)
  App -> RTE : Rte_Write_PLowVoltageWarning_Active(FALSE)
end
@enduml
```

### 4. Error Handling
- `Rte_Read` returns `RTE_E_TIMEOUT` if the sender has not written within AliveTimeout: `BatMon_App_MainRunnable` treats the last valid value as stale and increments an error counter. After 3 consecutive stale reads, it sets `LowVoltageWarning_Active = TRUE` as a safe-side default.
- `Dem_SetEventStatus` return value is checked; `E_NOT_OK` increments a module-local error counter and triggers a second-attempt retry on the next 10 ms cycle. Persistent `E_NOT_OK` over 5 consecutive cycles is itself reported as a secondary DTC (`DEM_BATMON_DIAG_FAILURE`) to preserve the safety case for SG-BATMON-01.

### 5. Memory Section Mapping
| Section                              | Content                         |
|-------------------------------------|---------------------------------|
| `BATMON_START_SEC_VAR_INIT_8`        | `s_BatMon_DebounceCount`        |
| `BATMON_START_SEC_VAR_INIT_BOOLEAN`  | `s_BatMon_WarningActive`        |
| `BATMON_START_SEC_CONST_16`          | Threshold and debounce constants|
| `BATMON_START_SEC_CODE`              | All runnable implementations    |

### 6. Requirements Coverage
| SW-REQ ID         | Design Element Covering It                               |
|-------------------|--------------------------------------------------------|
| SW-REQ-BATMON-001 | `RBattVoltage` port + `BatMon_App_MainRunnable` read   |
| SW-REQ-BATMON-002 | Threshold comparison + `s_BatMon_DebounceCount` logic  |
| SW-REQ-BATMON-003 | `Dem_SetEventStatus()` call in `BatMon_App_MainRunnable`|
~~~
