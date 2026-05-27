# Branch Conditional If Expr Runtime Evaluator Proof Local Acceptance Decision v0

Card: S3-R197-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-proof-local-runtime-evaluator-closure
Date: 2026-05-27

Depends on:
- S3-R197-C2-I
- S3-R197-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-evaluator-proof-local-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb`
- `igniter-lang/docs/tracks/stage3-round196-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-decision-v0.md`

---

## Decision

Decision:

```text
accept proof-local runtime/evaluator closure
accept RT-IF1..RT-IF13: 54/54 PASS
accept lazy semantics proof
accept non-selected branch behavior as proven
accept proof-local error surface as local/non-canonical
accept static dependency union and deferred dynamic dependency tracking
accept proof-local-only status
keep live runtime integration closed
keep release lane paused
keep public demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
authorize later live runtime implementation design-only route
do not authorize live implementation
do not authorize release execution or public claims
```

The proof-local evaluator experiment successfully proves the R196 lazy
semantics. It does not create live runtime support. It is sufficient to open a
design-only route for live runtime implementation boundaries.

---

## Acceptance Basis

C2-I result:

```text
status: proof-passed
checks_total: 54
checks_pass: 54
checks_fail: 0
failed_checks: []
proof_matrix: 13/13 RT-IF items PASS
```

C3-X pressure verdict:

```text
verdict: proceed
scope checks: 11/11 PASS
blockers: 0
non-blocking notes: 2
```

Accepted changed files:

| File | Accepted status |
| --- | --- |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb` | New proof-local runner and `ProofLocal::IfExprEvaluator`. |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json` | New proof-local summary. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md` | New proof-local implementation track doc. |

No live `lib/`, `RuntimeSmoke`, `CompilerOrchestrator`,
`runtime_machine_memory_proof`, parser, TypeChecker, SemanticIR, assembler,
release, public API/CLI, Spark, docs/spec, `.igapp`, or production surface
changes are accepted by this decision.

---

## RT-IF1..RT-IF13 Status

Accepted proof matrix:

| ID | Status |
| --- | --- |
| RT-IF1 condition `true` selects only `then_branch` | PASS |
| RT-IF2 condition `false` selects only `else_branch` | PASS |
| RT-IF3 non-selected `then_branch` would fail but does not fire | PASS |
| RT-IF4 non-selected `else_branch` would fail but does not fire | PASS |
| RT-IF5 condition failure propagates before branch evaluation | PASS |
| RT-IF6 selected branch failure propagates | PASS |
| RT-IF7 non-Bool condition fails closed; no truthy/falsy coercion | PASS |
| RT-IF8 malformed `if_expr` fails closed | PASS |
| RT-IF9 unknown selected-path expression kind fails closed | PASS |
| RT-IF10 unknown non-selected-path expression kind does not fire | PASS |
| RT-IF11 nested `if_expr` applies lazy semantics recursively | PASS |
| RT-IF12 static deps stay union; selected-branch call path proven | PASS |
| RT-IF13 closed-surface scan | PASS |

Detailed sub-check result:

```text
54/54 PASS
```

---

## Lazy Semantics Proof Status

Accepted:

```text
semantics.lazy: true
semantics.non_selected_branch_evaluation: forbidden
semantics.truthy_falsy_coercion: false
```

Proof basis:

- structural evaluator shape: mutually exclusive Ruby `if` arms;
- dynamic RT-IF3 / RT-IF4 would-fail non-selected branches do not fire;
- RT-IF5 proves condition failure happens before branch evaluation;
- RT-IF10 proves unknown expression kind in non-selected path does not fire;
- RT-IF11 proves nested lazy behavior recursively.

The non-selected branch behavior is accepted as proven.

---

## Error Surface Status

Accepted proof-local error surface:

```text
proof_local_plain_raise_or_error_object
```

Accepted proof-local classes:

- `ProofLocal::MalformedIfExprError`;
- `ProofLocal::ConditionNotBoolError`;
- `ProofLocal::UnsupportedExpressionKindError`.

These are accepted only as proof-local, non-canonical instrumentation.

