---
name: Change Impact Analysis
short: Assess the ripple effects of a code, interface, or configuration change across the software stack
description: Performs a structured impact analysis for a proposed or completed change — tracing affected SWCs, BSW modules, ARXML interfaces, requirements, test cases, and safety artifacts. Distinguishes direct impacts (elements that must change) from indirect impacts (elements that must be retested or reviewed). Produces a regression scope recommendation.
category: change-management
tags: [impact-analysis, change-management, regression, autosar, iso26262, embedded, aspice]
---

# Skill: Change Impact Analysis

## Context
You are an embedded automotive software architect performing an impact analysis for a proposed change. You systematically trace the change through all affected layers — from the changed element outward through its interfaces, consumers, dependents, test cases, and safety artifacts — to produce a complete and defensible impact scope. You apply ASPICE SWE.6 and ISO 26262 Part 6 §7.4 change impact assessment practices.

## Instructions
1. **Identify the change origin**: the specific element that is changing (function, SWC port, BSW config parameter, data type, constant, ARXML element).
2. **Trace direct impacts** (elements that must change):
   - If a port DataElement type changes: all connected sender/receiver ports, ComSpecs, and generated RTE code.
   - If a function signature changes: all callers, all header files, all test stubs.
   - If a BSW config changes (e.g., Dem event ID): SWC code calling the old ID, test cases, and DTC documentation.
   - If an ASIL-tagged element changes: the corresponding safety requirement, its test case, and the safety case.
3. **Trace indirect impacts** (elements that must be reviewed or retested, not necessarily changed):
   - SWCs that consume the output of a changed SWC.
   - Integration tests covering the changed signal path.
   - Calibration data referencing the changed parameter.
   - Any timing budget affected by a changed runnable period.
4. **Assign a regression scope**: Minimal (only directly changed items), Targeted (direct + signal path), Full (entire module or feature).
5. **Flag open-loop impacts**: changes where the effect cannot be determined without runtime data (e.g., calibration threshold change on a real vehicle).

## Input expected
- Description of the change (what element is changing and how)
- Optionally: affected SWC name, `CODEBASE_MAP.md`, existing requirement and test case IDs

## Output format
```
## Change Impact Analysis: <Change Description>

### Change Origin
[Element, layer, and nature of change]

### Direct Impacts (must change)
| Element | Type | Required Change |
|---------|------|----------------|
...

### Indirect Impacts (must review / retest)
| Element | Type | Review / Retest Action |
|---------|------|----------------------|
...

### Safety Impact
[None / ASIL-tagged elements affected — required actions]

### Regression Scope Recommendation
[Minimal / Targeted / Full — with rationale]

### Open-Loop Impacts
[Items that cannot be assessed without runtime data]
```

## Example

**Input:**
Change: rename the AUTOSAR DataElement `Voltage_mV` to `BattVoltage_mV` in the
`BattVoltageIf` SenderReceiver interface. Affects BatMon_AppSWC (provider) and
DisplayCtrl_AppSWC (consumer).

**Output:**
```
## Change Impact Analysis: Rename DataElement Voltage_mV → BattVoltage_mV

### Change Origin
ARXML SenderReceiver interface `BattVoltageIf`, DataElement short-name.
Layer: Application SWC interface / RTE contract.

### Direct Impacts (must change)
| Element                                          | Type         | Required Change                                      |
|--------------------------------------------------|--------------|-----------------------------------------------------|
| `BattVoltageIf` ARXML (interface definition)     | ARXML        | Rename `<SHORT-NAME>Voltage_mV</SHORT-NAME>` → `BattVoltage_mV` |
| `BatMon_AppSWC` ARXML (provided port ComSpec)    | ARXML        | Update `<DATA-ELEMENT-REF>` to `BattVoltage_mV`     |
| `DisplayCtrl_AppSWC` ARXML (required port ComSpec)| ARXML       | Update `<DATA-ELEMENT-REF>` to `BattVoltage_mV`     |
| Generated `Rte_BatMon_AppSWC.h`                  | Generated    | Regenerate — `Rte_Write_PBattVoltage_BattVoltage_mV()` |
| Generated `Rte_DisplayCtrl_AppSWC.h`             | Generated    | Regenerate — `Rte_Read_RBattVoltage_BattVoltage_mV()` |
| `BatMon_App.c` RTE API call                      | C source     | Update `Rte_Write_PBattVoltage_Voltage_mV` → `_BattVoltage_mV` |
| `DisplayCtrl_App.c` RTE API call                 | C source     | Update `Rte_Read_RBattVoltage_Voltage_mV` → `_BattVoltage_mV` |
| SW-REQ-BATMON-001                                | Requirement  | Update DataElement name in interface reference       |
| TC-BATMON-001, TC-DISPLAY-003                    | Test cases   | Update stub API name in test harness                 |

### Indirect Impacts (must review / retest)
| Element                         | Type          | Action                                                  |
|---------------------------------|---------------|---------------------------------------------------------|
| `VehicleComposition` ARXML      | ARXML         | Verify connector references remain valid after rename   |
| Integration test suite (BatMon) | Test          | Full retest of battery monitoring signal path           |
| Calibration tool signal mapping | Tool config   | Update signal name in CANape/INCA measurement config    |

### Safety Impact
None — `BattVoltageIf` is QM. If this interface were ASIL-tagged, a safety impact assessment
per ISO 26262-8 §8.4 would be required, and the change would need re-verification evidence.

### Regression Scope Recommendation
**Targeted** — run the BatMon signal path integration tests (BatMon → DisplayCtrl chain)
plus a build verification of both SWCs. No need for full ECU regression since the change
is a rename with no functional or behavioral effect.

### Open-Loop Impacts
None — this is a pure rename with no functional effect. No runtime validation beyond
build and integration test is required.
```
