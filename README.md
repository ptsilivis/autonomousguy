# autonomousguy

[![npm version](https://img.shields.io/npm/v/autonomousguy.svg)](https://www.npmjs.com/package/autonomousguy)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js >=18](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)

Open-source AI agent skills for embedded automotive engineers - AUTOSAR, MISRA C, ISO 26262 - that give Copilot and Claude the domain context they are missing.

## Install

```shell
# Install all skills (global)
npx skills add ptsilivis/autonomousguy -g

# Browse what's inside before installing
npx skills add ptsilivis/autonomousguy --list
```

That is all you need. Works with Claude Code, GitHub Copilot, Cursor, Codex, Gemini CLI, and any tool that supports Agent Skills.

## What's inside

10 mode-aware skills covering the ECU software lifecycle. Each skill routes from your input to the right sub-workflow, so one skill handles several related tasks. Start with `codebase-analysis` on a new project: it writes `.autonomousguy/CODEBASE_MAP.md`, which the other skills reference.

The AUTOSAR column states which platform a skill assumes. Skills marked "Classic + Adaptive" default to Classic AUTOSAR (CP) and switch to Adaptive AUTOSAR (AP) when your input names AP concepts (ara::com, ara::exec, C++14, POSIX, service-oriented, manifest).

| Skill | What it does | Platform |
|---|---|---|
| `codebase-analysis` | Scans the repo and maps SWCs, BSW usage, port interfaces, RTE API calls, signal flow, and ASIL zones into `CODEBASE_MAP.md`. | Classic + Adaptive |
| `autosar-swc` | Component design, port interface definition, SWC code, plain-text diagrams, and integration review. | Classic + Adaptive |
| `autosar-bsw` | BSW config (Com, NvM, Dem, Dcm, Os, MemIf), ARXML debugging, RTE generation troubleshooting, and CAN COM-stack debugging (CanIf -> PduR -> Com). | Classic + Adaptive |
| `misra` | Audit C against MISRA C:2025 or write code that is compliant by construction. | Classic (MISRA C) |
| `code-review` | Embedded C correctness review (ISR safety, integer overflow, races, stack) plus AUTOSAR naming-convention audit. | Classic + Adaptive |
| `requirements` | Elicit, refine, and trace requirements in EARS notation with ASIL attributes. | Neutral |
| `iso26262` | Run a HARA to assign ASIL, or derive Safety Goals and Functional Safety Requirements with FTTI. | Neutral |
| `embedded-testing` | Generate MC/DC-covering unit tests and systematic boundary-value test points. | Classic + Adaptive |
| `embedded-debugging` | Triage a field problem report or debug a specific fault (HardFault, watchdog, Dem event, stack overflow). | Classic + Adaptive |
| `change-and-impact` | Analyze a change request before work begins, or trace direct and indirect ripple effects with a regression scope. | Classic + Adaptive |

Domain coverage: AUTOSAR Classic (CP) and Adaptive (AP), BSW, MCAL, RTE, AUTOSAR OS, ara::com, ara::exec, SOA, MISRA C, ISO 26262, ASIL, functional safety, ECU, CAN.

## Why it exists

Embedded automotive work carries a lot of domain context - AUTOSAR layering, MISRA C rules, ISO 26262 ASIL logic - that general AI tools do not know. Without it you re-explain the same background on every prompt. These skills encode that context once so the AI gives consistent, expert-level answers without the re-explaining.

## Usage

The two commands above cover most needs. For finer control:

```shell
# Install one skill (use the name shown by --list)
npx skills add ptsilivis/autonomousguy --skill autosar-bsw

# Target a specific agent
npx skills add ptsilivis/autonomousguy -a claude-code
npx skills add ptsilivis/autonomousguy -a copilot

# Non-interactive (CI)
npx skills add ptsilivis/autonomousguy -y
```

After install, each skill lands in your agent's native location (e.g. `.claude/skills/<name>/SKILL.md`). Invoke it the way you invoke any Agent Skill.

## Supported agents

Claude Code, GitHub Copilot, Cursor, Codex, Gemini CLI, opencode, and any tool that supports the Agent Skills convention. Path resolution is handled by the `skills` CLI per agent. Pass `-a <agent>` to target one explicitly; without it the CLI detects installed agents.

## Requirements

- Node.js >=18 (for `npx`).
- An AI tool that supports Agent Skills.

## Contributing

This is early. Feedback on gaps - missing skills, weak guidance, wrong domain detail - is wanted. Open an issue: https://github.com/ptsilivis/autonomousguy/issues

To work on the repo:

```shell
git clone https://github.com/ptsilivis/autonomousguy.git
cd autonomousguy
node bin/validate.js   # validate skill structure
```

## Standards and licensing notice

The skills reference two copyrighted standards:

- MISRA C:2025 - (c) The MISRA Consortium Ltd. Sold per-seat; not redistributable.
- ISO 26262:2018 (all parts) - (c) ISO. Sold per-part; not redistributable.

This library cites rule and clause identifiers (e.g. "MISRA C:2025 Rule 11.3", "ISO 26262-3:2018 Table 4") and paraphrases their intent in its own words. It does not reproduce normative text, rationale, amplification, examples, or full lookup tables. To apply these skills on a real project you must hold a properly licensed copy of each standard. If you spot content that reproduces normative text rather than paraphrasing it, open an issue and it will be rewritten.

## License

MIT (c) [autonomousguy](https://github.com/ptsilivis/autonomousguy)
