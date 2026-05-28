# Stage 3 Round 198 Status Curation v0

Card: S3-R198-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round198-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-28

Depends on:
- S3-R198-C1-D
- S3-R198-C2-X
- S3-R198-C3-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round197-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R198.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## R198 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R198-C1-D | `branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0` | Done; designs the live evaluator boundary only. |
| S3-R198-C2-X | `branch-conditional-if-expr-live-runtime-evaluator-implementation-design-pressure-v0` | Proceed; 12/12 PASS, no blockers, 3 non-blocking notes. |
| S3-R198-C3-A | `branch-conditional-if-expr-live-runtime-evaluator-implementation-design-decision-v0` | Accepted design; authorizes only later Slice 1 implementation-authorization review. |
| S3-R198-C4-S | `stage3-round198-status-curation-v0` | Done; records R199 as authorization-review boundary, not implementation. |

---

## Design Status

R198 status:

```text
accepted-design-authorized-slice1-implementation-authorization-review
```

The live `if_expr` runtime/evaluator implementation design is accepted. R198
does not authorize live implementation, runtime behavior changes, release
execution, public claims, counterfactual audit implementation, Spark/API/CLI
widening, or compiler behavior changes.

---

## Live Placement Decision

Accepted live placement:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
IgniterLang::SemanticIRExpressionEvaluator
```

Accepted first-slice boundary:

```text
internal lib boundary
direct-require-only
not root-required
proof-harness consumer only
```

Not accepted as first placement:

- `RuntimeSmoke`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics`;
- assembler or `.igapp`;
- `experiments/runtime_machine_memory_proof/compiled_program.rb`.

---

## Slice Strategy

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

Candidate future Slice 1 write scope only if a later authorization review
approves it:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md
```

Candidate Slice 1 behavior remains bounded to internal evaluator support for
`literal`, `ref`, and `if_expr`, with `apply` / `field_access` included only if
the authorization review explicitly needs them for proof-local reasons.
`tbackend_read` is excluded from Slice 1 unless a separate temporal/runtime
authority opens it.

---

## Runtime Diagnostics / Error Surface

Runtime diagnostics remain internal, local, and open.

Candidate internal exception family remains only a future implementation-review
shape:

```text
IgniterLang::SemanticIRExpressionEvaluator::Error
IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
```

Binding note from C2-X/C3-A:

```text
runtime.* labels are proof-debug / human-readable labels only.
```

They are not canonized runtime diagnostics, not `OOF-RT-*`, not public result
fields, not Diagnostics / CompilationReport vocabulary, and not API/CLI wording.

---

## Dependency / Cache Stance

Accepted:

```text
static dependency union remains the compiler/runtime boundary
dynamic selected-branch dependency tracking remains deferred
```

Slice 1 must not introduce path-sensitive dependency receipts, dynamic
dependency authority, path-sensitive cache keys, cache invalidation changes,
freshness state changes, or runtime report fields implying selected-path
dependency authority. Proof traces may demonstrate lazy evaluation only as
debug/proof evidence.

---

## Counterfactual Audit Stance

Counterfactual audit is future pressure only.

Accepted phrase:

```text
Runtime is lazy.
Audit is aware.
```

R198 does not authorize counterfactual evaluator implementation,
counterfactual dry-runs, branch comparison reports, effect sandboxing, public
counterfactual API/CLI, or eager latent-branch evaluation.

The future live evaluator should preserve explicit condition/branch structure
so a later audit layer can inspect latent branch metadata without changing
normal lazy runtime behavior.

---

## Binding Notes For Next Review

- NB-1: `runtime.*` labels are proof-debug / human-readable only, not canon.
- NB-2: before a later Slice 2 proof RuntimeMachine consumer path opens, its
  regression must cover the current proof-runtime expression corpus, including
  `apply` and `field_access`.
- NB-3: `tbackend_read` remains out of Slice 1 without separate
  temporal/runtime authority.

---

## Exact Next Route

Next route:

```text
Card: S3-R199-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-live-runtime-evaluator-slice1-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R198-C4-S
```

Goal: decide whether bounded Slice 1 live `if_expr` runtime/evaluator
implementation may begin.

Allowed review subject only:

```text
internal direct-require SemanticIRExpressionEvaluator core
proof harness only
no root require
no RuntimeSmoke / CompilerOrchestrator / public result integration
```

---

## Remaining Closed Surfaces

Closed after R198:

- live implementation in R198;
- root require;
- `RuntimeSmoke` changes for Slice 1;
- `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, Diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler behavior;
- assembler, `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden migration;
- proof RuntimeMachine consumer changes;
- `tbackend_read`;
- counterfactual audit implementation;
- release execution, RubyGems publish, tag/push/sign/deploy;
- public demo/stable/production/all-grammar claims;
- Spark, API, CLI, runtime, production, cache authority.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R198 as accepted design and
routes only S3-R199-C1-A implementation-authorization review next.

---

## Compact Handoff

R198 accepts the live runtime/evaluator design for `if_expr` and selects
`IgniterLang::SemanticIRExpressionEvaluator` as the future internal
direct-require-only Slice 1 placement. It does not authorize implementation.
Counterfactual audit remains future pressure only. The exact next dispatch is
S3-R199-C1-A, a bounded Slice 1 implementation-authorization review.
