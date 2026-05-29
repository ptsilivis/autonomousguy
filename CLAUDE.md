# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**autonomousguy** is an `npx`-installable AI skill library for embedded automotive engineers. It ships 29 domain-accurate prompt files (skills) covering the full ECU software lifecycle — from codebase onboarding and AUTOSAR integration through MISRA compliance, ISO 26262 safety analysis, debugging, and change management.

The vision is an "AI colleague": a skill set that supports engineers from problem report through implementation and closure, across any AI tool (Claude Code, GitHub Copilot, Cursor, Gemini CLI, etc.).

## Commands

```bash
npm install          # install @inquirer/prompts
node bin/cli.js      # run CLI interactively from repo
npx . init           # simulate npx autonomousguy init
npm pack --dry-run   # verify package contents before publish
npm publish          # publish to npm (requires auth)
```

No build step, test suite, or linter configured.

## Architecture

Two concerns: a **CLI installer** and a **skill library**.

### CLI (`bin/cli.js`)

Interactive installer built with `@inquirer/prompts`. Four-step flow:

1. **Scope** — local (current directory) or global (home directory)
2. **Tools** — multi-select from 8 supported AI tools
3. **Skills** — install all 29, or pick by category then individual skill
4. **Copy** — skills land in `<baseDir>/<tool.dir>/skills/autonomousguy/<category>/`

Frontmatter is parsed at runtime from each `.md` file (simple regex, no YAML library) to populate the `name` and `short` description shown during skill selection.

### Tool registry (`TOOLS` array in `bin/cli.js`)

All tools use the same directory pattern — no special-casing for any tool:

| Tool | Base dir |
|---|---|
| Claude Code | `.claude` |
| GitHub Copilot | `.github` |
| Cursor | `.cursor` |
| Gemini CLI | `.gemini` |
| ChatGPT Codex | `.agents` |
| OpenCode | `.opencode` |
| JetBrains AI | `.idea` |
| General Agent | `.autonomousguy` |

Install path for every tool: `<baseDir>/<tool.dir>/skills/autonomousguy/<category>/`

To add a new tool: append one `{ name, dir }` entry to `TOOLS`.

### Skills (`skills/`)

29 skill files across 11 categories. Every file must have:

**YAML frontmatter** (required fields: `name`, `short`, `description`, `category`, `tags`):
```yaml
---
name: Human-readable skill name
short: One-line description shown in CLI picker
description: Two-sentence description of what the skill does.
category: <category-slug>
tags: [tag1, tag2]
---
```

**Five content sections** (in this order):
- `## Context` — who the AI should behave as
- `## Instructions` — numbered step-by-step behavior
- `## Input expected` — what the user must provide
- `## Output format` — exact response structure (use code blocks)
- `## Example` — realistic embedded automotive input/output pair; no placeholders

The CLI counts `.md` files per subdirectory automatically — no registration step needed.

### Skill inventory

| Category | Skill files | Domain |
|---|---|---|
| `workspace/` | codebase-analysis | First-run scan → writes `.autonomousguy/CODEBASE_MAP.md` |
| `autosar/` | autosar-integration, swc-development, bsw-configuration, arxml-debugging, rte-generation-troubleshooting | AUTOSAR Classic end-to-end |
| `code-quality/` | misra-review, misra-driven-development, code-review, naming-conventions | MISRA C:2025 audit and compliant development |
| `architecture/` | component-design, uml-generation, interface-definition | SWC topology, UML (PlantUML/Mermaid), port interfaces |
| `requirements/` | elicitation, refinement, traceability | EARS notation, defect detection, traceability matrix |
| `safety/` | iso26262-asil, safety-goals | HARA, ASIL lookup, Safety Goals, FTTI, FSR derivation |
| `testing/` | unit-test-generation, boundary-analysis | MC/DC test generation, BVA for embedded types |
| `documentation/` | doxygen, sw-design-doc, changelog | Doxygen, ASPICE SWE.3 SDD, release changelogs |
| `toolchain/` | cmake-conan, can-dbc-analysis | ARM cross-compilation, CAN DBC → AUTOSAR COM mapping |
| `debugging/` | problem-report-analysis, targeted-debugging | Field PR investigation, watchdog/race/HardFault debugging |
| `change-management/` | change-request-analysis, impact-analysis | CR analysis with ASIL impact, full ripple-effect tracing |

### `CODEBASE_MAP.md`

`workspace/codebase-analysis` writes `.autonomousguy/CODEBASE_MAP.md` into the user's project root on first run. It maps SWCs, BSW dependencies, signal flows, ASIL zones, and the function index. Every other skill references this file to avoid re-reading the codebase. It is project-local and should not be committed (add to `.gitignore`).

## Design decisions (locked)

- **Skill format**: five-section Markdown with YAML frontmatter. Both are required — frontmatter for CLI, sections for AI consumption.
- **Install pattern (current)**: all tools use `.<tool>/skills/autonomousguy/` — no single-file concatenation for any tool. This is a staging layout; files are not auto-discovered by any tool in their installed form (no tool reads `.<tool>/skills/autonomousguy/` natively). Users invoke skills by manually pasting or referencing the file.
- **Install pattern (v0.2 decision)**: add per-tool emitters — transform canonical `.md` on install into each tool's native format (`SKILL.md` dirs for Claude Code, `.mdc` for Cursor, `.prompt.md` for Copilot, etc.). This is the v0.2 headline feature. The "no special-casing for any tool" constraint from v0.1 is **superseded** by this decision.
- **Dependency**: `@inquirer/prompts` for the interactive TUI. The "zero deps" constraint of the original prototype was dropped in favour of a usable multi-select CLI.
- **Skill validator**: `bin/validate.js` checks every `skills/**/*.md` for required frontmatter keys and the five required sections in order. Run automatically via `prepublishOnly`.
- **Versioning**: single version in `package.json`; bump before every `npm publish`.

## What's next (v0.2 candidates)

- GitHub repository setup (topics: autosar, misra, embedded, automotive, ai, iso26262)
- `npm publish` to make `npx autonomousguy init` work publicly
- A `skills-lock.json` at project level to track which autonomousguy version is installed (following the impeccable pattern)
- **Per-tool emitters (HR-1)**: transform canonical `.md` into each tool's native format on install (Claude Code `SKILL.md` dirs, Cursor `.mdc`, Copilot `.prompt.md`, Gemini CLI commands, etc.)
- Additional skills identified during design: `autosar/swc-migration`, `safety/fmea`, `testing/integration-test-plan`
