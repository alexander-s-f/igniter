# Stage 3 Round 200 Status Curation v0

Card: S3-R200-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round200-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-28

Depends on:
- S3-R200-C1-D
- S3-R200-C2-X
- S3-R200-C3-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round199-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R200.md`

---

## R200 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R200-C1-D | `branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0` | Done; designs Slice 2 proof RuntimeMachine consumer boundary only. |
| S3-R200-C2-X | `branch-conditional-if-expr-proof-runtime-consumer-boundary-design-pressure-v0` | Proceed; 13/13 PASS, no blockers, 2 non-blocking notes. |
| S3-R200-C3-A | `branch-conditional-if-expr-proof-runtime-consumer-boundary-decision-v0` | Accepts design and authorizes only later implementation-authorization review. |
| S3-R200-C4-S | `stage3-round200-status-curation-v0` | Done; records R201 authorization-review boundary. |

---

## Design Status

R200 status:

```text
accepted-design-authorize-later-implementation-authorization-review
```

The proof RuntimeMachine consumer boundary design is accepted. R200 does not
authorize implementation, `RuntimeSmoke` integration, release execution, public
claims, counterfactual audit implementation, Spark/API/CLI widening, or
compiler behavior changes.

---

## Accepted Boundary

Accepted shape:

```text
Evaluator owns lazy if_expr selection.
Proof RuntimeMachine keeps apply, field_access, and tbackend_read.
Bridge is a backward-compatible per-call external_evaluator hook.
```

The boundary is adapter-style, not migration-style. It centralizes `if_expr`
lazy selection in `IgniterLang::SemanticIRExpressionEvaluator` while preserving
proof RuntimeMachine ownership of its local expression kinds.

---

## Expression-Kind Ownership Stance

Accepted ownership:

| Kind | Owner |
| --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` |
| `ref` | `SemanticIRExpressionEvaluator` |
| `if_expr` | `SemanticIRExpressionEvaluator` |
| `apply` | proof RuntimeMachine local |
| `field_access` | proof RuntimeMachine local |
| `tbackend_read` | proof RuntimeMachine / temporal-owned |

`apply` and `field_access` do not move into evaluator scope for Slice 2.
`tbackend_read` must not enter evaluator core without a separate
temporal/runtime authority gate.

---

## Evaluator Amendment Status

Accepted future amendment form for the next authorization review:

```ruby
evaluator.evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)
```

Status:

```text
design accepted
implementation not authorized by R200
```

Binding requirements for the future review:

- preserve existing `evaluate(expr, values = {}, call_trace: nil)` behavior when
  `external_evaluator:` is omitted;
- use the per-call keyword form, not constructor injection;
- if `external_evaluator` raises, propagate the exception unchanged;
- any `call_trace` entries remain debug/proof evidence only.

---

## tbackend_read Authority Stance

`tbackend_read` remains temporal/proof RuntimeMachine-owned.

For the next proof:

- mandatory: prove structurally that `tbackend_read` is not absorbed into
  evaluator core and is never evaluated in a non-selected branch;
- mandatory: prove selected-path delegation reaches proof RuntimeMachine local
  ownership rather than evaluator core;
- optional: include a full temporal fixture only if existing proof-local
  temporal infrastructure can be used without widening temporal authority.

No new temporal/runtime authority opens from R200.

---

## RuntimeSmoke / Root Require / Compiler Surfaces

Still closed:

- `RuntimeSmoke`;
- root require `igniter-lang/lib/igniter_lang.rb`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- Diagnostics centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler changes.

Any future proof RuntimeMachine consumer implementation must not be claimed as
`RuntimeSmoke` support.

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

`call_trace` remains debug/proof evidence only.

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

---

## Release / Public / Spark / API / CLI Status

Still closed:

- release evidence rewrite or relabeling;
- release execution, RubyGems publish, yank, tag, push, sign, deploy;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- RuntimeMachine/Gate 3 production authority;
- Ledger/TBackend production, BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

Release lane remains paused.

---

## Pressure Notes Resolved By C3-A

- NB-1: API amendment spelling is committed to per-call `external_evaluator:`
  keyword form.
- NB-2: PRT-IF5 temporal scope is structural/ownership proof mandatory; full
  temporal fixture optional only under existing proof-local temporal authority.

C3-A also binds exception propagation: external evaluator exceptions propagate
unchanged.

---

## Exact Next Dispatch Recommendation

Recommended next Main Line route:

```text
Card: S3-R201-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R200-C4-S
```

Goal:

```text
Decide whether a bounded Slice 2 proof RuntimeMachine consumer implementation
may begin: backward-compatible evaluator external_evaluator hook plus proof
RuntimeMachine consumer proof, with RuntimeSmoke and public surfaces closed.
```

No implementation may begin until that authorization review explicitly opens it.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R200 as accepted design and
routes only R201 implementation-authorization review next.

---

## Compact Handoff

R200 accepts the Slice 2 proof RuntimeMachine consumer boundary design. The
accepted shape is an adapter boundary: the evaluator owns lazy `if_expr`
selection, while proof RuntimeMachine keeps `apply`, `field_access`, and
`tbackend_read`. The per-call `external_evaluator:` form is selected for a
future review, but implementation is not authorized by R200. Next route:
S3-R201-C1-A authorization review only.
