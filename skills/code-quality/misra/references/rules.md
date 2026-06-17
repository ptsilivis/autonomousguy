# MISRA C:2025 — Full Rule Reference

Paraphrased reference of every MISRA C:2025 directive and rule, grouped by category. **This document does not reproduce normative MISRA text**: it cites identifiers and summarises intent in our own words. A licensed copy of MISRA C:2025 (© The MISRA Consortium Ltd.) remains authoritative for the canonical rule text, amplification, examples, and exception clauses.

Legend: **M** = Mandatory, **R** = Required, **A** = Advisory. C:2025 status flags:
- *(new)* — added in C:2025
- *(disapplied)* — no longer enforced in C:2025
- *(refined)* — wording or scope changed in C:2025

---

## Directives (22 total)

### Dir 1 — Implementation

- **Dir 1.1** (R): All implementation-defined behaviour shall be documented and understood.

### Dir 2 — Compilation and build

- **Dir 2.1** (R): All source files shall compile without errors.

### Dir 3 — Requirements traceability

- **Dir 3.1** (R): All code shall be traceable to documented requirements.

### Dir 4 — Code design

- **Dir 4.1** (R): Run-time failures shall be minimised.
- **Dir 4.2** (A): All assembly code shall be encapsulated and isolated.
- **Dir 4.3** (R): Assembly language shall be encapsulated and isolated.
- **Dir 4.4** (A): Sections of code should not be "commented out".
- **Dir 4.5** (A): Identifiers in the same name space with overlapping visibility should be typographically unambiguous.
- **Dir 4.6** (A): `typedef`s of fixed-size numeric types (`uint8_t`, `int16_t`, …) shall be used instead of bare `int`/`char`.
- **Dir 4.7** (R): If a function returns error information it shall be tested.
- **Dir 4.8** (A): When pointer to a structure is never dereferenced in a translation unit, the implementation should be hidden.
- **Dir 4.9** (A): A function should be used in preference to a function-like macro where they are interchangeable.
- **Dir 4.10** (R): Header files shall include precautions against multiple inclusion (include guards or `#pragma once`).
- **Dir 4.11** (R): Validity of values passed to library functions shall be checked.
- **Dir 4.12** (R): Dynamic memory allocation shall not be used.
- **Dir 4.13** (A): Functions which are designed to provide operations on a resource should be called in an appropriate sequence.
- **Dir 4.14** (R): The validity of values received from external sources shall be checked.
- **Dir 4.15** (R): Evaluation of floating-point expressions shall not lead to undefined behaviour.

---

## Rules (~201 total)

### Rule 1 — Standards

- **Rule 1.1** (M): Program shall contain no violations of the standard C syntax/constraints; shall not exceed implementation translation limits.
- **Rule 1.2** (A): Language extensions should not be used.
- **Rule 1.3** (M): No occurrence of undefined or critical unspecified behavior.
- **Rule 1.4** (M): Emergent language features shall not be used — covers `_Generic`, `_Atomic`, `<stdatomic.h>`, `_Noreturn`, `_Thread_local`, `<threads.h>` (Amd2 prohibition for C11/C18).
- **Rule 1.5** (R): Obsolescent features shall not be used.

### Rule 2 — Unused code

- **Rule 2.1** (R): No unreachable code.
- **Rule 2.2** (R): No dead code (statement with no persistent side effect).
- **Rule 2.3** (A): No unused `typedef` declarations.
- **Rule 2.4** (A): No unused tag declarations (`struct`, `union`, `enum`).
- **Rule 2.5** (A): No unused macro declarations.
- **Rule 2.6** (M): Functions shall not contain unused label declarations.
- **Rule 2.7** (A): No unused parameters in functions.
- **Rule 2.8** (A): No unused object definitions.

### Rule 3 — Comments

- **Rule 3.1** (M): The character sequences `/*` and `//` shall not be used within a comment.
- **Rule 3.2** (M): Line-splicing shall not be used in `//` comments.

### Rule 4 — Character sets and lexical conventions

- **Rule 4.1** (R): Octal and hexadecimal escape sequences shall be terminated.
- **Rule 4.2** (A): Trigraphs should not be used.

### Rule 5 — Identifiers

