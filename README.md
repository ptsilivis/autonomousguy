# autonomousguy

[![npm version](https://img.shields.io/npm/v/autonomousguy.svg)](https://www.npmjs.com/package/autonomousguy)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js ≥18](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS%20%7C%20windows-lightgrey)](#installation)

**An AI skill library for embedded automotive engineers.**

29 domain-accurate prompt files covering the full ECU software lifecycle: AUTOSAR integration, MISRA compliance, ISO 26262 safety analysis, requirements, testing, documentation, toolchain setup, debugging, and change management.

Install once. Use with any AI tool. No lock-in.

---

## Installation

### npx (recommended)

```bash
npx autonomousguy init
```

### Shell script — Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/ptsilivis/autonomousguy/master/install.sh | bash
```

### PowerShell — Windows

```powershell
irm https://raw.githubusercontent.com/ptsilivis/autonomousguy/master/install.ps1 | iex
```

The installer asks three questions: **scope** (local project or global), **tool(s)** (see supported tools below), and **skills** (all 29 or select by category). Skills land at `<base>/<tool-dir>/skills/autonomousguy/<category>/<skill>.md`.

---

## Skill catalogue

Start with `workspace/codebase-analysis` on any new project — it writes `.autonomousguy/CODEBASE_MAP.md`, which every other skill references.

### `workspace` — Onboarding
| Skill | What it does |
|---|---|
| `codebase-analysis` | Scans the repo; maps SWCs, BSW usage, signal flows, and ASIL zones into `CODEBASE_MAP.md`. |

### `autosar` — AUTOSAR Classic
| Skill | What it does |
|---|---|
| `autosar-integration` | Aligns SWC ports with ARXML, verifies RTE API consistency, resolves integration-time errors. |
| `swc-development` | Develops a new SWC from a port interface spec: runnable structure, RTE API calls, ISR-safe patterns. |
| `bsw-configuration` | Configures BSW modules (Com, Dem, NvM, Dcm, MemIf, Fee) from functional requirements. |
| `arxml-debugging` | Diagnoses ARXML schema violations, missing references, and toolchain import errors. |
| `rte-generation-troubleshooting` | Resolves RTE generator failures — unresolved ports, conflicting timing, mode-manager conflicts. |

### `code-quality` — MISRA & Code Review
| Skill | What it does |
|---|---|
| `misra-review` | MISRA C:2012 audit: violations by rule ID, severity, and location, with compliant rewrites. |
| `misra-driven-development` | Generates new code that is compliant-by-construction across memory, arithmetic, and control flow. |
| `code-review` | Embedded C review: correctness, ISR safety, stack usage, shared-resource access, AUTOSAR guidelines. |
| `naming-conventions` | Audits identifiers against AUTOSAR and project-specific conventions; produces a rename map. |

### `architecture` — Design
| Skill | What it does |
|---|---|
| `component-design` | Designs an AUTOSAR SWC topology: components, port types, data flows, ASIL boundaries. |
| `uml-generation` | Produces PlantUML or Mermaid diagrams (sequence, class, activity, state machine). |
| `interface-definition` | Specifies port interfaces with data element types, init values, and an ARXML sketch. |

### `requirements` — Requirements Engineering
| Skill | What it does |
|---|---|
| `elicitation` | Transforms an informal brief into EARS-notation requirements with acceptance criteria. |
| `refinement` | Audits requirements for ambiguity, incompleteness, and contradictions; rewrites defective items. |
| `traceability` | Builds a bidirectional requirements-to-implementation traceability matrix. |

### `safety` — ISO 26262
| Skill | What it does |
|---|---|
| `iso26262-asil` | Conducts a HARA: rates Severity / Exposure / Controllability, derives ASIL and Safety Goals. |
| `safety-goals` | Develops Safety Goals with FTTI, Functional Safety Requirements, Safe States, and ASIL decomposition. |

### `testing` — Test Design
| Skill | What it does |
|---|---|
| `unit-test-generation` | Generates MC/DC-adequate test cases with a coverage matrix and CppUTest / Unity code. |
| `boundary-analysis` | Applies BVA to embedded fixed-width types including overflow and off-by-one detection. |

### `documentation` — Technical Writing
| Skill | What it does |
|---|---|
| `doxygen` | Generates Doxygen comment blocks for functions, structs, and modules. |
| `sw-design-doc` | Produces an ASPICE SWE.3-compliant Software Design Document. |
| `changelog` | Writes a structured release changelog and flags safety-relevant changes requiring re-verification. |

### `toolchain` — Build & Interfaces
| Skill | What it does |
|---|---|
| `cmake-conan` | Generates CMake toolchain files and Conan profiles for ARM Cortex-M/R cross-compilation. |
| `can-dbc-analysis` | Maps DBC signals to AUTOSAR COM PDUs; flags scaling, endianness, and cycle-time issues. |

### `debugging` — Fault Investigation
| Skill | What it does |
|---|---|
| `problem-report-analysis` | Produces a root-cause investigation plan from a field problem report. |
| `targeted-debugging` | Guides debugging of watchdog resets, HardFaults, stack overflows, and race conditions. |

### `change-management` — Change Control
| Skill | What it does |
|---|---|
| `change-request-analysis` | Analyses scope, ASIL impact, and affected components; produces an implementation plan. |
| `impact-analysis` | Traces the full ripple effect across source, ARXML, requirements, tests, and safety artefacts. |

---

## How to use a skill

**Paste into any AI tool:** copy the full skill file (including frontmatter) into your tool's system prompt, custom instructions field, or chat window.

**Auto-discovery (Claude Code, Cursor, Gemini CLI):** after installation, skills live in `.<tool>/skills/autonomousguy/<category>/`. Invoke by name or via `/skill-name` syntax.

**Recommended workflow:**
1. Run `codebase-analysis` first on any new project.
2. Pick the skill that matches your task.
3. Chain skills naturally — e.g. `elicitation` → `component-design` → `swc-development` → `iso26262-asil` → `unit-test-generation`.

---

## Supported AI tools

| Tool | Skills installed at |
|---|---|
| Claude Code | `.claude/skills/autonomousguy/` |
| GitHub Copilot | `.github/skills/autonomousguy/` |
| Cursor | `.cursor/skills/autonomousguy/` |
| Gemini CLI | `.gemini/skills/autonomousguy/` |
| ChatGPT Codex | `.agents/skills/autonomousguy/` |
| OpenCode | `.opencode/skills/autonomousguy/` |
| JetBrains AI | `.idea/skills/autonomousguy/` |
| General / other | `.autonomousguy/skills/` |

---

## Skill format

Every skill file has YAML frontmatter (drives the installer picker) and five content sections (drive the AI):

```markdown
---
name: Human-readable skill name
short: One-line description shown in the CLI picker
description: Two-sentence summary.
category: <category-slug>
tags: [tag1, tag2]
---

## Context
## Instructions
## Input expected
## Output format
## Example
```

---

## Contributing

Open an issue before adding new categories (minimum two skills per category). For new skills within an existing category, a PR is sufficient.

**New skill checklist:**
- Add a `.md` file to `skills/<category>/` — no registration needed, the CLI discovers it automatically.
- Include all five frontmatter fields and all five content sections.
- The `## Example` must use realistic ECU inputs/outputs — no placeholders.

```bash
git clone https://github.com/ptsilivis/autonomousguy.git
cd autonomousguy && npm install
node bin/cli.js   # run the installer locally
```

---

## License

MIT © [AutonomousGuy](https://github.com/ptsilivis/autonomousguy)
