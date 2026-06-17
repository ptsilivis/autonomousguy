# autonomousguy

[![npm version](https://img.shields.io/npm/v/autonomousguy.svg)](https://www.npmjs.com/package/autonomousguy)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js ≥18](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS%20%7C%20windows-lightgrey)](#installation)

**AI skills for embedded automotive engineers — AUTOSAR, MISRA, ISO 26262, ECU development.**

**autonomousguy** is a library of 30 domain-accurate AI prompt files (_skills_) covering the full ECU software lifecycle. Use it with Claude Code, GitHub Copilot, Cursor, Gemini CLI, or any AI tool to get consistent, expert-level assistance on AUTOSAR integration, MISRA C:2025 compliance, ISO 26262 safety analysis, requirements engineering, testing, documentation, toolchain setup, debugging, and change management.

Install once. Works with any AI tool. No lock-in.

---

## Installation

autonomousguy ships as a set of [Agent Skills](https://github.com/vercel-labs/skills) and is installed with the standard `skills` CLI. The CLI resolves the correct path per agent — no custom installer required.

### Install all 30 skills

```bash
npx skills add ptsilivis/autonomousguy
```

### Install a single skill

```bash
npx skills add ptsilivis/autonomousguy --skill misra-review
```

### Browse before installing

```bash
npx skills add ptsilivis/autonomousguy --list
```

### Target a specific agent

```bash
npx skills add ptsilivis/autonomousguy -a claude-code
npx skills add ptsilivis/autonomousguy -a copilot
```

### Non-interactive (CI)

```bash
npx skills add ptsilivis/autonomousguy -y
```

---

## Skill catalogue (10 skills)

Each skill is mode-aware: it covers several related workflows in one prompt and routes from the user's input to the right behaviour. Start with `codebase-analysis` on any new project — it writes `.autonomousguy/CODEBASE_MAP.md`, which the other skills reference.

| Skill | Modes / what it does |
|---|---|
| `codebase-analysis` | First-run repo scan — maps SWCs, BSW usage, signal flows, ASIL zones, and function index into `CODEBASE_MAP.md`. |
| `autosar-swc` | (1) Component design, (2) Interface definition, (3) SWC development, (4) Diagram generation (plain-text box-and-arrow — no Mermaid/PlantUML renderer required), (5) Integration review. Covers the full SWC lifecycle from topology to ARXML-importable code and integration audits. |
| `autosar-bsw` | (1) BSW module configuration (Com/NvM/Dem/Dcm/Os/MemIf), (2) ARXML debugging, (3) RTE generation troubleshooting, (4) COM stack debugging (CanDrv → CanIf → PduR → Com signal flow, RX and TX). |
| `misra` | (1) Review existing code against MISRA C:2025 (~223 guidelines), (2) Develop new code that is MISRA-compliant by construction. Full rule reference at `references/rules.md`. |
| `code-review` | (1) Correctness review (ISR safety, integer overflow, race conditions, stack, control flow, ISO 26262 readiness), (2) AUTOSAR naming-convention audit / generation. |
| `requirements` | (1) Elicitation (EARS notation, ASIL attributes), (2) Refinement (vague → measurable), (3) Traceability matrix with safety-gap detection. |
| `iso26262` | (1) HARA / ASIL determination with S/E/C lookup, (2) Safety Goals & FSC with FTTI, FDTI, FRTI, EOTI and Functional Safety Requirements. Full reference at `references/asil-table.md`. |
| `embedded-testing` | (1) MC/DC-covering unit test generation with stubs and coverage matrix, (2) Boundary value analysis for embedded types with overflow / wrap / truncation risks. |
| `embedded-debugging` | (1) Problem-report triage with ranked hypotheses and investigation plan, (2) Targeted fault debugging (HardFault, watchdog, Dem event, stack overflow, AUTOSAR OS errors) with GDB / TRACE32 commands. |
| `change-management` | (1) Change-request analysis (planning before work begins), (2) Impact analysis (tracing direct + indirect ripple effects with regression scope). |

---

## How to use a skill

After `npx skills add ptsilivis/autonomousguy`, the CLI installs each skill in your agent's native location (e.g. `.claude/skills/<name>/SKILL.md`). Invoke the skill from your agent the same way you invoke any other Agent Skill.

**Recommended workflow:**
1. Run `codebase-analysis` first on any new project.
2. Pick the skill that matches your task.
3. Chain skills naturally — e.g. `elicitation` → `component-design` → `swc-development` → `iso26262-asil` → `unit-test-generation`.

---

## Supported AI tools

Path resolution is handled by the `skills` CLI per agent. Pass `-a <agent>` to target one explicitly: `claude-code`, `copilot`, `cursor`, `gemini-cli`, `codex`, `opencode`. Without `-a`, the CLI detects installed agents.

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
- Create a folder `skills/<category>/<skill-name>/` with a `SKILL.md` inside — no registration needed, the `skills` CLI discovers it automatically.
- Include all five frontmatter fields (`name`, `short`, `description`, `category`, `tags`) and all five content sections.
- The `## Example` must use realistic ECU inputs/outputs — no placeholders.
- Optional supporting files (`scripts/`, `references/`, `assets/`) may live alongside `SKILL.md`.

```bash
git clone https://github.com/ptsilivis/autonomousguy.git
cd autonomousguy
node bin/validate.js   # validate skill structure
```

---

## Standards & licensing notice

The skills in this library reference and operate on two copyrighted standards:

- **MISRA C:2025** — © The MISRA Consortium Ltd. Sold per-seat; not redistributable.
- **ISO 26262:2018** (all parts) — © ISO. Sold per-part; not redistributable.

This library cites rule and clause **identifiers** (e.g., "MISRA C:2025 Rule 11.3",
"ISO 26262-3:2018 §6.4.3.5 Table 4") and paraphrases their intent in our own words. It does
**not** reproduce the rule text, the standards' normative wording, the rationale or
amplification sections, the examples from the standards, or the full ASIL determination
table. To apply these skills in a real project you (or your organisation) must hold a
properly licensed copy of each standard — the skills are an operational aid, not a
substitute for the standard itself.

If you spot any content in this library that appears to reproduce normative text from
either standard rather than paraphrasing it, open an issue and we will rewrite it.

---

## License

MIT © [AutonomousGuy](https://github.com/ptsilivis/autonomousguy)
