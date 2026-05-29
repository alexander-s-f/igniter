# Branch Conditional If Expr Runtime Smoke Consumer Proof Pressure v0

Card: S3-R203-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-if-expr-runtime-smoke-consumer-proof-pressure-v0`

---

## Question

Does the S3-R203-C2-I proof-owned RuntimeSmoke consumer harness stay inside the
S3-R203-C1-A authorized write scope, correctly preserve the unmodified
RuntimeSmoke run/callback/eval_input_for shape, prove RS-IF1..RS-IF16 completely
(including both RS-IF5a apply and RS-IF5b field_access and the mandatory RS-IF16
rescue check), treat the transitive evaluator load strictly as a non-support
fact, generate proof-owned `.igapp` artifacts programmatically under the
authorized `out/` tree, and leave runtime_smoke.rb, compiled_program, evaluator,
root require, CompilerOrchestrator, CompilerResult, CompilationReport, dynamic
dep/cache, counterfactual audit, release, public runtime support claims, and
Spark/API/CLI all closed?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md` (C2-I track doc, 53/53 PASS)
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0.md` (C1-A authorization decision)
- `igniter-lang/docs/tracks/stage3-round202-status-curation-v0.md` (R202 binding requirements)
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb` (read-only scan)
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` (read-only scan, from R201)
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` (read-only scan, from R201)

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Write scope within C1-A authorization only (proof harness, out/, track doc) | PASS |
| SC-2 | RuntimeSmoke source unchanged (`runtime_smoke_file_changed: false`) | PASS |
| SC-3 | Proof RuntimeMachine source unchanged (`compiled_program_file_changed: false`) | PASS |
| SC-4 | Evaluator source unchanged (`evaluator_file_changed: false`) | PASS |
| SC-5 | Root require unchanged (`root_require_changed: false`; RS-IF12 2 sub-checks PASS) | PASS |
| SC-6 | RuntimeSmoke.run success/failure key sets unchanged and exactly verified (RS-IF7, 4 sub-checks) | PASS |
| SC-7 | RuntimeSmoke.callback unchanged and lambda shape verified (RS-IF8, 3 sub-checks) | PASS |
| SC-8 | RuntimeSmoke.eval_input_for unchanged, no if_expr special case added (RS-IF9, 3 sub-checks) | PASS |
| SC-9 | `.igapp` artifacts programmatically generated, proof-owned under `out/rs-if-proof-v0/igapps/` | PASS |
| SC-10 | RS-IF1..RS-IF16 all pass: 53/53 PASS | PASS |
| SC-11 | Both RS-IF5a (apply) and RS-IF5b (field_access) present and individually PASS | PASS |
| SC-12 | RS-IF2 covers both source/claim scan AND behavioral load-without-eval assertion (4 sub-checks) | PASS |
| SC-13 | RS-IF16 proves blocked failure shape for malformed if_expr (5 sub-checks, trusted: false) | PASS |
| SC-14 | No CompilerOrchestrator callback integration (`no_compiler_orchestrator_callback: true`; RS-IF11) | PASS |
| SC-15 | CompilerOrchestrator, CompilerResult, CompilationReport unchanged (RS-IF11, 4 sub-checks) | PASS |
| SC-16 | Release evidence not mutated; SHAs unchanged (RS-IF15: release_harness_sha_unchanged + slice1_proof_sha_unchanged) | PASS |
| SC-17 | No public runtime/support/production claims (`transitive_evaluator_load_equals_runtime_smoke_support: false`; `runtime_smoke_proof_support_equals_public_runtime: false`; RS-IF15) | PASS |
| SC-18 | Dynamic dependency/cache authority deferred (`no_dynamic_dependency_tracking: true`; RS-IF13) | PASS |
| SC-19 | Counterfactual audit future pressure only (`no_counterfactual_audit: true`; RS-IF14) | PASS |
| SC-20 | Spark/API/CLI remain closed (`no_spark_claim: true`; `no_public_api_cli_widening: true`; RS-IF15) | PASS |

**Result: 20/20 PASS — no blockers.**

---

## Claim Policy Verification

Three-level support hierarchy binding:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

JSON confirms both boolean guards: `false`. RS-IF2 proves the transitive load chain
(`runtime_smoke.rb` → `compiled_program.rb` → `semanticir_expression_evaluator.rb`)
is classified as an incidental consequence and not a support claim. RS-IF9 confirms
`eval_input_for` has no `if_expr` special case (explicit `sample_input` is used
for all proof contracts that are not the existing `Add` case).

Maximum allowed description verified in JSON:

