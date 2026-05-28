# Branch Conditional If Expr Proof Runtime Consumer Implementation Authorization Review v0

Card: S3-R201-C1-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0`  
Route: UPDATE  
Status: done / authorized-bounded-slice2-proof-runtime-consumer-implementation  
Date: 2026-05-28

Depends on:
- S3-R200-C4-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round200-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round199-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## Decision

Decision:

```text
authorize bounded Slice 2 proof RuntimeMachine consumer implementation
```

C2-I may begin in this round under the exact boundary below.

Rationale:

- R200 accepted the Slice 2 adapter boundary.
- R200 pressure returned 13/13 PASS and C3-A resolved the two ambiguity notes.
- Current evaluator is isolated and direct-require-only.
- Current proof RuntimeMachine already owns `apply`, `field_access`, and
  `tbackend_read`.
- The implementation can be proven without opening `RuntimeSmoke`, root require,
  compiler/result/report surfaces, public API/CLI, release, Spark, cache, or
  counterfactual audit.

This authorization is implementation-specific and proof-local. It does not
authorize RuntimeSmoke integration or public runtime claims.

---

## Authorized C2-I Boundary

```text
Card: S3-R201-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-proof-runtime-consumer-v0
Route: UPDATE
Depends on:
- S3-R201-C1-A
```

Goal:

```text
Implement the bounded Slice 2 proof RuntimeMachine consumer: add the
backward-compatible evaluator external_evaluator hook, route proof RuntimeMachine
if_expr evaluation through the evaluator, and prove PRT-IF1..PRT-IF15.
```

Allowed write scope:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md
```

No other file may be edited by C2-I unless C2-I stops and routes a delta review.

---

## Required Implementation Semantics

### Evaluator Hook API

The only authorized API amendment is the per-call keyword:

```ruby
evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)
```

Requirements:

- preserve existing behavior when `external_evaluator:` is omitted;
- keep constructor injection out of scope;
- evaluator remains internal and direct-require-only;
- `SUPPORTED_KINDS` must remain the evaluator-owned core kind list:
  `literal`, `ref`, `if_expr`;
- if a selected-path expression kind is unsupported by evaluator and
  `external_evaluator:` is present, delegate that selected expression to the
  external evaluator;
- do not call `external_evaluator` for a non-selected branch;
- do not call `external_evaluator` before condition evaluation;
- if `external_evaluator` raises, propagate the exception unchanged;
- `call_trace` may flow through the delegation boundary only as debug/proof
  evidence.

### Proof RuntimeMachine Consumer

`igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` may
direct-require `SemanticIRExpressionEvaluator` and consume it for `if_expr`.

Requirements:

- proof RuntimeMachine keeps local ownership of `apply`;
- proof RuntimeMachine keeps local ownership of `field_access`;
- proof RuntimeMachine keeps local ownership of `tbackend_read`;
- `tbackend_read` remains temporal/proof RuntimeMachine-owned and must not enter
  evaluator core;
- existing non-`if_expr` proof RuntimeMachine behavior must be preserved;
- no RuntimeSmoke result/report behavior may be changed.

---

## Expression-Kind Ownership Policy

