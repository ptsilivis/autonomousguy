# ISO 26262-3:2018 ASIL Determination Reference

Paraphrased reference of the parameters and the ASIL look-up table from ISO 26262-3:2018 (Concept Phase — HARA). **This document does not reproduce normative ISO 26262 text**: it paraphrases parameter classifications and reproduces Table 4 (which contains only the lettered ASIL grades A–D and QM, not normative wording). A licensed copy of ISO 26262-3:2018 (© ISO) remains authoritative for the canonical definitions, examples, and exception clauses.

## Risk parameters

### Severity (S0–S3)

| Class | Paraphrased meaning |
|-------|---------------------|
| **S0** | No injuries |
| **S1** | Light to moderate injuries (mostly reversible) — examples include AIS 1–2 |
| **S2** | Severe injuries (life-threatening, possibly irreversible) — examples include AIS 3–5 |
| **S3** | Fatal injuries (survival unlikely or impossible) — examples include AIS 6+ |

Severity is assessed against the occupants of the subject vehicle and any other road users that could be harmed by the hazardous event, considering typical accident outcomes for that event class.

### Exposure (E0–E4)

| Class | Paraphrased meaning |
|-------|---------------------|
| **E0** | Incredible — situation never occurs in practice |
| **E1** | Very low probability — situation occurs only in rare driving conditions |
| **E2** | Low probability — situation arises a few times per year |
| **E3** | Medium probability — situation arises once per month or more |
| **E4** | High probability — situation arises in most drives |

Exposure measures the probability of being in the operational situation in which the malfunction could lead to harm — not the probability of the fault itself.

### Controllability (C0–C3)

| Class | Paraphrased meaning |
|-------|---------------------|
| **C0** | Controllable in general — the driver/operator can always avoid harm |
| **C1** | Simply controllable — ≥ 99 % of drivers can avoid harm, most of the time |
| **C2** | Normally controllable — ≥ 90 % of drivers can avoid harm, most of the time |
| **C3** | Difficult to control or uncontrollable — < 90 % of drivers can avoid harm |

**Important:** C0 (generally controllable) implies QM regardless of S/E values and does not appear as a column in Table 4. Do not look up S/E/C0 combinations — the result is QM by definition.

## ASIL look-up — ISO 26262-3:2018 Table 4

| S / E  | C1 | C2 | C3 |
|--------|----|----|----|
| S1 E1  | QM | QM | QM |
| S1 E2  | QM | QM | QM |
| S1 E3  | QM | QM | A  |
| S1 E4  | QM | A  | B  |
| S2 E1  | QM | QM | QM |
| S2 E2  | QM | QM | A  |
| S2 E3  | QM | A  | B  |
| S2 E4  | A  | B  | C  |
| S3 E1  | QM | QM | A  |
| S3 E2  | QM | A  | B  |
| S3 E3  | A  | B  | C  |
| S3 E4  | B  | C  | D  |

Reading the table: pick the row from the (S, E) pair; pick the column from the C value. The cell value is the ASIL. Below-threshold combinations are QM (Quality Managed — managed by the QM system, not by ISO 26262 process requirements).

## ASIL decomposition rules — Part 9 §5

Decomposition allows splitting a parent ASIL requirement into two independent child requirements, each with a lower ASIL, provided the two implementations are demonstrably independent.

| Parent ASIL | Allowed decomposition pairs                                  |
|-------------|--------------------------------------------------------------|
| **D**       | C(D) + A(D), B(D) + B(D), D(D) + QM(D)                        |
| **C**       | B(C) + A(C), C(C) + QM(C)                                    |
| **B**       | A(B) + A(B), B(B) + QM(B)                                    |
| **A**       | A(A) + QM(A)                                                 |

Notation: `B(D)` means "implemented to ASIL-B but inherits the ASIL-D safety case context." Independence of the two child elements must be demonstrated via a **Dependent Failure Analysis (DFA)** per ISO 26262-9 §5. Separate compilation units alone are not sufficient evidence — the DFA must address common-cause failures (shared power, shared clock, shared sensor input) and cascading failures.

## FTTI / FDTI / FRTI / EOTI timing model

- **FTTI** — Fault Tolerant Time Interval: maximum time from fault occurrence to the onset of a hazardous event in the absence of a safety mechanism.
- **FDTI** — Fault Detection Time Interval: time from fault occurrence to fault detection.
- **FRTI** — Fault Reaction Time Interval: time from fault detection to safe-state activation.
- **EOTI** — Emergency Operation Time Interval: minimum duration the safe state must be maintained after activation (e.g., until power cycle or driver acknowledgement).

The safety case must demonstrate: **FDTI + FRTI ≤ FTTI** for every Safety Goal where a runtime detection-and-reaction mechanism is the mitigation.

## Common pitfalls

- **Mis-rating Exposure**: rating the probability of the fault occurring rather than the probability of being in the operational situation where the fault would harm.
- **Mis-rating Controllability**: assuming an "average driver" without evidence — Controllability needs justification from driving studies, fleet data, or established conventions for similar vehicles.
- **Skipping QM events**: even QM-rated events should be documented in the HARA — the rating itself is an output and supports future change impact analysis.
- **Forgetting C0**: do not look up an S/E/C0 cell in Table 4. The result is QM by definition.
- **Decomposition without DFA**: ASIL decomposition is invalid without a Dependent Failure Analysis. Compiler partition / separate translation unit alone do not establish independence.