- **Rule 5.1** (R): External identifiers shall be distinct.
- **Rule 5.2** (R): Identifiers declared in the same scope and name space shall be distinct.
- **Rule 5.3** (R): Identifiers declared in an inner scope shall not hide an outer-scope identifier.
- **Rule 5.4** (R): Macro identifiers shall be distinct.
- **Rule 5.5** (R): Identifiers shall be distinct from macro names.
- **Rule 5.6** (R): A `typedef` name shall be a unique identifier.
- **Rule 5.7** (R): A tag name shall be a unique identifier.
- **Rule 5.8** (R): External linkage identifiers shall be unique.
- **Rule 5.9** (A): Internal linkage identifiers should be unique.

### Rule 6 — Types

- **Rule 6.1** (R): Bit-fields shall only be declared with appropriate types.
- **Rule 6.2** (R): Single-bit named bit-fields shall not be signed.
- **Rule 6.3** *(new)* (R): Bit-field of length one shall not be of plain `int` type.

### Rule 7 — Literals and constants

- **Rule 7.1** (R): Octal constants shall not be used.
- **Rule 7.2** (R): A `u`/`U` suffix shall be applied to all unsigned-typed integer constants.
- **Rule 7.3** (R): The lowercase `l` suffix shall not be used in literal suffixes.
- **Rule 7.4** (R): String literals shall only be assigned to `const`-qualified objects.
- **Rule 7.5** *(refined)* (R): The argument of an integer constant macro shall have an appropriate type.
- **Rule 7.6** *(refined)* (R): The small integer variants of integer constant macros shall not be used.

### Rule 8 — Declarations and definitions

- **Rule 8.1** (R): Types shall be explicitly specified.
- **Rule 8.2** (R): Function types shall be in prototype form with named parameters.
- **Rule 8.3** (R): All declarations of an object/function shall use the same names and qualifiers.
- **Rule 8.4** (R): A compatible declaration shall be visible when an object/function with external linkage is defined.
- **Rule 8.5** (R): An external object or function shall be declared once in one and only one file.
- **Rule 8.6** (R): An identifier with external linkage shall have exactly one external definition.
- **Rule 8.7** (A): Functions and objects shall not be defined with external linkage if used in only one translation unit.
- **Rule 8.8** (R): The `static` storage-class specifier shall be used in all declarations of objects/functions that have internal linkage.
- **Rule 8.9** (A): An object should be defined at block scope if its identifier only appears in a single function.
- **Rule 8.10** (R): An `inline` function shall be declared with the `static` storage class.
- **Rule 8.11** (A): When an array with external linkage is declared, its size should be explicitly specified.
- **Rule 8.12** (R): Within an enumerator list, the value of an implicitly-specified enumeration constant shall be unique.
- **Rule 8.13** (A): A pointer should point to a `const`-qualified type whenever possible.
- **Rule 8.14** (R): The `restrict` type qualifier shall not be used.
- **Rule 8.15** (R): All declarations of an object with an explicit alignment specification shall specify the same alignment.
- **Rule 8.16** (A): The alignment specification of zero should not appear in an object declaration.
- **Rule 8.17** (A): At most one explicit alignment specifier should appear in an object declaration.
- **Rule 8.18** *(new)* (R): Tentative definitions shall not appear in header files — prevents unintended object duplication across translation units.
- **Rule 8.19** *(new)* (A): An object should be defined at block scope if its identifier appears only in a single function.

### Rule 9 — Initialisation

- **Rule 9.1** (M): The value of an object with automatic storage duration shall not be read before it has been set.
- **Rule 9.2** (R): The initialiser for an aggregate or union shall be enclosed in braces.
- **Rule 9.3** (R): Arrays shall not be partially initialised.
- **Rule 9.4** (R): An element of an object shall not be initialised more than once.
- **Rule 9.5** (R): Where designated initialisers are used, no unspecified elements shall be left.
- **Rule 9.6** *(new)* (A): An initialiser using chained designators should not contain initialisers without designators.
- **Rule 9.7** *(refined)* (M): Atomic objects shall be appropriately initialised before being accessed.

### Rule 10 — The essential type model

