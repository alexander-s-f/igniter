# Branch Conditional If Expr Live Runtime Evaluator Implementation Design v0

Card: S3-R198-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0`  
Route: UPDATE  
Depends on: S3-R197-C5-S  
Status: done  
Date: 2026-05-28

---

## Purpose

Design the boundary for live `if_expr` runtime/evaluator implementation after
the accepted proof-local lazy semantics experiment, without authorizing
implementation.

This card does not edit runtime/evaluator code, does not implement live support,
does not authorize implementation, does not authorize counterfactual audit
implementation, does not execute release commands, and does not authorize
public demo, stable, production, all-grammar, Spark, API, or CLI claims.

---

## Inputs Read

- `docs/tracks/stage3-round197-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md`
- `experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json`
- `docs/tracks/stage3-round196-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`
- `lib/igniter_lang/runtime_smoke.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/diagnostics.rb`
- `lib/igniter_lang/temporal_access_runtime.rb`
- `lib/igniter_lang/temporal_executor.rb`

Runtime/evaluator discovery used:

```bash
rg -n "Runtime|Evaluator|semantic_ir|if_expr" igniter-lang/lib igniter-lang/experiments
```

---

## Current Evidence State

R190 accepted internal compiler support for expression-level `if_expr` v0:

- TypeChecker support is live;
- `OOF-IF1..OOF-IF4` are live compiler diagnostics;
- `OOF-IF5` remains out/unowned;
- typed SemanticIR lowering is live;
- SemanticIR shape is flat and recursive:
  - `kind: "if_expr"`;
  - `condition`;
  - `then_branch`;
  - `else_branch`;
  - `resolved_type`;
- runtime/evaluator support remains closed.

R196 accepted lazy runtime/evaluator semantics as the v0 direction:

- condition first;
- runtime Bool only;
- selected branch only;
- non-selected branch evaluation forbidden;
- nested `if_expr` lazy recursively;
- static dependency union remains the compiler/runtime boundary;
- dynamic selected-branch dependency tracking is deferred;
- no `OOF-RT-*` vocabulary accepted.

R197 accepted proof-local runtime/evaluator closure:

```text
status: PASS
checks_total: 54
checks_pass: 54
checks_fail: 0
RT-IF1..RT-IF13: PASS
```

The accepted evaluator is `ProofLocal::IfExprEvaluator` in the experiment only.
It is not live runtime support.

---

## Live Runtime Surface Survey

Current runtime/evaluator facts:

- `IgniterLang::RuntimeSmoke` is proof-backed and delegates to
  `experiments/runtime_machine_memory_proof/compiled_program.rb`.
- `CompilerOrchestrator#compile` accepts an optional `runtime_smoke:` callback
  after assembly, but it does not own expression evaluation.
- `CompilerResult` and `CompilationReport` expose runtime smoke failures only
  through existing smoke/report paths.
- `experiments/runtime_machine_memory_proof/compiled_program.rb` has an
  evaluator for:
  - `apply`;
  - `field_access`;
  - `literal`;
  - `ref`;
  - `tbackend_read`.
- That proof runtime currently raises `ArgumentError` for unknown expression
  kinds.
- `TemporalAccessRuntime` and `TemporalExecutor::Phase1` are specialized
  runtime boundaries, not a general SemanticIR expression evaluator.
- There is no general live `IgniterLang::SemanticIRExpressionEvaluator` or
  equivalent under `lib/`.

Design implication:

```text
The first live implementation boundary should introduce a small internal
SemanticIR expression evaluator core. It should not start by changing
RuntimeSmoke, CompilerOrchestrator, CompilerResult, CompilationReport, or the
proof RuntimeMachine.
```

---

## Live Placement Decision

