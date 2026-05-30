# Branch Conditional Counterfactual Audit Level 2 Concept Proof Authorization Review v0

Card: S3-R209-C1-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-concept-proof-authorization-review-v0  
Route: UPDATE  
Status: done / authorized-bounded-proof-local-concept-proof  
Date: 2026-05-30

Depends on:
- S3-R208-C5-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round208-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-boundary-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-adjacent-concepts-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
authorize bounded proof-local Level 2 counterfactual dry-run concept proof
authorize C2-I in this round
authorize only experiment-local isolated dry-run helper and proof fixtures
do not authorize live implementation
do not authorize lib/runtime/report/API/cache/Spark/public authority
```

The R208 boundary is sufficiently specific for a first proof-local concept
proof. The proof may evaluate a latent branch only inside an explicitly invoked
experiment-local isolated dry-run helper. That evaluation has no live runtime
authority and cannot mutate actual runtime artifacts.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
```

---

## Authorization Scope

Authorized next card:

```text
Card: S3-R209-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0
Route: UPDATE
Depends on:
- S3-R209-C1-A
```

Allowed write scope:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md
```

Read-only / must remain unchanged:

```text
igniter-lang/lib/**
igniter-lang/docs/spec/**
igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
accepted R205/R207/R208 docs and evidence, except read-only citation
```

No other file writes are authorized.

---

## Proof-Local Projection Envelope

C2-I must produce proof-local projection envelopes shaped as non-canonical
evidence. Required conceptual fields:

```json
{
  "kind": "counterfactual_dry_run_projection",
  "level": 2,
  "source_branch_intention_ref": "proof-local-ref",
  "premise_set": {
    "assumed_condition": true,
    "input_snapshot_ref": "proof-local-snapshot",
    "assumption_refs": []
  },
  "projected_branch": "then",
  "dry_run_trace": [],
  "projected_value": null,
  "projected_failure": null,
  "projected_value_is_not_actual_output": true,
  "projected_failure_is_not_actual_failure": true,
  "isolation": {
    "actual_result_mutated": false,
    "reports_mutated": false,
    "receipts_mutated": false,
    "cache_mutated": false,
    "external_io_performed": false,
    "production_authority": false
  },
  "authority": {
    "dependency_authority": false,
    "cache_authority": false,
    "report_authority": false,
    "runtime_readiness_authority": false,
    "public_claim": false
  }
}
```

This shape is not canonical schema, not public API, not report/result/receipt
shape, not `CompatibilityReport`, not SemanticIR, and not runtime output.

---

## Allowed Evaluation Subset

Allowed inside the experiment-local dry-run helper:

- `literal`;
- `ref`;
- pure deterministic proof-local `apply`;
- `field_access` on immutable proof-local values;
- nested `if_expr` under the same isolation rules.

Required refusal cases:

- unsupported selected-path expression;
- effect / external IO / escape-like expression;
- `tbackend_read`;
- any live Ledger/TBackend read or write;
- any persistence/network/filesystem side effect.

Refusals must appear as `projected_failure` inside the proof-local projection
envelope. They must not be actual runtime failures.

---

## Required Proof Matrix

C2-I must satisfy:

| ID | Required proof |
| --- | --- |
| L2-DRY-1 | Explicit invocation only; no projection without proof harness call. |
| L2-DRY-2 | Level 1 branch-intention consumed as input, not replaced. |
| L2-DRY-3 | Pure latent branch produces `projected_value`. |
| L2-DRY-4 | `projected_value_is_not_actual_output: true`. |
| L2-DRY-5 | Selected actual result remains unchanged. |
| L2-DRY-6 | Unsupported selected dry-run expression produces `projected_failure`, not actual failure. |
| L2-DRY-7 | `projected_failure_is_not_actual_failure: true`. |
| L2-DRY-8 | Effect / external IO expression is refused; no side effect. |
| L2-DRY-9 | `tbackend_read` is refused; no live Ledger/TBackend read. |
| L2-DRY-10 | Nested `if_expr` dry-run is lazy inside isolated projection. |
| L2-DRY-11 | `premise_set` records `assumed_condition` and input/premise source. |
| L2-DRY-12 | Isolation block proves actual/report/receipt/cache/external IO/production mutation false. |
| L2-DRY-13 | Authority block proves dependency/cache/report/runtime/public authority false. |
| L2-DRY-14 | Forbidden vocabulary scan passes across proof output fields. |
| L2-DRY-15 | Closed-surface scan proves no `lib/**`, spec, report/API, RuntimeSmoke, Spark/API/CLI, or public claim mutation. |

The proof summary must report pass/fail status for each `L2-DRY-*` item.

---

## Forbidden Vocabulary Scan

C2-I must scan proof output fields for all forbidden terms:

```text
would_result
would_output
would_fail
counterfactual result
counterfactual output
counterfactual failure
latent runtime value
latent runtime failure
latent execution
latent branch execution
simulated branch result
dry-run result
branch replay
replayed branch value
symbolic_execution
causal_estimate
alternate_actual_output
```

These may not appear as positive output fields. If they appear only in a
forbidden-vocabulary list inside the track doc, that is acceptable, but the
machine-readable proof summary must not use them as projection fields.

---

## Command Matrix

Required:

```bash
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
```

C2-I may also run read-only file scans for closed surfaces and vocabulary.

---

## Required Answers

| Question | Answer |
| --- | --- |
| May C2-I begin in this round? | Yes. |
| May the proof evaluate a latent branch inside an experiment-local isolated dry-run helper? | Yes, but only in proof-local scope and only under the authorized pure/refusal subset. |
| Does live runtime non-selected branch evaluation remain closed? | Yes. |
| Are `projected_value` / `projected_failure` accepted only as proof-local no-authority fields? | Yes. |
| Does `tbackend_read` remain refuse-only? | Yes. |
| Do `lib/**`, RuntimeSmoke, report/result/receipt/CompatibilityReport, dependency/cache, public/API/Spark surfaces remain closed? | Yes. |

---

## Closed Surfaces

Remain closed during C2-I:

- live implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema/canon mutation;
- runtime/evaluator/RuntimeSmoke behavior;
- proof RuntimeMachine changes;
- live non-selected branch evaluation;
- effect execution;
- external IO;
- persistence;
- Ledger/TBackend live reads/writes;
- `tbackend_read` non-refusal behavior;
- dependency/cache authority;
- `CompilationReport`, `CompilerResult`, receipt, `CompatibilityReport`
  mutation;
- `.igapp` artifact schema or goldens;
- spec-body promotion;
- public API/CLI;
- release evidence or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Compact Handoff

C2-I is authorized. The proof may build an experiment-local isolated dry-run
helper and evaluate latent branches only inside that proof harness. Outputs may
be called proof-local Level 2 counterfactual dry-run concept evidence only if
the isolation block, authority block, disclaimer fields, forbidden vocabulary
scan, `tbackend_read` refusal, and closed-surface scan all pass. No live
implementation, public/runtime/report/API/cache/Spark authority, or release
claim is authorized.
