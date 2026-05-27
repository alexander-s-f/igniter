# Branch Conditional If Expr Runtime Evaluator Design Decision v0

Card: S3-R196-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-evaluator-design-decision-v0
Route: UPDATE
Status: done / accepted-design-authorize-proof-local-implementation-review
Date: 2026-05-27

Depends on:
- S3-R196-C1-D
- S3-R196-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-evaluator-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round195-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-acceptance-decision-v0.md`

Runtime/evaluator files were read through C1-D/C2-X:

- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- related runtime/orchestrator files cited by C1-D.

---

## Decision

Decision:

```text
accept runtime/evaluator design
accept lazy v0 runtime semantics
accept non-selected branch evaluation as forbidden
accept static dependency union as compiler/runtime boundary
defer dynamic selected-branch dependency tracking
defer structured runtime diagnostic vocabulary decision
authorize a later implementation-authorization review for proof-local evaluator experiment only
keep live runtime/evaluator implementation closed
keep RuntimeSmoke / CompilerOrchestrator integration closed
keep release lane paused
keep public demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
do not authorize implementation in this card
do not authorize release execution or public claims
```

The design is accepted as the correct v0 runtime direction: condition first,
Bool only, selected branch only, non-selected branch must not execute.

The next route may review whether to open a proof-local evaluator experiment.
It must not open live runtime/library integration directly.

---

## Acceptance Basis

C1-D design result:

```text
status: done
recommendation: accept design and route proof-local implementation-authorization review
runtime semantics: lazy
implementation: not authorized
```

C2-X pressure verdict:

```text
verdict: proceed
checks total: 9
checks pass: 9
checks fail: 0
blockers: none
non-blocking notes: 3
```

Accepted live-code findings:

- current proof runtime has no `if_expr` evaluator case;
- `RuntimeSmoke` delegates to `experiments/runtime_machine_memory_proof`;
- current proof evaluator raises on unknown expression kinds;
- no general production SemanticIR `if_expr` evaluator is present in `lib/`;
- artifact carriage of expressions is not runtime support.

---

## Accepted Runtime Semantics

Accepted v0 runtime/evaluator semantics are lazy:

1. Evaluate `condition`.
2. Require the evaluated condition to be runtime Bool: `true` or `false`.
3. If condition is `true`, evaluate only `then_branch`.
4. If condition is `false`, evaluate only `else_branch`.
5. Return the selected branch value.

Non-selected branch evaluation is forbidden.

This means non-selected branch failures, unsupported expression kinds, temporal
reads, side effects, or other observable behavior must not fire.

---

## Failure Propagation Policy

Accepted v0 failure policy:

| Failure source | Policy |
| --- | --- |
| Condition failure | Propagate immediately; do not evaluate branches. |
| Condition non-Bool | Fail closed; do not use Ruby truthy/falsy coercion. |
| Selected branch failure | Propagate selected-branch failure. |
| Non-selected branch would fail | Must not fire. |
| Missing `condition`, `then_branch`, or `else_branch` | Fail closed as malformed SemanticIR. |
| Unknown selected-path expression kind | Fail closed. |
| Unknown non-selected-path expression kind | Must not fire. |
| Nested `if_expr` | Apply the same lazy semantics recursively. |

Malformed SemanticIR is unreachable under accepted compiled input assumptions,
but a runtime/evaluator given malformed direct input must fail closed.

---

## Dependency And Cache Stance

Static dependency union remains accepted:

```text
condition + then_branch deps + else_branch deps
```

Runtime may dynamically touch only the selected branch, but this does not revise
compiler dependency metadata in v0.

Accepted stance:

- TypeChecker/SemanticIR dependency metadata remains conservative.
- `.igapp` compute node dependencies may remain static union dependencies.
- Cache invalidation remains conservative under static union dependencies.
- Dynamic selected-branch dependency tracking is deferred.
- Path-sensitive cache keys, invalidation, freshness, or dependency receipts are
  out of scope until a separate cache/runtime design authorizes them.

C2-X NB-1 is accepted:

```text
RT-IF12 may be satisfied by structural proof of selected-branch call path.
It must not require a new dynamic touch-tracing mechanism.
```

---

## Runtime Diagnostics Stance

No `OOF-RT-*` vocabulary is accepted by this decision.

Accepted stance:

- compiler `OOF-*` remains compiler/typechecking vocabulary;
- runtime/evaluator errors should use existing runtime error surfaces first;
- candidate `runtime.if_expr_*` codes remain provisional and local to future
  design/review until explicitly accepted.

C2-X NB-2 is binding for the next review:

```text
The implementation authorization review must explicitly decide the proof-local
error surface: plain raise / existing runtime errors vs structured runtime.*
codes. No runtime diagnostic code may become non-local/public without a later
decision.
```

---

## Future Implementation Authorization Review Boundary

A later implementation-authorization review may open next.

Exact next card:

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

Candidate next implementation card if authorized later:

```text
Card: S3-R197-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-v0
Route: UPDATE
```

Candidate proof-local write scope for a later C2-I, if authorized:

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md
```

