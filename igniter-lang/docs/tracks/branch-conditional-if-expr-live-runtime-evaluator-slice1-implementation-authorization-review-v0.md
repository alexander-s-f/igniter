# Branch Conditional If Expr Live Runtime Evaluator Slice1 Implementation Authorization Review v0

Card: S3-R199-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-live-runtime-evaluator-slice1-implementation-authorization-review-v0
Route: UPDATE
Status: done / authorized-bounded-slice1-implementation
Date: 2026-05-28

Depends on:
- S3-R198-C4-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round198-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-live-runtime-evaluator-implementation-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round197-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-acceptance-decision-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/lib/igniter_lang.rb`

---

## Decision

Decision:

```text
authorize bounded Slice 1 implementation
authorize S3-R199-C2-I in this round
authorize creation of semanticir_expression_evaluator.rb
authorize proof harness and implementation track doc
support only literal, ref, and if_expr
exclude apply and field_access from Slice 1
exclude tbackend_read from Slice 1
keep root require closed
keep RuntimeSmoke closed
keep CompilerOrchestrator closed
keep CompilerResult and CompilationReport closed
keep proof RuntimeMachine consumer closed
keep runtime diagnostics non-canonical/internal
keep dynamic dependency tracking deferred
keep counterfactual audit future pressure only
keep release lane paused
keep public demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
```

The authorization is narrow: implement the internal direct-require evaluator
core and proof harness only. It does not authorize integration into root
require, runtime smoke, compiler orchestration, reports/results, proof
RuntimeMachine, release evidence, public API/CLI, Spark, cache/dependency
authority, or counterfactual audit.

---

## Authorization Basis

R198 status:

```text
accepted-design-authorized-slice1-implementation-authorization-review
```

Accepted live placement:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
IgniterLang::SemanticIRExpressionEvaluator
```

Pressure basis:

```text
S3-R198-C2-X: proceed
scope_checks: 12/12 PASS
blockers: 0
```

R197 proof-local runtime/evaluator evidence:

```text
status: PASS
checks_total: 54
checks_pass: 54
checks_fail: 0
RT-IF1..RT-IF13: PASS
```

Local file survey:

- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` does not
  exist yet;
- `igniter-lang/lib/igniter_lang.rb` currently requires only
  `compiler_orchestrator` and `version`;
- `RuntimeSmoke` remains proof-backed and delegates to
  `runtime_machine_memory_proof`;
- `CompilerOrchestrator` transports runtime smoke but does not own expression
  evaluation;
- `CompilerResult` and `CompilationReport` expose runtime smoke/report surfaces
  that are out of Slice 1.

---

## Exact C2-I Implementation Boundary

Authorized next implementation card:

```text
Card: S3-R199-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-v0
Route: UPDATE
Depends on:
- S3-R199-C1-A
```

Allowed write scope:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md
```

No other files are authorized.

---

## Required Evaluator Shape

Authorized class/module:

```text
IgniterLang::SemanticIRExpressionEvaluator
```

Required boundary:

```text
internal
direct-require-only
not root-required
proof-harness consumer only
```

Required public-to-this-internal-class behavior may be simple, for example:

```text
evaluate(expr, values = {})
```

The exact method shape may be chosen by C2-I if the proof harness demonstrates
all required behavior and no public API/CLI/root require surface is widened.

---

## Supported Expression Kinds

Required and authorized expression kinds:

```text
literal
ref
if_expr
```

Excluded from Slice 1:

```text
apply
field_access
tbackend_read
```

`apply` and `field_access` remain deferred to a later Slice 2/proof
RuntimeMachine consumer decision. They must not be added in C2-I unless this
authorization is explicitly amended.

`tbackend_read` is explicitly excluded. Opening it requires a separate
temporal/runtime authority decision.

---

## Required Runtime Semantics

The Slice 1 evaluator must implement:

1. Evaluate `if_expr.condition` first.
2. Require runtime Bool exactly: `true` or `false`.
3. If condition is `true`, evaluate only `then_branch`.
4. If condition is `false`, evaluate only `else_branch`.
5. Return the selected branch value.
6. Apply the same lazy semantics recursively to nested `if_expr`.

Forbidden:

- Ruby truthy/falsy coercion;
- eager branch evaluation;
- speculative non-selected branch evaluation;
- side effects from non-selected branches;
- treating proof/debug trace as dependency authority.

---

## Required Failure Policies

The implementation must fail closed for:

- malformed expression node;
- missing `kind`;
- malformed `if_expr`;
- missing `condition`;
- missing `then_branch`;
- missing `else_branch`;
- non-Bool condition;
- unknown selected-path expression kind;
- missing selected-path reference.