Recommended live placement:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
IgniterLang::SemanticIRExpressionEvaluator
```

Recommended first implementation status:

```text
internal lib boundary, direct-require-only, not root-required
```

Rationale:

- It gives the language/runtime a reusable evaluator boundary rather than
  burying `if_expr` inside one proof runner.
- It avoids coupling the first slice to `RuntimeSmoke` or
  `runtime_machine_memory_proof`.
- It keeps public API/CLI and compiler pipeline behavior unchanged.
- It gives future `RuntimeSmoke` or proof RuntimeMachine work a stable consumer
  candidate without forcing that integration now.
- It avoids making `.igapp` assembly or report behavior part of the first live
  evaluator step.

Non-recommended first placements:

| Placement | Decision | Reason |
| --- | --- | --- |
| Extend `runtime_machine_memory_proof/compiled_program.rb` first | Defer | Keeps support proof-runtime-specific and may blur proof runtime with live evaluator ownership. |
| Modify `RuntimeSmoke` first | Defer | Smoke is a callback/report integration surface, not the evaluator core. |
| Modify `CompilerOrchestrator` first | Closed | Orchestrator should remain compile/assemble/smoke transport; expression evaluation does not belong there. |
| Modify `CompilerResult` / `CompilationReport` first | Closed | Runtime evaluator errors are not public compiler diagnostics in v0. |
| Modify assembler / `.igapp` first | Closed | Current SemanticIR and artifact expression carriage already preserve the needed shape. |

---

## Slice Recommendation

Implementation should be split.

### Slice 1: Internal Evaluator Core

Candidate future write scope:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md
```

Boundary:

- direct-require-only from proof harness;
- no edit to `lib/igniter_lang.rb`;
- no `RuntimeSmoke` edit;
- no `CompilerOrchestrator` edit;
- no `CompilerResult` / `CompilationReport` edit;
- no proof RuntimeMachine edit;
- no `.igapp` or golden mutation outside the proof output directory.

Responsibilities:

- evaluate supported SemanticIR expression nodes;
- implement `if_expr` lazy semantics;
- fail closed for malformed `if_expr`;
- fail closed for unknown selected-path expression kind;
- do not evaluate unknown non-selected-path expression kind;
- preserve exact runtime Bool requirement;
- support optional internal trace for proof only, not dependency authority.

Suggested supported expression kinds for Slice 1:

```text
literal
ref
if_expr
```

Optional only if needed by proof fixtures:

```text
apply
field_access
```

`tbackend_read` should remain out of Slice 1 unless a separate temporal/runtime
authority explicitly opens it.

### Slice 2: Proof Runtime Consumer

Potential later write scope:

```text
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/experiments/branch_conditional_if_expr_runtime_machine_consumer_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-machine-consumer-v0.md
```

Boundary:

- consume `IgniterLang::SemanticIRExpressionEvaluator` from the proof
  RuntimeMachine path;
- prove `.igapp` compute node evaluation can use the internal evaluator;
- still no `RuntimeSmoke`, orchestrator, result/report, public API/CLI, release,
  or production behavior changes.

This slice should wait until Slice 1 is accepted.

### Slice 3: RuntimeSmoke Consumer

Potential later write scope:

```text
igniter-lang/lib/igniter_lang/runtime_smoke.rb
proof-owned runtime smoke experiment or track
```

Boundary:

- may be considered only after Slice 1 and a proof RuntimeMachine consumer route
  are accepted;
- must preserve `RuntimeSmoke` as proof-backed unless a separate decision
  reclassifies it;
- must not change `CompilerOrchestrator`, `CompilerResult`, or
  `CompilationReport` without explicit authority.

Slice 3 is not recommended as the next implementation card.

---

## Result and Error Surface

Recommended Slice 1 error surface:

```text
internal exception classes, plain raise, proof wrapper normalizes for summary
```

Candidate internal classes:

```text
IgniterLang::SemanticIRExpressionEvaluator::Error
IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
```

Recommended internal reason labels, if useful for proof summaries:

| Internal reason | Meaning |
| --- | --- |
| `runtime.if_expr_malformed` | `if_expr` lacks `condition`, `then_branch`, or `else_branch`. |
| `runtime.if_expr_condition_not_bool` | Condition value is not exactly `true` or `false`. |
| `runtime.expression_unsupported` | Selected path contains unsupported expression kind. |
| `runtime.ref_missing` | Selected path references a missing value. |

Status:

- internal/provisional only;
- not `OOF-RT-*`;
- not `Diagnostics`;
- not `CompilationReport`;
- not public result surface;
- not API/CLI;
- not release evidence wording.

The proof harness may catch these exceptions and render a local summary shape.
The live evaluator itself should not write reports, sidecars, or diagnostics.

---

## Runtime Semantics

The future live evaluator must preserve the accepted R196/R197 semantics:

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
- hidden side-effect execution from the non-selected branch;
- treating proof call traces as dependency authority.

