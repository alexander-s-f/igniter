# Branch Conditional If Expr Release Harness Delta Authorization Review v0

Card: S3-R194-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-release-harness-delta-authorization-review-v0
Route: UPDATE
Status: done / authorized-bounded-compiler-only-delta-proof
Date: 2026-05-27

Depends on:
- S3-R193-C4-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round193-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-summary-hygiene-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round192-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`

---

## Decision

Decision:

```text
authorize a bounded compiler-only release-harness delta proof next
proof label: if_expr_internal_compiler_delta
old release evidence remains historical / unchanged / immutable
delta must be a new evidence packet, not a rewrite of old evidence
runtime/evaluator remains closed
public release/demo/stable/production/all-grammar claims remain closed
Spark/API/CLI remain closed
TypeChecker/SemanticIR/compiler behavior changes remain closed
this card does not run the proof
this card does not authorize release execution or public claims
```

R193 closed the proof-summary hygiene debt: the accepted `if_expr` implementation
proof remains `28/28 PASS`, unsupported-`if_expr` `OOF-TY0` absence is
machine-readable, derivative `OOF-TY0` is secondary-labeled, and
`no_spark_claim: true` is present.

That is enough to open a separate, bounded, compiler-only delta proof. It is not
enough to mutate historical release evidence or to make public/runtime claims.

---

## Authorization Basis

Accepted internal compiler support:

```text
R190: if_expr v0 implementation accepted
R191: docs/spec sync accepted
R192: old release evidence remains historical / unchanged / immutable
R193: proof-summary hygiene accepted
```

R193 proof-summary hygiene:

```text
status: PASS
checks_total: 28
checks_pass: 28
checks_fail: 0
unsupported_if_expr_oof_ty0_absent_all_negative_cases: true
derivative_oof_ty0_secondary_labeled_all_present_cases: true
no_spark_claim: true
release_harness_evidence_immutable: true
no_semantic_behavior_change: true
```

Historical release evidence status:

| Evidence packet | Status | `branch_conditional_if_expr` status |
| --- | --- | --- |
| `compiler_release_acceptance_harness_summary.json` | PASS, historical | excluded |
| `official_first_rc_evidence_summary.json` | PASS, historical | excluded |
| `combined_post_prep_smoke_summary.json` | PASS, historical | no branch/conditional claim |

The historical exclusion remains valid because those packets were produced
before `if_expr` internal compiler support landed and before proof-summary
hygiene closed.

---

## Exact Next Proof Card Boundary

```text
Card: S3-R195-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-release-harness-delta-proof-v0
Route: UPDATE
Depends on:
- S3-R194-C2-S
```

Goal:

```text
Create a new harness-local compiler-only if_expr delta evidence packet without
mutating accepted alpha / first-RC / release evidence.
```

Allowed write scope:

```text
igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-v0.md
```

No other files are authorized.

---

## Required Proof Label And Evidence Class

Required evidence label:

```text
if_expr_internal_compiler_delta
```

Allowed evidence class:

```text
post-alpha compiler-only delta evidence
```

Forbidden labels / claims:

```text
official_first_rc_evidence
alpha_release_evidence
release_execution_evidence
public_demo_evidence
runtime_evidence
production_evidence
all_grammar_evidence
Spark evidence
```

Generated outputs from S3-R195-C1-I may be called only:

```text
if_expr_internal_compiler_delta evidence
```

They must not be called official first-RC, alpha, release, public demo,
runtime, production, Spark, or all-grammar evidence.

---

## Required Summary / Result Packet Shape

The summary JSON must include, at minimum:

```json
{
  "evidence_label": "if_expr_internal_compiler_delta",
  "evidence_class": "post_alpha_compiler_only_delta",
  "status": "PASS|HOLD|FAIL",
  "checks_total": 0,
  "checks_pass": 0,
  "checks_fail": 0,
  "failed_checks": [],
  "release_scope": {
    "scope": "if_expr_internal_compiler_delta",
    "claimed_surfaces": [
      "typechecker_if_expr_v0",
      "typed_semanticir_if_expr_v0"
    ],
    "excluded_surfaces": [
      "runtime_evaluator",
      "lazy_branch_execution",
      "public_api_cli_widening",
      "spark",
      "public_demo",
      "stable",
      "production",
      "all_grammar"
    ],
    "old_evidence_rewritten": false,
    "public_claims_authorized": false,
    "production_runtime_authorized": false
  },
  "old_evidence_immutability": {
    "compiler_release_acceptance_harness_summary_unchanged": true,
    "official_first_rc_evidence_summary_unchanged": true,
    "combined_post_prep_smoke_summary_unchanged": true
  },
  "non_claims": {
    "not_official_first_rc_evidence": true,
    "not_alpha_release_evidence": true,
    "not_release_execution_evidence": true,
    "no_release_execution": true,
    "no_public_demo_claim": true,
    "no_stable_production_all_grammar_claim": true,
    "no_runtime_evaluator_support": true,
    "no_spark_claim": true,
    "no_public_api_cli_widening": true,
    "no_typechecker_semanticir_behavior_change": true
  }
}
```

The proof may extend this shape, but must not omit these fields.

---

## Required Proof Matrix

The delta proof must verify:

| ID | Required check |
| --- | --- |
| D-1 | Positive minimal `if_expr` compiles through TypeChecker and typed SemanticIR. |
| D-2 | Positive nested `if_expr` compiles through TypeChecker and typed SemanticIR. |
| D-3 | Negative non-Bool condition reports `OOF-IF1`. |
| D-4 | Negative missing `else` reports `OOF-IF2`. |
| D-5 | Negative branch mismatch reports `OOF-IF3`. |
| D-6 | Negative empty/non-value branch reports `OOF-IF4`. |
| D-7 | `OOF-IF5` remains absent / non-status. |
| D-8 | Unsupported-`if_expr` `OOF-TY0` is absent. |
| D-9 | Derivative `OOF-TY0`, if present, is labeled `secondary_type_propagation`. |
| D-10 | SemanticIR `if_expr` shape is flat and recursive: `condition`, `then_branch`, `else_branch`, `resolved_type`. |
| D-11 | Runtime/evaluator/lazy branch execution is not invoked and not claimed. |
| D-12 | Historical release evidence files remain unchanged. |
| D-13 | Public/Spark/API/CLI/release closed surfaces remain closed. |

Optional but recommended:

- include artifact path/hash of the new delta summary;
- include a closed-surface file scan;
- include a small excerpt of old release scope proving historical exclusion was
  read, not rewritten.

---

## Command Matrix

Required minimum command matrix for S3-R195-C1-I:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
```

