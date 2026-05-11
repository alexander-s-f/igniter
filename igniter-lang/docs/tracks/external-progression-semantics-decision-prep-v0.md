# Track: External Progression Semantics Decision Prep v0

Card: S3-R33-C5-P
Agent: `[Igniter-Lang Research Agent #2]`
Role: research-agent
Track: `external-progression-semantics-decision-prep-v0`
Status: done
Date: 2026-05-11

---

## Goal

Prepare a formal decision brief for external progression semantics from the
promoted inbox/runtime model, without implementation, grammar work, or runtime
authorization.

Read set:

```text
docs/inbox/runtime-loop-semantics-exploration.md
docs/tracks/external-progression-runtime-model-v0.md
docs/spec/ch13-managed-recursion.md
docs/dev/semantic-governance-heat-map.md
docs/proposals/PROP-023-stream-input-surface-v0.md
docs/spec/ch6-semanticir.md
docs/spec/ch9-stage2-reserved.md
```

---

## Decision Brief

[D] External progression should be treated as a separate semantic primitive for
runtime-managed temporal event potential, not as a replacement for all managed
loops.

Recommended classification:

```text
Finite / structural / fuel / convergent loops:
  remain managed local repetition classes.

Service loop:
  should become a service-facing surface over progression semantics.

External progression:
  a separate primitive for declarative event potential, bounded materialization,
  step receipts, cancellation, checkpoint/resume, and backpressure.
```

The useful sentence:

```text
service loop is the surface; progression is the semantic substrate.
```

This keeps Chapter 13's managed recursion doctrine intact while replacing the
imperative mental model for long-lived service execution.

---

## Comparison

| Model | Language meaning | Runtime role | Decision |
| --- | --- | --- | --- |
| Traditional managed loop | Local repetition with termination/convergence/fuel proof | Executes bounded local steps | Keep. This is still the right model for finite, structural, fuel-bounded, and convergent cases. |
| Service loop | Alive-by-liveness contract: stoppable, observable, bounded per step | Currently reads like repeated body execution with heartbeat/checkpoint obligations | Refactor semantically. Service loop should lower to progression obligations rather than imply eager looping. |
| External progression | Declarative event potential; materialized only under bounded demand/schedule | Event materializer creates step events; executor emits receipts | Promote to formal PROP surface. Not merely syntax for loop. |
| `stream` / `fold_stream` | External data flow; `stream` is ESCAPE; bounded `fold_stream` yields CORE value | Runtime materializes a bounded window, then evaluates CORE fold | Keep distinct. Streams are data sources/windows; progressions are execution/event lifecycle. |
| Runtime scheduler / event materializer | Concrete mechanism for timing, queues, workers, backpressure, replay, distribution | Implements progression lifecycle | Keep mostly runtime implementation. The language should constrain the observable contract, not prescribe scheduler algorithms. |

---

## Language Semantics Boundary

The language should own:

```text
progression declaration identity
progression source descriptor shape
bounded materialization invariant
step handler boundary
ProgressionEvent minimum fields
ProgressionStepReceipt minimum fields
cancellation requirement
checkpoint/resume obligation
backpressure as structured materialization state
no hidden eager infinite execution invariant
relationship to service contract liveness obligations
relationship to stream/fold_stream windows
OOF rules for hidden/unbounded progression-like behavior
```

The runtime should own:

```text
timer precision and clock implementation
queue technology
worker scheduling
retry policy
sharding / distribution
durable checkpoint storage
receipt sink implementation
backpressure algorithm
replay cursor storage
production observability integrations
```

---

## Minimum PROP Surface

[R] Route to a formal PROP, owned by Compiler/Grammar with Research proof
evidence attached.

Minimum PROP should define:

1. `Progression` as a named semantic entity distinct from `Stream[T]` and from
   finite/structural/fuel/convergent loops.
2. Service contract binding: service loops are progression-backed liveness
   surfaces, not eager repeated body execution.
3. Initial source descriptor model:

```text
source_kind: clock.every | queue | external
source_ref
payload_type
materialization_policy
```

4. Minimum `ProgressionEvent` shape:

```text
kind
progression_ref
source_kind
sequence
scheduled_at or materialized_at
payload
event_id
```

