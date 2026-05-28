# Branch Conditional If Expr Live Runtime Evaluator Implementation Design Decision v0

Card: S3-R198-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-design-decision-v0
Route: UPDATE
Status: done / accepted-design-authorized-slice1-implementation-authorization-review
Date: 2026-05-28

Depends on:
- S3-R198-C1-D
- S3-R198-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round197-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-acceptance-decision-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## Decision

Decision:

```text
accept live if_expr runtime/evaluator implementation design
authorize later Slice 1 implementation-authorization review only
do not authorize live implementation in this card
accept live placement: internal direct-require SemanticIRExpressionEvaluator
accept split implementation plan
accept LRT-IF1..LRT-IF15 proof matrix as future Slice 1 gate
accept runtime diagnostics as internal/local/open only
defer dynamic selected-branch dependency tracking
keep counterfactual audit as future pressure only
keep release lane paused
keep public demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
```

The design is accepted because it gives a precise live boundary without
prematurely integrating with `RuntimeSmoke`, `CompilerOrchestrator`, public
result surfaces, release evidence, Spark, or counterfactual audit.

---

## Acceptance Basis

Design output:

```text
recommended placement:
  igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
  IgniterLang::SemanticIRExpressionEvaluator

first slice:
  internal evaluator core
  direct-require-only
  no root require
  no RuntimeSmoke
  no CompilerOrchestrator
  no CompilerResult / CompilationReport
  no runtime_machine_memory_proof consumer yet
```

Pressure verdict:

```text
verdict: proceed
scope_checks: 12/12 PASS
blockers: 0
non_blocking_notes: 3
```

Accepted pressure notes become binding gate conditions for later reviews as
recorded below.

---

## Accepted Live Placement

Accepted placement:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
IgniterLang::SemanticIRExpressionEvaluator
```

Accepted status for the first implementation slice:

```text
internal lib boundary
direct-require-only
not root-required
proof-harness consumer only
```

Not accepted as the first placement:

- `RuntimeSmoke`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics`;
- assembler or `.igapp`;
- `experiments/runtime_machine_memory_proof/compiled_program.rb`.

---

## Accepted Slice Strategy

Implementation should be split.

Accepted next review target:

```text
Slice 1: internal evaluator core
```

Deferred:

```text
Slice 2: proof RuntimeMachine consumer
Slice 3: RuntimeSmoke consumer
```

Slice 2 and Slice 3 may not open until Slice 1 is separately authorized,
implemented, and accepted.

---

## Runtime Semantics Stance

The accepted future live evaluator semantics remain exactly aligned with
R196/R197:

1. Evaluate `condition` first.
2. Require runtime Bool exactly: `true` or `false`.
3. If `true`, evaluate only `then_branch`.
4. If `false`, evaluate only `else_branch`.
5. Return the selected branch value.
6. Apply the same rules recursively for nested `if_expr`.

Forbidden:

- Ruby truthy/falsy coercion;
- eager branch evaluation;
- speculative non-selected branch execution;
- non-selected branch side-effect execution;
- treating proof/debug traces as dependency authority.

---

## Runtime Diagnostics / Error Surface

Accepted stance:

```text
runtime diagnostics vocabulary remains local/open
internal exceptions may be designed for Slice 1
no public runtime diagnostic vocabulary is accepted
no OOF-RT-* vocabulary is accepted
```

The proposed internal exception family is acceptable as a future Slice 1
implementation-review candidate:

```text
IgniterLang::SemanticIRExpressionEvaluator::Error
IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
```

Binding condition from C2-X NB-1:

```text
Any internal runtime.* reason labels are proof-debug / human-readable labels
only. They are not a step toward canonizing runtime.* diagnostic vocabulary,
must not appear in public result shapes, and may be changed without an
OOF-RT-* governance gate.
```

---

## Dependency / Cache Stance

Accepted:

```text
static dependency union remains the compiler/runtime boundary
dynamic selected-branch dependency tracking remains deferred
```

Slice 1 must not introduce:

- path-sensitive dependency receipts;
- dynamic dependency authority;
- path-sensitive cache keys;
- cache invalidation changes;
- freshness state changes;
- runtime report fields implying selected-path dependency authority.

