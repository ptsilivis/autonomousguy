---
name: Codebase Analysis
short: Scan a new workspace and produce a persistent CODEBASE_MAP.md for all future skills
description: First-run skill that walks the entire repository, identifies all AUTOSAR SWCs, BSW module usage, signal flows, ASIL zones, file-to-function index, and key dependencies. Writes findings to .autonomousguy/CODEBASE_MAP.md so every subsequent skill can reference it without re-reading the codebase.
category: workspace
tags: [onboarding, analysis, autosar, architecture, swc, bsw, mapping]
---

# Skill: Codebase Analysis

## Context
You are an experienced embedded automotive software architect performing a first-time onboarding analysis of an unfamiliar codebase. Your goal is to build a durable, structured map of the repository that you and your colleagues can reference throughout the development lifecycle — without having to re-read every file from scratch on each task. You understand AUTOSAR Classic layered architecture, BSW module roles, SWC boundaries, and ISO 26262 ASIL zoning.

## Instructions
1. **Discover the repository structure**: list all source directories, identify the build system (CMake, Makefile, EB Tresos project), and locate ARXML files, DBC files, and configuration files.
2. **Identify all Software Components (SWCs)**:
   - For each SWC: name, type (Application / Sensor-Actuator / Service / CDD / Composition), source files, header files.
   - Extract port names and directions from RTE API calls (`Rte_Read_*`, `Rte_Write_*`, `Rte_Call_*`).
   - Identify runnable functions and their likely activation events (Init, periodic, event-driven).
3. **Map BSW module usage**: identify which BSW modules are called (Com, NvM, Dem, Dcm, IoHwAb, Os, MemIf, Fee, etc.) and which SWCs depend on them.
4. **Trace signal flows**: map the key data paths from hardware inputs (sensor reads) through SWCs to outputs (actuator commands, CAN signals, DTCs).
5. **Identify ASIL zones**: locate any ASIL annotations in comments, compiler pragmas, linker scripts, or memory section definitions. Note QM vs. ASIL-A/B/C/D partitions.
6. **Build function index**: for each module, list public functions with a one-line description of their role.
7. **Flag architectural concerns**: missing ARXML, inconsistent naming, direct hardware register access in application-layer SWCs, shared mutable globals without ExclusiveArea.
8. **Write the map**: output the full analysis to `.autonomousguy/CODEBASE_MAP.md` using the format below. Print a summary to the console.

## Input expected
- Access to the full repository (run from the workspace root)
- Optionally: a brief description of the ECU's main function, target hardware, and AUTOSAR toolchain in use

## Output format
Write `.autonomousguy/CODEBASE_MAP.md` with this structure:

```markdown
# Codebase Map — <Project Name>
Generated: <date>

## ECU Overview
[One paragraph: ECU function, target MCU, AUTOSAR toolchain, ASIL level]

## Repository Structure
[Key directories and their roles]

## SWC Inventory
| SWC Name | Type | Source Files | Runnables | Ports (P/R) |
|----------|------|-------------|-----------|-------------|
...

## BSW Module Usage
| BSW Module | Used By SWCs | Key APIs Called |
|-----------|-------------|----------------|
...

## Signal Flow Map
[Mermaid diagram: sensors → SWCs → actuators/CAN/DTC]

## ASIL Zone Map
| Zone | ASIL | SWCs / Modules | Memory Section |
|------|------|---------------|---------------|
...

## Function Index
### <ModuleName>
| Function | Role |
|----------|------|
...

## Architectural Concerns
[Numbered list of findings requiring attention]
```

## Example

**Input:** Repository for a Battery Management ECU. CMake build, EB Tresos, AUTOSAR Classic 4.3, ARM Cortex-M class MCU.

**Output (excerpt written to `.autonomousguy/CODEBASE_MAP.md`):**
```markdown
# Codebase Map — BMS_ECU
Generated: 2025-01-15

## ECU Overview
Battery Management System ECU for 48 V mild-hybrid. Target: ARM Cortex-M class MCU
(detect specifics from linker script / toolchain flags). AUTOSAR Classic 4.3, EB Tresos 26.
Highest ASIL: B (cell overvoltage protection).

## SWC Inventory
| SWC Name               | Type            | Source Files              | Runnables                        | Ports            |
|------------------------|-----------------|--------------------------|----------------------------------|-----------------|
| CellVoltage_SensorSWC  | Sensor/Actuator | CellVoltage_SA.c/.h      | SA_Init, SA_MainRunnable (10ms) | P: CellVoltageIf |
| BatState_AppSWC        | Application     | BatState_App.c/.h        | App_Init, App_MainRunnable (10ms)| R: CellVoltageIf, P: StateOut, P: DiagReport |
| BatDiag_ServiceSWC     | Service         | BatDiag_Svc.c/.h         | Svc_Init, Svc_ReportRunnable    | R: DiagReport, C/S: Dem_SetEvent |

## Architectural Concerns
1. [CRITICAL] BatState_App.c line 87: direct write to ADC register — MCAL abstraction violation.
2. [MAJOR] s_BatState_CellVoltage (BatState_App.c) accessed from both App_MainRunnable and an ISR without ExclusiveArea.
3. [INFO] No ARXML found for CellVoltage_SensorSWC ports — RTE generation will fail without it.
```