5. Minimum `ProgressionStepReceipt` shape:

```text
kind
progression_ref
event_id
sequence
scheduled_at/materialized_at
started_at
finished_at
outcome
reason
artifact_hash or output_ref
checkpoint_ref optional
```

6. Materialization states:

```text
materialized
blocked: progression.backpressure_queue_capacity
cancelled: progression.cancelled
suspended: progression.checkpoint_required
```

7. Static obligations:

```text
cancellation required
checkpoint required for resumable/infinite progression
max_step_latency or equivalent bounded-step policy
no direct nested progression inside CORE/pure compute
no hidden eager infinite loop
```

8. Relationship to existing surfaces:

```text
Stream[T] remains data flow.
fold_stream remains ESCAPE -> CORE via bounded window.
Progression may consume or emit stream events, but is not itself fold_stream.
Runtime scheduler implements progression; it is not the language identity.
```

9. SemanticIR target as proposal candidate only:

```text
progression_source_node
progression_materialization_policy_node
progression_step_handler_node
progression_receipt_policy_node
```

The PROP should explicitly avoid parser grammar acceptance until the semantic
surface and OOF rules are reviewed.

---

## Must Stay Deferred

```text
parser syntax
TypeChecker implementation
SemanticIR implementation
production RuntimeMachine scheduler
durable queue / durable checkpoint implementation
Ledger / TBackend binding
distributed scatter/gather or shard placement
production cache or memoization
live service execution authority
nested progressions inside pure contracts
unified stream executor
profile-pack migration or ProgressionPack implementation
```

---

## Acceptance Criteria If Promoted

A promoted PROP should be accepted only if it satisfies:

```text
AC-1: Defines progression separately from Stream[T], fold_stream, and local loops.
AC-2: States service loops are progression-backed liveness surfaces.
AC-3: Preserves finite/structural/fuel/convergent loop classes.
AC-4: Requires bounded materialization; forbids hidden eager infinite execution.
AC-5: Defines minimum ProgressionEvent and ProgressionStepReceipt shapes.
AC-6: Defines cancellation, checkpoint/resume, and backpressure semantics.
AC-7: Separates language obligations from runtime scheduler implementation.
AC-8: Names initial OOF/refusal categories for unbounded/hidden progression behavior.
AC-9: Declares no parser, SemanticIR, RuntimeMachine, Ledger, or .igapp authority.
AC-10: Includes a future proof plan covering clock, queue, cancellation, checkpoint, and backpressure cases.
```

---

## Recommended Route

Route: `PROP`

Recommended next card:

```text
external-progression-semantics-prop-draft-v0
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
```

Reason:

```text
The promoted runtime model already proves coherence. The remaining question is
not "keep researching?" but "what is the formal language boundary?"
```

This should not be routed as an implementation card. It is also stronger than a
meta-proposal because the minimum semantic surface is now concrete enough for a
formal PROP draft.

---

## Handoff

```text
Card: S3-R33-C5-P
Agent: [Igniter-Lang Research Agent #2]
Role: research-agent
Track: external-progression-semantics-decision-prep-v0
Status: done

[D] Decisions
- Progression is a separate semantic primitive for runtime-managed event potential.
- Service loop should become a surface over progression semantics.
- Finite, structural, fuel-bounded, and convergent loops remain managed local loop classes.
- Stream/fold_stream remains data-flow/window semantics, not execution progression.

[S] Signals
- Promoted runtime proof already shows lazy materialization, receipts, checkpoint/resume, backpressure, cancellation, and queue/clock common lifecycle.
- Heat Map GI-3 confirms managed recursion/service loop has no numbered PROP and zero compiler expression.
- Ch13's service loop obligations can be preserved while removing hidden eager loop semantics.

[T] Tests / Proofs
- No code or proof changes in this slice.
- Existing proof referenced: ruby igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model.rb -> PASS.

[R] Risks / Recommendations
- Route to formal PROP, not implementation.
- Keep parser syntax, SemanticIR implementation, runtime scheduler, Ledger/TBackend, durable queues, and profile-pack migration deferred.

[Next]
- Open external-progression-semantics-prop-draft-v0 for Compiler/Grammar.
```
