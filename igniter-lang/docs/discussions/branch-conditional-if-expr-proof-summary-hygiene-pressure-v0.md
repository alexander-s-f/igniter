# Branch Conditional If Expr Proof Summary Hygiene Pressure v0

Card: S3-R193-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-proof-summary-hygiene-pressure-v0

Context: internal — full read access to C1-P1 hygiene track, updated proof
summary JSON, proof runner source, R192 C3-A decision, and R192 status curation
Write access: none
Canon authority: none

---

## Question

Does the S3-R193-C1-P1 proof-summary hygiene output correctly preserve all 28
accepted semantic checks, machine-readably distinguish primary OOF-IF* diagnostics
from derivative OOF-TY0 type-propagation output, add `no_spark_claim: true`, and
leave all accepted release evidence, runtime/evaluator, public claims, Spark, and
code behavior surfaces unchanged?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md` (S3-R193-C1-P1)
- `igniter-lang/docs/tracks/stage3-round192-status-curation-v0.md` (S3-R192-C4-S)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-decision-v0.md` (S3-R192-C3-A)
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json` (updated by C1-P1)
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb` (runner source, spot-checked)

---

## Direct JSON Gate Verification

All R192-C3-A required hygiene gates verified directly from the updated proof
summary JSON and runner source:

```text
checks_total:  28   ✓
checks_pass:   28   ✓
checks_fail:   0    ✓
all_28_PASS:   true ✓

hygiene_evidence.status:                                PASS  ✓
hygiene_evidence.semantic_check_count_preserved:        true  ✓
hygiene_evidence.semantic_pass_count_preserved:         true  ✓
hygiene_evidence.semantic_fail_count_preserved:         true  ✓
hygiene_evidence.unsupported_if_expr_oof_ty0_absent_all_negative_cases: true  ✓
hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases: true  ✓
hygiene_evidence.no_spark_claim:                        true  ✓
hygiene_evidence.release_harness_evidence_immutable:    true  ✓
hygiene_evidence.no_semantic_behavior_change:           true  ✓

non_claims.no_spark_claim:                             true  ✓
non_claims.no_release_harness_mutation:                true  ✓
non_claims.no_release_evidence_mutation:               true  ✓
non_claims.no_runtime_evaluator_support:               true  ✓
non_claims.no_public_api_cli_widening:                 true  ✓
non_claims.no_public_demo_stable_claims:               true  ✓
non_claims.no_doc_spec_changes:                        true  ✓
non_claims.no_typechecker_semanticir_behavior_changes: true  ✓
non_claims.no_package_release_commands:                true  ✓

closed_surface_scan.status:                                    PASS  ✓
closed_surface_scan.release_harness_not_in_write_scope:        true  ✓
closed_surface_scan.runtime_not_modified:                      true  ✓
closed_surface_scan.typechecker_semanticir_behavior_not_changed_by_hygiene: true  ✓
closed_surface_scan.docs_spec_not_changed_by_hygiene:          true  ✓
closed_surface_scan.public_api_cli_not_changed_by_hygiene:     true  ✓
closed_surface_scan.spark_not_changed_by_hygiene:              true  ✓
```

Negative-case secondary labeling — verified per case:

```text
non_bool_condition:     primary=[OOF-IF1]  secondary=[]                oof_ty0_absent=true  ✓
missing_else:           primary=[OOF-IF2]  secondary=[OOF-TY0 sec]     oof_ty0_absent=true  ✓
branch_type_mismatch:   primary=[OOF-IF3]  secondary=[OOF-TY0 sec]     oof_ty0_absent=true  ✓
empty_branch:           primary=[OOF-IF4]  secondary=[OOF-TY0 sec]     oof_ty0_absent=true  ✓
```

Each secondary `OOF-TY0` entry carries:
```json
{
  "classification": "secondary_type_propagation",
  "secondary_type_propagation": true,
  "unsupported_if_expr_regression": false
}
```

---

## Scope Check Matrix

