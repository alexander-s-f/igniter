# External Progression Runtime Model v0

Card: inbox-background-runtime-loop-semantics-exploration
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/external-progression-runtime-model-v0
Status: done
Date: 2026-05-11

## Goal

Process the inbox note:

```text
igniter-lang/docs/inbox/runtime-loop-semantics-exploration.md
```

The research question was whether "progression" is more than a naming change
for managed loops. The proof-local answer is yes: external progression gives
Igniter-Lang a runtime ontology that can model infinite temporal potential,
bounded materialization, step receipts, backpressure, cancellation, and
checkpoint/replay without implying hidden eager loop execution.

This track is intentionally out-of-band and does not widen production
authorization.

## Verdict

[D] External progression works as a proof-local runtime model and is a step
forward from imperative loop semantics.

The important shift:

```text
loop = execute body repeatedly
progression = declare event potential; runtime materializes bounded steps
```

This is a meaningful new capability because it turns "run forever" into a
bounded, inspectable lifecycle:

```text
ProgressionSource
  -> EventMaterializer
  -> EventQueue
  -> StepExecutor
  -> ReceiptSink
```

## Proof

Command:

```text
ruby igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model.rb
```

Result:

```text
PASS external_progression_runtime_model
clock_progression_lazy_not_eager: ok
step_receipts_are_structured: ok
checkpoint_resume_no_duplicates: ok
backpressure_is_structured: ok
cancellation_blocks_future_materialization: ok
queue_progression_uses_same_lifecycle: ok
new_capability_matrix_has_all_expected: ok
summary: igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model_summary.json
```

## Proven Capabilities

| Capability | Proof signal |
| --- | --- |
| Lazy infinite progression window | A clock source declares infinite potential but only materializes three demanded events. |
| Receipt-first step audit | Every executed event produces a `progression_step_receipt` with event id, timing, outcome, and artifact hash. |
| Deterministic checkpoint/resume | Resume from cursor continues sequences `[0, 1, 2, 3]` without duplicate event ids. |
| Structured backpressure | Requesting five events with capacity two returns `progression.backpressure_queue_capacity`. |
| Structured cancellation | Cancelled progression emits a cancellation receipt and refuses future materialization. |
| Shared lifecycle for non-clock sources | A work-queue progression uses the same materialize/execute/receipt path as clock progression. |

## Runtime Envelope

Proof-local event shape:

```json
{
  "kind": "progression_event",
  "progression_ref": "progression/heartbeat/clock-5s",
  "source_kind": "clock.every",
  "sequence": 0,
  "scheduled_at": "2026-05-11T12:00:00Z",
  "payload": {},
  "event_id": "progression-event/<hash>"
}
```

Proof-local receipt shape:

```json
{
  "kind": "progression_step_receipt",
  "version": "progression-step-receipt-v1",
  "progression": "progression/heartbeat/clock-5s",
  "event_id": "progression-event/<hash>",
  "sequence": 0,
  "scheduled_at": "2026-05-11T12:00:00Z",
  "started_at": "2026-05-11T12:00:00Z",
  "finished_at": "2026-05-11T12:00:01Z",
  "outcome": "completed",
  "reason": "progression.step_completed",
  "artifact_hash": "sha256:<hash>"
}
```

Backpressure is represented as materialization state, not as an accidental
runtime exception:

```json
{
  "state": "blocked",
  "reason": "progression.backpressure_queue_capacity",
  "requested": 5,
  "accepted": 2,
  "capacity": 2
}
```

## Why This Is a Step Forward

| Axis | Imperative loop | External progression |
| --- | --- | --- |
| Ontology | Eager repeated body execution | Declarative temporal event potential |
| Scheduler | Hidden | Explicit source plus materializer |
| Infinite case | Requires out-of-band stop condition | Safe when materialized by bounded demand |
| Audit unit | Side effect or runtime log | `ProgressionStepReceipt` |
| Backpressure | Not semantic | Structured materialization state |
| Replay | Ad hoc | Cursor/checkpoint-oriented |

This makes service contracts better suited for long-lived orchestration,
telemetry ingestion, realtime video processing, and swarm/mesh coordination.
The proof demonstrates a common runtime lifecycle for clock progressions and
work-queue progressions, which is the strongest signal that this is not merely
syntax for loops.

## Boundaries

This track does not authorize:

```text
parser syntax
typechecker changes
SemanticIR primitive addition
RuntimeMachine production integration
durable scheduler
Ledger integration
production cache/memoization behavior
service-contract grammar changes
```

[R] The inbox hypothesis says progression may belong in SemanticIR. This track
does not decide that. It only shows the runtime model is coherent enough to
justify a formal proposal or next design card.

## Inbox Disposition

Status:

```text
promoted-track
```

Source:

```text
igniter-lang/docs/inbox/runtime-loop-semantics-exploration.md
```

Destination:

```text
igniter-lang/docs/tracks/external-progression-runtime-model-v0.md
```

Proof:

```text
igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model.rb
```

## Recommendation

[Next] Promote this from inbox research into a formal progression semantics
proposal if Architect wants language-level adoption.

The next formal slice should answer:

```text
1. Is progression a service-contract-only construct?
2. Is progression represented in SemanticIR or only in runtime manifests?
3. Does progression replace service loops, or coexist with local finite loops?
4. Which receipt fields become mandatory in canon?
5. What is the minimum cancellation/checkpoint/replay contract?
```

## Handoff

```text
Card: inbox-background-runtime-loop-semantics-exploration
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/external-progression-runtime-model-v0
Status: done

[D] Decisions
- Treated the inbox note as promoted-track research.
- External progression is proof-coherent and materially stronger than hidden loop execution for long-lived runtime behavior.
- The proof model uses explicit ProgressionSource -> EventMaterializer -> EventQueue -> StepExecutor -> ReceiptSink.

[S] Shipped / Signals
- Added proof-local runtime model for clock and queue progressions.
- Added structured progression step receipts, checkpoint/resume, backpressure, and cancellation evidence.
- Added inbox disposition linking the source note to this track.

[T] Tests / Proofs
- `ruby igniter-lang/experiments/external_progression_runtime_model/external_progression_runtime_model.rb` -> PASS.

[R] Risks / Recommendations
- Keep the result proposal-candidate only. No parser, typechecker, SemanticIR, or RuntimeMachine production changes are authorized here.
- The strongest next step is a formal progression semantics proposal with service-contract surface and SemanticIR placement decisions.

[Next]
- Architect/Compiler lane should decide whether to open a formal proposal card for progression-native service contracts.
```
