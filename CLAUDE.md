# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**autonomousguy** is a library of 30 Agent Skills for embedded automotive engineers, covering the full ECU software lifecycle — from codebase onboarding and AUTOSAR integration through MISRA compliance, ISO 26262 safety analysis, debugging, and change management.

It is installed via the standard [`skills` CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add ptsilivis/autonomousguy
```

The vision is an "AI colleague": a skill set that supports engineers from problem report through implementation and closure, across any AI tool that supports Agent Skills (Claude Code, GitHub Copilot, Cursor, Gemini CLI, etc.).

## Commands

```bash
node bin/validate.js          # validate skill structure (frontmatter + 5 sections)
npx skills add . --list       # list discovered skills locally
npx skills add . --skill <n>  # dry-install a single skill from this checkout
```

No build step, test suite, or linter configured.

## Architecture

A single concern: a **skill library** in the Agent Skills layout. Path resolution per agent is handled by the upstream `skills` CLI — this repo has no installer code.

### Skills (`skills/`)

30 skills across 11 categories, in catalog layout:

```
skills/<category>/<skill-name>/SKILL.md
```

Every `SKILL.md` must have:

**YAML frontmatter** (required fields: `name`, `short`, `description`, `category`, `tags`):
```yaml
---
name: human-readable-skill-name
short: One-line description shown in pickers
description: Two-sentence description of what the skill does.
category: <category-slug>
tags: [tag1, tag2]
---
```

`name` and `description` are required by the `skills` CLI. `short`, `category`, and `tags` are project conventions used by the validator.

**Five content sections** (in this order):
- `## Context` — who the AI should behave as
- `## Instructions` — numbered step-by-step behavior
- `## Input expected` — what the user must provide
- `## Output format` — exact response structure (use code blocks)
- `## Example` — realistic embedded automotive input/output pair; no placeholders

Optional supporting files (`scripts/`, `references/`, `assets/`) may live alongside `SKILL.md`. The `skills` CLI auto-discovers everything in the skill folder — no registration step needed.

### Skill inventory (10 consolidated skills, mode-aware)

| Path | Skill | Modes |
|---|---|---|
| `workspace/codebase-analysis/` | Codebase Analysis | First-run scan → `.autonomousguy/CODEBASE_MAP.md` |
| `autosar/autosar-swc/` | AUTOSAR SWC Design & Development | Component design / Interface definition / SWC development / UML / Integration review |
| `autosar/autosar-bsw/` | AUTOSAR BSW & COM Stack | BSW configuration / ARXML debugging / RTE generation / COM stack debugging |
| `code-quality/misra/` | MISRA C:2025 | Review / Develop (+ `references/rules.md`) |
| `code-quality/code-review/` | Embedded C Code Review | Correctness review / Naming-convention review |
| `requirements/requirements/` | Requirements Engineering | Elicitation / Refinement / Traceability |
| `safety/iso26262/` | ISO 26262 Functional Safety | HARA + ASIL / Safety Goals + FSC (+ `references/asil-table.md`) |
| `testing/embedded-testing/` | Embedded Testing | Unit-test generation / Boundary value analysis |
| `debugging/embedded-debugging/` | Embedded Debugging | Problem-report triage / Targeted fault debugging |
| `change-management/change-and-impact/` | Change Management | CR analysis / Impact analysis |

Each SKILL.md uses mode dispatch in `## Instructions`: it reads the input shape and routes to the appropriate sub-workflow, with one example per mode and a per-mode `## Output format` block. Three skills carry optional `references/` companion files for content too large for the prompt (rule lists, lookup tables, layer walks).

### `CODEBASE_MAP.md`

`workspace/codebase-analysis` writes `.autonomousguy/CODEBASE_MAP.md` into the user's project root on first run. It maps SWCs, BSW dependencies, signal flows, ASIL zones, and the function index. Every other skill references this file to avoid re-reading the codebase. It is project-local and should not be committed.

## Design decisions (locked)

- **Distribution**: Agent Skills convention via the `skills` CLI. No bespoke installer, no per-tool emitters in this repo — path resolution per agent is the CLI's job.
- **Layout**: catalog form (`skills/<category>/<name>/SKILL.md`). Categories preserve domain grouping; the CLI walks one extra level deep to discover them.
- **Skill format**: five-section Markdown with YAML frontmatter. Both are required — `name`+`description` for the CLI, the project-specific `short`/`category`/`tags` and the five sections for the validator and AI consumption.
- **Skill validator**: `bin/validate.js` checks every `skills/**/SKILL.md` for required frontmatter keys and the five required sections in order.
- **Versioning**: single version in `package.json`; bump before any tag/release.

## What's next

- Additional skills identified during design: `autosar/swc-migration`, `safety/fmea`, `testing/integration-test-plan`
- Optional: GitHub plugin (`plugin.json`) and marketplace listing (deferred — separate task)
