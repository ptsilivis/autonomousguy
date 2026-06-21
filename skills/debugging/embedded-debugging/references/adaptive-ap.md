# Adaptive AUTOSAR (AP) debugging variant - POSIX / ara:: fault catalog

Use when the input names POSIX/Linux/QNX, ara::, C++, segfault, core dump, or Execution/State Management. AP runs as POSIX processes on an application processor; the Classic MCU fault model (HardFault, CFSR decode, watchdog kick, AUTOSAR OS ProtectionHook, TRACE32-on-MCU) does not apply. Keep the same Problem-report triage and Targeted fault debugging output structure; swap in this catalog and tooling.

## Tooling (AP)

- gdb / gdbserver on the application processor; load core dumps (`coredumpctl`, `/var/lib/systemd/coredump`, or QNX dumper).
- ara::log output (DLT viewer) instead of DET hooks.
- AddressSanitizer / UndefinedBehaviorSanitizer / Valgrind for memory faults; perf / top for CPU and timing.
- Wireshark (SOME/IP dissector) or DDS spy for service communication faults.
- Execution Management / State Management logs for restart and Function-Group state issues.

## Symptom classification (AP)

- **Process crash**: SIGSEGV (null/dangling pointer, bad cast), SIGABRT (assert, uncaught exception, std::terminate), SIGFPE.
- **Restart loop**: Execution Management keeps restarting a process that exits non-zero; check exit code and ara::exec ReportExecutionState.
- **Communication failure**: ara::com event not received, method `Future` timeout, `kServiceNotAvailable`, serialization mismatch.
- **Resource failure**: memory leak / OOM (killed by OOM killer), file-descriptor leak, ara::per storage error/corruption.
- **Timing failure**: missed deadline under load, thread starvation, priority inversion (POSIX scheduling).
- **State failure**: wrong Function-Group state, startup ordering / dependency not met.

## Common fault -> root cause mapping (AP)

- **SIGSEGV**: dereferencing an empty `ara::core::Optional`/expired `shared_ptr`, use-after-free, out-of-bounds on `std::vector`. Load core in gdb, `bt`, inspect the faulting frame; run under ASan to pinpoint.
- **Uncaught exception / SIGABRT**: ignored `ara::core::Result` that was an error then `.Value()` called; check `terminate` handler and the throwing call. If exceptions are banned by profile, the throwing API is the bug.
- **Restart loop**: process exits before reporting kRunning, or a startup dependency (required service, Function-Group state) is never satisfied. Inspect Execution Manifest and EM logs.
- **Service not available**: provider not offering, service/instance ID mismatch, discovery (SOME/IP-SD multicast) blocked, consumer not retrying. Capture SOME/IP traffic.
- **Memory growth / OOM**: leak (missing RAII, cyclic shared_ptr), unbounded queue/container. Confirm with Valgrind/ASan and heap profiling.
- **Missed deadline**: blocking call in a callback thread, lock contention, wrong POSIX scheduling policy/priority. Profile with perf; check thread priorities and mutex hold times.

## Output (AP)

Begin with `Platform: Adaptive (AP)`. Use the same `## Problem Report Analysis` or `## Targeted Debugging: <Fault Type>` layout, but populate Affected Elements with Adaptive Applications / functional clusters, give gdb/core/ara::log/ASan steps (not register reads or OS counters), and inspect C++/ara:: code patterns.
