
# **External Progression Model v0**

Status: promoted-track / proof-backed research intake
Author: `[Igniter-Lang Compiler/Grammar Expert]`  
Date: 2026-05-10  
Source: runtime/loop semantics exploration

---

## **Disposition**

Date: 2026-05-11
Owner: `[Igniter-Lang Research Agent]`
Status: `promoted-track`

Destination:

```text
igniter-lang/docs/tracks/external-progression-runtime-model-v0.md
```

Proof:

```text
igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model.rb
```

Summary:

```text
The external progression hypothesis is proof-coherent and materially expands
Igniter-Lang runtime modeling beyond hidden eager loop execution. Keep this
source as inbox archaeology until the next cleanup point.
```

---

## **1. Problem**

Current managed-loop theory in Igniter-Lang still models repetition as an  
internal control-flow construct:

```igniter
loop tick in clock.every(5.seconds) {
  ProcessTick(tick)
}
```

Even with managed loops, the semantic model still implies:

```text
runtime repeatedly executes loop body
```

This preserves an imperative mental model:

- hidden scheduler
- hidden repetition
- hidden progression semantics
- loop-as-execution

For service systems, mesh systems, realtime coordination, and replayable  
temporal systems, this becomes increasingly awkward.

The runtime already behaves more like:

- event materialization
- queue progression
- reactive scheduling
- temporal step execution

than a traditional imperative loop.

---

## **2. Hypothesis**

Repetition should not be modeled as:

```text
execute body repeatedly
```

but as:

```text
declare a potentially infinite progression of events
```

This changes the ontology:

|**Traditional loop**|**External progression**|
|---|---|
|imperative repetition|declarative temporal progression|
|eager execution|lazy materialization|
|hidden scheduler|explicit progression source|
|loop body|progression handler|
|mutable loop state|event/step receipts|
|“run forever”|“produce potential future events”|

---

## **3. Core Idea**

Introduce an external progression construct.

Instead of:

```igniter
loop tick in clock.every(5.seconds) {
  ProcessTick(tick)
}
```

the language surface becomes:

```igniter
service contract SwarmCoordinator
  driven by clock.every(5.seconds)
{
  ProcessTick(tick)
}
```

or:

```igniter
service contract SwarmCoordinator
  progression clock.every(5.seconds)
{
  ProcessTick(tick)
}
```

The progression source:

- does not execute eagerly
- does not recursively call the body
- produces a potentially infinite stream of future events

The runtime materializes events on demand.

---

## **4. Runtime Consequence**

The runtime model changes from:

```text
while true:
  body()
```

to:

```text
ProgressionSource
  -> EventMaterializer
  -> EventQueue
  -> StepExecutor
  -> ReceiptSink
```

The loop itself becomes declarative.

The runtime owns:

- scheduling
- throttling
- backpressure
- cancellation
- replay
- distribution
- checkpointing

The language owns:

- progression declaration
- step semantics
- receipts
- liveness policy
- bounded execution rules

---

## **5. New Semantic Distinction**

### **Loop**

Imperative repetition.

```text
Loop = eager repeated execution
```

### **Progression**

Declarative temporal event source.

```text
Progression = potentially infinite declarative event sequence
```

---

## **6. Potential Language Surface**

### **Service progression**

```igniter
service contract Monitor
  driven by sensor_stream
{
  Analyze(signal)
}
```

### **Clock progression**

```igniter
service contract Heartbeat
  progression clock.every(1.second)
{
  EmitHeartbeat(tick)
}
```

### **Queue progression**

```igniter
service contract JobWorker
  progression work_queue
{
  ProcessJob(job)
}
```

### **Mesh progression**

```igniter
service contract SwarmConsensus
  progression swarm_events
{
  Reconcile(event)
}
```

---

## **7. Why This Matters**

### **A. Eliminates hidden infinite execution semantics**

The language no longer implies:

- recursive runtime looping
- hidden scheduler ownership
- implicit eager execution

### **B. Aligns with event-sourced/runtime-replay systems**

The runtime already behaves like:

- progression materializer
- queue executor
- receipt producer

