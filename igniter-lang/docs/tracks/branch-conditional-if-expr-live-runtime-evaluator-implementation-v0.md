# Branch Conditional If Expr Live Runtime Evaluator Implementation v0

Card: S3-R199-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-v0
Route: UPDATE
Status: done / proof-passed
Date: 2026-05-28

Depends on:
- S3-R199-C1-A

---

## Purpose

Implement the authorized Slice 1 `IgniterLang::SemanticIRExpressionEvaluator`
live internal direct-require evaluator and its proof harness.

This card creates one live `lib/` file and one proof experiment package.
It does not modify root require, RuntimeSmoke, CompilerOrchestrator,
CompilerResult, CompilationReport, Diagnostics, parser, TypeChecker,
SemanticIR emitter, assembler, loader/report, CompatibilityReport,
docs/spec, release evidence, package/release files, public API/CLI, or Spark.
It does not run release commands, create tags, push, publish, sign, or deploy.
It does not claim public demo / stable / production / all-grammar /
runtime support and does not canonize runtime diagnostic codes.

---

## Authorization Basis

- S3-R199-C1-A: `authorized-bounded-slice1-implementation`
  - R198 status: accepted-design-authorized-slice1-implementation-authorization-review
  - Accepted live placement:
    `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
    `IgniterLang::SemanticIRExpressionEvaluator`
  - Slice 1 expression kinds: literal, ref, if_expr only
  - apply/field_access/tbackend_read excluded
  - Root require remains closed
  - RuntimeSmoke/CompilerOrchestrator/CompilerResult/CompilationReport closed
  - Dynamic dependency tracking deferred
  - Counterfactual audit future pressure only

---

## Changed File List

| File | Change |
| --- | --- |
| `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` | New (live internal evaluator) |
| `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb` | New (proof harness) |
| `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json` | New (generated summary) |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md` | This track doc (new) |

No other files changed.

---

## Command Matrix Results

```text
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
→ Syntax OK

ruby -c igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
→ Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
→ PASS branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0
   checks_total=68
   checks_pass=68
   checks_fail=0
   failed_checks=[]
   LRT-IF1:  PASS (4 sub-checks)
   LRT-IF2:  PASS (4 sub-checks)
   LRT-IF3:  PASS (3 sub-checks)
   LRT-IF4:  PASS (3 sub-checks)
   LRT-IF5:  PASS (3 sub-checks)
   LRT-IF6:  PASS (2 sub-checks)
   LRT-IF7:  PASS (8 sub-checks)
   LRT-IF8:  PASS (5 sub-checks)
   LRT-IF9:  PASS (3 sub-checks)
   LRT-IF10: PASS (4 sub-checks)
   LRT-IF11: PASS (5 sub-checks)
   LRT-IF12: PASS (5 sub-checks)
   LRT-IF13: PASS (4 sub-checks)
   LRT-IF14: PASS (5 sub-checks)
   LRT-IF15: PASS (10 sub-checks)
   summary_sha256=sha256:8e72338e6210a8b05f3a50a9819f74fe231ea465a7519f89c0c9ad1ba80fa62e

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
   failed_checks=[]
   old_harness_sha256_matched=true
   summary_sha256=sha256:882f407a52659d122b3fd6b73f874a68693c4023b80d7d493c65e755ae9cd364
   (unchanged — regression OK)
```

---

## Proof Matrix Result

| ID | Required proof | Sub-checks | Result |
| --- | --- | --- | --- |
| LRT-IF1 | `condition=true` → only `then_branch` evaluated; value returned | 4 | PASS |
| LRT-IF2 | `condition=false` → only `else_branch` evaluated; value returned | 4 | PASS |
| LRT-IF3 | Non-selected `then_branch` would fail → no failure when condition is false | 3 | PASS |
| LRT-IF4 | Non-selected `else_branch` would fail → no failure when condition is true | 3 | PASS |
| LRT-IF5 | Condition failure propagates before branch evaluation | 3 | PASS |
| LRT-IF6 | Selected branch failure propagates | 2 | PASS |
| LRT-IF7 | Non-Bool condition values fail closed; no truthy/falsy coercion | 8 | PASS |
| LRT-IF8 | Missing `condition` / `then_branch` / `else_branch` fails closed | 5 | PASS |
| LRT-IF9 | Unknown selected-path expression kind fails closed | 3 | PASS |
| LRT-IF10 | Unknown non-selected-path expression kind does not fire | 4 | PASS |
| LRT-IF11 | Nested `if_expr` lazy recursively | 5 | PASS |
| LRT-IF12 | Static deps vs proof trace; trace is not dependency authority | 5 | PASS |
| LRT-IF13 | Error surface isolation; no public diagnostics/report/result | 4 | PASS |
| LRT-IF14 | Direct-require-only boundary; no root require | 5 | PASS |
| LRT-IF15 | Closed-surface scan | 10 | PASS |

