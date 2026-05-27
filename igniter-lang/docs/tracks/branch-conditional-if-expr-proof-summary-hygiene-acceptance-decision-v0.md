# Branch Conditional If Expr Proof Summary Hygiene Acceptance Decision v0

Card: S3-R193-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-proof-summary-hygiene-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-hygiene-closure
Date: 2026-05-27

Depends on:
- S3-R193-C1-P1
- S3-R193-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-summary-hygiene-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round192-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-decision-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`

---

## Decision

Decision:

```text
accept proof-summary hygiene closure
accept C2-X pressure verdict: proceed, 8/8 PASS, no blockers
accept preserved 28/28 semantic proof
accept unsupported-if_expr OOF-TY0 absence as machine-readable
accept derivative OOF-TY0 secondary labeling
accept no_spark_claim: true
keep accepted release evidence unchanged
keep runtime/public/API/Spark claims closed
allow later release-harness delta authorization review to open next
do not authorize release-harness delta execution in this card
do not authorize release execution or public claims
```

R193 closes the proof-summary hygiene debt selected by R192. The implementation
proof remains semantically unchanged while the summary is now clearer and safer
for future machine/human readers.

---

## Acceptance Basis

C1-P1 hygiene result:

```text
status: PASS
checks_total: 28
checks_pass: 28
checks_fail: 0
failed_checks: none
```

C2-X pressure verdict:

```text
checks total: 8
checks pass: 8
checks fail: 0
blockers: none
non-blocking notes: 1 cosmetic data-modeling note
```

Accepted changed files:

| File | Accepted change |
| --- | --- |
| `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb` | Adds hygiene metadata generation while preserving semantic checks. |
| `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json` | Adds primary/secondary diagnostic split, hygiene evidence, and `no_spark_claim`. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md` | Records the hygiene closure. |

No TypeChecker/SemanticIR behavior change is accepted by this card.

---

## Accepted Hygiene Closure

Accepted machine-readable hygiene fields:

```text
hygiene_evidence.status: PASS
hygiene_evidence.semantic_check_count_preserved: true
hygiene_evidence.semantic_pass_count_preserved: true
hygiene_evidence.semantic_fail_count_preserved: true
hygiene_evidence.unsupported_if_expr_oof_ty0_absent_all_negative_cases: true
hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases: true
hygiene_evidence.no_spark_claim: true
hygiene_evidence.release_harness_evidence_immutable: true
hygiene_evidence.no_semantic_behavior_change: true
```

Accepted non-claims:

```text
non_claims.no_spark_claim: true
non_claims.no_release_harness_mutation: true
non_claims.no_release_evidence_mutation: true
non_claims.no_runtime_evaluator_support: true
non_claims.no_public_api_cli_widening: true
non_claims.no_public_demo_stable_claims: true
non_claims.no_doc_spec_changes: true
non_claims.no_typechecker_semanticir_behavior_changes: true
non_claims.no_package_release_commands: true
```

---

## Diagnostic Hygiene Status

Accepted negative-case status:

| Case | Primary rules | Secondary rules | Unsupported-`if_expr` `OOF-TY0` absent |
| --- | --- | --- | --- |
| `non_bool_condition` | `OOF-IF1` | none | true |
| `missing_else` | `OOF-IF2` | `OOF-TY0` classified as `secondary_type_propagation` | true |
| `branch_type_mismatch` | `OOF-IF3` | `OOF-TY0` classified as `secondary_type_propagation` | true |
| `empty_branch` | `OOF-IF4` | `OOF-TY0` classified as `secondary_type_propagation` | true |

Accepted secondary entry shape:

```json
{
  "rule": "OOF-TY0",
  "classification": "secondary_type_propagation",
  "secondary_type_propagation": true,
  "unsupported_if_expr_regression": false
}
```

This closes the R190/R191 ambiguity:

- `OOF-TY0 Unsupported expression kind: if_expr` remains absent and replaced;
- derivative `OOF-TY0 Type mismatch: expected ..., got Unknown` remains
  acceptable only as explicitly labeled secondary type-propagation output.

---

## Cosmetic Note

C2-X raises one non-blocking cosmetic note:

