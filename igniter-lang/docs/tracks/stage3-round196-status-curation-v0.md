# Stage 3 Round 196 Status Curation v0

Card: S3-R196-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round196-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-27

Depends on:
- S3-R196-C1-D
- S3-R196-C2-X
- S3-R196-C3-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-evaluator-design-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round195-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R196.md`

---

## R196 Outcome Table

| Card | Output | Status | Curated result |
| --- | --- | --- | --- |
| S3-R196-C1-D | `branch-conditional-if-expr-runtime-evaluator-design-v0.md` | done | Designs lazy v0 runtime/evaluator semantics for accepted expression-level `if_expr`; recommends proof-local experiment first. |
| S3-R196-C2-X | `branch-conditional-if-expr-runtime-evaluator-design-pressure-v0.md` | proceed | Pressure PASS 9/9, no blockers; carries three non-blocking notes on RT-IF12, diagnostic surface, and Option C criteria. |
| S3-R196-C3-A | `branch-conditional-if-expr-runtime-evaluator-design-decision-v0.md` | done / accepted-design-authorize-proof-local-implementation-review | Accepts design and opens only a proof-local implementation-authorization review next. |
| S3-R196-C4-S | `stage3-round196-status-curation-v0.md` | done | R196 design acceptance curated into Stage 3 map and exact S3-R197 authorization-review boundary recorded. |

---

## Design Status

Design status:

```text
accepted-design-authorize-proof-local-implementation-review
```

Accepted v0 runtime/evaluator direction:

```text
lazy branch semantics
```

Implementation status:

```text
not authorized
```

Only a later proof-local implementation-authorization review may open next.

---

## Lazy / Eager Decision

Accepted policy:

```text
lazy
```

Accepted evaluation order:

1. Evaluate `condition`.
2. Require runtime Bool: `true` or `false`.
3. If `true`, evaluate only `then_branch`.
4. If `false`, evaluate only `else_branch`.
5. Return the selected branch value.

Ruby truthy/falsy coercion is not accepted.

---

## Non-Selected Branch Status

Non-selected branch evaluation:

```text
forbidden
```

Non-selected branch failures, unsupported expression kinds, temporal reads, side
effects, or other observable behavior must not fire.

Accepted failure policy:

- condition failure propagates before branch evaluation;
- condition non-Bool fails closed;
- selected branch failure propagates;
- malformed `if_expr` fails closed;
- unknown selected-path expression kind fails closed;
- unknown non-selected-path expression kind must not fire;
- nested `if_expr` applies the same lazy semantics recursively.

---

## Dependency / Cache Status

Static dependency union remains accepted:

```text
condition + then_branch deps + else_branch deps
```

Runtime may dynamically touch only the selected branch, but this does not revise
compiler dependency metadata in v0.

Dynamic selected-branch dependency tracking:

```text
deferred
```

Path-sensitive cache keys, invalidation, freshness, dependency receipts, or
touch-trace infrastructure remain out of scope until a separate cache/runtime
design authorizes them. RT-IF12 may be satisfied by structural proof of the
selected-branch call path; it must not require new dynamic dependency tracking.

---

## Runtime Diagnostics Status

New `OOF-RT-*` vocabulary:

```text
not accepted
```

Candidate `runtime.if_expr_*` codes remain provisional. The next authorization
review must explicitly decide the proof-local error surface: plain raise /
existing runtime errors vs. structured `runtime.*` codes. No runtime diagnostic
code may become non-local or public without a later decision.

---

## Exact Next Route

Next card:

```text
Card: S3-R197-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R196-C4-S
```

Goal:

```text
Decide whether a proof-local if_expr runtime/evaluator semantics experiment may
begin.
```

Candidate implementation card if later authorized:

```text
Card: S3-R197-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-v0
Route: UPDATE
```

Candidate future write scope, if authorized later:

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md
```

No live `lib/` runtime, `RuntimeSmoke`, `CompilerOrchestrator`, assembler,
`.igapp`, public API/CLI, release, Spark, or production write scope is
authorized by R196.

---

## Required Future Proof Matrix

Future authorization review should require RT-IF1..RT-IF13:

| ID | Required status |
| --- | --- |
| RT-IF1 | Condition `true`: only `then_branch` evaluated; value returned. |
| RT-IF2 | Condition `false`: only `else_branch` evaluated; value returned. |
| RT-IF3 | Non-selected `then_branch` would fail: no failure when condition is `false`. |
| RT-IF4 | Non-selected `else_branch` would fail: no failure when condition is `true`. |
| RT-IF5 | Condition failure: branches are not evaluated; condition failure propagates. |
| RT-IF6 | Selected branch failure propagates. |
| RT-IF7 | Non-Bool condition fails closed; no truthy/falsy coercion. |
| RT-IF8 | Missing condition / then / else fails closed as malformed SemanticIR. |
| RT-IF9 | Unknown selected-path expression kind fails closed. |
| RT-IF10 | Unknown non-selected-path expression kind produces no failure. |
| RT-IF11 | Nested `if_expr` applies lazy semantics recursively. |
| RT-IF12 | Static deps stay union; selected-branch call path structurally proven. |
| RT-IF13 | Closed-surface scan. |

---

## Release / Public / Spark / API Status

Release lane:

```text
paused
```

Public demo/stable/production/all-grammar claims:

```text
closed
```

Spark/API/CLI:

```text
closed
```

Compiler behavior changes:

```text
closed
```

---

## Remaining Closed Surfaces

Remain closed:

- runtime/evaluator implementation;
- live `RuntimeSmoke` or `CompilerOrchestrator` behavior changes;
- parser, classifier, TypeChecker, SemanticIR, compiler behavior, assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- release harness mutation or release command execution;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Current-Status Delta

Applied compact current-status update:

- R196 accepts lazy runtime/evaluator design for `if_expr`;
- non-selected branch execution is forbidden;
- static dependency union remains accepted and dynamic selected-branch
  dependency tracking is deferred;
- runtime diagnostic vocabulary remains open/provisional;
- exact next route is R197 proof-local implementation-authorization review.

No implementation, release execution, public claims, Spark/API/CLI widening, or
compiler behavior changes were authorized by this status-curation card.

---

## Compact Handoff

R196 is closed as accepted design. The next Main Line card should be
S3-R197-C1-A
`branch-conditional-if-expr-runtime-evaluator-proof-local-implementation-authorization-review-v0`.
That card may only decide whether to open a proof-local evaluator experiment.
Implementation itself, live runtime/library integration, release execution,
public claims, Spark/API/CLI widening, and compiler behavior changes remain
closed until explicitly authorized.
