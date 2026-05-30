# Branch Conditional Counterfactual Audit Level 2 Dry-Run Concept Proof Pressure v0

Card: S3-R209-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-pressure-v0`

---

## Question

Did S3-R209-C2-I stay inside the authorized write scope, prove L2-DRY-1..L2-DRY-15
with correct isolation and no-authority semantics, correctly refuse `tbackend_read`
and effect expressions, verify laziness inside the isolated projection, and confirm
all closed surfaces unchanged?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md` (C2-I track doc)
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json` (proof JSON)
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb` (proof harness — read selectively)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-concept-proof-authorization-review-v0.md` (C1-A authorization)
- `igniter-lang/docs/tracks/stage3-round208-status-curation-v0.md` (R208 status)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-boundary-decision-v0.md` (C4-A R208 boundary decision)

Independent verification commands run:

```bash
git show --name-only HEAD
# → 3 files: track doc, harness .rb, summary JSON

rg -n "would_result|...|alternate_actual_output" harness.rb summary.json
# → 2 locations: terms_checked array in JSON; comment in harness line 762
# → No projection field names or values contain forbidden terms (Python verification: CLEAR)

grep -n "require.*igniter_lang|require.*lib/" harness.rb
# → no output (no lib/ requires)

grep -n "then_branch|else_branch" harness.rb | head -15
# → single lazy selection at line 203: `selected = cond_val ? expr["then_branch"] : expr["else_branch"]`
```

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Write scope limited to authorized experiment dir and track doc | PASS |
| SC-2 | L2-DRY-1..L2-DRY-15 all present and passing (52/52) | PASS |
| SC-3 | Projection requires explicit invocation; no implicit evaluation | PASS |
| SC-4 | Level 1 branch-intention consumed as input, not replaced | PASS |
| SC-5 | `projected_value` and `projected_failure` are no-authority, not actual output/failure | PASS |
| SC-6 | Isolation block all-false fields present and verified | PASS |
| SC-7 | Authority block all-false fields present and verified | PASS |
| SC-8 | `tbackend_read` refused; no live backend reads | PASS |
| SC-9 | Full forbidden vocabulary scan passes (17 terms, CLEAR) | PASS |
| SC-10 | No `lib/**`, RuntimeSmoke, report/result/receipt/CompatibilityReport, spec/PROP, public/Spark/API/CLI mutation | PASS |
| SC-11 | Laziness preserved inside isolated projection (nested `if_expr` proven) | PASS |
| SC-12 | NB-2 disclaimers (`projected_value_is_not_actual_output: true`, `projected_failure_is_not_actual_failure: true`) present in JSON | PASS |

**Result: 12/12 PASS — no blockers. C4-A may accept proof closure.**

---

## Detailed Findings

### SC-1: Write Scope Exact

Git history confirms exactly 3 files in the C2-I commit (`1d17334f`):
```text
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json
```

Authorized scope (C1-A):
```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md
```
Exact match. No lib/, spec chapters, proposals, or prior proof evidence files touched.

### SC-2: L2-DRY-1..L2-DRY-15 All PASS (52/52)

All 15 proof groups confirmed in JSON by name. Sub-check counts:

| Group | Checks | Result |
|-------|-------:|--------|
| L2-DRY-1 | 3 | PASS |
| L2-DRY-2 | 4 | PASS |
| L2-DRY-3 | 3 | PASS |
| L2-DRY-4 | 1 | PASS |
| L2-DRY-5 | 3 | PASS |
| L2-DRY-6 | 3 | PASS |
| L2-DRY-7 | 1 | PASS |
| L2-DRY-8 | 3 | PASS |
| L2-DRY-9 | 3 | PASS |
| L2-DRY-10 | 3 | PASS |
| L2-DRY-11 | 4 | PASS |
| L2-DRY-12 | 6 | PASS |
| L2-DRY-13 | 6 | PASS |
| L2-DRY-14 | 3 | PASS |
| L2-DRY-15 | 6 | PASS |

### SC-3: Explicit Invocation Only

L2-DRY-1 checks: `projections_only_exist_after_explicit_build_call`,
`no_implicit_projection_on_fixture_construction`,
`projected_branch_matches_explicit_premise` — all PASS.

The `build_projection` function is never called automatically on fixture
construction. No projection exists unless the proof harness explicitly calls
`build_projection(...)` with an `assumed_condition` argument. This matches
the C1-A invocation policy.

### SC-4: Level 1 Consumed as Input

