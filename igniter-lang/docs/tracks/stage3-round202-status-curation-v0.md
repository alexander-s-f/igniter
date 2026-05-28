# Stage 3 Round 202 Status Curation v0

Card: S3-R202-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round202-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-28

Depends on:
- S3-R202-C1-D
- S3-R202-C2-X
- S3-R202-C3-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round201-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R202.md`

---

## R202 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R202-C1-D | `branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0` | Done; designs proof-owned RuntimeSmoke consumer harness boundary only. |
| S3-R202-C2-X | `branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-pressure-v0` | Proceed; 13/13 PASS, no blockers, 3 non-blocking notes. |
| S3-R202-C3-A | `branch-conditional-if-expr-runtime-smoke-consumer-boundary-decision-v0` | Accepts design and authorizes only later implementation-authorization review. |
| S3-R202-C4-S | `stage3-round202-status-curation-v0` | Done; records R203 authorization-review boundary. |

---

## Design Status

R202 status:

```text
accepted-design-authorize-later-implementation-authorization-review
```

The RuntimeSmoke consumer boundary design is accepted. R202 does not authorize
RuntimeSmoke implementation, proof harness creation, release execution, public
claims, counterfactual audit, Spark/API/CLI widening, or production behavior.

---

## RuntimeSmoke Boundary Status

Accepted future route shape:

```text
proof-owned RuntimeSmoke consumer harness
no runtime_smoke.rb edits
no CompilerOrchestrator callback integration
no CompilerResult / CompilationReport mutation
no public API/CLI widening
no release/public/runtime/production claim
```

The next route may be an implementation-authorization review for a proof harness
that exercises existing `RuntimeSmoke.run` against proof-owned `.igapp`
artifacts containing `if_expr`.

No code, proof harness, fixture, or output write is authorized by R202.

---

## Transitive-Load Stance

Binding hierarchy:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

Known transitive load:

```text
runtime_smoke.rb loads compiled_program.rb
compiled_program.rb loads semanticir_expression_evaluator.rb
```

This is an accepted known consequence of R201. It does not count as
RuntimeSmoke support by itself. Support requires a dedicated proof and
acceptance decision.

---

## Dual-Path Evaluator Stance

The R201 dual-path evaluator remains accepted for this route:

```text
external_evaluator absent  -> Slice 1 path
external_evaluator present -> Slice 2 path
```

RuntimeSmoke work does not require evaluator unification. Dual-path duplication
is known future evaluator debt and does not block a proof-owned RuntimeSmoke
consumer proof.

---

## RuntimeSmoke Method Stances

Accepted for the first proof route:

- `RuntimeSmoke.run` result shape remains unchanged.
- `RuntimeSmoke.callback` behavior remains unchanged.
- `RuntimeSmoke.eval_input_for` remains unchanged.
- `RuntimeSmoke.available?` / `ensure_available!` remain unchanged.

Fixture policy:

- no new `if_expr` contract id special cases;
- keep the existing `Add` special case unchanged;
- proof-owned `.igapp` fixtures must use explicit `sample_input`;
- fixture defaults belong in the proof harness, not in `RuntimeSmoke`.

---

## Bound Requirements For Next Review

C3-A resolved C2-X notes as binding requirements:

- RS-IF5 must cover both proof RuntimeMachine-local selected branch kinds:
  `RS-IF5a` for `apply` and `RS-IF5b` for `field_access`.
- Proof artifacts must be generated programmatically under
  `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/`.
- RS-IF2 must include both:
  - source/claim scan proving proof artifacts do not claim transitive load as
    RuntimeSmoke support;
  - behavioral assertion proving require/load of RuntimeSmoke without
    `RuntimeSmoke.run` does not execute an `if_expr` artifact or invoke
    evaluator evaluation.
- Add mandatory `RS-IF16`: malformed or non-Bool `if_expr` through
  `RuntimeSmoke.run` returns existing blocked failure shape with
  `trusted: false`, without diagnostics/result/report widening.

---

## Remaining Closed Surfaces

Remain closed after R202:

- implementation in this card;
- `runtime_smoke.rb` edits;
- root require changes;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- Diagnostics centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation outside a
  future proof-owned output directory;
- release harness mutation, release commands, release execution;
- public demo/release/stable/production/all-grammar/runtime claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Exact Next Route Recommendation

Recommended next Main Line route:

```text
Card: S3-R203-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R202-C4-S
```

Goal:

```text
Decide whether a bounded proof-owned RuntimeSmoke consumer harness may begin,
with no runtime_smoke.rb edits, no result-shape changes, and no public runtime
claims.
```

No RuntimeSmoke implementation or proof harness may begin until that
authorization review explicitly opens it.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R202 as accepted RuntimeSmoke
consumer boundary design and routes only R203 authorization review next.

---

## Compact Handoff

R202 accepts the RuntimeSmoke consumer boundary design as a proof-owned harness
route. Transitive evaluator load is not support; proof support is not public
runtime support; public runtime support is not production. The next route is
S3-R203-C1-A authorization review only, with no `runtime_smoke.rb` edits and no
RuntimeSmoke implementation authorized by R202.
