# PROP-037 Progression Descriptor Shape Proof v0

Card: S3-R38-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop037-progression-descriptor-shape-proof-v0
Status: done
Date: 2026-05-12

## Goal

Create the first proof-local descriptor shape for accepted proposal-only
PROP-037 progression/service liveness.

Inputs read:

```text
igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/gates/prop037-progression-acceptance-review-v0.md
igniter-lang/docs/tracks/stage3-round37-general-status-curation-v0.md
```

## Boundary

This track is descriptor proof only.

It does not authorize or implement:

```text
parser syntax
TypeChecker implementation
SemanticIR implementation
RuntimeMachine scheduler
durable queues
durable checkpoints
Ledger/TBackend binding
receipt sink implementation
production execution
ProgressionPack dispatch
new PROGRESSION fragment class
```

PROP-037 remains accepted proposal-only. Metadata presence does not imply runtime
readiness.

## Descriptor Contract

The proof uses descriptor version:

```text
prop037-progression-source-descriptor-v0
```

Required descriptor fields:

```text
kind
descriptor_version
progression_ref
source_kind
source_ref
payload_type
materialization_policy
handler_ref
receipt_policy
liveness
```

Closed v0 `source_kind` vocabulary:

```text
clock.every
queue
external_event
```

Allowed materialization modes:

```text
bounded_demand
bounded_schedule
bounded_queue
```

Allowed backpressure policies:

```text
block
drop
suspend
```

Required liveness obligations:

```text
cancellation: required
checkpoint.required: true
checkpoint.resume: from_checkpoint
max_step_latency: <bounded duration>
```

Required receipt policy:

```text
receipt_policy.required: true
receipt_policy.sink_ref: receipt_sink/progression/...
```

## Modeled Descriptors

The proof models one descriptor per accepted source kind:

| Fixture | `source_kind` | Source ref | Materialization mode |
| --- | --- | --- | --- |
| `clock_every_5s` | `clock.every` | `clock/every/5s` | `bounded_schedule` |
| `queue_work_items` | `queue` | `queue/proof_local/work_items` | `bounded_queue` |
| `external_event_http_request` | `external_event` | `http_listener/on_request` | `bounded_demand` |

The `queue` fixture is proof-local only and explicitly carries:

```text
durable_queue: false
durable_checkpoint: false
production_execution: false
```

The `external_event` fixture proves descriptor-level specialization below the
closed top-level vocabulary. It does not authorize an HTTP listener.

## Negative Cases

The proof validates these rejection paths:

| Case | Expected result |
| --- | --- |
| unsupported top-level source kind `http.listener` | `OOF-PR9` |
| eager/unbounded materialization | `OOF-PR2` |
| missing cancellation policy | `OOF-PR3` |
| missing checkpoint policy | `OOF-PR4` |
| missing receipt policy | `OOF-PR7` |
| missing bounded step policy | `OOF-PR5` |
| attempted `fragment_class: PROGRESSION` | `PROP-037-NONAUTH` |
| attempted runtime execution claim | `PROP-037-NONAUTH` |

## Proof

Command:

```text
ruby igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof.rb
```

Result:

```text
PASS prop037_progression_descriptor_shape_proof
valid_descriptors_pass: ok
models_exact_required_source_kinds: ok
closed_v0_source_kind_rejects_new_top_level: ok
bounded_materialization_required: ok
cancellation_policy_required: ok
checkpoint_policy_required: ok
receipt_policy_required: ok
bounded_step_required: ok
no_progression_fragment_class: ok
runtime_authority_remains_closed: ok
summary: igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof_summary.json
```

Summary artifact:

```text
igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof_summary.json
```

## Decisions

[D] The first proof-local descriptor shape can cover the accepted PROP-037 v0
source vocabulary without introducing a new fragment class.

[D] `external_event` can be specialized through descriptor metadata while
preserving the closed top-level `source_kind` rule.

[D] Descriptor metadata can require bounded materialization, cancellation,
checkpoint, receipt, and bounded-step policies while keeping runtime execution
closed.

## Remaining Gaps Before Implementation

| Layer | Required blocker closure |
| --- | --- |
| Parser | Accepted service-loop/progression syntax proposal and parser implementation authorization. |
| Classifier/TypeChecker | Accepted OOF-PR ownership and typed descriptor proof plan. |
| SemanticIR | Accepted node/artifact shape and golden fixture plan. |
| Assembler/.igapp | Manifest schema authorization for `progression_sources`. |
| RuntimeMachine | Scheduler/materializer gate and proof-local implementation plan. |
| Durability | Durable queue/checkpoint/receipt sink design and authorization. |
| Ledger/TBackend | Separate binding decision; not implied by descriptor metadata. |
| Production execution | Explicit runtime/production gate. |
| ProgressionPack | Compiler profile/pack migration authorization. |

## Changed Files

```text
igniter-lang/docs/tracks/prop037-progression-descriptor-shape-proof-v0.md
igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof.rb
igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof_summary.json
```

## Handoff

```text
Card: S3-R38-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop037-progression-descriptor-shape-proof-v0
Status: done

[D] Decisions
- Proof-local PROP-037 descriptor shape is coherent for `clock.every`, `queue`, and `external_event`.
- The v0 source kind vocabulary remains closed.
- Descriptor metadata can enforce bounded materialization, cancellation, checkpoint, receipt, and bounded-step obligations.
- Runtime authority remains closed and no `PROGRESSION` fragment class is introduced.

[S] Shipped / Signals
- Added proof-local descriptor validator and fixtures.
- Added PASS summary JSON.
- Added this track doc with remaining implementation gaps.

[T] Tests / Proofs
- `ruby -c igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof.rb` -> Syntax OK.
- `ruby igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof.rb` -> PASS.

[R] Risks / Recommendations
- Do not treat descriptor shape as parser, TypeChecker, SemanticIR, RuntimeMachine, durable queue, Ledger/TBackend, or production execution authorization.
- Next proof should decide either CompatibilityReport readiness refusal or OOF-PR diagnostic taxonomy ownership, without runtime scheduling.

[Next]
- Route PROP-037 CompatibilityReport readiness proof or OOF-PR diagnostic proof as a separate card.
```