- **Rule 10.1** (R): Operands shall not be of an inappropriate essential type.
- **Rule 10.2** (R): Expressions of essentially character type shall not be used inappropriately in addition/subtraction.
- **Rule 10.3** (R): Value of an expression shall not be assigned to an object with a narrower essential type or different essential category.
- **Rule 10.4** (R): Both operands of an operator in which usual arithmetic conversions are performed shall have the same essential type category.
- **Rule 10.5** (A): Value of an expression should not be cast to an inappropriate essential type.
- **Rule 10.6** (R): The value of a composite expression shall not be assigned to an object with wider essential type.
- **Rule 10.7** (R): If a composite expression is used as one operand of an operator in which the usual arithmetic conversions are performed, the other operand shall not have wider essential type.
- **Rule 10.8** (R): The value of a composite expression shall not be cast to a different essential type category or a wider essential type.

### Rule 11 — Pointer type conversions

- **Rule 11.1** (R): Conversions shall not be performed between a pointer to a function and any other type.
- **Rule 11.2** (R): Conversions shall not be performed between a pointer to an incomplete type and any other type.
- **Rule 11.3** (R): A cast shall not be performed between a pointer to object type and a pointer to a different object type.
- **Rule 11.4** (A): A conversion should not be performed between a pointer to object and an integer type.
- **Rule 11.5** (A): A conversion should not be performed from pointer to `void` into pointer to object.
- **Rule 11.6** (R): A cast shall not be performed between pointer to `void` and an arithmetic type.
- **Rule 11.7** (R): A cast shall not be performed between pointer to object and a non-integer arithmetic type.
- **Rule 11.8** (R): A cast shall not remove any `const` or `volatile` qualification from the type pointed to by a pointer.
- **Rule 11.9** (R): The macro `NULL` shall be the only permitted form of integer null pointer constant.
- **Rule 11.10** (R): The `_Atomic` qualifier shall not be applied to a pointer's referenced type — Amd4.
- **Rule 11.11** *(new)* (A): Pointers shall not be implicitly compared to NULL — use explicit `ptr != NULL` not `if (ptr)`.

### Rule 12 — Expressions

- **Rule 12.1** (A): The precedence of operators within expressions should be made explicit.
- **Rule 12.2** (R): The right-hand operand of a shift operator shall lie in the range zero to one less than the width of the essential type of the left-hand operand.
- **Rule 12.3** (A): The comma operator should not be used.
- **Rule 12.4** (A): Evaluation of constant expressions should not lead to unsigned integer wrap-around.
- **Rule 12.5** *(new in C:2023)* (M): The `sizeof` operator shall not have an operand which is a function parameter declared as "array of type".
- **Rule 12.6** *(refined)* (R): Structure and union members of atomic objects shall not be directly accessed.

### Rule 13 — Side effects

- **Rule 13.1** (R): Initialiser lists shall not contain persistent side effects.
- **Rule 13.2** (R): The value of an expression and its persistent side effects shall be the same under all permitted evaluation orders.
- **Rule 13.3** (A): A full expression containing an increment (`++`) or decrement (`--`) operator should have no other potential side effects.
- **Rule 13.4** (A): The result of an assignment operator should not be used.
- **Rule 13.5** (R): The right-hand operand of a logical `&&` or `||` shall not contain persistent side effects.
- **Rule 13.6** (M): The operand of `sizeof` shall not contain any expression which has potential side effects.

### Rule 14 — Control statement expressions

- **Rule 14.1** (R): A loop counter shall not have essentially floating type.
- **Rule 14.2** (R): A `for` loop shall be well-formed.
- **Rule 14.3** (R): Controlling expressions shall not be invariant.
- **Rule 14.4** (R): The controlling expression of an `if` statement or iteration statement shall be essentially Boolean.

### Rule 15 — Control flow

- **Rule 15.1** (A): The `goto` statement should not be used.
- **Rule 15.2** (R): The `goto` statement shall jump to a label declared later in the same function.
- **Rule 15.3** (R): Any label referenced by a `goto` statement shall be declared in the same block as the `goto` or in any block enclosing it.
- **Rule 15.4** (A): There should be no more than one `break` or `goto` statement used to terminate any iteration statement.
- **Rule 15.5** *(disapplied in C:2025)*: A function should have a single point of exit at the end. **Status note:** no longer required by MISRA C:2025; project standards derived from ISO 26262 Part 6 may still enforce for ASIL-C/D.
- **Rule 15.6** (R): The body of an iteration statement or selection statement shall be a compound statement.
- **Rule 15.7** (R): All `if … else if` constructs shall be terminated with an `else` statement.