```text
RuntimeSmoke has proof-context consumer evidence for if_expr through the
existing proof RuntimeMachine path.
```

All forbidden descriptions remain closed (public runtime support, production
support, RuntimeSmoke public support, stable/all-grammar runtime, release/demo
evidence, Spark/API/CLI integration).

---

## Proof Matrix Spot Verification

| Group | Sub-checks | Key assertions confirmed |
|-------|-----------|--------------------------|
| RS-IF1 (3) | PASS | Direct require without root require change; RuntimeSmoke available |
| RS-IF2 (4) | PASS | Source scan: RuntimeSmoke has no direct evaluator reference; behavioral: load without run does not invoke evaluator |
| RS-IF3 (4) | PASS | condition=true → then_branch 42; `trusted: true`; load_status loaded; evaluate_status ok |
| RS-IF4 (3) | PASS | condition=false → else_branch 99; `trusted: true`; not then_branch value |
| RS-IF5a (3) | PASS | `apply(stdlib.integer.add, 10, 5)` → 15; adapter path through smoke confirmed |
| RS-IF5b (2) | PASS | `field_access({"x"=>77,...}, "x")` → 77; selected field_access through smoke |
| RS-IF6 (2) | PASS | condition=true; non-selected else_branch apply does not fire; output from then_branch only |
| RS-IF7 (4) | PASS | Exact success key set (6 keys); exact failure key set (3 keys); `load_status: "blocked"`; `trusted: false` |
| RS-IF8 (3) | PASS | callback source unchanged; returns lambda; lambda produces same result as run |
| RS-IF9 (3) | PASS | eval_input_for returns sample_input for non-Add; returns Add default for Add; no if_expr special case in source |
| RS-IF10 (3) | PASS | Dual-path evaluator has both methods; Slice 1 structural proof strings present; both paths work independently |
| RS-IF11 (4) | PASS | CompilerOrchestrator not loaded; not modified; CompilerResult not modified; CompilationReport not modified |
| RS-IF12 (2) | PASS | Root require not changed; not loaded by proof |
| RS-IF13 (2) | PASS | No cache/dependency tracking in evaluator; call_trace not authority |
| RS-IF14 (2) | PASS | No counterfactual in evaluator; no latent branch evaluation |
| RS-IF15 (4) | PASS | No release commands; release harness SHA unchanged; Slice 1 proof SHA unchanged; no Spark/API/CLI reference |
| RS-IF16 (5) | PASS | Malformed if_expr (missing `condition`) → blocked; load_status blocked; trusted false; error mentions evaluator class; no diagnostics/report widening |

All 17 proof groups independently verified against JSON sub-check names.

---

## Artifact Policy Verification

Seven proof-owned `.igapp` directories created programmatically under
`experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/rs-if-proof-v0/igapps/`:

| Artifact | Contract | Purpose |
|----------|----------|---------|
| `rs_if3_cond_true.igapp/` | `IfExprCondTrue` | condition=true → then_branch 42 |
| `rs_if4_cond_false.igapp/` | `IfExprCondFalse` | condition=false → else_branch 99 |
| `rs_if5a_selected_apply.igapp/` | `IfExprSelectedApply` | selected apply → 15 |
| `rs_if5b_selected_field_access.igapp/` | `IfExprSelectedFieldAccess` | selected field_access → 77 |
| `rs_if6_non_selected_no_fire.igapp/` | `IfExprNonSelectedNoFire` | non-selected else_branch isolation |
| `rs_if16_malformed_if_expr.igapp/` | `IfExprMalformed` | missing `condition` → rescue path |
| `rs_regression_apply.igapp/` | `ProofApplyRegression` | non-if_expr regression baseline |

`igapp_artifacts_proof_owned: true`. None borrowed, relabeled, or mutated from
prior evidence. Artifact location matches C1-A authorized pattern.

---

## Dual-Path Evaluator Regression

RS-IF10 proves Slice 1/Slice 2 separation intact:

- Slice 1 structural proof strings present: `eval_expr(expr.fetch("then_branch"), values, call_trace) # line A: then_branch only`
- Slice 2 ext path: `eval_expr_ext(expr, values, call_trace, external_evaluator)`
- Both paths exercised independently (RS-IF10.slice1_and_slice2_both_work PASS)

PRT proof regression SHA unchanged: `sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374` (56/56 PASS). No dual-path unification or structural-proof rewrite occurred.

---

## Non-Blocking Notes

