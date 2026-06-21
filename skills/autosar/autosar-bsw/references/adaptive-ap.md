# Adaptive AUTOSAR (AP) variant - platform services and communication

Use this when the input names Adaptive AUTOSAR (AP): ara::com, ara::exec, ara::diag, ara::per, C++14+, POSIX/Linux/QNX, service-oriented (SOA), manifests, Execution Management, or State Management.

AP has no BSW layer and no COM stack. The Classic BSW concerns map onto ara:: Functional Clusters provided by the Adaptive Platform Foundation and Services. Communication is service-oriented over SOME/IP or DDS, not signal-based over CAN PDUs. Configuration is by JSON/ARXML manifests deployed per machine and per executable, not by static EB Tresos / DaVinci ECU config.

## Classic-to-Adaptive mapping

| Classic concern | Adaptive equivalent | Notes |
|---|---|---|
| Com / PduR (signals, I-PDUs) | ara::com (services, events, methods, fields) | proxy on consumer, skeleton on provider; service discovery; transport binding SOME/IP or DDS |
| Dcm / Dem (UDS, DTCs) | ara::diag | diagnostic server, DTCs, operation/monitor, ara::diag::DTCInformation |
| NvM / MemIf / Fee (persistence) | ara::per | key-value storage and file storage, redundancy/CRC via per config |
| Os (tasks, schedule, ExclusiveArea) | ara::exec + POSIX scheduling | Execution Management starts/stops processes; State/Function-Group state; threads, not OS tasks |
| Wdg (watchdog) | ara::phm (Platform Health Management) | supervised entities, alive/deadline/logical supervision |
| Det / Dlt | ara::log | severity-leveled logging, not DET hooks |

## Modes (AP)

### Service configuration (replaces BSW configuration)

1. Identify the service interface(s): events, methods, fields. Define in the service interface description (ARXML) and the deployment manifest (SOME/IP service ID, instance ID, event/method IDs).
2. Decide transport binding: SOME/IP (signal-based service binding, service discovery on UDP) or DDS.
3. Provider: implement the skeleton, OfferService(), set fields, Send() events. Consumer: FindService() / StartFindService(), create the proxy, Subscribe() to events, call methods (returning ara::core::Future).
4. Persistence: declare ara::per key-value or file storage in the manifest; access via OpenKeyValueStorage / OpenFileStorage.
5. Diagnostics: configure ara::diag DTCs and the diagnostic server manifest; map monitors to events.
6. Produce a manifest checklist and flag common deployment errors (mismatched service/instance IDs, missing service discovery, machine vs executable manifest scope).

### Manifest debugging (replaces ARXML debugging)

1. Classify the error: service/instance ID mismatch between provider and consumer manifests; missing required-port to provided-port binding; network endpoint (IP/port) wrong; transport binding mismatch (SOME/IP vs DDS); data type mismatch in the service interface.
2. Locate it in the right manifest scope: Machine Manifest (machine-wide, network, ara::com transport), Execution Manifest (per process, startup, state dependency), Service Instance Manifest (service-to-instance mapping).
3. Provide the corrected manifest fragment and a prevention rule.

### Startup / execution troubleshooting (replaces RTE generation troubleshooting)

There is no RTE generation in AP. The analogous failures are Execution Management and binding failures:
1. Process does not start: Execution Manifest startup config, dependency on a Function-Group state not reached, missing resource/permission.
2. Service not discovered: service discovery not running, service/instance ID mismatch, network down, firewall/multicast for SOME/IP-SD.
3. Method call hangs or throws: ara::core::Future timeout, skeleton not offering, ara::com error (kServiceNotAvailable). Inspect the ara::com::ErrorCode.
4. Give the exact manifest field or ara::com call to fix and a post-fix validation step.

### Service communication debugging (replaces COM stack debugging)

1. Classify symptom: event not received (subscription, offer, discovery), wrong value (serialization / data type / endianness in SOME/IP), intermittent (network loss, QoS), method error (Future error code).
2. Confirm network level first: capture SOME/IP or DDS traffic (Wireshark with the SOME/IP dissector, or DDS spy). Check service discovery (Offer/Subscribe/SubscribeAck) before blaming the application.
3. Walk the path: provider skeleton Offer/Send -> transport (SOME/IP-SD + serialization) -> consumer proxy Subscribe + event receive handler. This replaces the CanIf -> PduR -> Com layer-walk.
4. Probe with ara::log at each stage; inspect ara::core::Result / ErrorCode rather than DET hooks.
5. Common anti-patterns: service/instance ID mismatch; consumer subscribes before provider offers and never retries; serialization config mismatch (alignment, endianness, struct order) between provider and consumer; QoS/reliability mismatch in DDS.

## Output format (AP)

Begin with `Platform: Adaptive (AP)`. Then use the matching layout:

### Service configuration
```
## Service Configuration: <Service/Interface>

### Service Interface
[events / methods / fields, with SOME/IP or DDS binding]

### Deployment Manifest
| Manifest | Field | Value | Notes |
|----------|-------|-------|-------|

### Provider / Consumer Steps
[skeleton Offer + Send ; proxy Find + Subscribe + call]

### Common Errors & Resolutions
| Error | Root Cause | Fix |

### Validation Checklist
- [ ] ...
```

### Manifest debug / startup / communication
```
## AP Debug Report

### Classification
[event-not-received | wrong-value | method-error | startup | manifest-mismatch]

### Network/Discovery Confirmation
[SOME/IP-SD or DDS capture - service offered? subscribed? acked?]

### Path Walk
| Stage | Check | Expected | Observed / Next Probe |
|-------|-------|----------|------------------------|
| Provider skeleton | Offer/Send | ... | ... |
| Transport (SOME/IP/DDS) | discovery + serialization | ... | ... |
| Consumer proxy | Subscribe + handler | ... | ... |

### Most Likely Root Cause
[manifest field or ara:: call + one-sentence why]

### Fix
[corrected manifest fragment or ara:: code change]

### Safety Impact
[None / ASIL-X - re-verification scope]

### Prevention Rule
[one line]
```