L2-DRY-2 checks: `l1_fixture_a_unchanged_after_projection_a`,
`l1_fixture_b_unchanged_after_projection_b`, `projection_references_l1_via_source_ref_field`,
`l1_non_execution_guarantee_not_invalidated` — all PASS.

JSON proof_scope: `l1_branch_intentions_mutated: false`. Each projection references
the source Level 1 fixture via `source_branch_intention_ref` (a string pointer),
not a mutation. The Level 1 `non_execution_guarantee: true` for the actual runtime
path remains valid — Level 2 dry-run is an explicit additional evaluation in a
separate isolated context, not a replacement of the Level 1 record.

### SC-5: No-Authority and Non-Actual Disclaimers

**Three independent layers** confirm `projected_value` and `projected_failure` are
non-actual and carry no authority:

1. **Boolean disclaimer fields on every projection:** `projected_value_is_not_actual_output: true`,
   `projected_failure_is_not_actual_failure: true`

2. **String disclaimer:** `"no_authority_disclaimer": "projected_value and projected_failure carry no dependency/cache/report/runtime/public authority; they are proof-local concept evidence only"`

3. **Schema-level disclaimer block in JSON summary:**
```json
"disclaimer": {
  "projected_value_is_not_actual_output": true,
  "projected_failure_is_not_actual_failure": true,
  "dry_run_projection_not_public_runtime_support": true,
  "level2_proof_not_public_counterfactual_support": true,
  "no_authority_on_any_projection": "...",
  "assumptions_shaped_premise_refs_not_prop032_extension": true,
  "level2_does_not_invalidate_level1_non_execution_guarantee": true
}
```

L2-DRY-4 (`all_projections_have_projected_value_is_not_actual_output_true`)
and L2-DRY-7 (`all_projections_have_projected_failure_is_not_actual_failure_true`)
both PASS. The NB-2 condition from S3-R208-C3-X is fully satisfied.

### SC-6: Isolation Block (L2-DRY-12)

Six sub-checks verify each isolation field false on all projections:
```json
"isolation": {
  "actual_result_mutated":  false,
  "reports_mutated":        false,
  "receipts_mutated":       false,
  "cache_mutated":          false,
  "external_io_performed":  false,
  "production_authority":   false
}
```

`ISOLATION_BLOCK` is a frozen constant in the harness — all values structurally
guaranteed false. The projections_summary confirms `isolation_clean: true` for
all 6 projections.

### SC-7: Authority Block (L2-DRY-13)

Six sub-checks including `no_authority_disclaimer_present`:
```json
"authority": {
  "dependency_authority":        false,
  "cache_authority":             false,
  "report_authority":            false,
  "runtime_readiness_authority": false,
  "public_claim":                false
}
```

`AUTHORITY_BLOCK` is a frozen constant. All authority fields structurally false.
`authority_clean: true` on all 6 projections in summary.

### SC-8: `tbackend_read` Refusal (L2-DRY-9)

Three checks:
- `tbackend_read_refused_in_projection`: Fixture D latent branch
  (`tbackend_read("accounts/active")`) returns `projected_failure` with
  `refused: "tbackend_read_refused_in_dry_run"` ✓
- `no_tbackend_read_in_loaded_features`: `$LOADED_FEATURES` scan confirms no
  Ledger, TBackend, or runtime backend loaded ✓
- `tbackend_read_in_refused_kinds_constant`: Source-level check confirms
  `REFUSED_KINDS.include?("tbackend_read")` ✓

`tbackend_read_live: false`, `ledger_read_live: false` in proof_scope. Projected
failure note: `"Dry-run refusal — not an actual runtime failure."` — correct
framing. No live temporal read occurred.

### SC-9: Forbidden Vocabulary Scan (L2-DRY-14)

The JSON `forbidden_vocabulary_scan` checks **17 terms** (the 14 R206/R207 terms
plus 3 additional from the adjacent concepts survey: `symbolic_execution`,
`causal_estimate`, `alternate_actual_output`). This covers the NB-1 condition
from S3-R208-C3-X (which required the full 14-term scan).

The rg scan independently found matches in two locations:
1. The `terms_checked` array in the JSON (listing terms scanned for — expected
   and permitted by C1-A: "they may not appear as positive output fields")
2. A comment in the harness at line 762: `# "projected_value" is the accepted
   Level 2 vocabulary (not "would_result" etc.)` — a comment explaining what NOT
   to use

**Python verification against projection fields:** projections_summary,
disclaimer, and claim_policy all returned CLEAR — no forbidden term appears as
a projection field key or string value. The scan result recorded in JSON is
correct: `"scan_result": "CLEAR"`, `"result": "no forbidden terms appear as
positive projection field names or values"`.