---

## Malformed SemanticIR Policy

Malformed direct input should fail closed.

Fail closed when:

- `expr` is not a Hash-like expression node;
- `kind` is missing;
- `if_expr.condition` is missing;
- `if_expr.then_branch` is missing;
- `if_expr.else_branch` is missing;
- selected-path expression kind is unsupported;
- selected-path reference is missing;
- condition evaluates to a non-Bool value.

Do not pre-evaluate or deeply validate the non-selected branch beyond requiring
the branch field to exist. A non-selected branch with an unsupported expression
kind should not fail unless that branch is selected.

This preserves both lazy semantics and fail-closed behavior for structurally
invalid `if_expr` nodes.

---

## Dependency and Cache Stance

Static union remains accepted and conservative:

```text
condition deps + then_branch deps + else_branch deps
```

Dynamic selected-branch dependency tracking remains deferred.

Slice 1 must not introduce:

- path-sensitive dependency receipts;
- dynamic dependency authority;
- path-sensitive cache keys;
- cache invalidation changes;
- freshness state changes;
- runtime report fields implying selected-path dependency authority.

An optional proof trace may record evaluation order, but it must be labeled as
debug/proof evidence only.

---

## Counterfactual Audit Stance

The future pressure document records the phrase:

```text
Runtime is lazy.
Audit is aware.
```

R198 stance:

- acknowledge the pressure;
- do not implement counterfactual audit;
- do not evaluate latent/non-selected branches in normal runtime;
- preserve explicit `condition`, `then_branch`, and `else_branch` structure so a
  future audit layer can inspect static branch metadata;
- avoid designs that require eager evaluation to produce explanations;
- keep counterfactual dry-run, comparison reports, effect sandboxing, and public
  counterfactual API/CLI closed.

Future audit work should be a separate design route. It must not be smuggled
into the evaluator implementation as "helpful" eager evaluation.

---

## Integration Boundaries

| Surface | R198 decision |
| --- | --- |
| `SemanticIRExpressionEvaluator` | Recommended first live internal boundary. |
| Root require `lib/igniter_lang.rb` | Closed for Slice 1. |
| `RuntimeSmoke` | May be a later consumer, not the next slice. |
| `CompilerOrchestrator` | Closed. |
| `CompilerResult` | Closed. |
| `CompilationReport` | Closed. |
| `Diagnostics` | Closed. |
| `runtime_machine_memory_proof` | Later consumer candidate, not Slice 1. |
| Assembler / `.igapp` | Closed; no artifact shape changes needed. |
| Parser / classifier / TypeChecker / SemanticIR emitter | Closed; already accepted compiler support remains unchanged. |
| Public API/CLI | Closed. |
| Release harness / release evidence | Closed; release lane paused. |
| Spark | Closed. |

---

## Future Proof and Regression Matrix

Future Slice 1 implementation review should require:

| ID | Proof case | Expected result |
| --- | --- | --- |
| LRT-IF1 | `condition=true` | Only `then_branch` evaluated; value returned. |
| LRT-IF2 | `condition=false` | Only `else_branch` evaluated; value returned. |
| LRT-IF3 | Non-selected `then_branch` would fail | No failure when condition is false. |
| LRT-IF4 | Non-selected `else_branch` would fail | No failure when condition is true. |
| LRT-IF5 | Condition failure | Propagates before branch evaluation. |
| LRT-IF6 | Selected branch failure | Propagates selected branch failure. |
| LRT-IF7 | Non-Bool condition values | Fail closed; no truthy/falsy coercion. |
| LRT-IF8 | Missing `condition` / `then_branch` / `else_branch` | Fail closed as malformed `if_expr`. |
| LRT-IF9 | Unknown selected-path kind | Fail closed. |
| LRT-IF10 | Unknown non-selected-path kind | Does not fire. |
| LRT-IF11 | Nested `if_expr` | Lazy semantics recurse. |
| LRT-IF12 | Static deps vs proof trace | Static union preserved; trace is not dependency authority. |
| LRT-IF13 | Error surface isolation | Exceptions remain internal; no `Diagnostics`, report, result, API/CLI exposure. |
| LRT-IF14 | Direct-require-only boundary | New evaluator is not required by `lib/igniter_lang.rb`. |
| LRT-IF15 | Closed-surface scan | No orchestrator, RuntimeSmoke, CompilerResult, CompilationReport, assembler, release, public, Spark, or production changes. |

