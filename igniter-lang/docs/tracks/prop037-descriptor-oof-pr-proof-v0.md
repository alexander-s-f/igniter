# Track: PROP-037 Descriptor OOF-PR Proof v0

Card: S3-R40-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop037-descriptor-oof-pr-proof-v0`
Status: done
Date: 2026-05-12

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` may consume this proof as the OOF-PR
  descriptor diagnostic baseline.
- `[Igniter-Lang Bridge Agent]` may use the readiness-refusal split when mapping
  future manifest/profile bridge requirements.

---

## Route

```text
Route: UPDATE
Card: S3-R40-C1-P1
Role: compiler-grammar-expert
Stage/Round observed: Stage 3 / Round 40
Previous known card: S3-R39-C1-P1
Same-role newer work: P-54 namespace sync closed; OOF-PR* is reserved for progression
```

---

## Goal

Implement a proof-local descriptor OOF-PR validation proof for PROP-037
progression diagnostics after P-54 namespace closure.

This proof validates descriptors only. It does not implement parser,
TypeChecker, SemanticIR, assembler, RuntimeMachine, Ledger/TBackend, durable
queues/checkpoints, receipt sinks, production cache, production execution,
ProgressionPack migration, or a `PROGRESSION` fragment class.

---

## Inputs Read

- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `roles/compiler-grammar-expert.md`
- `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `docs/tracks/prop037-progression-descriptor-shape-proof-v0.md`
- `docs/tracks/prop037-oof-pr-diagnostic-design-v0.md`
- `docs/tracks/ch11-profile-oof-namespace-sync-v0.md`
- `docs/tracks/stage3-round39-status-curation-v0.md`

---

## Delivered

Added proof experiment:

```text
experiments/prop037_descriptor_oof_pr_proof/prop037_descriptor_oof_pr_proof.rb
experiments/prop037_descriptor_oof_pr_proof/prop037_descriptor_oof_pr_proof_summary.json
```

The proof emits a summary JSON because this proof owns the artifact.

---

## Descriptor Fixtures

Valid descriptor fixtures cover all accepted v0 source kinds:

| Fixture | `source_kind` | Source ref | Runtime readiness |
|---------|---------------|------------|-------------------|
| `clock_every_valid_descriptor` | `clock.every` | `clock/every/5s` | `ready: false`, `progression.runtime_execution_not_authorized` |
| `queue_valid_descriptor` | `queue` | `queue/proof_local/work_items` | `ready: false`, same refusal |
| `external_event_valid_descriptor` | `external_event` | `proof_local/external_event/http_shape_only` | `ready: false`, same refusal |

The external-event fixture intentionally uses a proof-local source ref instead
of a production-like listener name.

---

## Diagnostic Matrix

| Fixture | Expected diagnostic | Result |
|---------|---------------------|--------|
| `missing_source_descriptor` | `OOF-PR1` | PASS |
| `unbounded_materialization` | `OOF-PR2` | PASS |
| `missing_cancellation` | `OOF-PR3` | PASS |
| `missing_checkpoint_for_resumable` | `OOF-PR4` | PASS |
| `missing_max_step_latency` | `OOF-PR5` with `severity: "error"` | PASS |
| `missing_receipt_policy` | `OOF-PR7` | PASS |
| `unsupported_source_kind` | `OOF-PR9` | PASS |

Deferred by design:

| Code | Reason |
|------|--------|
| `OOF-PR6` | Needs compiler-owned fragment context to detect hidden external/effectful progression inside CORE/pure computation. |
| `OOF-PR8` | Needs compiler-owned AST/typed boundary to detect nested progression inside pure contract/compute. |

---

## Readiness Separation

Valid descriptors produce no OOF diagnostics. They produce runtime readiness
metadata only:

```json
{
  "progression_profile_status": "present",
  "progression_runtime_readiness": {
    "ready": false,
    "reason": "progression.runtime_execution_not_authorized"
  }
}
```

This proves the accepted split:

```text
invalid descriptor -> OOF-PR diagnostic
valid descriptor + closed runtime -> readiness refusal, not OOF
```

No live-call invariants are explicit and all false:

```text
progression_scheduler_call_attempted
progression_materializer_call_attempted
progression_receipt_sink_call_attempted
durable_checkpoint_call_attempted
ledger_call_attempted
tbackend_call_attempted
production_cache_call_attempted
progression_pack_dispatch_attempted
```

---

## Command Matrix

| Command | Result |
|---------|--------|
| `ruby -c igniter-lang/experiments/prop037_descriptor_oof_pr_proof/prop037_descriptor_oof_pr_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop037_descriptor_oof_pr_proof/prop037_descriptor_oof_pr_proof.rb` | PASS |

Proof output:

```text
PASS prop037_descriptor_oof_pr_proof
valid_descriptors_pass_without_oof: ok
valid_descriptors_cover_source_kinds: ok
valid_descriptors_runtime_readiness_refuses_separately: ok
oof_pr1_missing_source_descriptor: ok
oof_pr2_unbounded_materialization: ok
oof_pr3_missing_cancellation: ok
oof_pr4_missing_checkpoint_for_resumable: ok
oof_pr5_missing_max_step_latency_error: ok
oof_pr7_missing_receipt_policy: ok
oof_pr9_unsupported_source_kind: ok
runtime_readiness_refusal_is_not_oof: ok
no_live_calls_attempted: ok
no_progression_fragment_class_or_runtime_binding: ok
```

---

## Remaining Gaps Before Implementation

| Layer | Remaining gap |
|-------|---------------|
| Parser | Accepted service-loop/progression source syntax and parser implementation authorization. |
| Classifier/TypeChecker | Compiler-owned progression AST/typed descriptor boundary; OOF-PR6 and OOF-PR8 still need fragment context. |
| SemanticIR | Accepted progression node/artifact shape and golden fixture plan. |
| Assembler/.igapp | Manifest schema authorization for `progression_sources`; no real `.igapp` mutation yet. |
| CompatibilityReport | Readiness proof may consume valid descriptors while keeping runtime readiness false. |
| RuntimeMachine | Scheduler/materializer gate and proof-local implementation plan. |
| Durability | Durable queue/checkpoint/receipt sink design and authorization. |
| Ledger/TBackend | Separate binding decision; not implied by progression. |
| Production execution | Explicit runtime/production gate. |
| ProgressionPack | Compiler profile/pack migration authorization. |

---

## Non-Authorization

This track does not authorize:

- parser syntax or implementation;
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

## Worktree Note

Unrelated dirty files observed during this slice and not touched:

- `docs/lineups/old-discussions-pre-gate3-spine.md`
- `docs/tracks/gate3-r13-r22-lineup-authority-verification-v0.md`
- `docs/tracks/pre-gate3-lineup-rq1-rq2-revision-v0.md`

---

## Handoff

```text
Card: S3-R40-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop037-descriptor-oof-pr-proof-v0
Status: done

[D] Decisions
- OOF-PR descriptor proof is proof-local and descriptor-only.
- OOF-PR1/2/3/4/5/7/9 are validated with CompilationReport-shaped diagnostics.
- OOF-PR5 is proven as severity error.
- Valid descriptors produce readiness refusal, not OOF.

[S] Shipped / Signals
- Added prop037_descriptor_oof_pr_proof experiment.
- Added proof-owned PASS summary JSON.
- Added this track doc.

[T] Tests / Proofs
- ruby -c prop037_descriptor_oof_pr_proof.rb -> PASS.
- ruby prop037_descriptor_oof_pr_proof.rb -> PASS.

[R] Risks / Recommendations
- OOF-PR6 and OOF-PR8 remain deferred until a compiler-owned progression AST or typed surface exists.
- Next safe proof is CompatibilityReport readiness consumption of valid descriptors with runtime readiness false.

[Next]
- Route PROP-037 CompatibilityReport readiness proof, or a compiler-owned
  AST/typed boundary design before PR6/PR8.
```
