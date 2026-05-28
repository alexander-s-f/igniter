# Branch Conditional If Expr Live Runtime Evaluator Implementation Acceptance Decision v0

Card: S3-R199-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-slice1-live-runtime-evaluator-implementation
Date: 2026-05-28

Depends on:
- S3-R199-C2-I
- S3-R199-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-slice1-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-live-runtime-evaluator-implementation-pressure-v0.md`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/stage3-round198-status-curation-v0.md`

Additional local verification was run by C4-A:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
```

All five commands passed.

---

## Decision

Decision:

```text
accept Slice 1 live if_expr runtime/evaluator implementation closure
accept IgniterLang::SemanticIRExpressionEvaluator as live internal direct-require-only support
accept LRT-IF1..LRT-IF15: 68/68 PASS
accept literal/ref/if_expr as the only Slice 1 supported expression kinds
accept tbackend_read/apply/field_access exclusion
accept root require unchanged
accept RuntimeSmoke and proof RuntimeMachine consumer still closed
accept internal exception surface as non-canonical
accept call_trace as debug/proof evidence only
keep dynamic dependency tracking deferred
keep counterfactual audit future pressure only
keep release lane paused
keep public demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
```

The implementation is accepted as the first live internal runtime evaluator
core. It remains direct-require-only and is not integrated with root require,
`RuntimeSmoke`, `CompilerOrchestrator`, `CompilerResult`,
`CompilationReport`, proof RuntimeMachine, public API/CLI, release evidence, or
Spark.

---

## Accepted Changed Files

Accepted changed files:

| File | Status |
| --- | --- |
| `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` | Accepted live internal direct-require evaluator. |
| `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb` | Accepted proof harness. |
| `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json` | Accepted proof summary. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md` | Accepted implementation track doc. |

No other write scope is accepted.

---

## Command Matrix Result

C2-I reported and C4-A re-ran the required command matrix.

Accepted results:

```text
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
=> Syntax OK

ruby -c igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
=> PASS, 68/68

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
=> PASS, 54/54, summary sha unchanged

ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
=> PASS, 39/39, old_harness_sha256_matched=true
```

Release-harness delta command remains regression evidence only. It is not
release execution or release-evidence mutation.

---

## LRT-IF1..LRT-IF15 Status

Accepted proof matrix:

| ID | Result | Sub-checks |
| --- | --- | --- |
| LRT-IF1 | PASS | 4 |
| LRT-IF2 | PASS | 4 |
| LRT-IF3 | PASS | 3 |
| LRT-IF4 | PASS | 3 |
| LRT-IF5 | PASS | 3 |
| LRT-IF6 | PASS | 2 |
| LRT-IF7 | PASS | 8 |
| LRT-IF8 | PASS | 5 |
| LRT-IF9 | PASS | 3 |
| LRT-IF10 | PASS | 4 |
| LRT-IF11 | PASS | 5 |
| LRT-IF12 | PASS | 5 |
| LRT-IF13 | PASS | 4 |
| LRT-IF14 | PASS | 5 |
| LRT-IF15 | PASS | 10 |

Summary:

```text
checks_total: 68
checks_pass: 68
checks_fail: 0
failed_checks: []
```

---

## Evaluator Status

Accepted class:

```text
IgniterLang::SemanticIRExpressionEvaluator
```

