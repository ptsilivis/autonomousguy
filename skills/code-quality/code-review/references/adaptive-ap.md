# Adaptive AUTOSAR (AP) C++14 review variant

Use when the code is C++14+ or names ara:: APIs. AP code is governed by the AUTOSAR C++14 Coding Guidelines and MISRA C++:2023, not MISRA C. Keep the same Critical/Major/Minor output format; swap in these concerns.

## Correctness review (AP)

1. **Error handling**: prefer `ara::core::Result` / `ara::core::Future` and `ara::core::ErrorCode`; check that Results are not ignored (no discarded error). Exceptions only where the project profile allows; if exceptions are banned, flag `throw`/unguarded throwing calls.
2. **Resource management (RAII)**: every owned resource wrapped in an object with a destructor; no raw `new`/`delete` in application code; use `std::unique_ptr`/`std::shared_ptr`. Flag manual lifetime management and leaks.
3. **Concurrency**: ara::com event handlers and method calls run on framework threads. Flag shared mutable state without `std::mutex`/`std::atomic`; flag blocking calls inside callbacks; check `Future::then` continuations for data races. No ISR/volatile model here.
4. **ara::com usage**: provider Offers before consumers rely on the service; consumer handles `kServiceNotAvailable` and re-discovery; method calls treat `Future` timeouts.
5. **Type safety**: prefer fixed-width and `ara::core` types for serialized data; watch implicit conversions and narrowing (`{}` init); `enum class` over plain enum.
6. **Determinism / safety**: dynamic allocation is allowed in AP but flag it on hot/safety paths; bounded execution where ASIL applies; avoid exceptions across ABI boundaries.
7. **Dependency injection / lifecycle**: ara::exec lifecycle (ReportExecutionState), clean shutdown, no work before initialization.

## Naming review (AP)

Apply AUTOSAR C++14 / MISRA C++ conventions (replaces the Classic C identifier rules):
- Types (class/struct/enum class): `UpperCamelCase` (e.g. `BrakeService`, `VehicleSpeedProxy`).
- Functions and methods: `UpperCamelCase` per AUTOSAR C++14 (or the project's chosen style - state which); be consistent.
- Variables: `lowerCamelCase`; member variables with a trailing `_` or `m` prefix per the project profile.
- Constants / constexpr: `kUpperCamelCase` or `UPPER_SNAKE` per profile.
- Namespaces: lowercase; respect `ara::` cluster namespaces.
- No Hungarian/`g_`/`s_` storage-class prefixes from the Classic C scheme; use scope and `const` instead.
- Service interface elements (events/methods/fields) match the service interface description names.

When auditing: flag identifiers and constructs that violate the above and give the corrected form. When generating: produce a C++14 naming scheme for the described element set.

## Output

Begin with `Platform: Adaptive (AP)`. Use the same `## Embedded C++ Code Review` layout with Critical/Major/Minor findings and the summary table, and the same naming-review table format.
