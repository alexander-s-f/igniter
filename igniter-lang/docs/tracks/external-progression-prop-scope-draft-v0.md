# Track: External Progression PROP Scope Draft v0

Card: S3-R34-C6-P
Agent: `[Igniter-Lang Research Agent #2]`
Role: research-agent
Track: `external-progression-prop-scope-draft-v0`
Status: done
Date: 2026-05-11

---

## Goal

Turn the external progression decision prep into a formal PROP scope draft,
without implementation.

Read set:

```text
docs/tracks/external-progression-semantics-decision-prep-v0.md
docs/tracks/progression-pack-shadow-boundary-v0.md
docs/spec/ch13-managed-recursion.md
docs/proposals/PROP-023-stream-input-surface-v0.md
```

This document is proposal-prep only. It does not create a numbered PROP and
does not authorize parser, TypeChecker, SemanticIR, RuntimeMachine scheduler,
Ledger/TBackend, durable queue, or production execution work.

---

## Draft PROP Title

```text
PROP-TBD: External Progression and Service Liveness Semantics v0
```

Candidate number: `PROP-037+`, subject to Architect / Compiler-Expert queue
assignment. `PROP-036` is already reserved for `compiler_profile_id` manifest
identity, so this draft must not claim it.

---

## Scope Decision

[D] Progression is its own semantic primitive, but the first PROP should model
it as runtime capability / manifest metadata first, not as a new fragment class.

Reason:

```text
CORE / ESCAPE / STREAM / TEMPORAL / OOF is already a working fragment lattice.
Progression is not a value-flow fragment like STREAM or a history-read fragment
like TEMPORAL. It is service/event lifecycle semantics around materialization,
step execution, receipts, cancellation, checkpoint, and backpressure.
```

Recommended first compiler classification:

```text
contract lifecycle: service
required_capability: progression_materialize
required_caps:
  - progression_materialize
  - progression_step_execute
  - progression_step_receipt
  - progression_checkpoint_resume   # when resumable/infinite
  - progression_cancel              # when service/infinite
```

Fragment-class position:

```text
current PROP scope: no new PROGRESSION fragment class
future candidate: PROGRESSION fragment class only after SemanticIR and
  CompatibilityReport proof show that capability/manifest metadata is insufficient
```

This preserves the existing lattice while still making progression visible to
assemblers, loaders, CompatibilityReport, and future profile/pack validation.

---

## Relationship To Managed Loops

[D] Progression does not replace finite, structural, fuel-bounded, or convergent
loops.

Preserve Chapter 13 loop classes:

| Class | Scope after progression PROP |
| --- | --- |
| `FiniteLoop` | unchanged; local bounded repetition over finite collections |
| `StructuralRecursion` | unchanged; `recur()` with decreasing variant |
| `FuelBoundedRecursion` | unchanged; explicit static step budget |
| `ConvergentLoop` | unchanged; metric + threshold + fuel |
| `ServiceLoop` | becomes a surface over progression obligations |

Lowering model:

```text
service contract X
  progression driven_by SOURCE
  cancellation required
  checkpoint every DURATION
  max_step_latency DURATION
{
  handler contracts...
}

lowers conceptually to:

ProgressionDeclaration(X, SOURCE)
ProgressionMaterializationPolicy(...)
ProgressionStepHandler(...)
ProgressionReceiptPolicy(...)
ServiceLivenessObligations(...)
```

The service loop stays user-facing. Progression is the semantic substrate that
prevents hidden eager infinite execution.

---

## Difference From Stream[T] And fold_stream

[D] `Stream[T]` remains data flow. `Progression` is execution/event lifecycle.

| Surface | Owns | Result |
| --- | --- | --- |
| `stream name: T` | external unbounded data source | ESCAPE handle requiring a window |
| `fold_stream(...) @window_bounded` | bounded fold over materialized stream window | CORE value result |
| `progression driven_by SOURCE` | potential future/external events and service step lifecycle | service materialization and step receipts |

Required distinction:

```text
Stream may feed a progression source.
Progression may emit stream-like observations.
fold_stream may run inside a progression step if it is bounded.
Progression itself is not fold_stream, and a stream window is not a service
executor.
```

This avoids turning every event source into a stream fold and avoids giving
stream capability handlers responsibility for service liveness, cancellation,
checkpointing, and step receipts.

---

## Minimum Source Descriptor

Initial source descriptor model:

```json
{
  "kind": "progression_source",
  "progression_ref": "progression/<contract>/<name>",
  "source_kind": "clock.every | queue | external_event",
  "source_ref": "clock/800ms | queue/jobs | http_listener/on_request",
  "payload_type": "Tick | Job | HttpRequest",
  "materialization_policy": {
    "mode": "bounded_demand",
    "max_batch_size": 1,
    "backpressure": "block | drop | suspend"
  }
}
```

Initial canonical source kinds:

```text
clock.every
queue
external_event
```

HTTP request listeners can be modeled as `external_event` first. A specialized
`http_listener.on_request` source can be a later stdlib/profile layer.

---

## Minimum ProgressionEvent Shape

```json
{
  "kind": "progression_event",
  "progression_ref": "progression/service/name",
  "source_kind": "clock.every",
  "source_ref": "clock/800ms",
  "sequence": 42,
  "scheduled_at": "2026-05-11T12:00:00Z",
  "materialized_at": "2026-05-11T12:00:00Z",
  "payload": {},
  "event_id": "progression-event/<hash>"
}
```

Required fields:

```text
kind
progression_ref
source_kind
source_ref
sequence
scheduled_at or materialized_at
payload
event_id
```

