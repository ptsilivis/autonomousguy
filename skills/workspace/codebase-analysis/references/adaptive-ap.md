# Adaptive AUTOSAR (AP) variant - mapping an Adaptive codebase

Use this when step 0 detects an Adaptive AUTOSAR repo: C++14+, CMake, ara:: usage, manifests, POSIX/Linux/QNX.

AP has no SWCs, ports, runnables, RTE, or BSW. Map the equivalent AP concepts instead, keeping the same CODEBASE_MAP.md spirit (durable per-component map other skills reference).

## What to scan for

- **Adaptive Applications**: each is a process/executable. Find them from CMake targets, `main()` entry points, and execution manifests. Record name, source dir, and the services it provides/consumes.
- **Service interfaces (ara::com)**: events, methods, fields. Find from generated proxy/skeleton headers and service interface descriptions. Record data types and binding (SOME/IP or DDS), service ID and instance ID.
- **Functional-cluster usage**: which ara:: clusters each app uses - ara::com (communication), ara::exec (Execution Management / lifecycle), ara::diag (diagnostics, replaces Dcm/Dem), ara::per (persistency, replaces NvM), ara::log (logging), ara::phm (health/watchdog). Record the concrete API surface (e.g. `OfferService`, `Subscribe`, `Send`, method calls, `OpenKeyValueStorage`).
- **Manifests**: Machine Manifest (network, transport), Execution Manifest (per process startup, Function-Group state deps), Service Instance Manifest (service-to-instance binding). Record key IDs and dependencies.
- **Requirement IDs**: same patterns as Classic (SW-REQ-*, REQ-*, FSR-*, SYS-REQ-*, Doxygen `@req`/`@trace`), scanned in C++ sources and docs.
- **ASIL zones**: from annotations, partitioning, and which Function-Groups/processes are safety-relevant.

## CODEBASE_MAP.md structure (AP)

```markdown
# Codebase Map - <Project Name> (Adaptive AUTOSAR)
Generated: <date>

## Platform
Adaptive AUTOSAR (AP). Target: <Linux/QNX>. Toolchain/stack: <vendor AP stack>. Transport: SOME/IP | DDS.

## Overview
[One paragraph: compute node function, OS, AP stack, ASIL, requirements toolchain]

## Repository Structure
[Key dirs, CMake layout, where manifests and service interfaces live]

## Adaptive Applications
- **<AppName>** - provides: <services>; consumes: <services>; clusters: ara::com, ara::per, ...

---

## Per-Application Detail

### Application: <AppName>
- **Executable / source dir**: ...
- **ASIL**: QM/A/B/C/D
- **Function-Group state dependency** (ara::exec): ...

##### Software Requirements
| Requirement ID | Source | Notes |

##### Service Interfaces
| Service | Role (provide/consume) | Element (event/method/field) | Data Type | Binding | Service/Instance ID |

##### Functional Cluster Usage
| Cluster | APIs Used | Purpose |
| ara::com | OfferService, Send, Subscribe | event provider/consumer |
| ara::per | OpenKeyValueStorage | persistence |
| ara::diag | DTC, monitor | diagnostics |
| ara::exec | ReportExecutionState | lifecycle |

##### Manifests
- Execution Manifest: startup, state deps
- Service Instance Manifest: service -> instance binding

(Repeat per Adaptive Application.)

---

## Cross-Cutting Maps

### Service Flow
Plain-text box-and-arrow: applications as boxes, arrows labeled with service interface + event/method and `[SOME/IP]` or `[DDS]`.

### Functional Cluster Map
| Cluster | Used By Apps | Notes |

### ASIL Zone Map
| Zone | ASIL | Apps / Function-Groups | Notes |

## Architectural Concerns
- service/instance ID mismatches, missing offers, ignored ara::core::Result, serialization mismatches, MISRA C used where MISRA C++ applies, etc.
```
