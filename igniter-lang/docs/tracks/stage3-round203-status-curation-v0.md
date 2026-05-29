# Stage 3 Round 203 Status Curation v0

Card: S3-R203-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round203-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-29

Depends on:
- S3-R203-C1-A
- S3-R203-C2-I
- S3-R203-C3-X
- S3-R203-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-smoke-consumer-proof-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round202-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R203.md`

---

## R203 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R203-C1-A | `branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0` | Done; authorizes bounded proof-owned RuntimeSmoke consumer harness. |
| S3-R203-C2-I | `branch-conditional-if-expr-runtime-smoke-consumer-v0` | Done; proof harness implemented in authorized experiment scope; RS-IF1..RS-IF16 / 53/53 PASS. |
| S3-R203-C3-X | `branch-conditional-if-expr-runtime-smoke-consumer-proof-pressure-v0` | Proceed; 20/20 PASS, no blockers, two non-blocking notes. |
| S3-R203-C4-A | `branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0` | Accepts proof-owned RuntimeSmoke consumer evidence only. |
| S3-R203-C5-S | `stage3-round203-status-curation-v0` | Done; records accepted proof-context status and R204 design-only route. |

---

## Proof Status

R203 status:

```text
accepted-proof-owned-runtime-smoke-consumer-evidence
```

Accepted maximum claim:

```text
RuntimeSmoke has proof-context consumer evidence for if_expr through the
existing proof RuntimeMachine path.
```

This is proof-context evidence only. It does not promote `if_expr` to public
runtime support, production/runtime support, release/demo evidence, Spark/API/CLI
integration, or a public RuntimeSmoke support claim.

---

## Accepted Changed Files

C4-A accepts only the following changed/output files:

| File | Accepted status |
| --- | --- |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb` | Proof-owned RuntimeSmoke consumer harness. |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json` | Proof summary; 53/53 PASS; `sha256:b866973f0ef0f1463ba28d8e67fe8b77293b163b2159ef5a0ddabe94c6ad9492`. |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/rs-if-proof-v0/igapps/**` | Programmatically generated proof-owned `.igapp` artifacts. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md` | Implementation/proof track doc. |

Read-only surfaces remain accepted unchanged:

```text
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

---

## Proof Matrix Result

| ID | Result | Checks | Curated note |
| --- | --- | ---: | --- |
| RS-IF1 | PASS | 3 | Direct-require RuntimeSmoke; root require unchanged. |
| RS-IF2 | PASS | 4 | Transitive evaluator load classified as non-support by source/claim scan plus behavioral load-without-eval assertion. |
| RS-IF3 | PASS | 4 | `condition=true` returns trusted output from `then_branch`. |
| RS-IF4 | PASS | 3 | `condition=false` returns trusted output from `else_branch`. |
| RS-IF5a | PASS | 3 | Selected `apply` works through proof RuntimeMachine-local adapter path. |
| RS-IF5b | PASS | 2 | Selected `field_access` works through proof RuntimeMachine-local adapter path. |
| RS-IF6 | PASS | 2 | Non-selected `apply` branch does not fire. |
| RS-IF7 | PASS | 4 | RuntimeSmoke success/failure key sets unchanged. |
| RS-IF8 | PASS | 3 | RuntimeSmoke callback source/shape unchanged; no orchestrator integration. |
| RS-IF9 | PASS | 3 | `eval_input_for` unchanged; no `if_expr` special case. |
| RS-IF10 | PASS | 3 | Dual-path evaluator preserved; Slice 1 and Slice 2 both work. |
| RS-IF11 | PASS | 4 | CompilerOrchestrator, CompilerResult, and CompilationReport remain closed. |
| RS-IF12 | PASS | 2 | Root require remains closed. |
| RS-IF13 | PASS | 2 | Dependency/cache authority remains closed. |
| RS-IF14 | PASS | 2 | Counterfactual audit remains future pressure only. |
| RS-IF15 | PASS | 4 | Release/public/Spark/API/CLI remain closed. |
| RS-IF16 | PASS | 5 | Malformed `if_expr` returns blocked failure shape with `trusted: false`; no diagnostics/report widening. |

Total:

```text
checks_total: 53
checks_pass: 53
checks_fail: 0
pressure: 20/20 PASS, no blockers
```

---

## Command Matrix Result

C4-A accepted local verification:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
=> PASS, 53/53

ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
=> Syntax OK

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
=> PASS, 56/56

ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
=> PASS, 68/68
```

---

## RuntimeSmoke Boundary Status

Accepted:

- existing `IgniterLang::RuntimeSmoke.run` can consume proof-owned `.igapp`
  artifacts containing `if_expr` through the accepted proof RuntimeMachine path;
- `runtime_smoke.rb` remains unchanged;
- `RuntimeSmoke.run` result shape remains unchanged;
- `RuntimeSmoke.callback` behavior remains unchanged;
- `RuntimeSmoke.eval_input_for` behavior remains unchanged;
- no `if_expr` special case is added to `eval_input_for`;
- no `CompilerOrchestrator#compile(..., runtime_smoke:)` path is opened.

Binding hierarchy remains:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

Pressure NB-1 is accepted as proof hygiene only: non-selected `field_access`
does not have a dedicated negative case, but selected `field_access`, lazy
dual-path structure, and non-selected `apply` isolation are accepted. Pressure
NB-2 is inherited from R201: `no_constructor_injection` and
`no_tbackend_read_in_evaluator_core` remain closed through accepted R201
evidence, not repeated as smoke-harness JSON keys.

---

## Remaining Closed Surfaces

Remain closed after R203:

- new implementation beyond the accepted proof harness;
- `runtime_smoke.rb` edits;
- root require changes;
- proof RuntimeMachine source changes;
- evaluator source changes;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- Diagnostics centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler pipeline,
  assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation
  outside the R203 proof-owned output directory;
- release evidence rewrite or relabeling;
- release commands, release execution, RubyGems publish, yank, tag, push, sign,
  deploy;
- public demo/release/stable/production/all-grammar/runtime claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit implementation, dry-run execution, comparison reports,
  effect sandboxing;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Exact Next Route Recommendation

Recommended Main Line route:

```text
Card: S3-R204-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-design-boundary-v0
Route: UPDATE
Depends on:
- S3-R203-C5-S
```

Goal:

```text
Design the counterfactual-audit boundary for if_expr: explain non-selected
branches without evaluating them in the live runtime, without dependency/cache
authority, without public API/CLI widening, and without public runtime claims.
```

This route must be design-only unless a later Architect decision explicitly
authorizes implementation.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R203 as accepted
proof-context RuntimeSmoke consumer evidence and routes R204 design-only
counterfactual-audit boundary next.

---

## Compact Handoff

R203 closes the proof-owned RuntimeSmoke consumer harness with 53/53 PASS,
pressure 20/20 PASS, and accepted C4-A local verification. The accepted claim is
bounded to proof-context evidence only: RuntimeSmoke can consume proof-owned
`if_expr` `.igapp` artifacts through the existing proof RuntimeMachine path.
RuntimeSmoke source, result shape, callback, input defaults, compiler/result/
report surfaces, release/public/Spark/API/CLI, counterfactual audit
implementation, dependency/cache authority, and production remain closed.
