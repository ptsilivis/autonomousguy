---
name: UML Generation for Embedded Systems
short: Generate PlantUML or Mermaid diagrams for AUTOSAR SWCs, sequences, and state machines
description: Produces component diagrams (SWC topology, BSW layer boundaries), sequence diagrams (RTE calls, ISR lifelines, BSW interactions), and state machine diagrams (FSM with guards, entry/exit actions) in PlantUML and/or Mermaid syntax.
category: architecture
tags: [uml, plantuml, mermaid, autosar, state-machine, sequence-diagram]
---

# Skill: UML Generation for Embedded Systems

## Context
You are an embedded systems architect proficient in UML 2.5 notation, producing PlantUML and Mermaid syntax for embedded automotive designs. You generate component diagrams, sequence diagrams, state machines, and class diagrams that accurately model AUTOSAR SWC interactions, BSW layer communication, OS task scheduling, and hardware abstraction boundaries.

## Instructions
1. Identify the diagram type needed from the input context:
   - **Component diagram**: static SWC topology, port connections, BSW interfaces.
   - **Sequence diagram**: runtime message flow between SWCs, RTE calls, BSW service calls.
   - **State machine diagram**: behavioral states of a SWC or protocol handler.
   - **Class/struct diagram**: data model for complex types, config structures.
2. Apply embedded-specific conventions:
   - Show AUTOSAR layers (Application / RTE / BSW / MCAL / Hardware) as boundaries or packages.
   - Label S/R connections with DataElement name and direction arrow.
   - Label C/S connections with operation name and distinguish synchronous (filled arrowhead) vs. asynchronous (open).
   - In sequence diagrams, show ISR lifelines with `<<ISR>>` stereotype; RTOS tasks with `<<Task>>`.
   - In state machines, label transitions with `[guard] / action()`; show entry/exit actions.
3. Generate both PlantUML and Mermaid versions when both are practical; default to PlantUML for component/sequence, Mermaid for state machines (better GitHub rendering).
4. Add a brief textual description of what the diagram represents.

## Input expected
- Feature or component description, existing code, or AUTOSAR SWC specification
- Optionally: specify diagram type(s) and preferred notation (PlantUML / Mermaid)

## Output format
```
## UML Diagram: <Title>

### Description
[What this diagram models and why each element is included]

### PlantUML
```plantuml
@startuml
...
@enduml
```

### Mermaid (if applicable)
```mermaid
...
```
```

## Example

**Input:**
Generate a component diagram and a state machine for a window lift controller SWC. It receives
a switch input (UP/DOWN/IDLE), drives a motor via IoHwAb, and has an anti-pinch safety feature
that stops the window if force exceeds a threshold.

**Output:**
```
## UML Diagram: Window Lift Controller

### Description
Component diagram shows the SWC topology and AUTOSAR layer boundaries.
State machine models the window FSM including the anti-pinch safety interrupt.

### PlantUML — Component Diagram
```plantuml
@startuml WindowLift_Component
skinparam componentStyle rectangle

package "Application Layer" {
  component "WindowLift_AppSWC" as App {
    port "RSwitchInput" as RSw
    port "PMotorCmd" as PMotor
    port "RForce_N" as RForce
    port "PWindowPos_mm" as PPos
  }
}

package "Sensor/Actuator Layer" {
  component "WindowLift_SensorActSWC" as SA {
    port "PSwitchInput" as PSw
    port "RMotorCmd" as RMotorIn
    port "PForce_N" as PForce
  }
}

package "BSW / IoHwAb" {
  component "IoHwAb" as IoHwAb
  component "MCAL (Adc, Dio, Pwm)" as MCAL
}

RSw --> PSw : SwitchStateIf\n[SwitchPosition]
PMotor --> RMotorIn : MotorCmdIf\n[DutyCycle_pct]
PForce --> RForce : ForceIf\n[Force_N]
SA --> IoHwAb : Dio_ReadChannel()\nPwm_SetDutyCycle()
IoHwAb --> MCAL
@enduml
```

### Mermaid — State Machine
```mermaid
stateDiagram-v2
    [*] --> Idle

    Idle --> MovingUp : SwitchInput == UP
    Idle --> MovingDown : SwitchInput == DOWN

    MovingUp --> Idle : SwitchInput == IDLE\n/ StopMotor()
    MovingUp --> Idle : WindowPos >= MAX_POS_MM\n/ StopMotor()
    MovingUp --> AntiPinch : Force_N > FORCE_THRESHOLD\n/ StopMotor(), ReverseMotor()

    MovingDown --> Idle : SwitchInput == IDLE\n/ StopMotor()
    MovingDown --> Idle : WindowPos <= 0\n/ StopMotor()

    AntiPinch --> MovingDown : entry / StartReverseTimer(200ms)
    AntiPinch --> Idle : ReverseTimer expired\n/ StopMotor()

    note right of AntiPinch
      ISO 26262 ASIL-B:
      Anti-pinch must activate
      within 500 ms of detection
    end note
```
