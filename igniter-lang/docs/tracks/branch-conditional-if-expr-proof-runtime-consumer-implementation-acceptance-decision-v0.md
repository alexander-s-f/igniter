# Branch Conditional If Expr Proof Runtime Consumer Implementation Acceptance Decision v0

Card: S3-R201-C4-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0`  
Route: UPDATE  
Status: done / accepted-slice2-proof-runtime-consumer-implementation  
Date: 2026-05-28

Depends on:
- S3-R201-C2-I
- S3-R201-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-runtime-consumer-implementation-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/out/branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/docs/tracks/stage3-round200-status-curation-v0.md`

Additional local verification was run by C4-A:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

All six commands passed.

---

## Decision

Decision:

```text
accept Slice 2 proof RuntimeMachine consumer implementation closure
accept PRT-IF1..PRT-IF15: 56/56 PASS
accept backward-compatible per-call external_evaluator hook
accept proof RuntimeMachine if_expr consumer path
accept apply/field_access/tbackend_read remain proof RuntimeMachine-local
accept RuntimeSmoke remains closed
accept root require remains closed
accept compiler/result/report surfaces remain closed
accept dynamic dependency tracking remains deferred
accept counterfactual audit remains future pressure only
keep release lane paused
keep public demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
```

The implementation satisfies the S3-R201-C1-A authorization. The proof
RuntimeMachine can now consume `SemanticIRExpressionEvaluator` through the
proof-only adapter path for `if_expr`.

This is not RuntimeSmoke integration and not public runtime support.

---

## Accepted Changed Files

Accepted changed files:

| File | Status |
| --- | --- |
| `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` | Accepted Slice 2 `external_evaluator:` per-call hook and dual-path evaluator. |
| `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` | Accepted proof RuntimeMachine `if_expr` adapter consumer path. |
| `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb` | Accepted proof harness. |
| `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/out/branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json` | Accepted proof summary. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md` | Accepted implementation track doc. |

No other write scope is accepted by this decision.

---

## Command Matrix Result

C2-I reported and C4-A re-ran the required command matrix.

Accepted results:

```text
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
=> Syntax OK

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
=> Syntax OK

ruby -c igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
=> PASS, 56/56

ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
=> PASS, 68/68

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
=> PASS, 54/54
```

C2-I also reported optional read-only release-harness delta regression:

```text
branch_conditional_if_expr_release_harness_delta_v0
=> PASS, 39/39, old_harness_sha256_matched=true
```

That optional command remains regression evidence only. It is not release
execution and does not mutate accepted release evidence.

---

## PRT-IF1..PRT-IF15 Status

Accepted proof matrix:

| ID | Result | Sub-checks |
| --- | --- | --- |
| PRT-IF1 | PASS | 3 |
| PRT-IF2 | PASS | 3 |
| PRT-IF3 | PASS | 3 |
| PRT-IF4 | PASS | 2 |
| PRT-IF5 | PASS | 4 |
| PRT-IF6 | PASS | 3 |
| PRT-IF7 | PASS | 2 |
| PRT-IF8 | PASS | 2 |
| PRT-IF9 | PASS | 5 |
| PRT-IF10 | PASS | 4 |
| PRT-IF11 | PASS | 4 |
| PRT-IF12 | PASS | 6 |
| PRT-IF13 | PASS | 4 |
| PRT-IF14 | PASS | 4 |
| PRT-IF15 | PASS | 7 |

Summary:

```text
checks_total: 56
checks_pass: 56
checks_fail: 0
failed_checks: []
summary_sha256: sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374
```

---

## Evaluator API / Backward Compatibility Status

Accepted API:

```ruby
evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)
```

Accepted status:

- per-call `external_evaluator:` keyword implemented;
- constructor injection remains absent/rejected;
- omitting `external_evaluator:` preserves Slice 1 behavior;
- Slice 1 proof remains 68/68 PASS with SHA unchanged;
- `SUPPORTED_KINDS` remains `literal`, `ref`, `if_expr`;
- `apply`, `field_access`, and `tbackend_read` are not added to evaluator core.

Accepted architecture:

```text
external_evaluator absent:
  Slice 1 eval_expr / eval_if_expr path

external_evaluator present:
  Slice 2 eval_expr_ext / eval_if_expr_ext path