Suggested command matrix for a later implementation card:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
```

The release-harness delta command is regression evidence only. It must not be
treated as release execution or public release authorization.

---

## Explicit Answers

### Where should live `if_expr` runtime/evaluator support live?

In a new internal direct-require-only file:

```text
lib/igniter_lang/semanticir_expression_evaluator.rb
IgniterLang::SemanticIRExpressionEvaluator
```

Not in `RuntimeSmoke`, `CompilerOrchestrator`, `CompilerResult`,
`CompilationReport`, assembler, or `.igapp` artifact code for the first live
slice.

### Should implementation be one slice or split?

Split.

Recommended order:

1. Internal evaluator core.
2. Proof RuntimeMachine consumer, if still needed after core acceptance.
3. `RuntimeSmoke` consumer, only after a separate authorization decision.

### Do runtime diagnostics remain local/open or get a proposed internal shape?

They remain local/open publicly, with a proposed internal exception shape for
Slice 1.

No `OOF-RT-*`, no `Diagnostics` integration, and no public runtime diagnostic
vocabulary is accepted here.

### May `RuntimeSmoke` be touched in a later implementation card?

Yes, but not in the next recommended Slice 1 card.

`RuntimeSmoke` may be considered only as a later consumer after the internal
evaluator core and, preferably, a proof RuntimeMachine consumer have been
accepted.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

They remain closed for Slice 1 and should not be changed merely to add internal
expression evaluation.

### Does dependency/cache behavior remain static-union/conservative?

Yes.

Static dependency union remains the accepted compiler/runtime boundary.

### Does dynamic selected-branch dependency tracking remain deferred?

Yes.

Proof traces may demonstrate lazy selection, but they are not dependency
tracking authority.

### Does counterfactual audit remain future pressure only?

Yes.

No counterfactual audit, dry run, comparison report, or latent-branch execution
is authorized.

### May implementation authorization review open next?

Yes.

Recommended next review: authorize or hold Slice 1 only, the internal
direct-require evaluator core plus proof harness.

### Does release lane remain paused?

Yes.

No release execution or release evidence mutation opens from this design.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

No public claims open from this design.

### Do Spark/API/CLI remain closed?

Yes.

No Spark, public API, or CLI surface opens.

---

## C3-A Decision Options

| Option | Meaning | Recommended stance |
| --- | --- | --- |
| Accept design and authorize later implementation-authorization review | Open a future review for Slice 1 internal evaluator core only | Preferred. |
| Accept design but keep implementation held | Record boundary, but wait before any live lib write | Acceptable if Architect wants another runtime architecture pressure pass. |
| Conditional accept with blockers | Require stricter naming/error-surface wording before review | Viable only if internal exception shape is considered too broad. |
| Hold pending more architecture survey | Delay due to uncertainty about runtime placement | Not necessary; direct-require internal evaluator avoids integration risk. |
| Redirect | Route to counterfactual audit or cache/dependency design first | Not recommended; both are deferred and not required for live evaluator core. |

Preferred C3-A:

```text
accept design and authorize a later implementation-authorization review for
Slice 1 only: internal direct-require SemanticIR expression evaluator core plus
proof harness. Keep RuntimeSmoke, CompilerOrchestrator, CompilerResult,
CompilationReport, release/public/Spark/API/CLI, cache/path-sensitive tracking,
and counterfactual audit closed.
```

---

## Closed Surfaces

- implementation in this card;
- `RuntimeSmoke` changes for the next slice;
- `CompilerOrchestrator` behavior changes;
- `CompilerResult` changes;
- `CompilationReport` changes;
- `Diagnostics` centralization or new public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation;
- `lib/igniter_lang.rb` root require changes;
- release harness mutation, release commands, release execution;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Recommendation

Accept the design and route the next card as an implementation-authorization
review for Slice 1 only:

```text
lib/igniter_lang/semanticir_expression_evaluator.rb
experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/**
docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md
```

The future implementation should extract the proven lazy `if_expr` semantics
into an internal direct-require evaluator core. It should not touch
`RuntimeSmoke`, `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`,
release evidence, public API/CLI, Spark, cache behavior, or counterfactual audit.
