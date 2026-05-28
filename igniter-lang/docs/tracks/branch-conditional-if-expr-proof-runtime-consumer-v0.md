# Branch Conditional If Expr Proof Runtime Consumer v0

Card: S3-R201-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-proof-runtime-consumer-v0
Route: UPDATE
Status: done / proof-passed
Date: 2026-05-28

Depends on:
- S3-R201-C1-A

---

## Purpose

Implement the bounded Slice 2 proof RuntimeMachine consumer: add the
backward-compatible `external_evaluator:` per-call hook to
`SemanticIRExpressionEvaluator`, wire the proof RuntimeMachine `if_expr`
evaluation through the evaluator via the adapter boundary, and prove
PRT-IF1..PRT-IF15.

This card does not edit `RuntimeSmoke`, root require, `CompilerOrchestrator`,
`CompilerResult`, `CompilationReport`, `Diagnostics`, parser, TypeChecker,
SemanticIR emitter, assembler, loader/report, `CompatibilityReport`, docs/spec,
release evidence, package/release files, public API/CLI, or Spark. It does not
run release commands, create tags, push, publish, sign, or deploy. It does not
claim public demo / stable / production / all-grammar / runtime support and does
not canonize runtime diagnostic codes.

---

## Authorization Basis

- S3-R201-C1-A: `authorized-bounded-slice2-proof-runtime-consumer-implementation`
  - R200 status: accepted-design-authorize-later-implementation-authorization-review
  - R200 C3-A accepted adapter boundary design
  - R200 pressure (C2-X): 13/13 PASS; two ambiguity notes resolved by C3-A
  - Accepted API amendment: per-call `external_evaluator:` keyword only;
    constructor injection rejected
  - `apply`, `field_access`, `tbackend_read` remain proof RuntimeMachine-local
  - `RuntimeSmoke`, root require, compiler/result/report surfaces, release,
    public, Spark, cache authority, counterfactual audit remain closed

---

## Changed File List

| File | Change |
| --- | --- |
| `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` | Edited — add Slice 2 path (`eval_expr_ext`, `eval_if_expr_ext`) and `external_evaluator:` hook |
| `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` | Edited — add direct-require of evaluator and `if_expr` case in `eval_expr` via adapter |
| `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb` | New — proof harness (PRT-IF1..PRT-IF15) |
| `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/out/branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json` | New — generated summary |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md` | This track doc (new) |

No other files changed.

---

## Command Matrix Results

```text
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
→ Syntax OK

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
→ Syntax OK

ruby -c igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
→ Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
→ PASS branch_conditional_if_expr_proof_runtime_consumer_v0
   checks_total=56
   checks_pass=56
   checks_fail=0
   failed_checks=[]
   PRT-IF1:  PASS (3 sub-checks)
   PRT-IF2:  PASS (3 sub-checks)
   PRT-IF3:  PASS (3 sub-checks)
   PRT-IF4:  PASS (2 sub-checks)
   PRT-IF5:  PASS (4 sub-checks)
   PRT-IF6:  PASS (3 sub-checks)
   PRT-IF7:  PASS (2 sub-checks)
   PRT-IF8:  PASS (2 sub-checks)
   PRT-IF9:  PASS (5 sub-checks)
   PRT-IF10: PASS (4 sub-checks)
   PRT-IF11: PASS (4 sub-checks)
   PRT-IF12: PASS (6 sub-checks)
   PRT-IF13: PASS (4 sub-checks)
   PRT-IF14: PASS (4 sub-checks)
   PRT-IF15: PASS (7 sub-checks)
   summary_sha256=sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374

ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
→ PASS branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0
   checks_total=68
   checks_pass=68
   checks_fail=0
   failed_checks=[]
   summary_sha256=sha256:8e72338e6210a8b05f3a50a9819f74fe231ea465a7519f89c0c9ad1ba80fa62e
   (unchanged — regression OK)

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
→ PASS branch_conditional_if_expr_runtime_evaluator_proof_v0
   checks_total=54
   checks_pass=54
   checks_fail=0
   failed_checks=[]
   summary_sha256=sha256:62be7c1c292b03eaaeec6f306926d8a1a5a8796cbf9c64522657680fa0b08495
   (unchanged — regression OK)

ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
→ PASS branch_conditional_if_expr_release_harness_delta_v0
   evidence_label=if_expr_internal_compiler_delta
   evidence_class=post_alpha_compiler_only_delta
   checks_total=39
   checks_pass=39
   checks_fail=0
   old_harness_sha256_matched=true
   summary_sha256=sha256:882f407a52659d122b3fd6b73f874a68693c4023b80d7d493c65e755ae9cd364
   (unchanged — regression OK)