Total: **68/68 PASS** (15/15 LRT-IF items PASS)

---

## Evaluator Architecture

`IgniterLang::SemanticIRExpressionEvaluator` is a live internal class defined
in `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`.
It is direct-require-only and is not root-required.

### Public Interface

```ruby
evaluator = IgniterLang::SemanticIRExpressionEvaluator.new
value = evaluator.evaluate(expr, values = {}, call_trace: nil)
```

- `expr` — Hash with a `"kind"` key representing a SemanticIR expression node.
- `values` — Hash (String keys) mapping resolved node names to runtime values.
- `call_trace:` — Optional Array; if provided, evaluated expression kinds are
  appended in order. Proof/debug evidence only; not dependency authority.

### Supported Expression Kinds (Slice 1)

```text
literal     — returns expr["value"]
ref         — looks up expr["name"] in values hash
if_expr     — lazy conditional (see semantics below)
```

Excluded from Slice 1:

```text
apply         — deferred to Slice 2 / proof RuntimeMachine consumer decision
field_access  — deferred to Slice 2 / proof RuntimeMachine consumer decision
tbackend_read — explicitly excluded; requires temporal/runtime authority decision
```

### Lazy Evaluation Order (`eval_if_expr`)

```
1. Fail closed if condition / then_branch / else_branch is missing
   (MalformedIfExprError)
2. cond_val = eval_expr(condition, values, call_trace)
3. Guard: cond_val must be exactly true or false
   (ConditionNotBoolError if not)
4. if cond_val == true  → eval_expr(then_branch, values, call_trace)  # line A: then_branch only
   else                 → eval_expr(else_branch, values, call_trace)  # line B: else_branch only
```

The two Ruby `if` arms in step 4 are mutually exclusive. The non-selected branch
Hash is never passed to `eval_expr` in normal evaluation.

### Internal Exception Hierarchy

```text
IgniterLang::SemanticIRExpressionEvaluator::Error
  IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
  IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
  IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
  IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
```

All internal to this class. Not OOF-RT-* vocabulary. Not integrated with
Diagnostics, CompilationReport, CompilerResult, or public API/CLI surface.

---

## Call Trace Evidence

The public `evaluate` method accepts an optional `call_trace:` Array. Evaluated
expression kinds are pushed in order. This provides dynamic proof that the
non-selected branch is never evaluated.

| Scenario | Call trace | Result |
| --- | --- | --- |
| `condition=true`, `then=lit(42)`, `else=lit(99)` | `["if_expr", "literal", "literal"]` | 42 |
| `condition=false`, `then=lit(42)`, `else=lit(99)` | `["if_expr", "literal", "literal"]` | 99 |
| Nested: outer=true→inner(false→failing/42) | `["if_expr", "literal", "if_expr", "literal", "literal"]` | 42 |

For `condition=true`: the trace shows `if_expr` (outer), `literal` (condition),
`literal` (then_branch value). The `else_branch` is NOT in the trace.

For `condition=false`: identical shape but the second `literal` is the else value.

For nested: only 5 kind-tokens — outer `if_expr`, outer cond `literal`,
inner `if_expr`, inner cond `literal`, inner `else_branch` `literal`.
Neither `failing_expr_lrt` entry appears in the trace.

---

## Key Proof Points

### LRT-IF3 / LRT-IF4: Non-selected branch isolation

```ruby
# LRT-IF3: condition=false, then_branch=failing_expr_lrt → NO error, result=7
trace = []
result = evaluator.evaluate(
  { "kind" => "if_expr",
    "condition"   => { "kind" => "literal", "value" => false },
    "then_branch" => { "kind" => "failing_expr_lrt" },
    "else_branch" => { "kind" => "literal", "value" => 7 } },
  {},
  call_trace: trace
)
# result = 7; trace does not include "failing_expr_lrt"

# LRT-IF4: condition=true, else_branch=failing_expr_lrt → NO error
result = evaluator.evaluate(
  { "kind" => "if_expr",
    "condition"   => { "kind" => "literal", "value" => true },
    "then_branch" => { "kind" => "literal", "value" => 7 },
    "else_branch" => { "kind" => "failing_expr_lrt" } },
  {},
  call_trace: trace
)
# result = 7; trace does not include "failing_expr_lrt"
```

