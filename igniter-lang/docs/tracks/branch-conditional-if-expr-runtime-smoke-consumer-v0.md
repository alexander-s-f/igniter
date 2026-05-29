# Branch Conditional If Expr Runtime Smoke Consumer v0

Card: S3-R203-C2-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `branch-conditional-if-expr-runtime-smoke-consumer-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-29

Depends on:
- S3-R203-C1-A

---

## Summary

Implemented a bounded proof-owned RuntimeSmoke consumer harness for `if_expr`.
Proves RS-IF1..RS-IF16 (53 checks, all PASS).

The harness:
- Direct-requires `IgniterLang::RuntimeSmoke` without touching the root require
- Programmatically generates proof-owned `.igapp` directories under the experiment's `out/` tree
- Calls `IgniterLang::RuntimeSmoke.run` directly against those artifacts
- Covers condition-true, condition-false, selected `apply`, selected `field_access`, non-selected branch isolation, malformed rescue, and all closed-surface checks

No files outside the authorized write scope were modified.

---

## Authorized Write Scope

Written:
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/` (runtime output)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md` (this file)

Read-only (unchanged, scanned/verified):
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/lib/igniter_lang.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`

---

## Proof Artifacts

### `.igapp` Artifacts (proof-owned, under `out/rs-if-proof-v0/igapps/`)

| File | Contract | Purpose |
|------|----------|---------|
| `rs_if3_cond_true.igapp/` | `IfExprCondTrue` | if_expr condition=true → then_branch literal 42 |
| `rs_if4_cond_false.igapp/` | `IfExprCondFalse` | if_expr condition=false → else_branch literal 99 |
| `rs_if5a_selected_apply.igapp/` | `IfExprSelectedApply` | Selected then_branch uses `apply` (proof RM-local) |
| `rs_if5b_selected_field_access.igapp/` | `IfExprSelectedFieldAccess` | Selected then_branch uses `field_access` (proof RM-local) |
| `rs_if6_non_selected_no_fire.igapp/` | `IfExprNonSelectedNoFire` | Condition=true; else_branch `apply` must not fire |
| `rs_if16_malformed_if_expr.igapp/` | `IfExprMalformed` | Missing `condition` key → blocked failure shape |
| `rs_regression_apply.igapp/` | `ProofApplyRegression` | Non-if_expr regression; apply-only contract |

All artifacts created programmatically by the harness. No borrowed, relabeled, or mutated prior evidence.

### Summary JSON

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json
sha256:b866973f0ef0f1463ba28d8e67fe8b77293b163b2159ef5a0ddabe94c6ad9492
```

---

## Proof Matrix

| ID | Check | Result |
|----|-------|--------|
| RS-IF1 | Direct-require `RuntimeSmoke` | PASS (3 sub-checks) |
| RS-IF2 | Transitive evaluator load classified | PASS (4 sub-checks) |
| RS-IF3 | `RuntimeSmoke.run` on condition=true artifact | PASS (4 sub-checks) |
| RS-IF4 | `RuntimeSmoke.run` on condition=false artifact | PASS (3 sub-checks) |
| RS-IF5a | Selected branch uses proof RM-local `apply` | PASS (3 sub-checks) |
| RS-IF5b | Selected branch uses proof RM-local `field_access` | PASS (2 sub-checks) |
| RS-IF6 | Non-selected branch does not fire | PASS (2 sub-checks) |
| RS-IF7 | Existing `RuntimeSmoke.run` result shape unchanged | PASS (4 sub-checks) |
| RS-IF8 | Existing `RuntimeSmoke.callback` behavior unchanged | PASS (3 sub-checks) |
| RS-IF9 | Existing `RuntimeSmoke.eval_input_for` unchanged | PASS (3 sub-checks) |
| RS-IF10 | Dual-path evaluator preserved | PASS (3 sub-checks) |
| RS-IF11 | Compiler/result/report closure | PASS (4 sub-checks) |
| RS-IF12 | Root require closure | PASS (2 sub-checks) |
| RS-IF13 | Dependency/cache closure | PASS (2 sub-checks) |
| RS-IF14 | Counterfactual audit closure | PASS (2 sub-checks) |
| RS-IF15 | Release/public/Spark/API/CLI closure | PASS (4 sub-checks) |
| RS-IF16 | Rescue behavior for malformed `if_expr` | PASS (5 sub-checks) |

**Total: 53/53 PASS**

---

## Key Findings

### RS-IF2: Transitive Evaluator Load Classification

Load chain: `runtime_smoke.rb` → `compiled_program.rb` → `semanticir_expression_evaluator.rb`

- `runtime_smoke.rb` has no direct reference to `SemanticIRExpressionEvaluator`
- `compiled_program.rb` loads the evaluator via `require_relative`
- The evaluator is therefore available transitively when RuntimeSmoke is used
- **Claim policy**: transitive load ≠ RuntimeSmoke support of `if_expr`

### RS-IF3 / RS-IF4: Condition Branch Selection

- Condition=true: `RuntimeSmoke.run` returns `trusted: true`, `outputs: {"result" => 42}` (then_branch)
- Condition=false: `RuntimeSmoke.run` returns `trusted: true`, `outputs: {"result" => 99}` (else_branch)

### RS-IF5a / RS-IF5b: Adapter Path Through Smoke

- `apply` expression in selected then_branch: `apply(stdlib.integer.add, 10, 5)` → 15 via proof RM-local handler
- `field_access` in selected then_branch: `field_access({"x"=>77,"y"=>88}, "x")` → 77 via proof RM-local handler
- Both routed through `SemanticIRExpressionEvaluator#evaluate` → `external_evaluator` callback → proof RM `eval_expr`