### Rule 16 — Switch statements

- **Rule 16.1** (R): All `switch` statements shall be well-formed.
- **Rule 16.2** (R): A `switch` label shall only be used when the most closely-enclosing compound statement is the body of a `switch` statement.
- **Rule 16.3** (R): An unconditional `break` statement shall terminate every switch-clause.
- **Rule 16.4** (R): Every `switch` statement shall have a `default` label.
- **Rule 16.5** (R): A `default` label shall appear as either the first or the last switch label.
- **Rule 16.6** (R): Every `switch` statement shall have at least two switch-clauses.
- **Rule 16.7** (R): A `switch` expression shall not have essentially Boolean type.

### Rule 17 — Functions

- **Rule 17.1** (R): The standard header `<stdarg.h>` shall not be used.
- **Rule 17.2** (R): Functions shall not call themselves, either directly or indirectly (no recursion).
- **Rule 17.3** (M): A function shall not be declared implicitly.
- **Rule 17.4** (M): All exit paths from a function with non-`void` return type shall have an explicit `return` statement with an expression.
- **Rule 17.5** (A): The function argument corresponding to a parameter declared to have an array type shall have an appropriate number of elements.
- **Rule 17.6** (M): The declaration of an array parameter shall not contain the `static` keyword between `[]`.
- **Rule 17.7** (R): The value returned by a function having non-`void` return type shall be used.
- **Rule 17.8** (A): A function parameter should not be modified.
- **Rule 17.9** *(refined)* (R): A function declared with a `_Noreturn` function specifier shall not return to its caller.
- **Rule 17.10** *(refined)* (R): A function declared with a `_Noreturn` specifier shall have a `void` return type.
- **Rule 17.11** (A): A function that never returns should be declared with a `_Noreturn` specifier.
- **Rule 17.12** (A): A function identifier should only be used with either a preceding `&`, or with a parenthesised parameter list.
- **Rule 17.13** *(new in C:2023)* (R): A function type shall not be type-qualified.

### Rule 18 — Pointers and arrays

- **Rule 18.1** (R): A pointer resulting from arithmetic on a pointer operand shall address an element of the same array as that pointer operand.
- **Rule 18.2** (R): Subtraction between pointers shall only be applied to pointers that address elements of the same array.
- **Rule 18.3** (R): The relational operators shall not be applied to objects of pointer type except where they point into the same object.
- **Rule 18.4** (A): The `+`, `-`, `+=` and `-=` operators should not be applied to expressions of pointer type.
- **Rule 18.5** (A): Declarations should contain no more than two levels of pointer nesting.
- **Rule 18.6** (R): The address of an object with automatic or thread-local storage shall not be copied to another object that persists after the first object has ceased to exist.
- **Rule 18.7** (R): Flexible array members shall not be declared.
- **Rule 18.8** (R): Variable-length array types shall not be used.
- **Rule 18.9** *(refined)* (R): An object with temporary lifetime shall not undergo array-to-pointer conversion.
- **Rule 18.10** *(new)* (M): Pointers to variably-modified array types shall not be used.

### Rule 19 — Overlapping storage

- **Rule 19.1** (M): An object shall not be assigned or copied to an overlapping object.
- **Rule 19.2** (A): The `union` keyword should not be used.
- **Rule 19.3** *(new)* (R): A union member shall not be read unless it is the current active member — prevents undefined behavior from inactive-member reads.

### Rule 20 — Preprocessing directives

