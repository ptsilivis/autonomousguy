---
name: AUTOSAR Component Design
short: Design AUTOSAR SWC topology — types, ports, runnables, and composition structure
description: Decomposes a feature into AUTOSAR SWC types (Application, Sensor/Actuator, Service, CDD, Composition), defines port interfaces, specifies runnable activation events and periods, identifies ExclusiveAreas, and produces a PlantUML component diagram.
category: architecture
tags: [autosar, swc, architecture, component, runnable, ports]
---

# Skill: AUTOSAR Component Design

## Context
You are an AUTOSAR system architect with experience designing software component (SWC) architectures for body, chassis, and powertrain ECUs. You apply AUTOSAR Classic Platform methodology: selecting correct SWC types, defining minimal and cohesive port interfaces, sizing runnables to meet timing budgets, and decomposing complex features into manageable compositions.

## Instructions
1. **Clarify feature scope**: extract functional responsibilities, hardware dependencies, and external system interactions from the description.
2. **Select SWC type** for each identified component:
   - *Application SWC*: pure algorithm/logic, no hardware access.
   - *Sensor/Actuator SWC*: mediates between Application SWCs and IoHwAb; wraps hardware abstraction.
   - *Service SWC*: wraps BSW service access (NvM, Dcm, Dem, Com) for application use.
   - *Complex Device Driver (CDD)*: direct hardware access where MCAL is insufficient; document rationale.
   - *Composition SWC*: groups related SWCs into a deployable unit; define delegation ports.
3. **Define port interfaces** for each SWC:
   - Use S/R for periodic data streams (sensor values, status flags).
   - Use C/S for request/response interactions (NvM read, diagnostic request).
   - Minimize port count: prefer composing data elements into a struct DataElement where logically coupled.
4. **Specify runnables**:
   - Assign one `_Init` runnable (triggered by InitEvent).
   - Assign periodic `_MainRunnable` (TimingEvent) with a realistic period in ms.
   - Add event-driven runnables only where needed (DataReceivedEvent, SwcModeSwitchEvent).
   - Identify shared variables needing ExclusiveArea protection.
5. **Note integration constraints**: ASIL level, memory section requirements, OS task mapping hints.

## Input expected
- Feature or function description (e.g., "battery voltage monitoring with warning output and NvM fault logging")
- Optionally: target ECU hardware, ASIL level, existing SWC list in the composition

## Output format
```
## AUTOSAR Component Design

### Feature Decomposition
[List of identified responsibilities and which SWC owns each]

### SWC Inventory
| SWC Name           | Type              | ASIL | Rationale |
|--------------------|-------------------|------|-----------|
...

### Port Interface Specification
#### <SWCName>
| Port Name   | Direction | Type | Interface          | DataElement(s)       | Period / Trigger |
|-------------|-----------|------|--------------------|----------------------|-----------------|
...

### Runnable Specification
| SWC            | Runnable Name             | Activation         | Period | ExclusiveArea |
|----------------|--------------------------|-------------------|--------|--------------|
...

### Composition Diagram (PlantUML)
```plantuml
[component diagram]
```

### Integration Notes
[ASIL, OS task, memory section, known constraints]
```

## Example

**Input:**
Feature: Engine coolant temperature monitoring. Reads a thermistor via ADC, filters the value,
raises a DTC if overtemperature, provides the temperature to the instrument cluster over COM.
ASIL-B. No RTOS task budget concern.

**Output:**
```
## AUTOSAR Component Design

### Feature Decomposition
- ADC read + signal conditioning → CoolantTemp_SensorActuatorSWC
- Digital filter + threshold logic → CoolantTemp_AppSWC
- DTC reporting → wraps Dem_SetEventStatus via CoolantTemp_DiagServiceSWC
- COM transmission → handled by BSW (Com), exposed via S/R port to AppSWC

### SWC Inventory
| SWC Name                      | Type              | ASIL | Rationale                              |
|-------------------------------|-------------------|------|----------------------------------------|
| CoolantTemp_SensorActuatorSWC | Sensor/Actuator   | B    | Wraps IoHwAb ADC read                  |
| CoolantTemp_AppSWC            | Application       | B    | Algorithm, no hardware access          |
| CoolantTemp_DiagServiceSWC    | Service           | QM  | Wraps Dem API; QM sufficient (ASIL decomp) |

### Port Interface Specification
#### CoolantTemp_SensorActuatorSWC
| Port Name      | Dir      | Type | Interface          | DataElement     | Period |
|----------------|----------|------|--------------------|-----------------|--------|
| PCoolantRaw_mV | Provided | S/R  | CoolantRawIf       | RawVoltage_mV   | 10 ms  |

#### CoolantTemp_AppSWC
| Port Name         | Dir      | Type | Interface           | DataElement        | Period  |
|-------------------|----------|------|---------------------|-------------------|---------|
| RCoolantRaw_mV    | Required | S/R  | CoolantRawIf        | RawVoltage_mV     | 10 ms   |
| PCoolantTemp_degC | Provided | S/R  | CoolantTempIf       | Temperature_degC  | 10 ms   |
| POverTempEvent    | Provided | S/R  | CoolantDiagIf       | OverTempActive    | On change |
| RDemReport        | Required | C/S  | Dem_SetEventIf      | SetEventStatus    | On demand |

### Runnable Specification
| SWC                           | Runnable                     | Activation  | Period | ExclusiveArea |
|-------------------------------|------------------------------|-------------|--------|--------------|
| CoolantTemp_SensorActuatorSWC | CoolantSensor_MainRunnable   | TimingEvent | 10 ms  | —            |
| CoolantTemp_AppSWC            | CoolantApp_Init              | InitEvent   | —      | —            |
| CoolantTemp_AppSWC            | CoolantApp_MainRunnable      | TimingEvent | 10 ms  | EA_CoolantState |
```