```

---

## Proof Matrix Result

| ID | Required proof | Sub-checks | Result |
| --- | --- | --- | --- |
| PRT-IF1 | `if_expr` condition=true returns `then_branch` | 3 | PASS |
| PRT-IF2 | `if_expr` condition=false returns `else_branch` | 3 | PASS |
| PRT-IF3 | Selected branch contains `apply` — proof RM local path through adapter | 3 | PASS |
| PRT-IF4 | Selected branch contains `field_access` — proof RM local path through adapter | 2 | PASS |
| PRT-IF5 | Selected-path `tbackend_read` ownership — structural proof | 4 | PASS |
| PRT-IF6 | Non-selected branch with unsupported kind does not fire | 3 | PASS |
| PRT-IF7 | Non-selected `tbackend_read` without backend/as_of does not fire | 2 | PASS |
| PRT-IF8 | Condition failure — branches not evaluated | 2 | PASS |
| PRT-IF9 | Non-Bool condition fails closed; no truthy/falsy coercion | 5 | PASS |
| PRT-IF10 | Malformed `if_expr` fails closed | 4 | PASS |
| PRT-IF11 | Nested `if_expr` with selected local kind — lazy recursion works | 4 | PASS |
| PRT-IF12 | Existing non-`if_expr` proof RM fixtures — no regression | 6 | PASS |
| PRT-IF13 | Direct-require/root-require scan | 4 | PASS |
| PRT-IF14 | RuntimeSmoke closure scan | 4 | PASS |
| PRT-IF15 | Report/public/release/Spark closure scan | 7 | PASS |

Total: **56/56 PASS** (15/15 PRT-IF items PASS)

---

## Evaluator Architecture (Slice 2 Amendment)

### Two-Path Design

The Slice 2 amendment preserves the Slice 1 evaluation pipeline intact and adds
a parallel Slice 2 extension path:

```
evaluate(expr, values, call_trace:, external_evaluator:)
  │
  ├── external_evaluator absent  →  eval_expr(expr, values, call_trace)
  │     [Slice 1 path — original 3-arg signature, no delegation]
  │
  └── external_evaluator present →  eval_expr_ext(expr, values, call_trace, ext_ev)
        [Slice 2 path — adds delegation for unsupported selected-path kinds]
```

This two-path design preserves Slice 1 structural proof invariants
(LRT-IF12: exact source patterns in `eval_if_expr` remain unchanged) while
adding the Slice 2 extended pipeline in separate methods.

### Evaluator Public API (Slice 2 amendment — backward-compatible)

```ruby
evaluator = IgniterLang::SemanticIRExpressionEvaluator.new

# Slice 1 (unchanged): no external_evaluator
value = evaluator.evaluate(expr, values)
value = evaluator.evaluate(expr, values, call_trace: trace)