| Kind | Authorized owner for C2-I |
| --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` |
| `ref` | `SemanticIRExpressionEvaluator` |
| `if_expr` | `SemanticIRExpressionEvaluator` |
| `apply` | proof RuntimeMachine local |
| `field_access` | proof RuntimeMachine local |
| `tbackend_read` | proof RuntimeMachine / temporal-owned |

`apply`, `field_access`, and `tbackend_read` must not be added to evaluator
core in C2-I.

---

## tbackend_read Authority Stance

`tbackend_read` remains temporal/proof RuntimeMachine-owned.

C2-I must prove:

- `tbackend_read` is not absorbed into evaluator core;
- selected-path `tbackend_read` ownership reaches proof RuntimeMachine local
  handling rather than evaluator core;
- non-selected `tbackend_read` does not fire, including when backend/as_of are
  absent.

A full temporal fixture is optional only if it reuses existing proof-local
temporal infrastructure without widening authority.

---

## Required Proof Matrix

| ID | Required proof | Expected status |
| --- | --- | --- |
| PRT-IF1 | `.igapp` / contract compute with `if_expr`, condition true | Returns `then_branch`. |
| PRT-IF2 | `.igapp` / contract compute with `if_expr`, condition false | Returns `else_branch`. |
| PRT-IF3 | Selected branch contains `apply` | Proof RuntimeMachine local path works through adapter. |
| PRT-IF4 | Selected branch contains `field_access` | Proof RuntimeMachine local path works through adapter. |
| PRT-IF5 | Selected-path `tbackend_read` ownership | Structural proof mandatory; full temporal fixture optional under existing proof authority only. |
| PRT-IF6 | Non-selected branch contains unsupported kind | Does not fire. |
| PRT-IF7 | Non-selected branch contains `tbackend_read` without backend/as_of | Does not fire. |
| PRT-IF8 | Condition failure | Branches are not evaluated. |
| PRT-IF9 | Non-Bool condition | Fails closed; no truthy/falsy coercion. |
| PRT-IF10 | Malformed `if_expr` | Fails closed. |
| PRT-IF11 | Nested `if_expr` with selected local kind | Lazy recursion works. |
| PRT-IF12 | Existing non-`if_expr` proof RuntimeMachine fixtures | No regression for `apply`, `field_access`, `tbackend_read`. |
| PRT-IF13 | Direct-require/root-require scan | `lib/igniter_lang.rb` unchanged. |
| PRT-IF14 | RuntimeSmoke closure scan | `runtime_smoke.rb` unchanged; no smoke result/report change. |
| PRT-IF15 | Report/public/release/Spark closure scan | No report/result/API/CLI/release/Spark changes. |

Required summary shape:

- top-level status: `PASS`, `HOLD`, or `FAIL`;
- named PRT-IF results;
- total/pass/fail check counts;
- changed-file list;
- command matrix result;
- closed-surface scan result;
- explicit non-claims.

---

## Required Command Matrix

C2-I must run and report:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

Optional read-only regression:

```bash
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
```

The optional release-harness delta command, if run, remains regression evidence
only. It must not mutate, rewrite, or relabel accepted release evidence.

---

## Explicit Answers

### May C2-I begin in this round?

Yes.

C2-I is authorized under the bounded scope in this document.

### May `semanticir_expression_evaluator.rb` be edited?

Yes.

Only to add the backward-compatible per-call `external_evaluator:` hook and
support the required delegation semantics. It must remain internal,
direct-require-only, and not root-required.

### May `experiments/runtime_machine_memory_proof/compiled_program.rb` consume the evaluator?

Yes.

It may direct-require and consume `SemanticIRExpressionEvaluator` for `if_expr`
through the authorized adapter boundary. This does not authorize RuntimeSmoke
integration.

### Is the per-call `external_evaluator:` hook binding?

Yes.

### Is constructor injection rejected for Slice 2?

Yes.

Constructor injection remains out of scope for C2-I.

### Do external evaluator exceptions propagate unchanged?

Yes.

C2-I must not wrap, swallow, or convert external evaluator exceptions.

### Does `call_trace` remain proof/debug only?

Yes.

No dependency, cache, report, diagnostics, or public authority may derive from
`call_trace`.

### Do `apply` / `field_access` remain proof RuntimeMachine-local?

Yes.

They must not move into evaluator core in C2-I.

### Does `tbackend_read` remain temporal/proof RuntimeMachine-owned?

Yes.

### Does `RuntimeSmoke` remain closed?

Yes.

C2-I must not edit `igniter-lang/lib/igniter_lang/runtime_smoke.rb`. If the proof
RuntimeMachine change incidentally affects a path RuntimeSmoke can load, that is
not accepted as RuntimeSmoke support.

### Does root require remain closed?

Yes.

No `igniter-lang/lib/igniter_lang.rb` edit is authorized.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

### Does dynamic dependency tracking remain deferred?

Yes.

No path-sensitive dependency receipts, dynamic dependency authority,
path-sensitive cache keys, cache invalidation changes, freshness changes, or
runtime report fields open.

### Does counterfactual audit remain future pressure only?

Yes.

Runtime remains lazy. Audit remains future-aware but not implemented.

### Does release lane remain paused?

Yes.

No release execution, release evidence mutation, RubyGems publish, yank, tag,
push, sign, or deploy opens.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

---

## Excluded Surfaces

C2-I must not touch or authorize:

- implementation outside the allowed write scope;
- `RuntimeSmoke` integration;
- root require `igniter-lang/lib/igniter_lang.rb`;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler pipeline,
  assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation
  outside the new proof-owned output directory;
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

## Compact Decision Summary

S3-R201-C1-A authorizes bounded Slice 2 implementation.

The implementation may add a per-call `external_evaluator:` hook to the internal
evaluator and may wire proof RuntimeMachine to consume evaluator-owned
`if_expr`. Proof RuntimeMachine must keep `apply`, `field_access`, and
`tbackend_read`; RuntimeSmoke, root require, compiler/result/report, release,
public, Spark, API/CLI, cache authority, and counterfactual audit remain closed.

Exact next card:

```text
S3-R201-C2-I
Track: branch-conditional-if-expr-proof-runtime-consumer-v0
Mode: bounded implementation plus proof
```