Accepted file:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
```

Accepted boundary:

```text
internal
direct-require-only
not root-required
```

Accepted interface:

```ruby
evaluator = IgniterLang::SemanticIRExpressionEvaluator.new
value = evaluator.evaluate(expr, values = {}, call_trace: nil)
```

This is internal live support, not public API/CLI.

---

## Supported Expression Kind Status

Accepted Slice 1 supported expression kinds:

```text
literal
ref
if_expr
```

Accepted exclusions:

```text
apply: excluded
field_access: excluded
tbackend_read: excluded
```

`apply` and `field_access` remain deferred to a later Slice 2/proof
RuntimeMachine consumer boundary. `tbackend_read` remains excluded unless a
separate temporal/runtime authority opens it.

---

## Runtime Semantics Status

Accepted:

```text
semantics.lazy: true
condition first
runtime Bool exactly true/false
selected branch only
non-selected branch forbidden
nested if_expr lazy recursively
no truthy/falsy coercion
```

The implementation proves non-selected branch non-evaluation structurally and
dynamically:

- mutually exclusive Ruby `if` arms in `eval_if_expr`;
- LRT-IF3 and LRT-IF4 prove would-fail non-selected branches do not fire;
- LRT-IF5 proves condition failure happens before branch evaluation;
- LRT-IF10 proves unknown expression kind in non-selected path does not fire;
- LRT-IF11 proves nested lazy behavior.

---

## Error Surface Status

Accepted internal exception hierarchy:

```text
IgniterLang::SemanticIRExpressionEvaluator::Error
IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
```

Accepted diagnostic stance:

```text
internal/non-canonical only
no OOF-RT-*
no Diagnostics integration
no CompilationReport integration
no CompilerResult integration
no public API/CLI exposure
```

The C1-A/R198 NB-1 binding gate is accepted as satisfied: `runtime.*` strings
are proof-debug / human-readable internal reason labels only. They are not a
step toward canonizing runtime diagnostic vocabulary.

---

## Dependency / Cache Status

Accepted:

```text
static dependency union remains compiler/runtime boundary
dynamic selected-branch dependency tracking remains deferred
call_trace is debug/proof evidence only
```

The evaluator does not introduce path-sensitive dependency receipts, dynamic
dependency authority, path-sensitive cache keys, cache invalidation changes,
freshness state changes, or runtime report fields implying selected-path
dependency authority.

---

## Counterfactual Audit Status

Counterfactual audit remains future pressure only.

Not authorized:

- counterfactual evaluator;
- counterfactual dry-run;
- branch comparison report;
- effect sandboxing;
- public counterfactual API/CLI;
- eager latent-branch evaluation.

The accepted evaluator preserves normal lazy runtime behavior:

```text
Runtime is lazy.
Audit remains future-aware, not implemented here.
```

---

## Closed-Surface Status

Accepted closed surfaces:

| Surface | Status |
| --- | --- |
| Root require `lib/igniter_lang.rb` | Closed / unchanged. |
| `RuntimeSmoke` | Closed / unchanged. |
| `CompilerOrchestrator` | Closed / unchanged. |
| `CompilerResult` | Closed / unchanged. |
| `CompilationReport` | Closed / unchanged. |
| `Diagnostics` | Closed / unchanged. |
| proof RuntimeMachine `compiled_program.rb` | Closed / unchanged. |
| parser / TypeChecker / SemanticIR emitter / compiler pipeline | Closed / unchanged. |
| assembler / `.igapp` / goldens / artifacts | Closed / unchanged. |
| release execution / publish / tag / sign / deploy | Closed. |
| public API/CLI | Closed. |
| Spark | Closed. |

---

## Non-Blocking Notes

Accepted pressure notes:

### NB-1: LRT-IF14 duplicate sub-checks

LRT-IF14 contains two functionally identical root-require checks.

Decision:

```text
cosmetic / accepted as-is
```

No follow-up required.

### NB-2: MissingReferenceError has no dedicated proof case

`MissingReferenceError` is implemented and the internal error hierarchy is
machine-verified, but there is no dedicated named proof case that fires it.

Decision:

```text
accepted as-is / optional future proof enhancement
```

This does not block acceptance. A future proof hygiene pass may add a named
missing-ref case if useful.

---

## Explicit Answers

### Is Slice 1 implementation accepted?

Yes.

Slice 1 is accepted.

### Is live internal evaluator support accepted as direct-require-only?

Yes.

`IgniterLang::SemanticIRExpressionEvaluator` is accepted as live internal
direct-require-only support.

### Does RuntimeSmoke remain closed?

Yes.

### Does proof RuntimeMachine consumer remain closed?

Yes.

### Does dynamic dependency tracking remain deferred?

Yes.

### Does counterfactual audit remain future pressure only?

Yes.

### Does release lane remain paused?

Yes.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

---

## Exact Next Dispatch Recommendation

Immediate next card in this round:

```text
Card: S3-R199-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round199-status-curation-v0
Route: UPDATE
Depends on:
- S3-R199-C1-A
- S3-R199-C2-I
- S3-R199-C3-X
- S3-R199-C4-A
```

Recommended next Main Line route after status curation:

```text
Card: S3-R200-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0
Route: UPDATE
Depends on:
- S3-R199-C5-S
```

Goal:

```text
Design the Slice 2 proof RuntimeMachine consumer boundary for
IgniterLang::SemanticIRExpressionEvaluator without authorizing implementation.
```

Required focus for S3-R200-C1-D:

- whether proof RuntimeMachine should consume `SemanticIRExpressionEvaluator`;
- exact boundary for `experiments/runtime_machine_memory_proof/compiled_program.rb`;
- full current proof-runtime expression corpus coverage:
  - `apply`;
  - `field_access`;
  - `literal`;
  - `ref`;
  - `tbackend_read`;
- whether `tbackend_read` remains owned by temporal/runtime authority;
- whether `apply` / `field_access` should be added to the evaluator, adapted,
  or kept in proof RuntimeMachine;
- no `RuntimeSmoke` changes yet;
- no root require;
- no `CompilerOrchestrator`, `CompilerResult`, or `CompilationReport` changes;
- no release/public/Spark/API/CLI claims;
- counterfactual audit remains future pressure only.

Do not open RuntimeSmoke consumer implementation next. Slice 2 needs its own
design boundary first because it touches proof RuntimeMachine expression
coverage and temporal read authority.

---

## Remaining Closed Surfaces

Remain closed:

- root require `lib/igniter_lang.rb`;
- `RuntimeSmoke`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics`;
- proof RuntimeMachine consumer implementation;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler behavior;
- assembler, `.igapp`, `.ilk`, manifest, sidecar, artifact hash, goldens;
- `apply` / `field_access` live evaluator support until separately designed;
- `tbackend_read` until separate temporal/runtime authority;
- release execution, RubyGems publish, tag/push/sign/deploy;
- public demo/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

