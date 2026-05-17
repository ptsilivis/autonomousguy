# autonomousguy

[![npm version](https://img.shields.io/npm/v/autonomousguy.svg)](https://www.npmjs.com/package/autonomousguy)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js ≥18](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS%20%7C%20windows-lightgrey)](#installation)

**An AI skill library for embedded automotive engineers.**

autonomousguy ships 29 domain-accurate prompt files — called _skills_ — covering the full ECU software lifecycle: codebase onboarding, AUTOSAR integration, MISRA compliance, ISO 26262 safety analysis, requirements, testing, documentation, toolchain setup, debugging, and change management.

Install once. Use with any AI tool. No lock-in.

---

## Table of contents

- [Who it's for](#whos-it-for)
- [How it works](#how-it-works)
- [Installation](#installation)
  - [npx (Node.js)](#option-1-npx-requires-nodejs-18)
  - [Shell script (Linux / macOS)](#option-2-shell-script-linux--macos)
  - [PowerShell (Windows)](#option-3-powershell-windows)
- [Repository structure](#repository-structure)
- [Skill catalogue](#skill-catalogue)
- [Skill format](#skill-format)
- [How to use a skill](#how-to-use-a-skill)
- [Recommended workflow](#recommended-workflow)
- [Supported AI tools](#supported-ai-tools)
- [Contributing](#contributing)
- [License](#license)

---

## Who it's for

Embedded software engineers working on automotive ECUs — from juniors starting with AI-assisted development to seniors who want consistent, high-quality domain context across a team, without writing long system prompts from scratch.

autonomousguy is equally useful on Claude Code, GitHub Copilot, Cursor, Gemini CLI, or a proprietary enterprise AI tool. If your company restricts which AI products engineers can use, the plain-Markdown format means you can paste any skill directly into a chat window without installing anything.

---

## How it works

Each skill is a self-contained Markdown file with a YAML frontmatter header and five structured sections. When you give a skill to an AI tool — whether by pasting it into a chat, setting it as a system prompt, or letting the tool auto-discover it from a directory — the AI adopts the role, follows the instructions, and produces output in the exact format described.

Skills are designed to chain. The `workspace/codebase-analysis` skill produces a `CODEBASE_MAP.md` file that every other skill can reference, so the AI always has accurate context about your SWCs, BSW dependencies, signal flows, and ASIL zones without re-reading the codebase on every task.

---

## Installation

Three installation paths are provided. All three ask the same interactive questions — local vs. global scope, which AI tool(s) to install for, and which skill categories to include — and produce identical results.

### Option 1 — npx (requires Node.js ≥18)

```bash
npx autonomousguy init
```

This is the fastest path if you have Node.js available. `npx` downloads the package and runs the interactive installer in one step.

### Option 2 — Shell script (Linux / macOS)

**From a local clone:**

```bash
git clone https://github.com/ptsilivis/autonomousguy.git
cd autonomousguy
bash install.sh
```

**Without cloning first** (downloads the repo archive automatically):

```bash
curl -fsSL https://raw.githubusercontent.com/ptsilivis/autonomousguy/master/install.sh | bash
```

Requires only `bash`, `curl`, `tar`, `find`, and `cp` — all standard on any Linux or macOS system.

### Option 3 — PowerShell (Windows)

**From a local clone:**

```powershell
git clone https://github.com/ptsilivis/autonomousguy.git
cd autonomousguy
.\install.ps1
```

**Without cloning first** (downloads the zip archive automatically):

```powershell
irm https://raw.githubusercontent.com/ptsilivis/autonomousguy/master/install.ps1 | iex
```

Requires PowerShell 5.1 or later (included in Windows 10/11).

### What the installer does

Whichever path you choose, the installer walks you through three questions:

1. **Scope** — install into the current project directory (local) or your home directory (global, applies to all projects)
2. **Tool(s)** — pick one or more supported AI tools; skills are copied into that tool's discovery directory
3. **Skills** — install all 29 skills, or select specific categories (and optionally individual skills within each category)

Skills land at `<base>/<tool-dir>/skills/autonomousguy/<category>/<skill>.md`.

---

## Repository structure

```
autonomousguy/
├── bin/
│   └── cli.js                        # Interactive Node.js installer (npx entry point)
├── skills/
│   ├── workspace/
│   │   └── codebase-analysis.md      # First-run scan → CODEBASE_MAP.md
│   ├── autosar/
│   │   ├── autosar-integration.md
│   │   ├── swc-development.md
│   │   ├── bsw-configuration.md
│   │   ├── arxml-debugging.md
│   │   └── rte-generation-troubleshooting.md
│   ├── code-quality/
│   │   ├── misra-review.md
│   │   ├── misra-driven-development.md
│   │   ├── code-review.md
│   │   └── naming-conventions.md
│   ├── architecture/
│   │   ├── component-design.md
│   │   ├── uml-generation.md
│   │   └── interface-definition.md
│   ├── requirements/
│   │   ├── elicitation.md
│   │   ├── refinement.md
│   │   └── traceability.md
│   ├── safety/
│   │   ├── iso26262-asil.md
│   │   └── safety-goals.md
│   ├── testing/
│   │   ├── unit-test-generation.md
│   │   └── boundary-analysis.md
│   ├── documentation/
│   │   ├── doxygen.md
│   │   ├── sw-design-doc.md
│   │   └── changelog.md
│   ├── toolchain/
│   │   ├── cmake-conan.md
│   │   └── can-dbc-analysis.md
│   ├── debugging/
│   │   ├── problem-report-analysis.md
│   │   └── targeted-debugging.md
│   └── change-management/
│       ├── change-request-analysis.md
│       └── impact-analysis.md
├── install.sh                        # Bash installer (Linux/macOS, no Node.js required)
├── install.ps1                       # PowerShell installer (Windows, no Node.js required)
├── package.json
└── README.md
```

**`bin/cli.js`** — The Node.js CLI. Interactive, uses `@inquirer/prompts` for multi-select checkboxes. Reads skill frontmatter at runtime to populate the picker.

**`skills/`** — The skill library. Plain Markdown files. No build step. Adding a file to the right subdirectory is all it takes to register a new skill with the CLI.

**`install.sh` / `install.ps1`** — Shell equivalents of the Node.js CLI for environments where Node.js is not available (common in corporate automotive settings). Both scripts auto-download the skills archive from GitHub if run outside a local clone.

---

## Skill catalogue

29 skills across 11 categories. Start with `workspace/codebase-analysis` on any new project.

### `workspace` — Onboarding

| Skill | What it does |
|---|---|
| `codebase-analysis` | Scans the repository, identifies all SWCs, BSW module usage, signal flows, ASIL zones, and the function index. Writes the findings to `.autonomousguy/CODEBASE_MAP.md` — referenced by every other skill. |

### `autosar` — AUTOSAR Classic

| Skill | What it does |
|---|---|
| `autosar-integration` | End-to-end integration guidance: aligning SWC ports with ARXML, verifying RTE API consistency, and resolving integration-time errors. |
| `swc-development` | Develops a new Application or Sensor-Actuator SWC from a port interface specification: runnable structure, RTE API calls, ISR-safe patterns. |
| `bsw-configuration` | Configures BSW modules (Com, Dem, NvM, Dcm, MemIf, Fee) from functional requirements, with ARXML-sketch output and common pitfall warnings. |
| `arxml-debugging` | Diagnoses ARXML schema violations, missing references, and toolchain import errors with step-by-step remediation. |
| `rte-generation-troubleshooting` | Identifies and resolves RTE generator failures — unresolved ports, conflicting timing, mode-manager conflicts — with corrected ARXML fragments. |

### `code-quality` — MISRA & Code Review

| Skill | What it does |
|---|---|
| `misra-review` | Full MISRA C:2012 compliance audit: lists violations by rule ID, severity, and location, with compliant rewrites and deviation justifications. |
| `misra-driven-development` | Generates new code that is compliant-by-construction: rule-constrained patterns for memory, arithmetic, control flow, and pointers. |
| `code-review` | Embedded C review covering correctness, ISR safety, stack usage, shared-resource access, and AUTOSAR coding guidelines. |
| `naming-conventions` | Audits and corrects identifier naming against AUTOSAR and project-specific conventions; produces a rename map. |

### `architecture` — Design

| Skill | What it does |
|---|---|
| `component-design` | Designs an AUTOSAR SWC topology for a feature: identifies components, port types, inter-component data flows, and ASIL boundaries. |
| `uml-generation` | Produces PlantUML or Mermaid diagrams (sequence, class, activity, state machine) for a given SWC interaction or algorithm. |
| `interface-definition` | Specifies port interfaces — sender/receiver, client/server — with data element types, init values, and an ARXML sketch for import into the configurator. |

### `requirements` — Requirements Engineering

| Skill | What it does |
|---|---|
| `elicitation` | Transforms an informal feature brief into well-formed EARS-notation requirements with acceptance criteria and testability checks. |
| `refinement` | Audits an existing requirements set for ambiguity, incompleteness, and internal contradictions; rewrites defective items. |
| `traceability` | Builds a bidirectional requirements-to-implementation traceability matrix and identifies coverage gaps. |

### `safety` — ISO 26262

| Skill | What it does |
|---|---|
| `iso26262-asil` | Conducts a HARA: enumerates hazardous events, rates Severity / Exposure / Controllability, looks up ASIL from the ISO 26262-3 table, and derives top-level Safety Goals. |
| `safety-goals` | Develops Safety Goals with FTTI, Functional Safety Requirements, Safe States, and an ASIL decomposition strategy for software and hardware elements. |

### `testing` — Test Design

| Skill | What it does |
|---|---|
| `unit-test-generation` | Generates MC/DC-adequate test cases with a coverage matrix, stub list, and CppUTest / Unity test code. |
| `boundary-analysis` | Applies boundary value analysis to embedded fixed-width types (uint8, int16, …), including overflow, wraparound, and off-by-one detection. |

### `documentation` — Technical Writing

| Skill | What it does |
|---|---|
| `doxygen` | Generates Doxygen-compatible comment blocks for functions, structs, and modules, following automotive doc standards. |
| `sw-design-doc` | Produces an ASPICE SWE.3-compliant Software Design Document: architecture, component descriptions, interface specs, and design decisions. |
| `changelog` | Writes a structured release changelog from a commit range, and flags changed safety-relevant items that require re-verification. |

### `toolchain` — Build & Interfaces

| Skill | What it does |
|---|---|
| `cmake-conan` | Generates CMake toolchain files and Conan profiles for ARM Cortex-M/R cross-compilation, covering compiler flags, sysroot, and linker script wiring. |
| `can-dbc-analysis` | Extracts signals from a DBC file, maps them to AUTOSAR COM PDUs and signals, and flags scaling, endianness, or cycle-time issues. |

### `debugging` — Fault Investigation

| Skill | What it does |
|---|---|
| `problem-report-analysis` | Produces a structured root-cause investigation plan from a field problem report: fault hypothesis tree, data collection steps, and reproduction strategy. |
| `targeted-debugging` | Guides targeted debugging sessions for watchdog resets, HardFaults, stack overflows, race conditions, and AUTOSAR OS errors. |

### `change-management` — Change Control

| Skill | What it does |
|---|---|
| `change-request-analysis` | Analyses a change request: clarifies scope, assesses ASIL impact, identifies affected components, and produces an implementation plan. |
| `impact-analysis` | Traces the full ripple effect of a change across source code, ARXML, requirements, test cases, and safety artefacts. |

---

## Skill format

Every skill file follows the same structure. Both parts are required: the frontmatter drives the installer picker; the content sections drive the AI.

```markdown
---
name: Human-readable skill name
short: One-line description shown in the CLI picker
description: Two-sentence summary of what the skill does and what it produces.
category: <category-slug>
tags: [tag1, tag2, tag3]
---

## Context
Who the AI should act as and what domain knowledge it should assume.

## Instructions
Numbered, step-by-step behaviour the AI must follow.

## Input expected
What the user must provide before invoking the skill.

## Output format
Exact structure of the AI's response — headings, tables, code blocks.

## Example
A realistic embedded automotive input/output pair. No placeholders.
```

**Frontmatter fields:**

| Field | Required | Description |
|---|---|---|
| `name` | yes | Full name shown in the CLI skill picker |
| `short` | yes | One-line label shown next to the skill name in the picker |
| `description` | yes | Two-sentence description used for documentation |
| `category` | yes | Must match the subdirectory name under `skills/` |
| `tags` | yes | Array of lowercase strings for discoverability |

**Content sections:**

| Section | Purpose |
|---|---|
| `## Context` | Sets the AI's persona and assumed knowledge |
| `## Instructions` | Step-by-step numbered list the AI must follow |
| `## Input expected` | What the user must provide to get a useful response |
| `## Output format` | Exact shape of the response (headings, tables, code blocks) |
| `## Example` | Realistic embedded automotive input and output — no lorem ipsum |

---

## How to use a skill

**Paste into any AI tool:**

Open the skill file, copy its full contents (including frontmatter), and paste it into your AI tool's system prompt, custom instructions field, or chat window. The `## Context` and `## Instructions` sections give the AI everything it needs to behave correctly.

**Auto-discovery (Claude Code, Cursor, Gemini CLI):**

After installation, skills live in `.<tool>/skills/autonomousguy/<category>/`. Tools that support skill directories pick them up automatically. Invoke by name in the skill panel or via `/skill-name` syntax — for example, `/misra-review`.

**Invoke in a proprietary or enterprise AI tool:**

Skills are plain text. If your company uses an internally hosted AI product without a plugin system, paste the skill content into the conversation the same way you would a system prompt. The five-section structure works in any model.

---

## Recommended workflow

Follow this sequence in any new project for best results:

1. **Install skills** using whichever method fits your environment (see [Installation](#installation)).

2. **Run `codebase-analysis` first.** In your AI tool, invoke or paste the `workspace/codebase-analysis` skill and let it scan the repository. It writes `.autonomousguy/CODEBASE_MAP.md` — a persistent map of your SWCs, BSW dependencies, signal flows, and ASIL zones. Add this file to `.gitignore` if it is project-local.

3. **Reference `CODEBASE_MAP.md` in subsequent skills.** Most skills instruct the AI to load `.autonomousguy/CODEBASE_MAP.md` at the start of the session. This means the AI already knows your architecture and does not need to re-read the whole codebase on every task.

4. **Pick the skill that matches your current task.** Use the category table above to find the right skill. Provide the input the skill asks for (the `## Input expected` section tells you exactly what to share).

5. **Chain skills naturally.** For example: `requirements/elicitation` → `architecture/component-design` → `autosar/swc-development` → `safety/iso26262-asil` → `testing/unit-test-generation`. Each skill's output is a natural input for the next.

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

The installer copies the same Markdown files to whichever paths you select. If your tool is not listed, choose **General Agent** during installation and point your tool at `.autonomousguy/skills/`, or simply paste skill contents manually.

---

## Contributing

Contributions are welcome. Open an issue first for new categories or significant structural changes. For new individual skills within an existing category, a pull request is sufficient.

### Adding a skill

1. Create a `.md` file in the appropriate `skills/<category>/` subdirectory. The CLI discovers skill files at runtime by listing `.md` files in each subdirectory — no registration step is needed.

2. Add the required YAML frontmatter (all five fields: `name`, `short`, `description`, `category`, `tags`).

3. Write the five content sections in order: `## Context`, `## Instructions`, `## Input expected`, `## Output format`, `## Example`.

4. The `## Example` section **must** contain a realistic embedded automotive input/output pair. No placeholders, lorem ipsum, or generic examples. Reviewers will reject examples that do not reflect real ECU development scenarios.

### Quality bar for skills

- **Context** must name a specific engineering role and state the domain knowledge the AI should assume (e.g. "experienced AUTOSAR integrator familiar with Classic Platform R4.x").
- **Instructions** must be numbered steps, not a paragraph. Each step should be independently actionable.
- **Output format** must specify the exact structure — headings, table columns, code block language tags — so output is predictable and diff-able.
- **Example** must use realistic signal names, ASIL levels, MISRA rule IDs, or ARXML constructs. The example is the primary way reviewers validate that the skill produces useful output.

### Adding a new category

Open an issue describing the domain area and the skills you plan to add. New categories need at least two skills to be accepted — a single skill rarely justifies a new subdirectory.

### Running locally

```bash
git clone https://github.com/ptsilivis/autonomousguy.git
cd autonomousguy
npm install
node bin/cli.js       # run the interactive installer from the repo
```

No build step or test suite is required. Skill validation is by domain review, not automated testing.

---

## License

MIT © [Panagiotis Tsilivis](https://github.com/ptsilivis)

See [LICENSE](LICENSE) for the full text.