### SC-10: Closed Surfaces (L2-DRY-15)

Six sub-checks: `no_lib_files_loaded`, `no_runtime_smoke_or_compiled_program_loaded`,
`compiler_result_not_modified`, `compiler_orchestrator_not_modified`,
`no_spec_body_chapter_modified`, `no_spark_api_cli_loaded_by_proof` — all PASS.

Harness `grep -n "require.*igniter_lang\|require.*lib/"` returns empty — no
lib/ code is loaded at all. The harness requires only `digest`, `fileutils`,
and `json` (Ruby stdlib). All proof evaluation logic is self-contained in
`isolated_eval` and `build_projection` functions.

Proof_scope JSON: `lib_files_modified: false`, `evaluator_loaded: false`,
`runtime_smoke_loaded: false`, `compiled_program_loaded: false`,
`compiler_result_modified: false`, `compilation_report_modified: false`,
`spec_body_chapters_modified: false`, `grammar_parser_modified: false`.

### SC-11: Laziness Inside Isolated Projection (L2-DRY-10)

The structural invariant in `isolated_eval` at line 203:
```ruby
selected = cond_val ? expr["then_branch"] : expr["else_branch"] # lazy
isolated_eval(selected, values, depth + 1)
```
Only one branch is passed to `isolated_eval`. This mirrors the Level 1 evaluator
structure and proves the dry-run inherits the lazy evaluation contract.

Fixture C uses `if_expr_node(condition: lit(true), then_branch: apply(add,3,4), else_branch: escape("laziness_trap"))` with `assumed_condition: true`. Result:
- `projected_value: 7` (then_branch evaluated)
- `projected_failure: nil` (else_branch escape was never reached)

If eager evaluation occurred, `escape("laziness_trap")` would hit the
`REFUSED_KINDS` check and return a `projected_failure`. `projected_failure: nil`
is the behavioral proof that lazy selection is active inside the dry-run context.

### SC-12: NB-2 Disclaimers (from S3-R208-C3-X)

The S3-R208-C3-X NB-2 condition required explicit boolean disclaimers for
`projected_value` and `projected_failure`. Both are present at two levels:
- Per-projection envelope: `projected_value_is_not_actual_output: true`,
  `projected_failure_is_not_actual_failure: true`
- Schema-level summary: `disclaimer.projected_value_is_not_actual_output: true`,
  `disclaimer.projected_failure_is_not_actual_failure: true`

Additionally, `disclaimer.level2_does_not_invalidate_level1_non_execution_guarantee: true`
is present — correctly separating the dry-run context from the Level 1 actual
runtime non-execution guarantee.

---

## Projection Coverage Assessment

Six projections across five fixtures cover all required behavioral cases:

| Projection | Latent kind | Result |
|-----------|------------|--------|
| A (`ref`) | `ref("fallback")` → 99 | `projected_value` path ✓ |
| B (`apply`) | `apply(add, a, b)` → 15 | `projected_value` path ✓ |
| B2 (`field_access`) | `field_access(score_map, "score")` → 77 | `projected_value` path ✓ |
| C (nested `if_expr`) | nested if → `apply(add,3,4)` | Laziness inside dry-run ✓ |
| D (`tbackend_read`) | refused | `projected_failure` refusal path ✓ |
| E (`escape`) | refused | Effect refusal path ✓ |

All pure expression kinds produce `projected_value`. Both refused kinds produce
`projected_failure` with `"note": "Dry-run refusal — not an actual runtime
failure."` — the refusal note explicitly disclaims the failure as non-actual.

---

## Claim Policy Verification

JSON claim_policy confirms four non-equivalences machine-readably:
```json
"projected_value_equals_actual_output":         false
"dry_run_projection_equals_public_runtime":     false
"level2_equals_live_non_selected_evaluation":   false
"level2_grants_cache_dependency_authority":     false
"level2_grants_report_result_authority":        false
```

Maximum allowed claim accepted in JSON:
```text
Proof-local Level 2 counterfactual dry-run concept evidence: latent branches
can be evaluated inside an experiment-local isolated projection envelope with
no-authority disclaimers, explicit premise_set, and full isolation block.
```

This is bounded and accurate.

---

## Non-Blocking Notes

None. The proof is complete, well-bounded, and addresses all R208-C3-X conditions.

---

## Verdict

```text
PASS — 12/12 PASS, no blockers, no non-blocking notes
C4-A may accept proof closure
```

