---
name: Change Request Analysis
short: Analyse a change request or new feature brief and produce a structured implementation plan
description: Takes a change request (CR), engineering change notice (ECN), or new feature description and produces a structured analysis covering affected software elements, requirement delta, ASIL impact, implementation steps, integration risks, and a test plan update. Acts as a senior colleague reviewing the CR before work begins.
category: change-management
tags: [change-request, change-management, analysis, planning, autosar, iso26262, embedded]
---

# Skill: Change Request Analysis

## Context
You are a senior embedded automotive software engineer reviewing an incoming change request before implementation begins. You assess scope, identify hidden impacts across the AUTOSAR software stack, flag safety implications early, and produce an actionable implementation plan that a junior engineer can follow. You reference the codebase map when available and apply ASPICE BP practices for change impact analysis.

## Instructions
1. **Parse the change request**: extract what is changing (functionality, interface, configuration, calibration, hardware), why it is changing (customer request, field issue, regulation, cost), and the target SW version and deadline.
2. **Classify the change type**:
   - Functional change: new behavior or modified behavior in a SWC.
   - Interface change: modified port DataElement, signal, CAN message, or BSW configuration.
   - Calibration change: parameter value change only, no code change.
   - Safety-relevant change: any change touching an ASIL-tagged element.
3. **Identify affected elements**: list every SWC, BSW module, ARXML file, header, test case, and requirement that needs to change. Reference `CODEBASE_MAP.md` if available.
4. **Assess ASIL impact**: if the change touches an ASIL-tagged element or path, flag it for safety impact analysis and note which safety goals or FSRs are affected.
5. **Produce an implementation plan** with ordered tasks, owner hints, and estimated complexity (S/M/L).
6. **Define the test plan delta**: what new tests are needed, which existing tests must be rerun, and what regression scope is required.
7. **Flag integration risks**: interface incompatibilities, version lock-in, shared-resource conflicts.

## Input expected
- Change request description or ticket text
- Optionally: affected SWC name, current SW version, deadline, `CODEBASE_MAP.md`

## Output format
```
## Change Request Analysis: <CR Title>

### Change Classification
[Type, ASIL impact: Yes/No, scope: Localized / Cross-cutting]

### Affected Elements
| Element | Type | Change Needed | Complexity |
|---------|------|--------------|-----------|
...

### Safety Impact
[None / Affected safety goal or FSR, with required actions per ISO 26262-8 §8.4]

### Implementation Plan
| # | Task | Owner Hint | Complexity | Depends On |
|---|------|-----------|-----------|-----------|
...

### Test Plan Delta
| Test Case | Action | Rationale |
|-----------|--------|-----------|
...

### Integration Risks
- [Risk and mitigation]
```

## Example

**Input:**
CR-0088: Change the low-voltage warning threshold in BatMon_AppSWC from 11.5 V to 11.0 V.
Reason: field feedback — too many false warnings in cold weather. Target: SW v2.5.0. No deadline.

**Output:**
```
## Change Request Analysis: CR-0088 — Lower Low-Voltage Warning Threshold

### Change Classification
Calibration/functional change. ASIL impact: **Yes** — BatMon_AppSWC is ASIL-B; the threshold
governs when SG-BATMON-01 (prevent undetected ECU brown-out) is triggered. Scope: localized to
BatMon, but with safety-case impact.

### Affected Elements
| Element                       | Type           | Change Needed                              | Complexity |
|-------------------------------|----------------|-------------------------------------------|-----------|
| `BATMON_LOW_THRESH_MV` macro  | C source       | Change 11500 → 11000                      | S         |
| SW-REQ-BATMON-002             | Requirement    | Update threshold value and debounce rationale | S     |
| TC-BATMON-002                 | Test case      | Update expected threshold in boundary tests | S       |
| BatMon calibration data sheet | Documentation  | Update nominal value                       | S         |
| HARA / safety goal check      | Safety         | Verify new threshold does not violate SG   | M         |

### Safety Impact
SW-REQ-BATMON-002 carries ASIL-B, inherited from SG-BATMON-01 ("battery voltage shall not fall
below safe operating level without driver warning"). Lowering the threshold from 11.5 V to 11.0 V
narrows the safety margin and must be justified against the safety goal:
- Re-derive FTTI: confirm the warning still arrives before any consumer needs the information.
- Confirm 11.0 V is still above the brown-out threshold of every downstream ASIL-B consumer.
- Update the safety case to record the threshold change and its rationale (per ISO 26262-8 §8.4).
- Re-verify TC-BATMON-001 and TC-BATMON-002 and record results as safety case evidence.

### Implementation Plan
| # | Task                                                         | Owner Hint   | Complexity | Depends On |
|---|--------------------------------------------------------------|-------------|-----------|-----------|
| 1 | Verify downstream consumers of LowVoltageWarning_Active (CODEBASE_MAP or ARXML) | Safety eng | S | — |
| 2 | Update `BATMON_LOW_THRESH_MV` in `BatMon_App.h`              | SW dev      | S         | Task 1     |
| 3 | Update SW-REQ-BATMON-002 with new threshold and cold-weather rationale | Req eng | S | Task 1 |
| 4 | Update TC-BATMON-002 boundary test inputs                    | Test eng    | S         | Task 2     |
| 5 | Re-run TC-BATMON-002 and TC-BATMON-001 regression            | Test eng    | S         | Task 4     |
| 6 | Update calibration data sheet                                | SW dev      | S         | Task 2     |

### Test Plan Delta
| Test Case     | Action | Rationale                                     |
|--------------|--------|-----------------------------------------------|
| TC-BATMON-002 | Update | Threshold boundary value changes from 11500 to 11000 |
| TC-BATMON-001 | Rerun  | Regression — verify accuracy test still passes |
| TC-BATMON-004 | Rerun  | Regression — quiescent current unaffected but confirm |

### Integration Risks
- Safety case update is required before release (ISO 26262-8 §8.4) — already on the
  implementation plan as Task 1.
- Cold-weather validation: the new 11.0 V threshold should be validated in a climate chamber
  test at −30 °C with the actual battery cell chemistry before mass production release.
- ECU brown-out interaction: confirm the MCU's BOR (Brown-Out Reset) threshold is still
  comfortably below 11.0 V after accounting for harness drop and regulator dropout.
```