### RS-IF6: Non-Selected Branch Isolation

- Condition=true, else_branch contains `apply(stdlib.integer.add, 1, 2)`
- Result: `trusted: true`, `outputs: {"result" => 42}` (then_branch only)
- Non-selected `apply` never executed — proves lazy branch selection through smoke path

### RS-IF7: Result Shape

Success keys: `compatibility_report_status`, `contract_id`, `evaluate_status`, `load_status`, `outputs`, `trusted`

Failure keys: `error`, `load_status`, `trusted`

Shapes unchanged; verified against all proof artifacts.

### RS-IF16: Rescue Behavior

Malformed `if_expr` (missing `condition` key) → `MalformedIfExprError` → RuntimeSmoke rescue:
- `load_status: "blocked"`, `trusted: false`, `error:` contains error class/message
- No diagnostics/compilation_report/compiler_result key widening

---

## Closed Surfaces Verified

| Surface | Status |
|---------|--------|
| `runtime_smoke.rb` edits | Closed — source scanned, unchanged |
| `semanticir_expression_evaluator.rb` edits | Closed — source scanned, unchanged |
| `compiled_program.rb` edits | Closed — source scanned, unchanged |
| Root require (`igniter_lang.rb`) edits | Closed — source scanned, no new requires |
| `CompilerOrchestrator` | Closed — not loaded by proof; source scanned |
| `CompilerResult` | Closed — source scanned, no if_expr refs |
| `CompilationReport` | Closed — source scanned, no if_expr refs |
| `CompilerOrchestrator#compile(..., runtime_smoke:)` | Closed — not called |
| Counterfactual audit | Closed — no dry_run/eager_branch/counterfactual in evaluator code |
| Dynamic dependency/cache tracking | Closed — no cache semantics in evaluator |
| Release commands | Closed — no git push / gem push in proof script |
| Public demo/stable/production claims | Closed |
| Spark/API/CLI | Closed |

---

## Dual-Path Evaluator Regression

The Slice 1/2 dual-path evaluator is verified intact:
- Slice 1 structural proof strings present: `eval_expr(expr.fetch("then_branch"), values, call_trace) # line A: then_branch only`
- Slice 2 ext path present: `eval_expr_ext(expr, values, call_trace, external_evaluator)`
- Both paths work independently (verified in RS-IF10.slice1_and_slice2_both_work)

PRT proof regression (S3-R201-C2-I): 56/56 PASS (SHA unchanged: `sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374`)

---

## Command Matrix Output

```bash
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
# → Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
# → PASS branch_conditional_if_expr_runtime_smoke_consumer_v0
# → checks_total=53 checks_pass=53 checks_fail=0

ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
# → Syntax OK

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
# → Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
# → PASS branch_conditional_if_expr_proof_runtime_consumer_v0
# → checks_total=56 checks_pass=56 checks_fail=0
```

---

## Claim Policy (Binding)

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

Maximum allowed description (if later accepted by C4-A):

```text
RuntimeSmoke has proof-context consumer evidence for if_expr through the
existing proof RuntimeMachine path.
```

Forbidden descriptions remain closed:
- `if_expr public runtime support`
- `if_expr production runtime support`
- `RuntimeSmoke public support for if_expr`
- `stable/all-grammar runtime support`
- `release/demo evidence`
- `Spark/API/CLI integration`

---

## Exact Dispatch

```text
Card: S3-R203-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-runtime-smoke-consumer-v0
Route: UPDATE
Status: done
Depends on:
- S3-R203-C1-A
```
