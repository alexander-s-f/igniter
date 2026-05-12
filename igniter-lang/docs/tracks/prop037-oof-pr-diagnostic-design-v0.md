# Track: PROP-037 OOF-PR Diagnostic Design v0

Card: S3-R38-C3-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop037-oof-pr-diagnostic-design-v0`
Status: done
Date: 2026-05-12

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` may own the next proof-local fixture matrix.
- `[Igniter-Lang Bridge Agent]` may later map runtime readiness/refusal wording
  into manifest/profile bridge work.

---

## Route

```text
Route: UPDATE
Card: S3-R38-C3-P1
Role: compiler-grammar-expert
Stage/Round observed: Stage 3 / Round 38
Previous known card: S3-R37-C4-P
Same-role newer work: PROP-037 accepted proposal-only by S3-R37-C3-A
```

---

## Goal

Design the OOF-PR diagnostic family for accepted PROP-037 progression without
implementing compiler behavior.

This is diagnostic design only. It does not edit Parser, Classifier,
TypeChecker, SemanticIR, Assembler, RuntimeMachine, or runtime proof code.

---

## Inputs Read

- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `roles/compiler-grammar-expert.md`
- `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `docs/gates/prop037-progression-acceptance-review-v0.md`
- `docs/proposals/README.md`
- `docs/spec/README.md`
- `docs/spec/ch4-fragment-classification.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch6-semanticir.md`
- `docs/spec/ch7-runtime.md`
- `docs/spec/ch11-profile-system.md`
- `docs/spec/ch13-managed-recursion.md`

---

## Design Boundary

PROP-037 is accepted proposal-only. The diagnostic family is therefore a
candidate compiler/report vocabulary and proof-local validation target, not an
implementation claim.

The design keeps three layers separate:

| Layer | What it validates | Output shape | Runtime effect |
|-------|-------------------|--------------|----------------|
| Descriptor validation | Shape and policy of `ProgressionSource` metadata or proof-local descriptors | validation errors, optionally mapped to OOF-PR when the descriptor is compiler-owned | none |
| Compiler OOF diagnostics | Source/typed/proof-local compiler evidence that violates accepted progression obligations | `CompilationReport.diagnostics[]` with `OOF-PR*`; no loadable SemanticIR | none |
| Runtime readiness refusals | A valid progression descriptor exists, but runtime execution is not authorized or ready | CompatibilityReport/readiness refusal reason such as `progression.runtime_execution_not_authorized` | no scheduler/materializer call |

Rule of thumb:

```text
Invalid progression shape -> descriptor validation or compiler OOF.
Valid shape but unavailable runtime -> runtime readiness refusal.
```

---

## Diagnostic Table

| Code | Condition | Owner / layer | Default severity | Blocks SemanticIR? | Notes |
|------|-----------|---------------|------------------|--------------------|-------|
| `OOF-PR1` | Progression-like service surface has no explicit `ProgressionSource` descriptor | Compiler OOF when a compiler-visible service/progression surface exists; descriptor validator when metadata-only proof fixture lacks source descriptor | error | yes, if compiler-owned | Detects missing `kind`, `progression_ref`, or whole descriptor depending on fixture shape. |
| `OOF-PR2` | Progression source implies unbounded eager materialization | Descriptor validation first; compiler OOF if the descriptor is in source/typed artifact | error | yes, if compiler-owned | Includes missing bounded mode, missing `max_batch_size` where mode needs it, or explicit eager/unbounded mode. |
| `OOF-PR3` | Service progression lacks cancellation obligation | Descriptor/liveness validation; compiler OOF for source/typed service progression | error | yes, if compiler-owned | Required v0 liveness field: `liveness.cancellation == "required"` for service progression. |
| `OOF-PR4` | Infinite or resumable progression lacks checkpoint policy | Descriptor/liveness validation; compiler OOF for infinite/resumable service surface | error | yes, if compiler-owned | Applies when descriptor declares infinite/resumable/service behavior. Finite proof-local descriptors may avoid PR4 if not resumable. |
| `OOF-PR5` | Service or infinite progression lacks bounded-step policy such as `max_step_latency` | Descriptor/liveness validation; compiler OOF for service/infinite surface | error | yes, if compiler-owned | Accepted default from S3-R37-C3-A: error in v0. Softer warnings require later explicit authorization. |
| `OOF-PR6` | Progression handler hides external/effectful work inside CORE/pure computation | Compiler OOF at classifier/typechecker fragment boundary | error | yes | This is not a descriptor-shape error. It protects CORE/pure from hidden progression/effect execution. |
| `OOF-PR7` | Progression source has no step receipt policy | Descriptor validation first; compiler OOF if compiler-owned | error | yes, if compiler-owned | Requires `receipt_policy.required == true` and a policy target such as `sink_ref` or accepted proof-local equivalent. |
| `OOF-PR8` | Nested progression declared inside pure contract or pure compute boundary | Compiler OOF at classifier/typechecker boundary | error | yes | Parallel to existing fragment-boundary rules such as OOF-S3/OOF-TM7, but progression-specific. |
| `OOF-PR9` | Unsupported top-level `source_kind` or missing declared progression capability | Descriptor validation and compiler capability check | error | yes, if compiler-owned | Valid top-level kinds are `clock.every`, `queue`, `external_event`. Runtime instance not ready is not PR9; use readiness refusal. |

---

## Descriptor Validation Errors

Descriptor validation is the first proof-local target because PROP-037 starts
with capability/manifest metadata, not parser syntax.

Recommended validation categories:

| Category | Maps to | Example reason string |
|----------|---------|-----------------------|
| Missing descriptor | `OOF-PR1` when compiler-owned | `progression.descriptor_missing` |
| Unbounded materialization | `OOF-PR2` | `progression.materialization_unbounded` |
| Missing cancellation | `OOF-PR3` | `progression.cancellation_missing` |
| Missing checkpoint | `OOF-PR4` | `progression.checkpoint_missing` |
| Missing step bound | `OOF-PR5` | `progression.bounded_step_missing` |
| Missing receipt policy | `OOF-PR7` | `progression.receipt_policy_missing` |
| Unsupported source kind | `OOF-PR9` | `progression.source_kind_unsupported` |
| Capability not declared in profile/descriptor | `OOF-PR9` | `progression.capability_missing` |

Descriptor validation errors are not automatically runtime refusals. A valid
descriptor with `ready: false` should not emit OOF-PR; it should emit runtime
readiness metadata.

---

## Compiler OOF Diagnostics

Compiler OOF applies only when progression is represented inside a compiler-owned
artifact or proof-local compiler fixture.

Expected `CompilationReport` shape follows Ch6:

```json
{
  "rule": "OOF-PR5",
  "severity": "error",
  "message": "Service progression requires max_step_latency.",
  "node": "progression:LiveNewsClarity",
  "path": "contract:LiveNewsClarityService/progression:LiveNewsClarity",
  "category": "progression_oof"
}
```

Compiler OOF effects:

- `pass_result` is `oof` or `error`;
- `semantic_ir_ref` is `null`;
- no loadable `SemanticIRProgram` is emitted;
- no `.igapp/` artifact is assembled from the blocked program.

OOF-PR6 and OOF-PR8 are primarily compiler-fragment diagnostics. They should not
be modeled as runtime readiness refusals.

---

## Runtime Readiness Refusals

Runtime readiness is separate from OOF-PR.

Accepted PROP-037 readiness shape:

```json
{
  "progression_profile_status": "present",
  "progression_runtime_readiness": {
    "ready": false,
    "reason": "progression.runtime_execution_not_authorized"
  }
}
```

Recommended v0 refusal reason strings:

| Reason | Meaning |
|--------|---------|
| `progression.runtime_execution_not_authorized` | Descriptor is valid, but scheduler/materializer execution is not authorized. |
| `progression.runtime_capability_unavailable` | Descriptor is valid, but current runtime lacks a required progression runtime capability. |
| `progression.scheduler_not_configured` | Descriptor is valid, but no scheduler/materializer boundary is configured. |
| `progression.receipt_sink_unavailable` | Descriptor is valid, but the configured runtime cannot accept step receipts. |
| `progression.checkpoint_store_unavailable` | Descriptor is valid, but checkpoint storage is not configured. |

These are runtime/report refusals, not compiler OOFs. The no-live-call invariant
for this stage is:

```text
progression_scheduler_call_attempted == false
progression_materializer_call_attempted == false
progression_receipt_sink_call_attempted == false
durable_checkpoint_call_attempted == false
```

---

## OOF-PR5 Severity

OOF-PR5 is **error by default in v0**.

Accepted condition:

```text
service or infinite progression without bounded-step policy
```

Canonical example:

```json
{
  "rule": "OOF-PR5",
  "severity": "error",
  "message": "Service progression requires bounded-step policy such as max_step_latency."
}
```

A future bounded experiment profile may introduce a warning-like local policy
only through explicit authorization. Until then, proof cards must treat PR5 as
error.

---

## Namespace Collision / Spec-Lag

`docs/spec/ch11-profile-system.md` currently uses `OOF-PR1`, `OOF-PR2`, and
`OOF-PR3` for proposed profile-system violations. That collides with accepted
PROP-037 progression diagnostics.

Recommendation:

- Reserve `OOF-PR*` for **Progression** after PROP-037 acceptance.
- Rename the proposed Ch11 profile diagnostics in a future spec-sync or PROP-034
  authoring card before profile diagnostics are implemented.
- Candidate replacement namespace: `OOF-PROF*` or `OOF-PF*`.

This collision is not a blocker for this design track, but it is a blocker for
any proof card that would emit both profile and progression diagnostics.

---

## Next Proof Card Recommendation

Recommended next card:

```text
Track: prop037-descriptor-oof-pr-proof-v0
Goal: proof-local descriptor validation for OOF-PR1..OOF-PR5, OOF-PR7,
      and OOF-PR9 without parser/TypeChecker/SemanticIR implementation.