The implementation must not fail for an unknown expression kind inside the
non-selected branch.

---

## Internal Error / Exception Surface

Authorized internal exception family:

```text
IgniterLang::SemanticIRExpressionEvaluator::Error
IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
```

C2-I may use this exact family or a narrower equivalent inside
`SemanticIRExpressionEvaluator`.

Runtime diagnostics policy:

```text
internal/local/open only
no OOF-RT-*
no Diagnostics integration
no CompilationReport integration
no CompilerResult integration
no public API/CLI wording
```

If the proof summary uses `runtime.*` labels, they are proof-debug /
human-readable labels only. They are not canonized runtime diagnostics and must
not appear in public result shapes.

---

## Dependency / Cache / Trace Policy

Accepted:

```text
static dependency union remains compiler/runtime boundary
dynamic selected-branch dependency tracking remains deferred
```

C2-I may include optional proof/debug trace only to prove lazy evaluation. Such
trace is not dependency authority.

C2-I must not introduce:

- path-sensitive dependency receipts;
- dynamic dependency authority;
- path-sensitive cache keys;
- cache invalidation changes;
- freshness state changes;
- runtime report fields implying selected-path dependency authority.

---

## Counterfactual Audit Policy

Counterfactual audit remains future pressure only.

C2-I must not implement:

- counterfactual evaluator;
- counterfactual dry-run;
- branch comparison report;
- effect sandboxing;
- public counterfactual API/CLI;
- eager latent-branch evaluation.

The evaluator may preserve explicit branch structure naturally by evaluating
the provided SemanticIR expression shape, but it must not execute latent branch
logic in normal runtime.

---

## Required Proof Matrix

C2-I must prove:

| ID | Required proof |
| --- | --- |
| LRT-IF1 | `condition=true` -> only `then_branch` evaluated; value returned. |
| LRT-IF2 | `condition=false` -> only `else_branch` evaluated; value returned. |
| LRT-IF3 | Non-selected `then_branch` would fail -> no failure when condition is false. |
| LRT-IF4 | Non-selected `else_branch` would fail -> no failure when condition is true. |
| LRT-IF5 | Condition failure propagates before branch evaluation. |
| LRT-IF6 | Selected branch failure propagates. |
| LRT-IF7 | Non-Bool condition values fail closed; no truthy/falsy coercion. |
| LRT-IF8 | Missing `condition` / `then_branch` / `else_branch` fails closed. |
| LRT-IF9 | Unknown selected-path expression kind fails closed. |
| LRT-IF10 | Unknown non-selected-path expression kind does not fire. |
| LRT-IF11 | Nested `if_expr` lazy recursively. |
| LRT-IF12 | Static deps vs proof trace; trace is not dependency authority. |
| LRT-IF13 | Error surface isolation; no public diagnostics/report/result. |
| LRT-IF14 | Direct-require-only boundary; no root require. |
| LRT-IF15 | Closed-surface scan. |

The proof summary must explicitly report all LRT-IF1..LRT-IF15 results, total
checks, pass/fail counts, and failed check list.

---

## Required Command Matrix

C2-I must run and record:

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

## Explicit Answers

### May C2-I begin in this round?

Yes.

S3-R199-C2-I may begin under the exact boundary above.

### May `semanticir_expression_evaluator.rb` be created?

Yes.

It is the only authorized live `lib/` file for C2-I.

### Are `literal`, `ref`, and `if_expr` the only required expression kinds?

Yes.

They are also the only authorized expression kinds for Slice 1.

### Are `apply` and `field_access` excluded or narrowly allowed?

Excluded for C2-I.

They may be reconsidered only in a later Slice 2/proof RuntimeMachine consumer
route or explicit amended authorization.

### Is `tbackend_read` excluded?

Yes.

`tbackend_read` is explicitly excluded from Slice 1.

### Does root require remain closed?

Yes.

`igniter-lang/lib/igniter_lang.rb` must not be edited.

### Do `RuntimeSmoke`, `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

They remain closed for C2-I.

### Do internal `runtime.*` labels remain non-canonical proof/debug labels?

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

- any file outside the authorized C2-I write scope;
- root require `lib/igniter_lang.rb`;
- `RuntimeSmoke`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics`;
- `experiments/runtime_machine_memory_proof/compiled_program.rb`;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler behavior;
- assembler, `.igapp`, `.ilk`, manifest, sidecar, artifact hash, goldens;
- `apply`, `field_access`, `tbackend_read`;
- release harness mutation beyond read-only regression command;
- release execution, RubyGems publish, tag/push/sign/deploy;
- public demo/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