### LRT-IF5: Branches not evaluated on condition failure

```ruby
# condition=failing_expr_lrt → raises before any branch evaluation
# call_trace after rescue: ["if_expr", "failing_expr_lrt"]
# "literal" (from branches) is NOT in the trace
```

### LRT-IF7: Non-Bool coercion rejected

All non-Bool values fail with `ConditionNotBoolError`:
`42` (Integer), `"truthy"` (String), `nil` (NilClass), `0` (Integer),
`{}` (Hash). No truthy/falsy Ruby semantics applied.

### LRT-IF12: Structural + dynamic proof (LRT-IF12)

Structural: `eval_if_expr` contains two mutually exclusive Ruby `if` arms
(verified via source inspection):

```ruby
if cond_val == true
  eval_expr(expr.fetch("then_branch"), values, call_trace) # line A: then_branch only
else
  eval_expr(expr.fetch("else_branch"), values, call_trace) # line B: else_branch only
end
```

Dynamic: LRT-IF3 and LRT-IF4 prove at runtime that a would-fail expression in
the non-selected branch never fires, confirming `eval_expr` is never called on
the non-selected side.

Dependency policy: static TypeChecker union (condition + then + else) is
preserved unchanged. Dynamic selected-branch dependency tracking is deferred
per C1-A.

---

## Closed-Surface Scan

| Surface | Result |
| --- | --- |
| `lib/igniter_lang.rb` (root require) | Not modified — CLEAR |
| `lib/igniter_lang/runtime_smoke.rb` | Not modified — CLEAR |
| `lib/igniter_lang/compiler_orchestrator.rb` | Not modified — CLEAR |
| `lib/igniter_lang/compiler_result.rb` | Not modified — CLEAR |
| `lib/igniter_lang/compilation_report.rb` | Not modified — CLEAR |
| `experiments/runtime_machine_memory_proof/compiled_program.rb` | Not modified — CLEAR |
| `lib/igniter_lang/typechecker.rb` | Not modified — CLEAR |
| `lib/igniter_lang/semanticir_emitter.rb` | Not modified — CLEAR |
| Release harness / first-RC / smoke evidence | Not in write scope — CLEAR |
| `docs/spec/` | Not in write scope — CLEAR |
| `README.md`, `RELEASE_NOTES.md`, `igniter_lang.gemspec` | Not modified — CLEAR |
| Live runtime modules loaded (proof) | Evaluator only (direct require) — CLEAR |
| Compiler pipeline modules loaded (proof) | None loaded — CLEAR |
| Diagnostics/CompilationReport/CompilerResult loaded (proof) | None loaded — CLEAR |

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
```

`IgniterLang::SemanticIRExpressionEvaluator` is a live internal class in `lib/`.
It is direct-require-only and is not integrated into `RuntimeSmoke`,
`CompilerOrchestrator`, any root require, or any public API/CLI surface.
It is not production runtime evidence, not public demo evidence, not all-grammar
evidence, and not official release evidence.

---

## Compact Result

```text
card:                  S3-R199-C2-I
track:                 branch-conditional-if-expr-live-runtime-evaluator-implementation-v0
status:                done / proof-passed
checks_total:          68
checks_pass:           68
checks_fail:           0
proof_matrix:          15/15 LRT-IF items PASS
summary_sha256:        sha256:8e72338e6210a8b05f3a50a9819f74fe231ea465a7519f89c0c9ad1ba80fa62e
semantics.lazy:        true
non_selected_eval:     forbidden (proven dynamically via LRT-IF3, LRT-IF4, LRT-IF5)
truthy_falsy_coercion: false (proven via LRT-IF7: 5 non-Bool types rejected)
static_union:          true (TypeChecker unchanged)
dynamic_tracking:      deferred
error_surface:         internal_exception_classes (non-canonical, not OOF-RT-*)
live_lib_file:         igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
proof_local_only:      false
root_require_changed:  false
closed_surface_scan:   CLEAR
regression_rt_proof:   54/54 PASS (sha256 unchanged)
regression_delta_proof: 39/39 PASS (sha256 unchanged)
```
