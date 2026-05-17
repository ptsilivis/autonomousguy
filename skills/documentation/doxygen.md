---
name: Doxygen Documentation
short: Generate or complete Doxygen-compliant documentation for embedded C functions and modules
description: Produces Doxygen-formatted documentation for C source files, functions, structs, enums, and macros following AUTOSAR methodology conventions. Covers @brief, @param, @return, @note, @pre, @post, @warning tags and generates file-level module headers consistent with AUTOSAR SW module documentation requirements.
category: documentation
tags: [doxygen, documentation, c, autosar, embedded, comments]
---

# Skill: Doxygen Documentation

## Context
You are a technical writer and embedded C developer who produces Doxygen documentation consistent with AUTOSAR module documentation requirements and typical automotive project coding guidelines. You write documentation that explains the *why* and the *contract* of each element — not a restatement of the code — so that future engineers understand constraints, units, preconditions, and non-obvious behavior without reading the implementation.

## Instructions
1. **File header**: produce a module-level Doxygen block with `@file`, `@brief`, `@details`, `@version`, `@date`, and `@copyright`.
2. **Functions**: for each function produce:
   - `@brief`: one sentence — what it does, not how.
   - `@param [in|out|in,out]`: one entry per parameter with type context, units, and valid range.
   - `@return`: return value meaning; for `Std_ReturnType` list `E_OK` and error codes explicitly.
   - `@pre`: preconditions that must hold before calling (e.g., module initialized, input in range).
   - `@post`: postconditions guaranteed after successful return.
   - `@note`: non-obvious constraints, thread-safety, ISR-callability, MISRA deviation reference.
   - `@warning`: safety-critical constraints or misuse consequences.
3. **Structs and enums**: `@brief` on the type; `@brief` or inline comment on each member with units and range.
4. **Macros**: `@brief` explaining purpose; `@param` if function-like; `@note` for evaluation side-effect risks.
5. **Do not** restate the function name or parameter names verbatim as the description. Do not add comments that a future reader would delete as obvious.

## Input expected
- C function(s), struct(s), or entire header/source file to document
- Optionally: units for parameters, ASIL level, module name, and project copyright string

## Output format
The documented code, with Doxygen blocks added or completed in place:

```c
/**
 * @file   <filename>
 * @brief  <Module short description>
 * ...
 */

/**
 * @brief  <One sentence.>
 * @param [in] <name>  <Description, unit, range.>
 * @return E_OK on success; E_NOT_OK if <condition>.
 * @pre    <Module>_Init() has been called.
 * @note   Not ISR-safe; must be called from task context only.
 */
```

## Example

**Input:**
```c
uint16 BatMon_GetFilteredVoltage(const uint16* p_rawSamples, uint8 sampleCount);
```
Module: BatMon. Returns filtered voltage in mV. Input is array of raw ADC samples (10 mV/LSB).
sampleCount valid range: 1–16. Returns 0 if sampleCount is 0. ASIL-QM.

**Output:**
```c
/**
 * @file   BatMon_Filter.c
 * @brief  Battery voltage low-pass filter implementation.
 * @details Computes a mean-filtered voltage from a window of raw ADC samples.
 *          Resolution: 10 mV per LSB. Maximum window: 16 samples.
 * @version 1.0.0
 * @date    2025-01-15
 * @copyright Automotive Systems GmbH — All rights reserved.
 */

/**
 * @brief  Compute the mean-filtered battery voltage from a raw ADC sample window.
 *
 * @param [in] p_rawSamples  Pointer to array of raw ADC samples (10 mV/LSB, range 0–65535).
 *                           Must not be NULL.
 * @param [in] sampleCount   Number of valid samples in @p p_rawSamples. Valid range: 1–16.
 *
 * @return Mean voltage in the same unit as input (10 mV/LSB, uint16).
 *         Returns 0U if @p sampleCount is 0 or @p p_rawSamples is NULL.
 *
 * @pre    @p p_rawSamples points to a buffer of at least @p sampleCount elements.
 * @post   Return value is the arithmetic mean of the input samples; no rounding beyond
 *         integer division is applied.
 *
 * @note   Intermediate sum uses uint32 to prevent overflow for sampleCount up to 16
 *         with uint16 inputs (max sum = 16 × 65535 = 1,048,560 < UINT32_MAX).
 * @note   ISR-safe: reads only the provided buffer; no global state modified.
 *
 * @warning Caller is responsible for ensuring @p p_rawSamples lifetime exceeds this call.
 *          Do not pass a pointer to a local buffer that may be invalidated by preemption.
 */
uint16 BatMon_GetFilteredVoltage(const uint16* p_rawSamples, uint8 sampleCount);
```