```

The dual-path shape is accepted because it preserves Slice 1 structural proof
invariants while adding the Slice 2 adapter path.

---

## External Evaluator / call_trace Status

Accepted:

- selected-path unsupported expression kinds delegate to `external_evaluator`;
- `external_evaluator` is never called for non-selected branches;
- `external_evaluator` is never called before condition evaluation;
- external evaluator exceptions propagate unchanged;
- `call_trace` remains proof/debug evidence only.

Rejected/not opened:

- dependency receipts from `call_trace`;
- path-sensitive cache keys;
- dynamic dependency authority;
- runtime report fields based on selected path.

---

## Expression Ownership Status

Accepted ownership:

| Kind | Owner |
| --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` |
| `ref` | `SemanticIRExpressionEvaluator` |
| `if_expr` | `SemanticIRExpressionEvaluator` |
| `apply` | proof RuntimeMachine local |
| `field_access` | proof RuntimeMachine local |
| `tbackend_read` | proof RuntimeMachine / temporal-owned |

`apply` and `field_access` remain proof RuntimeMachine-local. `tbackend_read`
remains temporal/proof RuntimeMachine-owned and is not evaluator core.

PRT-IF5 structural proof is accepted as sufficient under the R200/R201 boundary.
A full temporal fixture remains optional future proof hygiene, not a blocker.

---

## RuntimeSmoke Status

RuntimeSmoke remains closed.

Accepted details:

- `igniter-lang/lib/igniter_lang/runtime_smoke.rb` is unchanged;
- no `RuntimeSmoke` result-shape or report behavior change is accepted;
- no `RuntimeSmoke` support claim is accepted;
- C3-X NB-3 is recorded: because `runtime_smoke.rb` already loads
  `compiled_program.rb`, and `compiled_program.rb` now loads the evaluator,
  RuntimeSmoke may transitively load the evaluator.

Decision on NB-3:

```text
accepted known consequence of the proof RuntimeMachine adapter boundary
not a RuntimeSmoke feature opening
not RuntimeSmoke support acceptance
requires separate Slice 3 / RuntimeSmoke authorization before any claim
```

---

## Root Require / Compiler Result Report Status

Still closed and accepted unchanged:

- root require `igniter-lang/lib/igniter_lang.rb`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics`;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler pipeline;
- assembler / artifact / report surfaces.

---

## Dependency / Cache Status

Static dependency union remains the accepted conservative model.

Still deferred/closed:

- dynamic selected-branch dependency tracking;
- path-sensitive dependency receipts;
- dynamic dependency authority;
- path-sensitive cache keys;
- cache invalidation changes;
- freshness state changes;
- runtime report fields implying selected-path dependency authority.

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

Runtime remains lazy. Audit remains future-aware, not implemented here.

---

## Pressure Notes Disposition

C3-X reported 18/18 PASS, no blockers, and three non-blocking notes.

### NB-1: `no_constructor_injection` absent from JSON `non_claims`

Disposition:

```text
accepted as cosmetic proof-hygiene note
```

The substance is covered by `semantics.constructor_injection: false`, source
shape, and track-doc non-claims. No immediate follow-up required.

### NB-2: dual-path duplication is future-facing architectural debt

Disposition:

```text
accepted as known future design question
```

The dual-path design is accepted for Slice 2 because it preserves Slice 1
structural proof invariants. Any future RuntimeSmoke consumer / Slice 3 route
should explicitly decide whether to preserve or unify the paths.

### NB-3: RuntimeSmoke transitively loads the evaluator

Disposition:

```text
accepted known consequence / not a surface opening
```

This must be carried into any later RuntimeSmoke design-only or authorization
review.

---

## Explicit Answers

### Is Slice 2 proof RuntimeMachine consumer implementation accepted?

Yes.

### Can proof RuntimeMachine now consume the evaluator through the proof-only consumer path?

Yes.

The proof RuntimeMachine can consume `SemanticIRExpressionEvaluator` through the
accepted proof-only `if_expr` adapter path.

### Does RuntimeSmoke remain closed?

Yes.

### Does root require remain closed?

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

## Remaining Closed Surfaces

Remain closed:

- RuntimeSmoke integration or support claim;
- root require;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler pipeline,
  assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation
  outside accepted proof-owned output;
- release evidence rewrite or relabeling;
- release execution, RubyGems publish, yank, tag, push, sign, deploy;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Exact Next Dispatch Recommendation

Immediate next card:

```text
Card: S3-R201-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round201-status-curation-v0
Route: UPDATE
Depends on:
- S3-R201-C1-A
- S3-R201-C2-I
- S3-R201-C3-X
- S3-R201-C4-A
```

Recommended next Main Line route after status curation:

```text
Card: S3-R202-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0
Route: UPDATE
Depends on:
- S3-R201-C5-S
```

Goal:

```text
Design whether and how RuntimeSmoke may consume the accepted proof
RuntimeMachine if_expr path, explicitly handling the transitive evaluator load,
dual-path evaluator question, public non-claims, and closed compiler/result/report
surfaces.
```

No RuntimeSmoke implementation is authorized by this decision.
