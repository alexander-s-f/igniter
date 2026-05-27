# Branch Conditional If Expr Runtime Evaluator Proof Local v0

Card: S3-R197-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-v0
Route: UPDATE
Status: done / proof-passed
Date: 2026-05-27

Depends on:
- S3-R197-C1-A

---

## Purpose

Implement the authorized proof-local if_expr runtime/evaluator semantics
experiment. Proves lazy branch conditional semantics without modifying any live
`lib/` code.

This card does not edit live runtime/evaluator code, RuntimeSmoke,
CompilerOrchestrator, parser, TypeChecker, SemanticIR, assembler, loader/report,
CompatibilityReport, docs/spec, release evidence, package/release files, public
API/CLI, or Spark. It does not run release commands, create tags, push, publish,
sign, or deploy. It does not claim public demo / stable / production / all-grammar
/ runtime support and does not canonize runtime diagnostic codes.

---

## Authorization Basis

- S3-R197-C1-A: `authorized-proof-local-runtime-evaluator-experiment`
  - R196 accepted lazy runtime/evaluator semantics design (C1-D)
  - R196 design decision accepted (C2-D / C3-A)
  - C1-A authorizes proof-local evaluator helper inside experiment only
  - Live `lib/` integration remains closed
  - Dynamic dependency tracking remains deferred

---

## Changed File List

| File | Change |
| --- | --- |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb` | New (proof runner + ProofLocal::IfExprEvaluator) |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json` | New (generated summary) |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md` | This track doc (new) |

No other files changed.

---

## Command Matrix Results

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
→ Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
→ PASS branch_conditional_if_expr_runtime_evaluator_proof_v0
   checks_total=54
   checks_pass=54
   checks_fail=0
   failed_checks=[]
   RT-IF1:  PASS (3 sub-checks)
   RT-IF2:  PASS (3 sub-checks)
   RT-IF3:  PASS (3 sub-checks)
   RT-IF4:  PASS (3 sub-checks)
   RT-IF5:  PASS (3 sub-checks)
   RT-IF6:  PASS (2 sub-checks)
   RT-IF7:  PASS (6 sub-checks)
   RT-IF8:  PASS (4 sub-checks)
   RT-IF9:  PASS (2 sub-checks)
   RT-IF10: PASS (4 sub-checks)
   RT-IF11: PASS (4 sub-checks)
   RT-IF12: PASS (5 sub-checks)
   RT-IF13: PASS (12 sub-checks)
   summary_sha256=sha256:62be7c1c292b03eaaeec6f306926d8a1a5a8796cbf9c64522657680fa0b08495
```

---

## Proof Matrix Result

| Check | Sub-checks | Result |
| --- | --- | --- |
| RT-IF1: Condition `true` → only `then_branch` evaluated; value returned | 3 | PASS |
| RT-IF2: Condition `false` → only `else_branch` evaluated; value returned | 3 | PASS |
| RT-IF3: Non-selected `then_branch` would fail → no failure when condition is `false` | 3 | PASS |
| RT-IF4: Non-selected `else_branch` would fail → no failure when condition is `true` | 3 | PASS |
| RT-IF5: Condition expression fails → branches not evaluated; failure propagates | 3 | PASS |
| RT-IF6: Selected branch failure propagates | 2 | PASS |
| RT-IF7: Non-Bool condition fails closed; no truthy/falsy coercion | 6 | PASS |
| RT-IF8: Missing `condition`/`then_branch`/`else_branch` fails closed as malformed | 4 | PASS |
| RT-IF9: Unknown selected-path expression kind fails closed | 2 | PASS |
| RT-IF10: Unknown non-selected-path expression kind produces no failure | 4 | PASS |
| RT-IF11: Nested `if_expr` — lazy semantics apply recursively | 4 | PASS |
| RT-IF12: Static dependency union stays; selected-branch call path proven | 5 | PASS |
| RT-IF13: Closed-surface scan | 12 | PASS |

Total: **54/54 PASS** (13/13 RT-IF items PASS)

---

## Proof-Local Evaluator Architecture

The `ProofLocal::IfExprEvaluator` class is defined inside the proof experiment
file only. It is not extracted to `lib/` and is not live runtime code.

Supported expression kinds (proof-local only):
```text
literal          — returns expr["value"]
ref              — returns values[expr["name"]]
if_expr          — lazy conditional (see below)
failing_expr     — always raises RuntimeError (used to verify non-selection)
```

Unsupported kinds raise `ProofLocal::UnsupportedExpressionKindError`.

**Lazy evaluation order** (`eval_if_expr`):
```
1. Fail closed if any of condition / then_branch / else_branch is missing
   (MalformedIfExprError)
2. cond_val = eval_expr(condition, values)
3. Guard: cond_val must be exactly true or false
   (ConditionNotBoolError if not)
4. if cond_val == true  → eval_expr(then_branch, values)   # line A: only then_branch
   else                 → eval_expr(else_branch, values)   # line B: only else_branch
```

The two arms of step 4 are mutually exclusive Ruby `if` branches. The
non-selected branch expression is never passed to `eval_expr`.

**Error surface** (proof-local, non-canonical):
```text
ProofLocal::MalformedIfExprError      — missing required if_expr keys
ProofLocal::ConditionNotBoolError     — condition not exactly true/false
ProofLocal::UnsupportedExpressionKindError — unknown expression kind
```

These are not structured runtime codes, not OOF-RT-* vocabulary, and must not
be published or canonized.

---

## Call Trace Evidence