- **Rule 20.1** (A): `#include` directives should only be preceded by preprocessor directives or comments.
- **Rule 20.2** (R): The `'`, `"` or `\` characters and the `/*` or `//` character sequences shall not occur in a header file name.
- **Rule 20.3** (R): The `#include` directive shall be followed by either a `<filename>` or `"filename"` sequence.
- **Rule 20.4** (R): A macro shall not be defined with the same name as a keyword.
- **Rule 20.5** (A): `#undef` should not be used.
- **Rule 20.6** (R): Tokens that look like a preprocessing directive shall not occur within a macro argument.
- **Rule 20.7** (R): Expressions resulting from the expansion of macro parameters shall be enclosed in parentheses.
- **Rule 20.8** (R): The controlling expression of a `#if` or `#elif` preprocessing directive shall evaluate to 0 or 1.
- **Rule 20.9** (R): All identifiers used in the controlling expression of `#if` or `#elif` preprocessing directives shall be `#define`'d before evaluation.
- **Rule 20.10** (A): The `#` and `##` preprocessor operators should not be used.
- **Rule 20.11** (R): A macro parameter immediately following a `#` operator shall not immediately be followed by a `##` operator.
- **Rule 20.12** (R): A macro parameter used as an operand to the `#` or `##` operators, which is itself subject to further macro replacement, shall only be used as an operand to these operators.
- **Rule 20.13** (R): A line whose first token is `#` shall be a valid preprocessing directive.
- **Rule 20.14** (R): All `#else`, `#elif` and `#endif` preprocessor directives shall reside in the same file as the `#if`, `#ifdef` or `#ifndef` directive to which they are related.

### Rule 21 — Standard libraries

- **Rule 21.1** (R): `#define` and `#undef` shall not be used on a reserved identifier or reserved macro name.
- **Rule 21.2** (R): A reserved identifier or reserved macro name shall not be declared.
- **Rule 21.3** (R): The memory allocation and deallocation functions of `<stdlib.h>` shall not be used (`malloc`, `calloc`, `realloc`, `free`).
- **Rule 21.4** (R): The standard header `<setjmp.h>` shall not be used.
- **Rule 21.5** (R): The standard header `<signal.h>` shall not be used.
- **Rule 21.6** (R): The Standard Library input/output routines shall not be used (`<stdio.h>`).
- **Rule 21.7** (R): The Standard Library functions `atof`, `atoi`, `atol`, `atoll` of `<stdlib.h>` shall not be used.
- **Rule 21.8** (R): The Standard Library termination functions of `<stdlib.h>` shall not be used.
- **Rule 21.9** (R): The Standard Library functions `bsearch` and `qsort` of `<stdlib.h>` shall not be used.
- **Rule 21.10** (R): The Standard Library time and date functions shall not be used.
- **Rule 21.11** (R): The standard header `<tgmath.h>` shall not be used.
- **Rule 21.12** (A): The exception handling features of `<fenv.h>` should not be used.
- **Rule 21.13** (M): Any value passed to a function in `<ctype.h>` shall be representable as `unsigned char` or be `EOF`.
- **Rule 21.14** (R): The Standard Library function `memcmp` shall not be used to compare null-terminated strings.
- **Rule 21.15** (R): The pointer arguments to the Standard Library functions `memcpy`, `memmove`, `memcmp` shall be pointers to qualified or unqualified versions of compatible types — Amd1 security.
- **Rule 21.16** (R): The pointer arguments to the Standard Library function `memcmp` shall point to either a pointer type, an essentially signed type, an essentially unsigned type, an essentially Boolean type or an essentially enum type.
- **Rule 21.17** (R): Use of the string-handling functions from `<string.h>` shall not result in accesses beyond the bounds of the objects referenced by their pointer parameters — Amd1 security.
- **Rule 21.18** (R): The `size_t` argument passed to any function in `<string.h>` shall have an appropriate value.
- **Rule 21.19** (M): The pointers returned by the Standard Library functions `localeconv`, `getenv`, `setlocale` or `strerror` shall only be used as if they have pointer to `const`-qualified type.
- **Rule 21.20** (M): The pointer returned by the Standard Library functions `asctime`, `ctime`, `gmtime`, `localtime`, `localeconv`, `getenv`, `setlocale` or `strerror` shall not be used following a subsequent call to the same function.
- **Rule 21.21** (R): The Standard Library function `system` of `<stdlib.h>` shall not be used.
- **Rule 21.22** (M): All operand arguments to any type-generic macros in `<tgmath.h>` shall have an appropriate essential type.
- **Rule 21.23** (R): All operand arguments to any multi-argument type-generic macros in `<tgmath.h>` shall have the same standard type.
- **Rule 21.24** (R): The random number generator functions of `<stdlib.h>` shall not be used.
- **Rule 21.25** (R): All memory synchronisation operations shall be executed in sequentially consistent order — Amd4.
- **Rule 21.26** (R): The Standard Library function `mtx_timedlock` shall only be invoked on mutex objects of appropriate mutex type — Amd4.

### Rule 22 — Resources

- **Rule 22.1** (R): All resources obtained dynamically shall be explicitly released.
- **Rule 22.2** (M): A block of memory shall only be freed if it was allocated by means of a Standard Library function.
- **Rule 22.3** (R): The same file shall not be open for read and write access at the same time on different streams.
- **Rule 22.4** (M): There shall be no attempt to write to a stream which has been opened as read-only.
- **Rule 22.5** (M): A pointer to a `FILE` object shall not be dereferenced.
- **Rule 22.6** (M): The value of a pointer to a `FILE` shall not be used after the associated stream has been closed.
- **Rule 22.7** (R): The macro `EOF` shall only be compared with the unmodified return value from any Standard Library function capable of returning `EOF`.
- **Rule 22.8** (R): The value of `errno` shall be set to zero prior to a call to an `errno`-setting function — Amd1 security.
- **Rule 22.9** (R): The value of `errno` shall be tested against zero after calling an `errno`-setting function — Amd1 security.
- **Rule 22.10** (R): The value of `errno` shall only be tested when the last function to be called was an `errno`-setting function — Amd1 security.
- **Rule 22.11** (R): A thread that was previously either joined or detached shall not be subsequently joined nor detached — Amd4.
- **Rule 22.12** (M): Thread objects, thread synchronisation objects and thread-specific storage pointers shall only be accessed by the appropriate Standard Library functions — Amd4.
- **Rule 22.13** (R): Thread objects, thread synchronisation objects and thread-specific storage pointers shall have appropriate storage duration — Amd4.
- **Rule 22.14** (M): Thread synchronisation objects shall be initialised before being accessed — Amd4.
- **Rule 22.15** (R): Thread synchronisation objects and thread-specific storage pointers shall not be destroyed until after all threads accessing them have terminated — Amd4.
- **Rule 22.16** (R): All mutex objects locked by a thread shall be explicitly unlocked by the same thread — Amd4.
- **Rule 22.17** (R): No thread shall unlock a mutex or call `cnd_wait` or `cnd_timedwait` for a mutex it has not locked before — Amd4.
- **Rule 22.18** (R): Non-recursive mutexes shall not be recursively locked — Amd4.
- **Rule 22.19** (R): A condition variable shall be associated with at most one mutex object — Amd4.
- **Rule 22.20** (M): Thread-specific storage pointers shall be created before being accessed — Amd4.

---

## C:2025 quick-reference summary

**Additions (4 new rules):**
| Rule    | Cat | Topic                                                  |
|---------|-----|--------------------------------------------------------|
| 8.18    | R   | No tentative definitions in headers                    |
| 8.19    | A   | Block-scope object definition preferred                |
| 11.11   | A   | No implicit pointer-to-NULL comparison                 |
| 19.3    | R   | No inactive union member read                          |

**Disapplied (1 rule):**
- **15.5** — single-exit-point no longer enforced by MISRA C:2025.

**Refined (selected from 69 total):**
- 7.5, 7.6 (integer constant macros), 9.7 (atomic init), 12.6 (atomic member access), 17.9, 17.10 (`_Noreturn`), 18.9 (temporary array decay), 18.10 (new mandatory: VLA-type pointers).

---

## Tool-flow notes

| Tool             | C:2025 support status                                                  |
|------------------|------------------------------------------------------------------------|
| Helix QAC        | Native C:2025 ruleset since QAC 2024.2 — most precise built-in support |
| Polyspace Bug Finder | C:2023 + Amd4 rules covered; C:2025 deltas planned                |
| LDRA Testbed     | C:2023 with C:2025 deltas via update packs                             |
| PC-lint Plus     | Configurable rule pack; check vendor for C:2025 add-on                 |

When a project pins to C:2023, the four C:2025 additions and the 15.5 disapplication are the deltas to surface in any review or deviation report.
