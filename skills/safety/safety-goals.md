---
name: Safety Goals Definition
short: Derive ISO 26262 Safety Goals, safe states, FTTI, and Functional Safety Requirements
description: Translates HARA hazardous events into well-formed Safety Goals with safe state definition, Fault Tolerant Time Interval (FTTI), and Functional Safety Requirements (FSR) allocated to system elements. Covers ASIL decomposition applicability.
category: safety
tags: [iso26262, safety-goals, ftti, functional-safety, fsr, decomposition]
---

# Skill: Safety Goals Definition

## Context
You are a functional safety engineer translating HARA hazardous events and ASIL levels into well-formed ISO 26262 Safety Goals and Functional Safety Concepts. You understand how Safety Goals cascade into Functional Safety Requirements (FSR), Technical Safety Requirements (TSR), and ultimately software-level requirements, and how safe states and FTTI (Fault Tolerant Time Interval) constrain system design.

## Instructions
1. For each provided hazardous event and its ASIL, formulate a Safety Goal that:
   - Is expressed as a constraint on the system's behavior (not an implementation solution).
   - Uses the form: `<Item> shall not <hazardous behavior> [under <operational condition>] [within <FTTI>].`
   - Captures the safe state the system shall reach when the hazard is triggered.
   - References the ASIL to be maintained through design.
2. Define the safe state for each Safety Goal:
   - The safe state must be reachable from the hazardous event via a deterministic, bounded transition.
   - Specify FTTI: the time window from hazard occurrence to safe state activation within which no unreasonable risk occurs.
   - Specify FTTS (Fault Tolerant Time State): how long the safe state must be maintained.
3. Derive high-level Functional Safety Requirements (FSR) from each Safety Goal:
   - FSRs are system-level design constraints that satisfy the Safety Goal.
   - Each FSR must be verifiable and allocated to a system element (ECU, sensor, actuator, network).
4. Note ASIL decomposition applicability (where redundancy or independence can lower individual element ASIL).

## Input expected
- Hazardous events with ID, description, and ASIL (from HARA output)
- Optionally: system architecture sketch, existing safe state candidates, timing constraints

## Output format
```
## Safety Goals and Functional Safety Concept

### Safety Goal: SG-<NNN>
- **Statement**: [Item] shall not [hazardous behavior] [under condition].
- **ASIL**: [A | B | C | D]
- **Linked Hazardous Event(s)**: [HE-xxx, HE-yyy]
- **Safe State**: [description of the safe system state]
- **FTTI**: [time from hazard onset to safe state activation, e.g., ≤ 100 ms]
- **FTTS**: [minimum time safe state must be maintained, e.g., until ignition cycle reset]

### Functional Safety Requirements (derived from SG-<NNN>)
| FSR ID     | Statement                                              | ASIL | Allocated To         |
|------------|--------------------------------------------------------|------|---------------------|
| FSR-001    | The <element> shall detect <fault> within <time>.      | D    | Torque Monitor SWC  |
...
```

## Example

**Input:**
HE-001: EPS applies unintended high torque (> 3 Nm) at highway speed. ASIL-D.
HE-003: EPS applies unintended high torque at low speed. ASIL-C.

**Output:**
```
## Safety Goals and Functional Safety Concept

### Safety Goal: SG-001
- **Statement**: The Electric Power Steering system shall not apply an unintended assist torque exceeding 3 Nm at the steering column under any vehicle operating condition.
- **ASIL**: D
- **Linked Hazardous Events**: HE-001, HE-003
- **Safe State**: EPS motor disabled (zero torque output); mechanical steering path remains intact to allow driver-only steering.
- **FTTI**: ≤ 50 ms from detection of torque command anomaly to motor disable (derived from 150 ms system-level budget minus 100 ms driver reaction time at 100 km/h).
- **FTTS**: Maintained until ECU power cycle or successful system reset with fault cleared.

### Functional Safety Requirements (SG-001)
| FSR ID   | Statement                                                                                     | ASIL | Allocated To                 |
|----------|-----------------------------------------------------------------------------------------------|------|------------------------------|
| FSR-001  | The EPS ECU shall monitor commanded motor torque against a ≤ 3 Nm limit and disable the motor within 20 ms if exceeded. | D | Torque Monitor SWC (ASIL-D) |
| FSR-002  | The EPS ECU shall detect sensor plausibility failures (torque sensor out-of-range) within 10 ms and transition to safe state. | D | Sensor Diagnostic SWC (ASIL-D) |
| FSR-003  | The EPS ECU shall provide a hardware-enforced current limit that prevents motor torque from exceeding the equivalent of 4 Nm, independent of software. | D | MCAL + hardware cutoff (ASIL-B(D), decomposed) |
| FSR-004  | The EPS ECU shall signal the safe state to the vehicle network (CAN: EPS_SafeState = TRUE) within 50 ms of fault detection. | B | Com SWC / Network layer |

### ASIL Decomposition Note
FSR-001 (ASIL-D) can be decomposed if two independent implementations exist:
- Software torque monitor (ASIL-B(D)) — SWC with separate data path.
- Hardware current limiter (ASIL-B(D)) — MCAL-level, no shared code with SW monitor.
Independence evidence required: separate compilation units, different input sources, no shared fault modes.
```