This model exposes the truth directly.

### **C. Better fit for distributed systems**

Progressions:

- shard naturally
- replay naturally
- checkpoint naturally
- suspend naturally
- migrate naturally

Traditional imperative loops do not.

### **D. Better fit for Igniter philosophy**

This aligns with:

- Managed Recursion Doctrine
- Honest Computing Doctrine
- Explicit Time
- Receipt-first execution
- No Hidden Consequences

---

## **8. Relationship To Streams**

External progression is not identical to Stream[T].

A stream is data flow.

A progression is temporal execution potential.

Relationship:

```text
Progression may consume streams
Progression may emit streams
Progression itself is runtime temporal structure
```

---

## **9. Step Semantics**

Each materialized progression event produces:

```igniter
receipt ProgressionStepReceipt {
  progression: ProgressionRef
  event_id: String

  scheduled_at: Timestamp
  started_at: Timestamp
  finished_at: Timestamp

  outcome:
    :completed |
    :failed |
    :timeout |
    :cancelled |
    :skipped

  artifact_hash: Hash
}
```

This turns repetition into:

- replayable
- auditable
- inspectable
- bounded temporal execution

---

## **10. Open Questions**

### **Q1 — Is progression a replacement for loops or an additional class?**

Possibilities:

```text
loop         = eager local repetition
progression  = declarative runtime-managed repetition
```

or:

```text
all service loops become progression-based
```

### **Q2 — Is progression syntax top-level only?**

Allowed:

```igniter
service contract ...
```

Forbidden:

```igniter
nested progression inside pure contract
```

?

### **Q3 — Does progression imply laziness?**

Current hypothesis:

```text
yes
```

Progressions are materialized only under runtime demand/scheduling.

### **Q4 — Relationship to managed recursion?**

Possible mapping:

```text
recursive contract = finite structural progression
service progression = infinite liveness progression
```

### **Q5 — Is progression runtime-only or part of SemanticIR?**

Current hypothesis:

```text
part of SemanticIR
```

because:

- replay
- receipts
- compatibility
- audit
- runtime guarantees  
  all depend on it.

---

## **11. Architectural Consequence**

This potentially shifts Igniter runtime architecture toward:

```text
Progression Runtime
```

instead of:

- imperative scheduler
- hidden service loops
- callback runtime

The runtime becomes:

- event materializer
- temporal progression engine
- accountable step executor

---

## **12. Preliminary Assessment**

This direction appears highly aligned with:

- realtime systems
- mesh systems
- distributed execution
- replayable systems
- audit-heavy systems
- service contracts
- swarm coordination
- event-sourced execution

The model may provide a cleaner semantic foundation than traditional imperative  
loop constructs for Igniter-Lang.

However:

- grammar
- runtime ownership
- progression lifecycle
- backpressure semantics
- stream integration
- cancellation semantics  
  remain unresolved.

---

## **13. Recommended Next Slice**

```text
Track:
external-progression-runtime-model-v0

Goal:
- compare loop vs progression semantics
- model runtime materialization lifecycle
- define progression receipts
- define cancellation/checkpoint/replay semantics
- determine whether service contracts should become progression-native

Role:
[Igniter-Lang Research Agent]

Pressure domains:
- swarm coordination
- realtime video processing
- telemetry ingestion
- long-lived service orchestration
```

---

## **Handoff**

```text
[Igniter-Lang Compiler/Grammar Expert]

[D]
- External progression is a distinct semantic model from imperative looping.
- Repetition may be better modeled as declarative temporal progression.
- Service contracts are the strongest candidate surface.

[S]
- Strong alignment with Managed Recursion and Honest Computing doctrines.
- Strong fit for replayable and mesh-distributed runtimes.

[R]
- Runtime materialization semantics unresolved.
- Relationship to Stream[T] unresolved.
- Cancellation/backpressure semantics unresolved.

[Q]
- Should progression replace service loops?
- Is progression a SemanticIR primitive?
- Can progression exist outside service contracts?

[Route]
- Research Agent:
  external-progression-runtime-model-v0
```