```

Suggested fixture set:

| Fixture | Expected result |
|---------|-----------------|
| `clock_every_valid_descriptor` | PASS; readiness false with `progression.runtime_execution_not_authorized` |
| `queue_valid_descriptor` | PASS; readiness false |
| `external_event_valid_descriptor` | PASS; readiness false |
| `missing_source_descriptor` | OOF-PR1 |
| `unbounded_materialization` | OOF-PR2 |
| `missing_cancellation` | OOF-PR3 |
| `missing_checkpoint_for_resumable` | OOF-PR4 |
| `missing_max_step_latency` | OOF-PR5 error |
| `missing_receipt_policy` | OOF-PR7 |
| `unsupported_source_kind` | OOF-PR9 |
| `runtime_not_authorized_valid_descriptor` | no OOF; readiness refusal only |

Defer OOF-PR6 and OOF-PR8 proof until a compiler-owned progression AST/typed
surface is authorized, because those rules need fragment-boundary context.

---

## Non-Authorization

This track does not authorize:

- parser syntax;
- TypeChecker implementation;
- SemanticIR implementation;
- assembler or `.igapp` changes;
- RuntimeMachine scheduler;
- live service execution;
- Ledger/TBackend binding;
- durable queues/checkpoints;
- receipt sink implementation;
- production cache;
- production execution;
- ProgressionPack migration;
- a new `PROGRESSION` fragment class.

---

## Handoff

```text
Card: S3-R38-C3-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop037-oof-pr-diagnostic-design-v0
Status: done

[D] Decisions
- OOF-PR1..OOF-PR9 are designed as accepted PROP-037 progression diagnostics.
- OOF-PR5 remains error by default in v0.
- Descriptor validation, compiler OOF, and runtime readiness refusals are separate layers.

[S] Shipped / Signals
- Diagnostic table with owner/layer/severity.
- Runtime readiness refusal vocabulary that does not masquerade as OOF.
- Spec-lag note: Ch11 profile-system currently collides with OOF-PR1..3.

[T] Tests / Proofs
- Not run; documentation/design-only card.

[R] Risks / Recommendations
- Before proof emission, resolve or explicitly tolerate the Ch11 OOF-PR namespace collision.
- Next proof should validate descriptor-shape OOF-PR cases without parser,
  TypeChecker, SemanticIR, assembler, or RuntimeMachine behavior.

[Next]
- Route `prop037-descriptor-oof-pr-proof-v0` for proof-local descriptors and
  diagnostic output.
```