The runner may call repo-local compiler APIs or CLI surfaces already used by the
existing harnesses, but it must not widen public API/CLI behavior.

Do not run release commands.

---

## Explicit Answers

### May a release-harness delta proof open next?

Yes.

A bounded compiler-only delta proof may open next as S3-R195-C1-I.

### Does this card itself run or authorize execution of the proof?

No.

This card authorizes the next proof card boundary only. It does not run proof
commands and does not create evidence outputs.

### May generated outputs be called official first-RC, alpha, release, or public demo evidence?

No.

Future outputs may be called only `if_expr_internal_compiler_delta evidence`.
They are not official first-RC evidence, alpha release evidence, release
execution evidence, or public demo evidence.

### Does accepted alpha / first-RC / release evidence remain unchanged?

Yes.

All accepted historical evidence remains unchanged and immutable.

### Does the historical `branch_conditional_if_expr` excluded-feature marker remain valid?

Yes.

It remains valid for historical first-RC/alpha evidence. A future delta packet
may add new post-alpha compiler-only evidence, but must not rewrite that
historical exclusion.

### Must the delta be a new evidence packet rather than a rewrite of old evidence?

Yes.

The delta must create a new evidence packet under the new experiment directory.

### Does runtime/evaluator support remain closed?

Yes.

No runtime/evaluator support, lazy branch execution, or runtime claim is opened.

### Do public release/demo/stable/production/all-grammar claims remain closed?

Yes.

No public claim is authorized.

### Do Spark/API/CLI remain closed?

Yes.

Spark fixtures, integration, evidence, production behavior, and public API/CLI
widening remain closed.

### Do TypeChecker/SemanticIR/compiler behavior changes remain closed?

Yes.

The delta proof may observe accepted behavior. It may not change TypeChecker,
SemanticIR, parser, compiler behavior, runtime, or public surfaces.

---

## Closed Surfaces

Remain closed:

- accepted alpha / first-RC / release evidence mutation;
- release harness corpus mutation outside the new proof-local experiment;
- release execution, publish, yank, tag, sign, deploy;
- public release/demo/stable/production/all-grammar claims;
- runtime/evaluator implementation or lazy branch execution;
- public API/CLI widening;
- Spark fixtures, integration, public evidence, or production behavior;
- parser, classifier, compiler orchestrator, assembler, root require changes;
- TypeChecker/SemanticIR/compiler behavior changes;
- docs/spec edits;
- `.igapp`, manifest, sidecar, artifact-hash, golden migration;
- loader/report, `CompilationReport`, `CompilerResult`, CompatibilityReport;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, production.

---

## C2-S Handoff

```text
R194 C1-A authorizes S3-R195-C1-I as a bounded compiler-only
if_expr release-harness delta proof.

Status to curate:
  authorized-bounded-compiler-only-delta-proof

Next exact card:
  S3-R195-C1-I
  branch-conditional-if-expr-release-harness-delta-proof-v0

Do not curate this as:
  release execution
  official first-RC evidence
  alpha release evidence
  public demo evidence
  runtime/evaluator support
  Spark/API/CLI support
```