| ID | Check | Evidence | Result |
| --- | --- | --- | --- |
| SC-1 | Semantic checks remain 28/28 PASS | `checks_total:28`, `checks_pass:28`, `checks_fail:0`; all 28 named checks have `"status":"PASS"`; `hygiene_evidence.semantic_check_count_preserved:true`; `hygiene_evidence.semantic_pass_count_preserved:true` | PASS |
| SC-2 | No accepted semantic behavior changed | All 28 check names are identical to original R189 C2-I summary; `non_claims.no_typechecker_semanticir_behavior_changes:true`; `closed_surface_scan.typechecker_semanticir_behavior_not_changed_by_hygiene:true`; `hygiene_evidence.no_semantic_behavior_change:true`; changed files list contains only proof runner, summary JSON, and track doc | PASS |
| SC-3 | Unsupported-`if_expr` OOF-TY0 absent for all negative cases | All four negative cases have `oof_ty0_for_if_expr_absent:true`; `hygiene_evidence.unsupported_if_expr_oof_ty0_absent_all_negative_cases:true`; runner helper `unsupported_if_expr_oof_ty0_absent?` machine-derives this per case | PASS |
| SC-4 | Derivative OOF-TY0 explicitly secondary-labeled where present | `missing_else`, `branch_type_mismatch`, `empty_branch` each have `secondary_rules` with `secondary_type_propagation:true` and `unsupported_if_expr_regression:false`; `derivative_oof_ty0_secondary_labeled:true` for all four cases; `hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases:true`; runner uses correct guard `!present || labeled` | PASS |
| SC-5 | `no_spark_claim: true` present | `hygiene_evidence.no_spark_claim:true`; `non_claims.no_spark_claim:true`; closes R190 NB-2 | PASS |
| SC-6 | No release harness / accepted evidence mutation | `non_claims.no_release_harness_mutation:true`; `non_claims.no_release_evidence_mutation:true`; `hygiene_evidence.release_harness_evidence_immutable:true`; `closed_surface_scan.release_harness_not_in_write_scope:true`; `release_harness_non_mutation.harness_summary_intact:true`; `release_harness_non_mutation.smoke_summary_intact:true` | PASS |
| SC-7 | No runtime/public/API/Spark/doc-spec/code behavior changes | `non_claims.no_runtime_evaluator_support:true`; `non_claims.no_doc_spec_changes:true`; `non_claims.no_public_api_cli_widening:true`; `closed_surface_scan.docs_spec_not_changed_by_hygiene:true`; `closed_surface_scan.public_api_cli_not_changed_by_hygiene:true`; `closed_surface_scan.spark_not_changed_by_hygiene:true`; `non_claims.no_package_release_commands:true` | PASS |
| SC-8 | Write scope matches authorized paths exactly | Changed files: proof runner `.rb`, summary `out/...json`, track doc — all within `experiments/branch_conditional_if_expr_v0_implementation_proof/**` and `docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md`; `closed_surface_scan.hygiene_authorized_write_paths` records both; no other files changed | PASS |

Overall: **8/8 PASS** — no blockers.

---

## [Agree]

- The 28 semantic checks are exactly preserved. All check names and statuses
  are identical to the original R189 C2-I accepted proof. The hygiene update
  adds metadata only; it does not add, remove, or rename any semantic check.

- The `primary_rules` / `secondary_rules` split is correctly constructed. The
  runner helper `secondary_oof_ty0_errors` correctly identifies only
  `OOF-TY0` entries with messages matching `Type mismatch:` patterns and
  excludes `Unsupported expression kind: if_expr` forms. The three cases that
  have derivative OOF-TY0 (`missing_else`, `branch_type_mismatch`,
  `empty_branch`) each receive a `secondary_rules` entry with
  `classification: "secondary_type_propagation"`,
  `secondary_type_propagation: true`, and
  `unsupported_if_expr_regression: false`.

- The `non_bool_condition` case correctly has no secondary rules and
  `derivative_oof_ty0_present: false`. OOF-IF1 rejects the condition and
  branches still infer, but no downstream type-annotation mismatch fires in
  this case. The primary-only result is correct.

- The `oof_ty0_for_if_expr_absent: true` field is present on all four
  negative cases, providing a flat per-case lookup that future readers and
  proof runners can use without parsing secondary_rules entries.

- The `hygiene_evidence` block is machine-derived from the actual case data,
  not hardcoded. The runner computes `derivative_oof_ty0_secondary_labeled_all_present_cases`
  as `negative_cases.values.all? { !present || labeled }` — correctly vacuous
  for the non_bool_condition case and actively verified for the three present
  cases.

- Legacy `rules` arrays are preserved alongside the new structured fields.
  This backward compatibility decision is correct — it does not break existing
  tooling or readers that rely on the original `rules` array format.

- `no_spark_claim: true` is present in both `hygiene_evidence` and
  `non_claims`, closing R190 NB-2. The proof JSON `non_claims` block now
  aligns with the implementation track doc non-claims table.

- The `non_claims` block is extended (not replaced) — the original 10 entries
  are preserved and four new hygiene-specific entries are added:
  `no_spark_claim`, `no_doc_spec_changes`,
  `no_typechecker_semanticir_behavior_changes`, and
  `no_package_release_commands`.

- The release harness evidence is confirmed immutable by both the
  `hygiene_evidence.release_harness_evidence_immutable: true` field and the
  existing CM-11 checks (`harness_summary_intact: true`,
  `smoke_summary_intact: true`) which are re-run by the hygiene proof.

