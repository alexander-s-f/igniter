# Stage 3 Round 201 Status Curation v0

Card: S3-R201-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round201-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-28

Depends on:
- S3-R201-C1-A
- S3-R201-C2-I
- S3-R201-C3-X
- S3-R201-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-runtime-consumer-implementation-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round200-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R201.md`

---

## R201 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R201-C1-A | `branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0` | Authorized bounded Slice 2 proof RuntimeMachine consumer implementation. |
| S3-R201-C2-I | `branch-conditional-if-expr-proof-runtime-consumer-v0` | Implemented and proof-passed; PRT-IF1..PRT-IF15 / 56/56 PASS. |
| S3-R201-C3-X | `branch-conditional-if-expr-proof-runtime-consumer-implementation-pressure-v0` | Proceed; 18/18 PASS, no blockers, 3 non-blocking notes. |
| S3-R201-C4-A | `branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0` | Accepted Slice 2 proof RuntimeMachine consumer implementation. |
| S3-R201-C5-S | `stage3-round201-status-curation-v0` | Done; records R202 RuntimeSmoke boundary design route. |

---

## Implementation Status

R201 status:

```text
accepted-slice2-proof-runtime-consumer-implementation
```

The proof RuntimeMachine can now consume `SemanticIRExpressionEvaluator` through
the accepted proof-only `if_expr` adapter path. This is not RuntimeSmoke
integration, not public runtime support, and not production authorization.

---

## Exact Accepted Changed Files

C4-A accepted the C2-I changed file set:

| File | Accepted status |
| --- | --- |
| `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` | Accepted Slice 2 `external_evaluator:` per-call hook and dual-path evaluator. |
| `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` | Accepted proof RuntimeMachine `if_expr` adapter consumer path. |
| `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb` | Accepted proof harness. |
| `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/out/branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json` | Accepted proof summary. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md` | Accepted implementation track doc. |

C5-S adds this status-curation track and updates `igniter-lang/docs/current-status.md`.

---

## Proof Matrix Result

Accepted proof matrix:

```text
PRT-IF1..PRT-IF15: PASS
checks_total: 56
checks_pass: 56
checks_fail: 0
failed_checks: []
summary_sha256: sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374
```

Accepted regression evidence:

```text
Slice 1 evaluator proof: 68/68 PASS, summary SHA unchanged
proof-local runtime/evaluator proof: 54/54 PASS, summary SHA unchanged
optional release-harness delta regression: 39/39 PASS, old harness SHA matched
```

The optional release-harness delta command remains regression evidence only. It
is not release execution and does not mutate accepted release evidence.

---

## Command Matrix Result

C2-I reported and C4-A re-ran the required command matrix:

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

Optional read-only regression:

```text
branch_conditional_if_expr_release_harness_delta_v0
=> PASS, 39/39, old_harness_sha256_matched=true
```

---

## Accepted Adapter Status

Accepted API:

```ruby
evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)
```

Accepted details:

- `external_evaluator:` is a per-call keyword hook;
- constructor injection remains absent/rejected;
- omitting `external_evaluator:` preserves Slice 1 behavior;
- Slice 1 proof remains 68/68 PASS with SHA unchanged;
- external evaluator exceptions propagate unchanged;
- `call_trace` remains proof/debug evidence only.

Accepted ownership:

| Kind | Owner |
| --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` |
| `ref` | `SemanticIRExpressionEvaluator` |
| `if_expr` | `SemanticIRExpressionEvaluator` |
| `apply` | proof RuntimeMachine local |
| `field_access` | proof RuntimeMachine local |
| `tbackend_read` | proof RuntimeMachine / temporal-owned |

`tbackend_read` remains temporal/proof RuntimeMachine-owned and is not evaluator
core.

---

## Remaining Closed Surfaces

Remain closed after R201:

- RuntimeSmoke integration or support claim;
- root require;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- Diagnostics centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler pipeline, assembler;
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

## Pressure Notes Disposition

- NB-1: `no_constructor_injection` absent from JSON `non_claims`; accepted as
  cosmetic proof-hygiene because `semantics.constructor_injection: false` and
  source shape cover the substance.
- NB-2: dual-path duplication is accepted as known future design debt.
- NB-3: RuntimeSmoke may transitively load the evaluator because
  `runtime_smoke.rb` already loads `compiled_program.rb`, and
  `compiled_program.rb` now loads the evaluator. This is an accepted known
  consequence, not a RuntimeSmoke feature opening.

---

## Exact Next Route Recommendation

Recommended next Main Line route:

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

No RuntimeSmoke implementation is authorized by R201-C5-S.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R201 as accepted Slice 2 proof
RuntimeMachine consumer implementation and routes only R202 RuntimeSmoke
consumer boundary design next.

---

## Compact Handoff

R201 accepts the proof RuntimeMachine `if_expr` adapter consumer path with
PRT-IF1..PRT-IF15 / 56/56 PASS. The evaluator has the per-call
`external_evaluator:` hook, proof RuntimeMachine keeps `apply`, `field_access`,
and `tbackend_read`, and all public/release/runtime-smoke/production surfaces
remain closed. Next route: S3-R202-C1-D design-only RuntimeSmoke consumer
boundary.