```text
non_bool_condition.derivative_oof_ty0_secondary_labeled is vacuously true while
derivative_oof_ty0_present is false.
```

Decision:

```text
accepted as cosmetic, not a blocker
```

The authoritative aggregate field is correctly named:

```text
hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases: true
```

Future proof runners may prefer `"n/a"` or an explanatory field for cases with
no derivative `OOF-TY0`, but no follow-up is required now.

---

## Release Evidence Status

Accepted release evidence remains:

```text
historical / unchanged / immutable
```

R193 does not mutate:

- `compiler_release_acceptance_harness_summary.json`;
- `official_first_rc_evidence_summary.json`;
- `combined_post_prep_smoke_summary.json`;
- release harness corpus;
- accepted alpha/release evidence.

The historical first-RC/alpha evidence continues to exclude
`branch_conditional_if_expr`. That exclusion remains historically correct and is
not rewritten.

---

## Runtime / Public / Spark / API Status

Remain closed:

- runtime/evaluator support and lazy branch execution;
- release execution, publish, yank, tag, sign, deploy;
- public demo, stable, production, runtime, or all-grammar claims;
- Spark fixtures, integration, public evidence, or production behavior;
- public API/CLI widening.

R193 does not authorize implementation, release, public claims, or Spark/API
work.

---

## Next Route Decision

Can a later release-harness delta authorization review open next?

```text
Yes, an authorization review may open next.
```

This does not authorize the delta proof itself. It authorizes only a review to
decide whether a bounded compiler-only release-harness delta proof may begin.

Exact next route:

```text
Card: S3-R194-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-release-harness-delta-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R193-C4-S
```

Goal:

```text
Decide whether a bounded compiler-only if_expr release-harness delta proof may
begin now that proof-summary hygiene is accepted.
```

The review must define:

- new experiment directory;
- new evidence label, recommended:

```text
if_expr_internal_compiler_delta
```

- old-evidence immutability checks;
- proof command matrix;
- compiler-only scope;
- explicit non-claims:
  - not official first-RC evidence;
  - no release execution;
  - no runtime/evaluator claim;
  - no public demo/stable/production/all-grammar claim;
  - no Spark claim;
  - no public API/CLI widening;
- forbidden mutation of accepted release evidence.

Do not open in S3-R194-C1-A unless explicitly and narrowly authorized:

- release-harness delta execution;
- release execution;
- public claims;
- runtime/evaluator implementation;
- Spark/API/CLI changes;
- TypeChecker/SemanticIR behavior changes.

---

## Explicit Answers

### Is `28/28 PASS` preserved?

Yes.

`checks_total == 28`, `checks_pass == 28`, and `checks_fail == 0` are accepted.

### Is unsupported-if_expr `OOF-TY0` absence machine-readable?

Yes.

All negative cases record `oof_ty0_for_if_expr_absent: true`, and aggregate
hygiene evidence records absence across all negative cases.

### Is derivative `OOF-TY0` secondary labeling accepted?

Yes.

Derivative `OOF-TY0` is labeled as `secondary_type_propagation` where present.

### Is `no_spark_claim` accepted?

Yes.

`no_spark_claim: true` is present in both `hygiene_evidence` and `non_claims`.

### Does accepted release evidence remain unchanged?

Yes.

Accepted release evidence remains historical and immutable.

### Do runtime/public/API/Spark claims remain closed?

Yes.

### May a later release-harness delta authorization review open next?

Yes.

Only the authorization review may open next. The actual release-harness delta
proof remains closed until separately authorized.

---

## Closed Surfaces

Remain closed:

- release harness delta execution;
- accepted alpha / first-RC / release evidence mutation;
- release harness corpus mutation;
- release execution, publish, yank, tag, sign, deploy;
- public release/demo/stable/production/all-grammar claims;
- runtime/evaluator implementation or lazy branch execution;
- public API/CLI widening;
- Spark fixtures, integration, public evidence, or production behavior;
- parser/classifier/orchestrator/assembler/root require changes;
- TypeChecker/SemanticIR behavior changes;
- docs/spec edits;
- `.igapp`, manifest, sidecar, artifact-hash, golden migration;
- loader/report, `CompilationReport`, `CompilerResult`, CompatibilityReport;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, production.