- The `hygiene_authorized_write_paths` field in `closed_surface_scan`
  correctly records the R193 write scope separately from the original R189
  write scope. This makes the authorization chain traceable.

- R190 NB-1 (proof-summary wording ambiguity) and R190 NB-2
  (`no_spark_claim` JSON gap) are both closed by this hygiene update.

---

## [Challenge]

No blocking challenges.

One cosmetic data-modeling observation: `non_bool_condition.derivative_oof_ty0_secondary_labeled: true` when `non_bool_condition.derivative_oof_ty0_present: false`. In Ruby, `[].all? { ... }` returns `true` (vacuous truth), so the runner correctly sets this field to `true` for the empty-secondary-rules case. The field is not wrong — it means "the secondary-labeling mechanism is active and would label any entry that appeared." However, a future reader encountering `secondary_labeled: true` alongside `present: false` might briefly wonder whether the two fields are consistent. See NB-1.

---

## [Missing]

No blocking gaps. One cosmetic non-blocking note:

**NB-1: `non_bool_condition.derivative_oof_ty0_secondary_labeled` is vacuously `true` when `derivative_oof_ty0_present` is `false`**

The field value is correct (Ruby `.all?` on an empty array returns `true`), and the authoritative summary field `hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases` correctly uses the phrasing "all present cases" with the explicit guard `!present || labeled`. No semantic issue exists.

For future proof readers, a clarifying comment in the runner or a field value of `"n/a"` for cases with `derivative_oof_ty0_present: false` would make the intent self-documenting without ambiguity. This is a data-modeling cosmetic note only. It does not affect any hygiene gate result, does not create any semantic confusion once the guard logic is understood, and is not a blocker for C3-A acceptance.

No further missing items.

---

## [Sharper Question]

Does the hygiene closure enable a future release-harness delta to record negative
`if_expr` diagnostic cases without the R190/R191 OOF-TY0 ambiguity?

Answer: Yes. The hygiene closure provides:
1. A `secondary_rules` pattern with explicit `classification: "secondary_type_propagation"` and `unsupported_if_expr_regression: false` that a future harness-delta proof runner can mirror directly.
2. A `oof_ty0_for_if_expr_absent: true` per-case field that a future runner can assert for the non-Bool-condition case.
3. The `hygiene_evidence.derivative_oof_ty0_secondary_labeled_all_present_cases: true` gate that a future delta summary can reference as a hygiene-passed basis.

A future release-harness delta proof may now use this pattern to classify its own
negative case diagnostics machine-readably without risk of the R190 ambiguity
being reproduced in new evidence. The R192-C2-X NB-1 concern (that CM-4..CM-7
"separated as secondary if present" required active, not passive, assertion) is
directly satisfied by this implementation.

---

## [Route]

**Verdict: proceed — 8/8 PASS, no blockers.**

```text
checks total: 8
checks pass:  8
checks fail:  0
blockers:     none
non-blocking notes: 1

NB-1: non_bool_condition.derivative_oof_ty0_secondary_labeled is vacuously true
      when derivative_oof_ty0_present is false; cosmetic data-modeling note only;
      authoritative hygiene_evidence block uses correct "all_present_cases" guard;
      no semantic impact; not a blocker
```

**Exact recommendation for C3-A:**

```text
Accept hygiene closure.

1. Accept that R190 NB-1 (derivative OOF-TY0 proof-summary wording ambiguity)
   is closed by the primary_rules/secondary_rules split with explicit
   classification fields.

2. Accept that R190 NB-2 (no_spark_claim absent from proof JSON non_claims)
   is closed by no_spark_claim: true in both non_claims and hygiene_evidence.

3. Carry NB-1 as a cosmetic data-modeling note: future proof runners should
   consider documenting or guarding the vacuously-true derivative_oof_ty0_secondary_labeled
   field for cases where derivative_oof_ty0_present is false. Non-blocking for
   hygiene acceptance.

4. The 28/28 semantic gate condition from R192-C3-A is satisfied exactly:
   checks_total==28, checks_pass==28, checks_fail==0.

5. Keep all closed surfaces closed:
   runtime/evaluator, release execution, release harness mutation,
   public claims, Spark, API/CLI widening, docs/spec, code behavior.

6. After accepting hygiene closure, a later authorization review may consider
   opening the bounded compiler-only release-harness delta
   (branch-conditional-if-expr-release-harness-delta-proof-v0) with the
   secondary-labeling pattern from this hygiene closure as its diagnostic
   classification baseline.

   That later route requires a separate authorization review that names:
     - new experiment directory
     - new evidence label (if_expr_internal_compiler_delta)
     - old-evidence immutability checks
     - explicit non-claims
   No forward commitment to that route is created by accepting hygiene closure.
```

Route: `track` — accept hygiene closure; carry NB-1 as cosmetic note; keep
harness delta held until separate authorization review.