The evaluator accepts an optional `trace: true` flag that records evaluated
expression kinds in order. This provides dynamic proof that the non-selected
branch is never called.

| Scenario | Call trace | Result |
| --- | --- | --- |
| `condition=true`, `then=lit(42)`, `else=lit(99)` | `["if_expr", "literal", "literal"]` | 42 |
| `condition=false`, `then=lit(42)`, `else=lit(99)` | `["if_expr", "literal", "literal"]` | 99 |
| Nested: outer=true→inner(false→fail/42) | `["if_expr", "literal", "if_expr", "literal", "literal"]` | 42 |

For condition=true: the trace shows `if_expr` (outer), `literal` (condition),
`literal` (then_branch value). The `else_branch` literal is NOT in the trace.

For condition=false: identical shape but the second `literal` is the else value.

For nested: only 5 kind-tokens: outer+inner `if_expr` + 3 `literal` (outer cond,
inner cond, inner else). Both `failing_expr` entries are absent from the trace.

---

## Key Proof Points

### RT-IF3 / RT-IF4: Non-selected branch isolation

```ruby
# RT-IF3: condition=false, then_branch=failing_expr → NO error, result=7
result = ev.eval_expr(
  { "kind"=>"if_expr", "condition"=>lit(false),
    "then_branch"=>{ "kind"=>"failing_expr" },
    "else_branch"=>lit(7) }, {})
# → result = 7, call_trace does not include "failing_expr"

# RT-IF4: condition=true, then_branch=lit(7), else_branch=failing_expr → NO error
result = ev.eval_expr(
  { "kind"=>"if_expr", "condition"=>lit(true),
    "then_branch"=>lit(7),
    "else_branch"=>{ "kind"=>"failing_expr" } }, {})
# → result = 7, call_trace does not include "failing_expr"
```

### RT-IF5: Branches not evaluated on condition failure

```ruby
# condition=failing_expr → raises before any branch evaluation
call_trace after rescue: ["if_expr", "failing_expr"]
# "literal" (from branches) is NOT in the trace
```

### RT-IF7: Non-Bool coercion rejected

All non-Bool values fail with `ConditionNotBoolError`:
`42` (Integer), `"truthy"` (String), `nil` (NilClass), `0` (Integer),
`[true]` (Array). No truthy/falsy Ruby semantics applied.

### RT-IF12: Structural + dynamic proof

Structural: `eval_if_expr` contains two mutually exclusive Ruby `if` arms
(verified via source inspection):
```ruby
if cond_val == true
  eval_expr(expr.fetch("then_branch"), values) # line A: only then_branch
else
  eval_expr(expr.fetch("else_branch"), values) # line B: only else_branch
end
```

Dynamic: RT-IF3 and RT-IF4 prove at runtime that a would-fail expression in the
non-selected branch never fires, confirming `eval_expr` is never called on the
non-selected side.

Dependency policy: static TypeChecker union (condition + then + else) is
preserved unchanged. Dynamic selected-branch dependency tracking is deferred
per C1-A.

---

## Closed-Surface Scan

| Surface | Result |
| --- | --- |
| `lib/igniter_lang/**` | Not in write scope — CLEAR |
| `experiments/runtime_machine_memory_proof/compiled_program.rb` | Not modified — CLEAR |
| `lib/igniter_lang/runtime_smoke.rb` | Not modified — CLEAR |
| `lib/igniter_lang/compiler_orchestrator.rb` | Not modified — CLEAR |
| `lib/igniter_lang/typechecker.rb` | Not modified — CLEAR |
| `lib/igniter_lang/semanticir_emitter.rb` | Not modified — CLEAR |
| Release harness / first-RC / smoke evidence | Not in write scope — CLEAR |
| `docs/spec/` | Not in write scope — CLEAR |
| `README.md`, `RELEASE_NOTES.md`, `igniter_lang.gemspec` | Not modified — CLEAR |
| Live runtime/evaluator modules loaded | None loaded — CLEAR |
| Compiler pipeline modules loaded | None loaded — CLEAR |
| `git diff` on all closed paths | Zero output — CLEAR |

---

## Non-Claims

```text
no_release_execution:                    true
no_public_demo_claim:                    true
no_stable_production_all_grammar_claim:  true
no_spark_claim:                          true
no_public_api_cli_widening:              true
no_live_runtime_integration:             true
no_compiler_behavior_change:             true
```

The `ProofLocal::IfExprEvaluator` is a proof-local class inside the experiment
file only. It does not integrate with `RuntimeSmoke`, `CompilerOrchestrator`, or
any `lib/` runtime module. It is not production runtime evidence, not public
demo evidence, not all-grammar evidence, and not official release evidence.

---

## Compact Result

```text
card:                  S3-R197-C2-I
track:                 branch-conditional-if-expr-runtime-evaluator-proof-local-v0
status:                done / proof-passed
checks_total:          54
checks_pass:           54
checks_fail:           0
proof_matrix:          13/13 RT-IF items PASS
summary_sha256:        sha256:62be7c1c292b03eaaeec6f306926d8a1a5a8796cbf9c64522657680fa0b08495
semantics.lazy:        true
non_selected_eval:     forbidden (proven dynamically via RT-IF3, RT-IF4, RT-IF5)
truthy_falsy_coercion: false (proven via RT-IF7: 5 non-Bool types rejected)
static_union:          true (TypeChecker unchanged)
dynamic_tracking:      deferred
error_surface:         proof_local_plain_raise_or_error_object (non-canonical)
live_runtime_changed:  false
lib_changed:           false
closed_surface_scan:   CLEAR
```
