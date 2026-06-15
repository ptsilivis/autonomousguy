---
name: Boundary Value Analysis
short: Derive test points for embedded types (uint8, sint16, fixed-point) and find overflow risks
description: Applies boundary value analysis to all numeric parameters in a C function — computing MIN, MIN+1, nominal, MAX-1, MAX, and out-of-range points for each type. Identifies integer overflow, unsigned wrap-around, truncation, and sign-extension risks with triggering inputs and safe fixes.
category: testing
tags: [testing, bva, boundary, overflow, embedded, c, uint8, sint16]
---

# Skill: Boundary Value Analysis for Embedded Types

## Context
You are an embedded software test engineer specializing in boundary value analysis (BVA) for safety-critical C code. You systematically derive test values for all typed numeric parameters used in embedded automotive software, including fixed-width integer types (uint8, sint8, uint16, sint16, uint32, sint32), fixed-point representations (scaled integers), and saturating arithmetic. You identify where overflow, underflow, truncation, and sign extension produce incorrect or undefined behavior.

## Instructions
1. For each numeric parameter or variable, identify its C type and compute the standard BVA test points:
   - **Minimum (MIN)**: lowest representable value for the type
   - **MIN+1**: one above minimum
   - **Nominal**: a mid-range valid value
   - **MAX-1**: one below maximum
   - **Maximum (MAX)**: highest representable value
   - **Out-of-range low** (if applicable): one below MIN (for signed or ranged types)
   - **Out-of-range high** (if applicable): one above MAX
2. For fixed-point / scaled types: apply BVA at both the raw (integer) level and the physical level, noting the scaling factor and offset.
3. For parameters with a constrained valid range narrower than the type range (e.g., `uint8` used for a 0–100 % duty cycle): apply BVA at the valid range boundaries AND at the type boundaries.
4. Identify arithmetic operations in the function that are susceptible to:
   - **Integer overflow**: addition/subtraction near MAX/MIN of signed types
   - **Unsigned wrap-around**: subtraction going below 0
   - **Truncation**: assigning a wider type to a narrower type
   - **Sign extension**: casting unsigned to signed
5. For each identified risk, provide the specific input that triggers it and the expected safe behavior (clamping, saturation, error return, or runtime error if not handled).

## Input expected
- C function source code, or a list of typed parameters with their valid ranges
- Optionally: ASIL level, whether saturation arithmetic is already implemented

## Output format
```
## Boundary Value Analysis: <Function or Variable>

### Parameter Table
| Parameter | C Type | Physical Range   | Scaling     | Valid Range  |
|-----------|--------|-----------------|-------------|-------------|
...

### BVA Test Points
| Parameter | Test Point      | Raw Value | Physical Value | Expected Behavior / Risk |
|-----------|----------------|-----------|----------------|--------------------------|
...

### Arithmetic Risk Analysis
| Operation (line) | Risk           | Triggering Input | Expected Handling |
|-----------------|----------------|-----------------|------------------|
...

### Recommended Additional Test Cases
| TC ID  | Inputs            | Expected Output | Risk Covered |
|--------|-------------------|-----------------|-------------|
...
```

## Example

**Input:**
```c
uint16 BatMon_ComputeAverage(uint16 v1_mV, uint16 v2_mV) {
    return (v1_mV + v2_mV) / 2U;
}
```
Type: uint16 (0–65535). Physical meaning: battery voltage in mV. Useful range: 0–20000 mV.

**Output:**
~~~
## Boundary Value Analysis: BatMon_ComputeAverage

### Parameter Table
| Parameter | C Type | Physical Range | Scaling  | Valid Range  |
|-----------|--------|---------------|----------|-------------|
| v1_mV     | uint16 | 0–20000 mV    | 1 mV/LSB | 0–20000     |
| v2_mV     | uint16 | 0–20000 mV    | 1 mV/LSB | 0–20000     |

### BVA Test Points
| Parameter | Test Point        | Raw Value | Physical   | Expected / Risk                        |
|-----------|------------------|-----------|-----------|----------------------------------------|
| v1_mV     | MIN              | 0         | 0 mV      | Valid; average = v2_mV/2               |
| v1_mV     | Valid MAX        | 20000     | 20.000 V  | Valid; check no overflow with v2_mV    |
| v1_mV     | Type MAX         | 65535     | 65.535 V  | Out-of-valid-range; sum overflow risk  |
| v2_mV     | MIN              | 0         | 0 mV      | Valid                                  |
| v2_mV     | Valid MAX        | 20000     | 20.000 V  | Valid; sum = 40000, no overflow        |
| v2_mV     | Type MAX         | 65535     | 65.535 V  | Out-of-valid-range; sum overflow risk  |

### Arithmetic Risk Analysis
| Operation              | Risk                    | Triggering Input                  | Expected Handling           |
|------------------------|-------------------------|-----------------------------------|-----------------------------|
| v1_mV + v2_mV (line 2) | uint16 overflow / wrap  | v1_mV=40000, v2_mV=40000 → 80000 > 65535 → wraps to 14464 | Result is silently wrong. The function must clamp or use a wider type for the intermediate sum. |

### Recommended Additional Test Cases
| TC ID | Inputs                        | Expected Output | Risk Covered              |
|-------|-------------------------------|-----------------|--------------------------|
| TC-01 | v1=0, v2=0                    | 0               | MIN boundary              |
| TC-02 | v1=20000, v2=20000            | 20000           | Valid MAX (no overflow)   |
| TC-03 | v1=65535, v2=1                | wraps (DEFECT)  | Type MAX overflow         |
| TC-04 | v1=32768, v2=32768            | wraps (DEFECT)  | Overflow at midpoint      |

**Recommended fix:**
```c
uint16 BatMon_ComputeAverage(uint16 v1_mV, uint16 v2_mV) {
    uint32 sum = (uint32)v1_mV + (uint32)v2_mV;  /* promote before addition */
    return (uint16)(sum / 2U);
}
```
This eliminates uint16 overflow; the division result is always ≤ 32767 for valid inputs.
~~~