# Slice 2 (new): with external_evaluator
ext_ev = ->(sub_expr, sub_vals) { ... }  # proof RuntimeMachine local handler
value = evaluator.evaluate(expr, values, external_evaluator: ext_ev)
value = evaluator.evaluate(expr, values, call_trace: trace, external_evaluator: ext_ev)
```

`external_evaluator` is a callable invoked as `external_evaluator.call(expr, values)`.
It captures `backend`, `as_of`, and any other proof RuntimeMachine context in its closure.
Exceptions propagate unchanged. Never called for non-selected branches or before
condition evaluation.

### Proof RuntimeMachine Adapter (`compiled_program.rb`)

The `eval_expr` method in `CompiledProgram` now handles `if_expr` via the adapter:

```ruby
when "if_expr"
  # Create external_evaluator closure capturing backend and as_of for local kinds.
  ext_ev = ->(sub_expr, sub_vals) { eval_expr(sub_expr, sub_vals, backend: backend, as_of: as_of) }
  if_expr_evaluator.evaluate(expr, values, external_evaluator: ext_ev)
```

- Evaluator owns: `if_expr` lazy selection, `literal`, `ref`
- Proof RuntimeMachine local (via `ext_ev` closure): `apply`, `field_access`, `tbackend_read`
- `if_expr_evaluator` is a lazy singleton `IgniterLang::SemanticIRExpressionEvaluator` instance

### Expression-Kind Ownership

| Kind | Owner |
| --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` |
| `ref` | `SemanticIRExpressionEvaluator` |
| `if_expr` (lazy selection) | `SemanticIRExpressionEvaluator` |
| `apply` | proof RuntimeMachine local |
| `field_access` | proof RuntimeMachine local |
| `tbackend_read` | proof RuntimeMachine / temporal-owned |

---

## Key Proof Points

### PRT-IF3: Selected `apply` branch routes through adapter

```ruby
# condition=true → then_branch=apply(add, 10, 5) → ext_ev called → 15
prog.evaluate_contract("...", {}, backend: nil, as_of: nil)
# → result = 15

# Flow:
# 1. eval_expr sees if_expr → creates ext_ev, calls evaluator.evaluate(if_expr, ...)
# 2. Evaluator selects then_branch (apply node)
# 3. apply unsupported → calls ext_ev.call(apply_node, values)
# 4. ext_ev = compiled_program's eval_expr → handles apply → returns 15
```

### PRT-IF5: `tbackend_read` ownership structural proof

1. `tbackend_read` NOT in `SUPPORTED_KINDS` (verified: `%w[literal ref if_expr]`)
2. Without `external_evaluator`: selected-path `tbackend_read` raises `UnsupportedExpressionKindError`
3. With `external_evaluator`: reaches the callable (not evaluator core), raises `ArgumentError`
   (proof: `"tbackend_read requires a backend"` in the error message from ext_ev)
4. In `compiled_program.rb`: `tbackend_read` case arm is local, NOT routed through `if_expr_evaluator`

### PRT-IF6 / PRT-IF7: Non-selected branch isolation

```ruby
# condition=false; then_branch=apply (never touched)
call_count = 0
ext_ev = ->(_, _) { call_count += 1; raise "should not be called" }
ev.evaluate(if_expr(condition: lit(false), then_branch: apply_expr(...), else_branch: lit(77)),
            {}, external_evaluator: ext_ev)
# → result = 77, call_count = 0

# condition=true; then_branch=lit(42), else_branch=tbackend_read (backend=nil, not touched)
prog.evaluate_contract(..., backend: nil, as_of: nil)
# → result = 42, no tbackend_read error
```

### PRT-IF11: Nested if_expr with apply in selected inner branch

```ruby
if_expr(condition: true,
  then_branch: if_expr(condition: true,
    then_branch: apply(add, 5, 6),  # → 11
    else_branch: lit(0)),
  else_branch: lit(0))
# → result = 11
```

---

## Closed-Surface Scan

