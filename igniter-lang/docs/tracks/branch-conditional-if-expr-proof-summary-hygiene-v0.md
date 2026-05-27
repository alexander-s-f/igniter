# Branch Conditional If Expr Proof Summary Hygiene v0

Card: S3-R193-C1-P1  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-proof-summary-hygiene-v0`  
Route: UPDATE  
Depends on: S3-R192-C4-S  
Status: done  
Date: 2026-05-27

---

## Purpose

Close R190/R191 proof-summary hygiene before any release-harness delta evidence.

This card updates only proof-owned summary metadata. It does not change
TypeChecker/SemanticIR behavior and does not touch release harness evidence,
public docs, runtime/evaluator, Spark, API/CLI, package/release, parser,
classifier, orchestrator, assembler, loader/report, CompatibilityReport,
`.igapp`, goldens, manifests, or artifact hashes.

---

## Inputs Read

- `docs/tracks/stage3-round192-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-design-v0.md`
- `docs/discussions/branch-conditional-if-expr-post-implementation-release-harness-delta-pressure-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md`
- `experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb`
- `experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`

---

## Changes

Updated proof-owned runner and regenerated its summary:

- added `primary_rules` and `secondary_rules` per negative `if_expr` case;
- recorded `oof_ty0_for_if_expr_absent` for all negative `if_expr` cases;
- labeled derivative `OOF-TY0` as:

```json
{
  "classification": "secondary_type_propagation",
  "secondary_type_propagation": true,
  "unsupported_if_expr_regression": false
}
```

- added `hygiene_evidence` machine-readable gate summary;
- added `no_spark_claim: true` to `non_claims`;
- added hygiene-specific closed-surface markers.

The legacy `rules` arrays are preserved for compatibility; derivative
`OOF-TY0` is duplicated into `secondary_rules` with explicit classification.

---

## Proof Gate Result

Summary:

```text
status: PASS
checks_total: 28
checks_pass: 28
checks_fail: 0
failed_checks: none
```

Hygiene gates:

| Gate | Result |
| --- | --- |
| Semantic proof count preserved | PASS |
| All existing semantic checks preserved | PASS |
| Unsupported-`if_expr` `OOF-TY0` absent for all negative cases | PASS |
| Derivative `OOF-TY0` secondary-labeled where present | PASS |
| `no_spark_claim: true` present | PASS |
| Release harness / accepted evidence immutable | PASS |
| Runtime/public/API/Spark/doc-spec/code behavior non-claims preserved | PASS |

---

## Negative Case Summary

| Case | Primary rules | Secondary rules | Unsupported-`if_expr` `OOF-TY0` absent |
| --- | --- | --- | --- |
| `non_bool_condition` | `OOF-IF1` | none | true |
| `missing_else` | `OOF-IF2` | `OOF-TY0` as `secondary_type_propagation` | true |
| `branch_type_mismatch` | `OOF-IF3` | `OOF-TY0` as `secondary_type_propagation` | true |
| `empty_branch` | `OOF-IF4` | `OOF-TY0` as `secondary_type_propagation` | true |

This closes the R190/R191 ambiguity: derivative `OOF-TY0` is secondary
Unknown-propagation output, not an unsupported-`if_expr` regression.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb` | PASS |
| `ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb` | PASS, 28/28 |

No release commands were run.

---

## Updated Proof Outputs

- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`

The summary now includes:

```text
hygiene_evidence.status: PASS
hygiene_evidence.unsupported_if_expr_oof_ty0_absent_all_negative_cases: true
hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases: true
hygiene_evidence.no_spark_claim: true
non_claims.no_spark_claim: true
```

---

## Closed-Surface Scan

Closed surfaces remain closed:

- release harness and accepted release evidence unchanged;
- runtime/evaluator unchanged;
- public docs/README release claims unchanged;
- Spark unchanged;
- public API/CLI unchanged;
- package/release unchanged;
- parser/classifier/orchestrator/assembler unchanged;
- loader/report, CompatibilityReport, `.igapp`, goldens, manifests, and
  artifact hashes unchanged.

Proof summary closed-surface marker:

```text
closed_surface_scan.status: PASS
closed_surface_scan.typechecker_semanticir_behavior_not_changed_by_hygiene: true
closed_surface_scan.docs_spec_not_changed_by_hygiene: true
closed_surface_scan.public_api_cli_not_changed_by_hygiene: true
closed_surface_scan.spark_not_changed_by_hygiene: true
```

---

## Changed File List

- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md`

---

## Recommendation

Recommendation:

```text
accept proof-summary hygiene closure
keep release-harness delta held until a separate authorization review names a
new evidence packet boundary
```

No release-harness delta, release execution, public claim, runtime/evaluator, or
Spark route is opened by this hygiene closure.

