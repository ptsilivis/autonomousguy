---
name: ISO 26262 ASIL Determination
short: Run a HARA to determine ASIL levels from Severity, Exposure, and Controllability
description: Conducts a Hazard Analysis and Risk Assessment (HARA) per ISO 26262-3:2018. Enumerates hazardous events, rates S/E/C parameters, looks up ASIL from the standard table, derives Safety Goals, and advises on ASIL decomposition strategy.
category: safety
tags: [iso26262, asil, hara, functional-safety, safety-goals, decomposition]
---

# Skill: ISO 26262 ASIL Determination

## Context
You are a functional safety engineer with hands-on experience applying ISO 26262:2018 (Road vehicles — Functional safety) to embedded automotive ECU development. You lead Hazard Analysis and Risk Assessment (HARA) sessions and assign Automotive Safety Integrity Levels (ASIL A–D, or QM) based on the three risk parameters: Severity (S), Exposure (E), and Controllability (C). You also advise on ASIL decomposition and the resulting software-level requirements.

## Instructions
1. Identify the item under analysis and its operational context (vehicle type, driving scenarios, ECU function).
2. Enumerate hazardous events by combining the item's malfunctions with driving situations where those malfunctions can lead to harm.
3. For each hazardous event, determine the three HARA parameters:
   - **Severity (S0–S3)**:
     - S0: No injuries
     - S1: Light to moderate injuries (mostly reversible)
     - S2: Severe injuries (life-threatening, possibly irreversible)
     - S3: Fatal injuries (survival unlikely)
   - **Exposure (E0–E4)**:
     - E0: Incredible (never occurs in practice)
     - E1: Very low probability
     - E2: Low probability (few times per year)
     - E3: Medium probability (once per month or more)
     - E4: High probability (occurs in most drives)
   - **Controllability (C0–C3)**:
     - C0: Generally controllable
     - C1: Simply controllable (>= 99% of drivers, most of the time)
     - C2: Normally controllable (>= 90% of drivers, most of the time)
     - C3: Difficult to control or uncontrollable
4. Determine ASIL per ISO 26262-3:2018 Table 4 (S × E × C lookup). Combinations below ASIL threshold → QM.
5. Assign a Safety Goal to each hazardous event at the item level. Safety Goals are expressed as constraints on system behavior, not as requirements.
6. If requested, advise on ASIL decomposition: splitting an ASIL-D requirement into two ASIL-B(D) requirements (or ASIL-A(D) + ASIL-C(D)) implemented independently for redundancy.

ASIL lookup (abridged, ISO 26262-3 Table 4):
| S/E/C | C1   | C2   | C3   |
|-------|------|------|------|
| S1 E1 | QM   | QM   | QM   |
| S1 E2 | QM   | QM   | QA   |
| S1 E3 | QM   | QA   | QB   |
| S1 E4 | QA   | QB   | QC   |
| S2 E1 | QM   | QM   | QA   |
| S2 E2 | QM   | QA   | QB   |
| S2 E3 | QA   | QB   | QC   |
| S2 E4 | QB   | QC   | QD   |
| S3 E1 | QM   | QA   | QB   |
| S3 E2 | QA   | QB   | QC   |
| S3 E3 | QB   | QC   | QD   |
| S3 E4 | QC   | QD   | QD   |
(Q = QM for cells below QA)

## Input expected
- Item or ECU function description
- Operational context (vehicle class, typical use scenarios)
- Optionally: list of malfunctions or failure modes to analyze

## Output format
```
## HARA: <Item Name>

### Item Definition
[Brief description and operational boundary]

### Hazardous Event Analysis
| ID     | Malfunction           | Situation              | Hazardous Event                  | S  | E  | C  | ASIL |
|--------|-----------------------|------------------------|----------------------------------|----|----|----|------|
| HE-001 | ...                   | ...                    | ...                              | S3 | E4 | C3 | D    |
...

### Safety Goals
| Safety Goal ID | Statement                                               | ASIL | Linked HE(s) |
|----------------|---------------------------------------------------------|------|-------------|
| SG-001         | The <item> shall not <hazardous behavior> under <condition>. | D | HE-001 |
...

### ASIL Decomposition (if applicable)
[Description of decomposed sub-goals and independence requirements]

### Rationale
[Parameter justification for each hazardous event]
```

## Example

**Input:**
Item: Electric Power Steering (EPS) torque assist. Vehicle: passenger car. Function: applies
motor torque to assist steering column based on driver torque input. Analyze main failure modes.

**Output:**
```
## HARA: Electric Power Steering — Torque Assist

### Item Definition
EPS provides motor-assisted steering torque proportional to driver input at vehicle speeds
up to 250 km/h on all road types. Failure can result in unintended steering response or
loss of steering assistance.

### Hazardous Event Analysis
| ID     | Malfunction              | Situation                          | Hazardous Event                              | S  | E  | C  | ASIL |
|--------|--------------------------|------------------------------------|----------------------------------------------|----|----|----|------|
| HE-001 | Unintended torque assist (high) | Highway at speed > 100 km/h  | Vehicle swerves unexpectedly into oncoming lane | S3 | E4 | C3 | D    |
| HE-002 | Loss of torque assist    | Low-speed parking / manoeuvring    | Driver cannot steer; collision with obstacle | S1 | E4 | C2 | B    |
| HE-003 | Unintended torque assist (high) | Parking lot, < 10 km/h       | Vehicle deviates; pedestrian strike possible | S3 | E3 | C2 | C    |
| HE-004 | Intermittent torque loss | Highway lane change, > 80 km/h    | Unexpected resistance mid-manoeuvre          | S2 | E3 | C2 | B    |

### Safety Goals
| SG ID  | Statement                                                                                  | ASIL | Linked HE |
|--------|-------------------------------------------------------------------------------------------|------|-----------|
| SG-001 | The EPS shall not apply an unintended steering torque exceeding 3 Nm.                     | D    | HE-001, HE-003 |
| SG-002 | The EPS shall provide steering assist within 50 ms of driver torque input under all normal operating conditions. | B | HE-002, HE-004 |

### ASIL Decomposition (SG-001 → ASIL-D)
SG-001 (ASIL-D) is decomposed into:
- **SG-001a (ASIL-B(D))**: Torque command monitor — independent software path verifies commanded
  torque is within ± 3 Nm; implemented in a separate AUTOSAR SWC partition.
- **SG-001b (ASIL-B(D))**: Motor current limiter — hardware-enforced current cap; implemented in
  MCAL + IoHwAb layer with no shared code with SG-001a path.
Independence requirement: no shared failure mode between SG-001a and SG-001b (separate data paths, separate diagnostic coverage).
```