S3-R209-C2-I is a correctly bounded proof-local Level 2 concept proof. All
L2-DRY-1..L2-DRY-15 checks pass (52/52). The harness is self-contained Ruby
with no lib/ loading — isolation is structural rather than behavioral-claim-only.
The isolation and authority blocks are frozen constants ensuring all-false values
structurally. Laziness inside the dry-run is proven behaviorally by the nested
`if_expr` escape-trap fixture. The forbidden vocabulary scan covers all 17 terms
and is independently confirmed CLEAR for all projection fields. Both NB conditions
from S3-R208-C3-X are satisfied. All closed surfaces are confirmed unchanged.

---

## C4-A Recommendation

**Accept S3-R209-C2-I as proof-local Level 2 counterfactual dry-run concept evidence.**

Required acceptance decisions for C4-A:

1. **Accept L2-DRY-1..L2-DRY-15 / 52/52 PASS** as proof-local Level 2 concept
   evidence that latent `if_expr` branches can be evaluated inside an
   experiment-local isolated projection envelope with no-authority disclaimers
   and explicit `premise_set`.

2. **Accept summary SHA** as anchor:
   `sha256:9463d8dc2ecce570423cf4e1385d1d40f0e4e0231b854d93a4db5fd5848ae8ba`

3. **Accept the maximum allowed claim** as binding:
   ```text
   Proof-local Level 2 counterfactual dry-run concept evidence: latent branches
   can be evaluated inside an experiment-local isolated projection envelope with
   no-authority disclaimers, explicit premise_set, and full isolation block.
   ```

4. **Record the five-level claim policy** as binding:
   ```text
   projected_value != actual_output
   projected_failure != actual_runtime_failure
   dry_run_projection != public_runtime_support
   Level2_proof != public_counterfactual_support
   Level2_proof != live_non_selected_evaluation
   ```

5. **Confirm `tbackend_read` remains refuse-only** in any future Level 2
   expansion. Fixture D proves the refusal path works correctly. Any non-refusal
   behavior for `tbackend_read` requires a separate temporal/runtime gate.

6. **Confirm all closed surfaces remain closed:** `lib/**`, parser/grammar,
   TypeChecker/SemanticIR schema, runtime/evaluator, RuntimeSmoke, proof
   RuntimeMachine, effect/external IO, Ledger/TBackend live reads, dependency/
   cache authority, CompilationReport/CompilerResult/receipt/CompatibilityReport
   mutation, spec-body promotion, public API/CLI, release/public/Spark/API/CLI
   claims.

7. **Confirm Level 1 non-execution guarantee is not invalidated** by Level 2.
   Level 1 describes the actual runtime path; Level 2 is an explicit isolated
   projection in a separate evaluation context.

8. **Do not promote `counterfactual_dry_run_projection` to a canonical schema**
   without a separate schema/report/API decision. It remains proof-local evidence.

---

[Agree]
- Write scope exactly matches C1-A authorization: 3 files, all within
  `experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/`
  and track doc.
- `isolated_eval` is self-contained Ruby (no lib/ loading); isolation is
  structural, not behavioral-claim-only.
- Laziness inside dry-run is proven behaviorally by the escape-trap nested
  `if_expr` fixture: `projected_value: 7`, `projected_failure: nil`.
- Isolation and authority blocks are frozen Ruby constants — all-false is
  structurally guaranteed, not asserted-only.
- Forbidden vocabulary scan covers 17 terms (14 R206/R207 + 3 adjacent-concept
  terms); rg matches are only in `terms_checked` array and a comment, confirmed
  CLEAR for all projection fields by independent Python check.
- Both NB conditions from S3-R208-C3-X satisfied: NB-1 (full 17-term scan),
  NB-2 (explicit per-projection and schema-level boolean disclaimers).
- Level 1 `non_execution_guarantee` explicitly preserved in disclaimer block.
- PROP-032 not amended; assumptions-shaped premise refs correctly disclaimed.

[Challenge]
- None.

[Missing]
- Nothing. The proof is complete.

[Sharper Question]
- The proof uses hand-authored `premise_set` with `input_snapshot_ref:
  "proof-local-snapshot"`. A future expansion using emitted SemanticIR from
  actual compiler output would need a more specific `input_snapshot_ref` (e.g.,
  pointing to an actual execution summary). When should that expansion be
  authorized, and does it require a new C1-A?

[Route]
- accept — C4-A should accept S3-R209-C2-I unconditionally and may close the
  Level 2 concept proof route.