`scheduled_at` is required for schedule-like sources. `materialized_at` is
required for demand/event sources. Both may be present.

---

## Minimum ProgressionStepReceipt Shape

```json
{
  "kind": "progression_step_receipt",
  "version": "progression-step-receipt-v1",
  "progression_ref": "progression/service/name",
  "event_id": "progression-event/<hash>",
  "sequence": 42,
  "scheduled_at": "2026-05-11T12:00:00Z",
  "materialized_at": "2026-05-11T12:00:00Z",
  "started_at": "2026-05-11T12:00:00Z",
  "finished_at": "2026-05-11T12:00:01Z",
  "outcome": "completed",
  "reason": "progression.step_completed",
  "artifact_hash": "sha256:<hash>",
  "checkpoint_ref": "checkpoint/<hash>"
}
```

Required fields:

```text
kind
version
progression_ref
event_id
sequence
started_at
finished_at
outcome
reason
artifact_hash or output_ref
```

Optional / policy-bound fields:

```text
scheduled_at
materialized_at
checkpoint_ref
error_ref
authority_ref
receipt_sink_ref
```

Outcome vocabulary:

```text
completed
failed
timeout
cancelled
skipped
suspended
blocked
```

---

## OOF Categories

Initial OOF/refusal categories for a formal PROP:

| Code | Condition | Severity |
| --- | --- | --- |
| `OOF-PR1` | Progression-like service has no explicit source descriptor | error |
| `OOF-PR2` | Progression source implies unbounded eager execution | error |
| `OOF-PR3` | Service progression lacks cancellation obligation | error |
| `OOF-PR4` | Infinite/resumable progression lacks checkpoint policy | error |
| `OOF-PR5` | Progression step has no bounded-step policy such as `max_step_latency` | error or warn, Compiler/Grammar decision |
| `OOF-PR6` | Progression handler attempts to hide external/effectful work inside a CORE/pure step | error |
| `OOF-PR7` | Progression emits no step receipt policy | error |
| `OOF-PR8` | Nested progression declared inside pure contract / pure compute | error |
| `OOF-PR9` | Progression claims unsupported source kind or missing runtime capability | error |

The PROP should decide whether `OOF-PR5` is an error or warning. Research
recommendation: error for service/infinite progressions, warning for bounded
experiment-only progressions.

---

## Manifest / Compatibility Surface

First adoption should target metadata shape, not execution:

```json
{
  "progression_sources": [
    {
      "progression_ref": "progression/service/name",
      "source_kind": "clock.every",
      "required_caps": [
        "progression_materialize",
        "progression_step_execute",
        "progression_step_receipt"
      ],
      "runtime_authority": "not_authorized"
    }
  ]
}
```

CompatibilityReport split:

```text
progression_profile_status:
  present | absent | unsupported | mismatch

progression_runtime_readiness:
  ready: false until explicit runtime scheduler authority exists
  reason: progression.runtime_execution_not_authorized
```

This mirrors the compiler profile authority firewall: metadata presence must not
imply execution authority.

---

## ProgressionPack Position

If the future profile-assembled compiler adopts this PROP, `ProgressionPack`
becomes the natural capability owner.

Initial pack capability list:

```text
progression_source
bounded_materialization
progression_step_receipt
progression_checkpoint_resume
progression_backpressure
progression_cancellation
```

But pack implementation remains deferred. The PROP may name
`ProgressionPack` as a future ownership target only.

---

## Explicit Non-Authorization

```text
No parser syntax
No TypeChecker implementation
No SemanticIR implementation
No new PROGRESSION fragment class
No RuntimeMachine scheduler
No durable queue
No durable checkpoint store
No Ledger / TBackend binding
No production execution
No profile-pack implementation
No .igapp / .ilk format migration
```

---

## Recommendation

[R] Ready for PROP number assignment, not ready for implementation.

Recommended route:

```text
Architect / Compiler-Expert assigns next available PROP number after PROP-036.
Compiler/Grammar Expert drafts the formal PROP from this scope.
Research Agent provides proof evidence from external_progression_runtime_model.
Implementation remains blocked until the PROP is accepted and a separate
implementation_candidate card exists.
```

This does not need more broad research before a PROP number. The remaining work
is formalization: exact OOF severities, source descriptor grammar, and whether
the initial manifest metadata belongs in `.igapp` or a proof-local report first.

---

## Handoff

```text
Card: S3-R34-C6-P
Agent: [Igniter-Lang Research Agent #2]
Role: research-agent
Track: external-progression-prop-scope-draft-v0
Status: done

[D] Decisions
- Progression is a separate semantic primitive, but first adoption should be runtime capability / manifest metadata, not a new fragment class.
- Service loops lower to progression obligations and do not replace finite, structural, fuel-bounded, or convergent loops.
- Stream/fold_stream remain data-flow/window semantics; progression owns event lifecycle and step receipts.
- The first PROP should define ProgressionEvent, ProgressionStepReceipt, source descriptors, and OOF-PR* categories.

[S] Signals
- Decision-prep, ProgressionPack shadow boundary, Ch13, and PROP-023 align on a clean separation: stream=data, progression=service event lifecycle.
- ProgressionPack is the future capability owner, but remains shadow-only.
- Metadata presence must not imply runtime execution authority.

[T] Tests / Proofs
- No code or proof changes in this slice.
- Existing proof evidence remains: ruby igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model.rb -> PASS.

[R] Risks / Recommendations
- Ready for PROP number assignment after PROP-036; not ready for implementation.
- Compiler/Grammar must own final OOF severities and any syntax/SemanticIR decisions.

[Next]
- Open external-progression-semantics-prop-draft-v0 for Compiler/Grammar Expert.
```