**NB-1 (minor — proof-hygiene gap):** RS-IF6 covers only `apply` in the
non-selected branch (`non_selected_apply_does_not_fire`, `output_from_then_branch_not_else`).
`field_access` in a non-selected branch has no dedicated negative proof case.
This is a proof-hygiene gap, not a behavioral gap: RS-IF5b proves selected
`field_access` routes correctly through the adapter; RS-IF10 proves the dual-path
lazy-dispatch invariant is structurally preserved. C4-A may accept as-is or note
as a future proof extension.

**NB-2 (informational — inherited non-claims):** The summary JSON non-claims
block (12 keys) does not include `no_constructor_injection` or
`no_tbackend_read_in_evaluator_core`. These are not applicable at the
smoke-harness level: the harness routes through `RuntimeSmoke.run`, not the
evaluator directly. Both remain closed under R201 evaluator acceptance (C1-A
Slice 1, PRT proof SHA unchanged). C4-A should record these as inherited from
R201 rather than as a gap in this proof.

---

## Verdict

```text
proceed — 20/20 PASS, no blockers, 2 non-blocking notes
```

S3-R203-C2-I is a correctly bounded proof-owned RuntimeSmoke consumer harness.
All RS-IF1..RS-IF16 checks pass (53/53). Write scope is confined to the
authorized experiment directory, out/, and track doc. All protected sources are
unchanged. The support-claim hierarchy is strictly maintained in both the JSON
policy block and the individual proof checks.

---

## C4-A Recommendation

**Accept S3-R203-C2-I as proof-owned RuntimeSmoke consumer proof.**

Required acceptance decisions for C4-A:

1. **Accept RS-IF1..RS-IF16 / 53/53 PASS** as proof evidence that RuntimeSmoke
   can consume proof-owned `if_expr` `.igapp` artifacts through the existing
   proof RuntimeMachine path.

2. **Accept summary SHA** as anchor:
   `sha256:b866973f0ef0f1463ba28d8e67fe8b77293b163b2159ef5a0ddabe94c6ad9492`

3. **Record maximum allowed claim** as binding constraint:
   ```text
   RuntimeSmoke has proof-context consumer evidence for if_expr through the
   existing proof RuntimeMachine path.
   ```

4. **Confirm all forbidden descriptions remain closed:**
   `if_expr public runtime support`, `if_expr production runtime support`,
   `RuntimeSmoke public support for if_expr`, `stable/all-grammar runtime support`,
   `release/demo evidence`, `Spark/API/CLI integration`.

5. **Record NB-1 as-is:** RS-IF6 field_access non-selected gap is proof-hygiene
   only; behavioral isolation proven structurally by RS-IF10.

6. **Record NB-2 as-is:** `no_constructor_injection` and
   `no_tbackend_read_in_evaluator_core` remain closed under inherited R201
   acceptance; omission from smoke-harness non-claims is appropriate.

7. **Confirm all closed surfaces remain closed** (per C1-A list):
   `runtime_smoke.rb`, `compiled_program.rb`, `semanticir_expression_evaluator.rb`,
   root require, CompilerOrchestrator, CompilerResult, CompilationReport,
   Diagnostics, release evidence, release commands, public/demo/production claims,
   Spark/API/CLI, dynamic dep/cache, counterfactual audit.

8. **Do not open public RuntimeSmoke `if_expr` support** without a separate
   authorization review. RuntimeSmoke proof-context evidence ≠ public runtime
   support. Any expansion of `eval_input_for`, runtime_smoke.rb, or public API
   surface requires its own C1-A.

---

[Agree]
- Write scope is strictly confined to the authorized experiment directory.
- RS-IF1..RS-IF16 are all present and individually sub-check-named in JSON.
- RuntimeSmoke run/callback/eval_input_for shapes verified unchanged.
- `.igapp` artifacts are programmatically created and proof-owned.
- Transitive evaluator load is correctly classified as non-support fact.
- Dual-path evaluator regression holds; Slice 1 SHA unchanged.
- Rescue behavior (RS-IF16) provides the mandatory malformed-input safety proof.
- Claim policy is correctly machine-enforced in both JSON booleans and proof checks.

[Challenge]
- None. No blockers identified.

[Missing]
- NB-1: `field_access` in non-selected branch not explicitly proven (proof-hygiene gap; behavioral coverage is structurally implied).
- NB-2: Inherited R201 non-claims not echoed in smoke-harness JSON (informational only; covered by R201 acceptance).

[Sharper Question]
- Can the accepted claim be promoted to a public RuntimeSmoke `if_expr` support statement, and if so what does the authorization path look like? (Answer: not yet — requires separate C1-A.)

[Route]
- accept — C4-A should accept S3-R203-C2-I and record the claim policy, SHA anchor, and NB items per the recommendation above.
