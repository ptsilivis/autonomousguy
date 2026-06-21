# Adaptive AUTOSAR (AP) variant - Adaptive Applications and ara::com services

Use this when the input names Adaptive AUTOSAR (AP): ara::com, ara::exec, C++14+, POSIX/Linux/QNX, service-oriented (SOA), manifests, proxy/skeleton, or Adaptive Application.

AP replaces the static SWC/RTE/ARXML model with dynamic, service-oriented Adaptive Applications running as POSIX processes on the Adaptive Platform. There are no SWCs, ports, runnables, RTE, or ExclusiveAreas. You design service interfaces (events, methods, fields), implement provider skeletons and consumer proxies in C++14+, and deploy via manifests. Coding follows the AUTOSAR C++14 Guidelines / MISRA C++:2023, not MISRA C.

## Classic-to-Adaptive mapping

| Classic concept | Adaptive equivalent |
|---|---|
| SWC type (App/Sensor/Actuator/Service/CDD) | Adaptive Application (a process); functional clusters provide platform services |
| Port (P/R) + PortInterface | Provided/Required service instance + service interface |
| SenderReceiver DataElement | ara::com event (Send/Subscribe) or field (with on-change notify) |
| ClientServer Operation | ara::com method (returns ara::core::Future) |
| ModeSwitch | field, or Function-Group state via ara::exec State Management |
| Parameter interface | configuration via manifest / ara::per |
| RTE API (Rte_Read/Write/Call) | proxy/skeleton API: event Send/Subscribe, method call, field Get/Set |
| Runnable on TimingEvent | application thread / timer; ara::exec lifecycle |
| ExclusiveArea | standard C++ synchronization (std::mutex), RAII |
| ARXML SWC + InternalBehavior | service interface description + deployment/execution manifests |
| AUTOSAR platform types (uint8, sint16) | C++ fixed-width types and ara::core types; std:: containers allowed |

## Modes (AP)

### Component design -> Adaptive Application + service design
1. Decompose the feature into Adaptive Applications (processes) and the services each provides or consumes.
2. Define each service interface: events, methods, fields, with data types.
3. Decide transport binding (SOME/IP or DDS) and service/instance IDs.
4. Note ASIL, Function-Group state dependencies (ara::exec), and which functional clusters are used (ara::per, ara::diag, ara::log, ara::phm).
5. Produce a plain-text deployment diagram: applications as boxes, service connections as arrows labeled with the service interface and binding.

### Interface definition -> service interface specification
1. Specify each element: event (data type, notification), method (IN/OUT params, ara::core::ErrorDomain for errors), field (data type, hasGetter/hasSetter/hasNotifier).
2. Choose C++ data types; for serialization note alignment/endianness in the SOME/IP binding.
3. Output: the service interface (ARXML/IDL sketch) and the matching C++ proxy/skeleton header expectations.

### SWC development -> Adaptive Application skeleton
1. Generate a C++14 skeleton: provider implements the generated Skeleton class, calls OfferService(), Send()s events, sets fields, registers method handlers returning ara::core::Future. Consumer uses FindService()/StartFindService(), constructs the Proxy, Subscribe()s to events with a receive handler, calls methods.
2. Use RAII, ara::core::Result/Future for error handling (no raw error codes), smart pointers, std:: containers. Follow AUTOSAR C++14 / MISRA C++:2023 style.
3. Provide the deployment manifest and execution manifest sketch (service/instance IDs, startup, Function-Group state).

### Diagram generation
Same plain-text box-and-arrow rules as Classic, but layers are: Adaptive Application(s) / ara:: Functional Clusters / OS (POSIX) / Hardware. Arrows carry service interface + event/method names and `[SOME/IP]` or `[DDS]`. No RTE layer.

### Integration review
Audit C++ source and manifests for: service/instance ID consistency between provider and consumer; correct proxy/skeleton API use; ara::core::Result/Future error handling (not ignored); Offer before consumers expect it; serialization config match; AUTOSAR C++14 naming and MISRA C++ style; no direct hardware access (route through the proper functional cluster or driver process). Flag use of MISRA C (wrong standard) or Classic RTE APIs in AP code.

## Output format (AP)

Begin with `Platform: Adaptive (AP)`. Mirror the Classic section headers but with AP terms, e.g.:
```
## Adaptive Application Design

### Feature Decomposition
[applications/processes and the services each provides/consumes]

### Service Inventory
| Service Interface | Provider App | Consumer App(s) | Binding | ASIL |

### Service Interface Spec
[events / methods / fields with C++ types]

### Skeleton/Proxy Notes
[Offer/Send/Subscribe/method-call snippets; ara::core::Future error handling]

### Manifests
[service instance IDs, execution manifest, Function-Group state]
```
For interface definition, SWC development, diagram, and integration review, reuse the corresponding Classic layout name with AP content.