Not accepted / not canonized:

- `OOF-RT-*`;
- public `runtime.if_expr_*` diagnostics;
- live runtime result shape;
- non-local runtime diagnostic vocabulary.

Runtime diagnostic vocabulary remains local/open.

---

## Dependency And Cache Status

Accepted:

```text
dependency_policy.static_union: true
dependency_policy.dynamic_selected_branch_tracking: deferred
dependency_policy.rt_if12_requires_dynamic_touch_tracing: false
```

RT-IF12 is accepted as structural proof plus dynamic non-selection evidence. It
does not introduce dynamic dependency tracking, dependency receipts,
path-sensitive cache keys, or touch-trace infrastructure.

Dynamic dependency tracking remains deferred.

---

## Proof-Local / Live Runtime Status

Accepted:

```text
runtime_scope.proof_local_only: true
runtime_scope.live_runtime_integration: false
runtime_scope.runtime_smoke_changed: false
runtime_scope.compiler_orchestrator_changed: false
runtime_scope.runtime_machine_memory_proof_changed: false
runtime_scope.lib_changed: false
```

The `ProofLocal::IfExprEvaluator` is accepted as proof-local only. It does not
integrate with live runtime, `RuntimeSmoke`, `CompilerOrchestrator`, or
production behavior.

---

## Non-Blocking Notes

C3-X records two non-blocking notes.

NB-1:

```text
call_trace is public on the proof-local evaluator and could be misread as
dependency tracking by a future reader.
```

Decision:

```text
cosmetic / non-blocking
```

The summary and RT-IF12 explicitly state that `call_trace` is proof
instrumentation only and not dynamic dependency tracking.

NB-2:

```text
release-command scan uses split-string pattern and <= 1 threshold.
```

Decision:

```text
cosmetic / non-blocking
```

The scan is acceptable for this proof. Future runners may prefer a cleaner
allowlist/denylist helper, but no follow-up is required now.

---

## Explicit Answers

### Is lazy semantics proof accepted?

Yes.

The proof-local lazy semantics proof is accepted.

### Is non-selected branch behavior proven?

Yes.

Non-selected branch failures and unknown expression kinds are proven not to
fire.

### Does dynamic dependency tracking remain deferred?

Yes.

Static dependency union remains accepted and dynamic selected-branch tracking
remains deferred.

### Does runtime diagnostic vocabulary remain local/open?

Yes.

The proof-local error classes are not canonical runtime diagnostics.

### May live runtime implementation design open next?

Yes.

A live runtime implementation design-only route may open next. It must not
authorize implementation.

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

## Exact Next Dispatch Recommendation

Recommended next card:

```text
Card: S3-R198-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0
Route: UPDATE
Depends on:
- S3-R197-C5-S
```

Goal:

```text
Design the boundary for live if_expr runtime/evaluator implementation after the
proof-local lazy semantics experiment, without authorizing implementation.
```

Required design focus:

- live placement choice:
  - internal `lib/igniter_lang/semanticir_expression_evaluator.rb`;
  - extension of `runtime_machine_memory_proof`;
  - `RuntimeSmoke` callback path;
  - or another bounded runtime layer;
- result/error surface:
  - plain raise;
  - proof-local pattern adaptation;
  - structured runtime errors;
  - no public diagnostics unless later authorized;
- integration boundaries:
  - whether `RuntimeSmoke` remains proof-backed;
  - whether `CompilerOrchestrator` stays unchanged;
  - whether `CompilerResult` / `CompilationReport` remain unchanged;
- proof matrix for future implementation;
- regression matrix for existing runtime/proof behavior;
- cache/dependency non-migration;
- release/public/Spark/API/CLI non-claims.

Do not authorize live implementation in S3-R198-C1-D.

---

## Remaining Closed Surfaces

Remain closed:

- live runtime/evaluator implementation;
- `lib/igniter_lang/**` runtime/evaluator changes;
- `RuntimeSmoke` behavior changes;
- `CompilerOrchestrator` behavior changes;
- `experiments/runtime_machine_memory_proof/compiled_program.rb` changes;
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