No live `lib/` runtime, `RuntimeSmoke`, `CompilerOrchestrator`, assembler,
`.igapp`, public API/CLI, release, Spark, or production write scope is
authorized by this design decision.

---

## Required Proof Matrix For Later Review

The future authorization review should require RT-IF1..RT-IF13:

| ID | Proof case | Required result |
| --- | --- | --- |
| RT-IF1 | Condition `true` | Only `then_branch` evaluated; value returned. |
| RT-IF2 | Condition `false` | Only `else_branch` evaluated; value returned. |
| RT-IF3 | Non-selected `then_branch` would fail | No failure when condition is `false`. |
| RT-IF4 | Non-selected `else_branch` would fail | No failure when condition is `true`. |
| RT-IF5 | Condition expression fails | Branches are not evaluated; condition failure propagates. |
| RT-IF6 | Selected branch fails | Selected-branch failure propagates. |
| RT-IF7 | Condition returns non-Bool | Runtime fails closed; no truthy/falsy coercion. |
| RT-IF8 | Missing condition / then / else | Runtime fails closed as malformed SemanticIR. |
| RT-IF9 | Unknown selected-path expression kind | Runtime fails closed. |
| RT-IF10 | Unknown non-selected-path expression kind | No failure. |
| RT-IF11 | Nested `if_expr` | Lazy semantics apply recursively. |
| RT-IF12 | Static dependency union vs runtime selected path | Static deps stay union; selected-branch call path structurally proven. |
| RT-IF13 | Closed-surface scan | No public API/CLI, release, Spark, production runtime, `.igapp`, docs/spec, or compiler behavior changes. |

Required command matrix for later proof-local experiment, if authorized:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

Optional read-only regression commands may be considered:

```text
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

No release commands may be included.

---

## Option C Forward Guidance

C2-X NB-3 is accepted as forward guidance:

```text
Any future Option C route that extends runtime_machine_memory_proof must require:
1. proof that adding if_expr does not alter existing expression-kind behavior;
2. explicit decision on proof-runtime vs production-runtime layer boundary.
```

Option C is not authorized now.

Accepted first route remains Option A:

```text
proof-local evaluator experiment
```

---

## Explicit Answers

### Are lazy runtime semantics accepted?

Yes.

V0 runtime/evaluator semantics are lazy.

### Is non-selected branch evaluation forbidden?

Yes.

The non-selected branch must not be evaluated or observed.

### Does static dependency union remain accepted?

Yes.

Static compiler dependency union remains accepted and conservative.

### Is dynamic selected-branch dependency tracking required now?

No.

It is deferred. RT-IF12 must not be interpreted as requiring dynamic dependency
tracking or touch-trace infrastructure.

### Is runtime diagnostics vocabulary accepted or still open?

Still open.

No new `OOF-RT-*` or public `runtime.if_expr_*` vocabulary is accepted now. The
next authorization review must decide proof-local error-surface handling.

### May implementation authorization review open next?

Yes.

Only a proof-local implementation authorization review may open next.
Implementation itself is not authorized by this card.

### Does release lane remain paused?

Yes.

No release execution, publish, yank, tag, sign, or deploy route is opened.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

No public/runtime/all-grammar support claim is opened.

### Do Spark/API/CLI remain closed?

Yes.

No Spark, public API, or CLI route is opened.

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
