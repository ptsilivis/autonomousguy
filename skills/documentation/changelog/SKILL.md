---
name: Changelog Generation
short: Generate a structured software changelog from git history, PRs, or a list of changes
description: Produces a structured software changelog for embedded automotive SW releases. Classifies changes as New Features, Bug Fixes, MISRA/Safety fixes, Interface Changes, Configuration Changes, and Deprecations. Assigns impact levels and flags changes requiring re-verification evidence under ISO 26262 or ASPICE change management.
category: documentation
tags: [changelog, documentation, release, git, iso26262, aspice, embedded]
---

# Skill: Changelog Generation

## Context
You are a technical lead producing release documentation for an embedded automotive software module. You write changelogs that serve two audiences: engineers (what changed and how to integrate it) and safety/quality managers (what needs re-verification and which requirements are affected). You follow Keep a Changelog conventions adapted for automotive SW, and you flag safety-relevant changes explicitly.

## Instructions
1. **Parse the input**: extract changed items from git log, PR descriptions, ticket list, or a bullet list of changes.
2. **Classify each change**:
   - `[FEAT]` New feature or capability added.
   - `[FIX]` Bug fix — include root cause if known.
   - `[SAFETY]` MISRA compliance fix, ASIL-relevant change, or safety finding resolution.
   - `[INTERFACE]` Port DataElement, function signature, CAN signal, or BSW API change — **breaking**.
   - `[CONFIG]` BSW or OS configuration change only, no functional code change.
   - `[DEPRECATE]` Element deprecated; provide migration path.
   - `[DOCS]` Documentation or comment update only.
3. **Assign impact level** per change:
   - `HIGH`: interface change, safety fix, or behavioral change affecting other SWCs.
   - `MEDIUM`: bug fix with user-visible effect.
   - `LOW`: internal refactoring, comment, or documentation only.
4. **Flag re-verification requirements**: any `[SAFETY]` or `[INTERFACE]` change requires a note on which test cases must be re-run.
5. **Format** in reverse chronological order (newest first).

## Input expected
- Git log output (`git log --oneline`), PR title list, ticket list, or bullet list of changes
- Optionally: SW version numbers (old and new), release date, module name

## Output format
```markdown
# Changelog — <ModuleName>

## [<NewVersion>] — <Date>

### Interface Changes (breaking) ⚠️
- [INTERFACE] [HIGH] <Description> — Re-verify: <TC-IDs>

### New Features
- [FEAT] [MEDIUM] <Description>

### Bug Fixes
- [FIX] [MEDIUM] <Description> (Root cause: <cause>)

### Safety & Compliance
- [SAFETY] [HIGH] <Description> — Re-verify: <TC-IDs>

### Configuration Changes
- [CONFIG] [LOW] <Description>

### Documentation
- [DOCS] [LOW] <Description>

---
## [<OldVersion>] — <Date>
...
```

## Example

**Input:**
Module: BatMon_AppSWC. Going from v1.3.0 to v1.4.0. Changes:
- Renamed DataElement Voltage_mV to BattVoltage_mV in BattVoltageIf
- Fixed debounce counter not resetting when voltage recovers (PR-0038)
- Lowered low-voltage threshold from 11.5V to 11.0V per CR-0088
- Added Doxygen to BatMon_Filter.c
- MISRA Rule 10.4 fix: changed `if (warningActive)` to `if (warningActive == TRUE)`

**Output:**
```markdown
# Changelog — BatMon_AppSWC

## [1.4.0] — 2025-01-20

### Interface Changes (breaking) ⚠️
- [INTERFACE] [HIGH] Renamed `BattVoltageIf` DataElement `Voltage_mV` → `BattVoltage_mV`.
  All connected SWCs (providers and consumers) and generated RTE headers must be updated.
  Re-verify: TC-BATMON-001, TC-BATMON-002, TC-DISPLAY-003.

### New Features
- [FEAT] [MEDIUM] Low-voltage threshold lowered from 11.5 V to 11.0 V per CR-0088.
  Cold-weather false-warning rate reduced. Re-verify: TC-BATMON-002 (boundary updated).

### Bug Fixes
- [FIX] [MEDIUM] Debounce counter not resetting when battery voltage recovers above threshold
  (PR-0038). Root cause: missing decrement branch in `BatMon_App_MainRunnable` when voltage
  was in range. `LowVoltageWarning_Active` could remain TRUE indefinitely after recovery.
  Re-verify: TC-BATMON-002.

### Safety & Compliance
- [SAFETY] [LOW] MISRA C:2025 Rule 14.4 fix: controlling expression `if (warningActive)`
  replaced with `if (warningActive == TRUE)`. No behavioral change.
  Re-verify: not required (comment-only semantic change confirmed by code review).

### Documentation
- [DOCS] [LOW] Added Doxygen function headers to all public functions in `BatMon_Filter.c`.

---

## [1.3.0] — 2024-11-10
...
```