| Surface | Result |
| --- | --- |
| `lib/igniter_lang.rb` (root require) | Not modified — `semanticir_expression_evaluator` not in root require — CLEAR |
| `lib/igniter_lang/runtime_smoke.rb` | Not modified; no evaluator reference; no if_expr dispatch — CLEAR |
| `lib/igniter_lang/compiler_orchestrator.rb` | Not modified; no evaluator reference — CLEAR |
| `lib/igniter_lang/compiler_result.rb` | Not modified; no evaluator reference — CLEAR |
| `lib/igniter_lang/compilation_report.rb` | Not modified; no evaluator reference — CLEAR |
| `lib/igniter_lang/typechecker.rb` | Not modified — CLEAR |
| `lib/igniter_lang/semanticir_emitter.rb` | Not modified — CLEAR |
| Diagnostics/CompilationReport/CompilerResult loaded (proof) | None loaded — CLEAR |
| `experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb` | Not modified — CLEAR |
| Release harness / first-RC / smoke evidence | Not in write scope; SHA unchanged — CLEAR |
| `docs/spec/` | Not in write scope — CLEAR |
| `README.md`, `RELEASE_NOTES.md`, `igniter_lang.gemspec` | Not modified — CLEAR |
| Slice 1 proof SHA | sha256:8e72338e6210a8b05f3a50a9819f74fe231ea465a7519f89c0c9ad1ba80fa62e (unchanged) |
| RT proof SHA | sha256:62be7c1c292b03eaaeec6f306926d8a1a5a8796cbf9c64522657680fa0b08495 (unchanged) |
| Release harness SHA | sha256:882f407a52659d122b3fd6b73f874a68693c4023b80d7d493c65e755ae9cd364 (unchanged) |

---

## Evaluator Amendment Note

The `external_evaluator:` parameter uses a **two-path design** to preserve Slice 1
structural proof invariants:

- Slice 1 private methods (`eval_expr`, `eval_if_expr`) retain their original
  3-argument signatures unchanged, so `LRT-IF12.structural_proof_mutually_exclusive_arms`
  continues to find the exact source patterns it checks for.
- Slice 2 adds parallel methods (`eval_expr_ext`, `eval_if_expr_ext`) with the
  4-argument signature, used only when `external_evaluator:` is provided.
- The public `evaluate` method dispatches to the appropriate path.

This preserves full backward compatibility with the Slice 1 proof (68/68 PASS,
SHA unchanged) while cleanly adding Slice 2 delegation.

---

## Non-Claims

```text
no_release_execution:                    true
no_public_demo_claim:                    true
no_stable_production_all_grammar_claim:  true
no_spark_claim:                          true
no_public_api_cli_widening:              true
no_runtime_smoke_integration:            true
no_compiler_orchestrator_integration:    true
no_counterfactual_audit:                 true
no_dynamic_dependency_tracking:          true
no_root_require_change:                  true
no_compiler_result_change:               true
no_compilation_report_change:            true
no_tbackend_read_in_evaluator_core:      true
no_constructor_injection:                true
```

The `external_evaluator:` hook is a per-call adapter bridge. It does not widen
the evaluator's `SUPPORTED_KINDS`, does not add `tbackend_read` to evaluator
core, does not require constructor injection, and does not integrate with
`RuntimeSmoke` or any public surface.

---

## Compact Result

```text
card:                        S3-R201-C2-I
track:                       branch-conditional-if-expr-proof-runtime-consumer-v0
status:                      done / proof-passed
checks_total:                56
checks_pass:                 56
checks_fail:                 0
proof_matrix:                15/15 PRT-IF items PASS
summary_sha256:              sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374
external_evaluator_hook:     per-call keyword, backward-compatible
constructor_injection:       false
if_expr_owned_by:            SemanticIRExpressionEvaluator
apply_owned_by:              proof RuntimeMachine local
field_access_owned_by:       proof RuntimeMachine local
tbackend_read_owned_by:      proof RuntimeMachine / temporal-owned
tbackend_read_in_evaluator:  false
lazy_through_adapter:        true
non_selected_ext_ev_call:    false (proven: PRT-IF6, PRT-IF7)
truthy_falsy_coercion:       false
slice1_regression:           68/68 PASS (SHA unchanged)
rt_proof_regression:         54/54 PASS (SHA unchanged)
release_harness_regression:  39/39 PASS (SHA unchanged)
closed_surface_scan:         CLEAR
```