Proof traces may demonstrate lazy evaluation, but they are not dependency
tracking authority.

---

## Counterfactual Audit Stance

Counterfactual audit is accepted only as future design pressure.

Accepted phrase:

```text
Runtime is lazy.
Audit is aware.
```

R198 does not authorize:

- counterfactual evaluator implementation;
- counterfactual dry-run;
- branch comparison reports;
- effect sandboxing;
- public counterfactual API/CLI;
- eager latent-branch evaluation.

The future live evaluator design should preserve explicit condition/branch
structure so a future audit layer can inspect latent branch metadata without
requiring eager normal-runtime evaluation.

---

## Binding Notes For Future Reviews

### NB-1: Internal `runtime.*` Labels Are Not Canon

Binding for Slice 1 implementation-authorization review:

- internal reason labels are proof-debug only;
- no public result shape exposure;
- no `Diagnostics` / `CompilationReport` exposure;
- no OOF-RT vocabulary;
- no public API/CLI wording.

### NB-2: Slice 2 Must Cover Existing Proof Runtime Corpus

Binding for a later Slice 2 authorization review, not for Slice 1:

- if `runtime_machine_memory_proof` becomes a consumer of the evaluator, its
  regression matrix must cover the current proof-runtime expression kind
  corpus, including `apply` and `field_access`.

### NB-3: `tbackend_read` Excluded From Slice 1

Binding for Slice 1 implementation-authorization review:

```text
tbackend_read is out of Slice 1.
```

Opening `tbackend_read` requires a separate temporal/runtime authority decision.

---

## Explicit Answers

### Is the live runtime/evaluator implementation design accepted?

Yes.

The design is accepted.

### May implementation authorization review open next?

Yes.

A later Slice 1 implementation-authorization review may open next.

### Is live implementation authorized now?

No.

This card authorizes only a future authorization-review route, not code.

### May `RuntimeSmoke` be included in a later implementation boundary?

Yes, but not in the next Slice 1 implementation boundary.

`RuntimeSmoke` may be considered only in a later consumer route after Slice 1 is
accepted, and preferably after a proof RuntimeMachine consumer route if still
needed.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

They remain closed for Slice 1.

### Does runtime diagnostics vocabulary remain local/open?

Yes.

Internal exception/reason-label shape may be designed for proof and internal
debugging only; no public runtime diagnostics vocabulary is accepted.

### Does dynamic selected-branch dependency tracking remain deferred?

Yes.

### Does counterfactual audit remain future pressure only?

Yes.

### Does release lane remain paused?

Yes.

No release execution or release evidence mutation is opened.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

---

## Exact Next Dispatch Recommendation

Recommended next card:

```text
Card: S3-R199-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-live-runtime-evaluator-slice1-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R198-C4-S
```

Goal:

```text
Decide whether a bounded Slice 1 live if_expr runtime/evaluator implementation
may begin: internal direct-require SemanticIRExpressionEvaluator core plus
proof harness only.
```

Candidate future implementation boundary, if authorized by S3-R199-C1-A:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md
```

Candidate Slice 1 behavior:

- support `literal`, `ref`, and `if_expr`;
- preserve lazy `if_expr` semantics;
- fail closed for malformed `if_expr`;
- fail closed for non-Bool condition;
- fail closed for unknown selected-path expression kind;
- do not evaluate unknown non-selected-path expression kind;
- support optional proof/debug trace only as non-authoritative evidence;
- keep `tbackend_read` excluded;
- keep `apply` and `field_access` out unless the authorization review
  explicitly and narrowly includes them for proof-local reasons.

Required future proof matrix:

```text
LRT-IF1..LRT-IF15
```

Required future command matrix:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
```

The release-harness delta command is regression evidence only. It is not
release execution, release evidence mutation, or public release authorization.

---

## Remaining Closed Surfaces

Remain closed:

- live implementation in this card;
- root require `lib/igniter_lang.rb`;
- `RuntimeSmoke` changes for Slice 1;
- `CompilerOrchestrator` behavior changes;
- `CompilerResult` changes;
- `CompilationReport` changes;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler behavior,
  assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- `runtime_machine_memory_proof` consumer changes for Slice 1;
- `tbackend_read`;
- release harness mutation, release commands, release execution;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

