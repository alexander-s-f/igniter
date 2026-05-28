# Branch Conditional If Expr Proof Runtime Consumer Boundary Design v0

Card: S3-R200-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0`  
Route: UPDATE  
Depends on: S3-R199-C5-S  
Status: done  
Date: 2026-05-28

---

## Purpose

Design the Slice 2 proof RuntimeMachine consumer boundary for
`IgniterLang::SemanticIRExpressionEvaluator` without authorizing implementation.

This card does not edit code, does not authorize implementation, does not
authorize `RuntimeSmoke` consumer changes, does not execute release commands,
and does not authorize public demo, stable, production, all-grammar, Spark, API,
or CLI claims.

---

## Inputs Read

- `docs/tracks/stage3-round199-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md`
- `lib/igniter_lang/semanticir_expression_evaluator.rb`
- `experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`
- `lib/igniter_lang/runtime_smoke.rb`
- `docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`
- prior R196/R197/R198 `if_expr` runtime/evaluator design and proof materials as needed.

---

## Current State

R199 accepts Slice 1:

```text
IgniterLang::SemanticIRExpressionEvaluator
lib/igniter_lang/semanticir_expression_evaluator.rb
internal, direct-require-only, not root-required
```

Accepted Slice 1 interface:

```ruby
evaluator = IgniterLang::SemanticIRExpressionEvaluator.new
value = evaluator.evaluate(expr, values = {}, call_trace: nil)
```

Accepted Slice 1 expression kinds:

```text
literal
ref
if_expr
```

Accepted exclusions:

```text
apply
field_access
tbackend_read
```

Proof status:

```text
LRT-IF1..LRT-IF15: PASS
checks_total: 68
checks_pass: 68
checks_fail: 0
```

Still closed after R199:

- root require;
- `RuntimeSmoke`;
- proof RuntimeMachine consumer implementation;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics`;
- parser/classifier/TypeChecker/SemanticIR/assembler behavior;
- release/public/Spark/API/CLI/runtime production claims.

---

## Proof RuntimeMachine Current Evaluator

`experiments/runtime_machine_memory_proof/compiled_program.rb` currently
evaluates compute node expressions locally:

```text
literal
ref
apply
field_access
tbackend_read
```

Current local ownership:

- `literal`: returns embedded value;
- `ref`: reads from runtime values;
- `apply`: recursively evaluates operands, then applies canonical/proof
  operators;
- `field_access`: recursively evaluates object, then fetches field;
- `tbackend_read`: requires backend and `as_of`, then reads temporal payload;
- unknown kind: raises `ArgumentError`.

`if_expr` is not supported in this proof RuntimeMachine today.

---

## Key Design Pressure

Naive delegation is not enough.

If proof RuntimeMachine delegates an entire `if_expr` node to the Slice 1
evaluator, that evaluator recursively owns the selected branch. A selected
branch containing `apply`, `field_access`, or `tbackend_read` would fail with
`UnsupportedExpressionKindError`, even though proof RuntimeMachine already knows
how to evaluate those kinds locally.

Therefore a robust Slice 2 consumer must either:

1. expand the evaluator to support proof RuntimeMachine expression kinds; or
2. add a bounded internal fallback/adapter hook so the evaluator owns lazy
   `if_expr` selection while proof RuntimeMachine keeps ownership of its local
   expression kinds.

Recommended route: option 2.

---

## Boundary Decision

Proof RuntimeMachine should consume `SemanticIRExpressionEvaluator` later, but
only after a bounded internal fallback hook is accepted.

Recommended Slice 2 implementation shape:

```text
SemanticIRExpressionEvaluator owns:
  literal
  ref
  if_expr lazy selection

Proof RuntimeMachine owns:
  apply
  field_access
  tbackend_read
  proof-local operator application
  backend/as_of temporal reads
```

The consumer boundary should be adapter-style, not migration-style.

Meaning:

- do not move all proof RuntimeMachine expression semantics into the evaluator;
- do not make evaluator depend on proof RuntimeMachine;
- do not make evaluator temporal-aware;
- do not make `tbackend_read` part of evaluator core;
- do not introduce public diagnostics or report/result fields.

---

## Required Evaluator API Amendment

The accepted Slice 1 API is sufficient for standalone `literal/ref/if_expr`
evaluation. It is not sufficient for a full proof RuntimeMachine consumer that
must preserve `apply`, `field_access`, and `tbackend_read` behavior inside
selected `if_expr` branches.

Recommended internal amendment:

```ruby
evaluator.evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)
```

or equivalent constructor injection:

```ruby
evaluator = IgniterLang::SemanticIRExpressionEvaluator.new(
  external_evaluator: ->(expr, values, call_trace:) { ... }
)
```

Required semantics:

- existing `evaluate(expr, values = {}, call_trace: nil)` behavior remains
  backward-compatible;
- when the evaluator encounters an unsupported selected-path kind and an
  `external_evaluator` is present, it delegates that selected expression to the
  external evaluator;
- no external evaluator is called for a non-selected branch;
- no external evaluator is called before the condition is evaluated;
- non-selected branch unsupported kinds still do not fire;
- internal exception classes remain non-canonical;
- `call_trace` remains debug/proof evidence only.

The exact API spelling can be chosen by the implementation authorization review.
The design requirement is the same: lazy `if_expr` selection must be owned by
the live evaluator, while proof RuntimeMachine can own selected-path expression
kinds outside Slice 1.

---

## Expression-Kind Ownership Plan

| Kind | Slice 2 owner | Rationale |
| --- | --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` | Already accepted Slice 1 core. |
| `ref` | `SemanticIRExpressionEvaluator` | Already accepted Slice 1 core; values hash is compatible. |
| `if_expr` | `SemanticIRExpressionEvaluator` | Lazy semantics must stay centralized in live evaluator. |
| `apply` | Proof RuntimeMachine local for Slice 2 | Uses proof operator registry and proof-only `compute_slots` / `build_snapshot` behavior. |
| `field_access` | Proof RuntimeMachine local for Slice 2 | Already implemented locally; can later move to evaluator if a general expression expansion is authorized. |
| `tbackend_read` | Temporal/proof RuntimeMachine local | Requires backend/as_of and temporal authority; excluded from evaluator core. |

`apply` / `field_access` should not move into evaluator scope in Slice 2.

Future route after Slice 2 may consider a general evaluator expansion for
`field_access`, and possibly `apply` with an injected operator handler, but that
is not needed for the proof RuntimeMachine consumer boundary.

---

## Future Write Scope Candidate

Recommended future implementation authorization review may consider this bounded
write scope:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md
```

Allowed changes if later authorized:

- add a backward-compatible internal fallback/adapter hook to
  `SemanticIRExpressionEvaluator`;
- direct-require `SemanticIRExpressionEvaluator` from
  `experiments/runtime_machine_memory_proof/compiled_program.rb`;
- route `literal/ref/if_expr` and nested lazy selected-path evaluation through
  the evaluator;
- preserve proof RuntimeMachine local handling for `apply`, `field_access`, and
  `tbackend_read`;
- add a proof experiment showing `.igapp` compute evaluation through the proof
  RuntimeMachine path for `if_expr`.

Not allowed in that Slice 2 review unless separately opened:

- edit `lib/igniter_lang.rb`;
- edit `RuntimeSmoke`;
- edit `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, or
  `Diagnostics`;
- mutate release evidence;
- mutate specs/canon/proposals;
- change assembler or artifact/golden shape;
- open public API/CLI, Spark, production runtime, or counterfactual audit.

---

## RuntimeSmoke Stance

`RuntimeSmoke` remains closed.

Slice 2 may edit the proof RuntimeMachine that `RuntimeSmoke` loads, but it must
not edit `lib/igniter_lang/runtime_smoke.rb`, change smoke result shape, change
smoke report behavior, or claim `RuntimeSmoke` support.

If a proof RuntimeMachine change incidentally allows an existing
`runtime_smoke:` callback to evaluate an `if_expr` artifact, that is not
accepted as a `RuntimeSmoke` feature until a separate route explicitly proves
and accepts it.

For Slice 2, test through a dedicated proof RuntimeMachine consumer harness, not
through the orchestrator smoke callback.

---

## Dependency and Cache Stance

Static dependency union remains accepted and conservative.

Dynamic selected-branch dependency tracking remains deferred.

Slice 2 must not introduce:

- path-sensitive dependency receipts;
- dynamic dependency authority;
- path-sensitive cache keys;
- cache invalidation changes;
- freshness state changes;
- runtime report fields implying selected-path dependency authority.

Any call trace remains debug/proof evidence only.

---

## Counterfactual Audit Stance

Counterfactual audit remains future pressure only.

Slice 2 must preserve:

- normal runtime is lazy;
- non-selected branch is not executed;
- latent branch may remain statically inspectable as SemanticIR structure;
- no counterfactual dry-run;
- no branch comparison report;
- no effect sandboxing;
- no public counterfactual API/CLI.

The adapter design helps future audit by keeping branch structure explicit and
not requiring eager non-selected branch evaluation.

---

## Future Proof Matrix

Required proof RuntimeMachine consumer cases:

| ID | Proof case | Expected result |
| --- | --- | --- |
| PRT-IF1 | `.igapp` / contract compute with `if_expr`, condition true | Output from `then_branch`. |
| PRT-IF2 | `.igapp` / contract compute with `if_expr`, condition false | Output from `else_branch`. |
| PRT-IF3 | Selected branch contains `apply` | Proof RuntimeMachine local `apply` path works through adapter. |
| PRT-IF4 | Selected branch contains `field_access` | Proof RuntimeMachine local `field_access` path works through adapter. |
| PRT-IF5 | Selected branch contains `tbackend_read` with backend/as_of | Remains proof RuntimeMachine temporal-owned; works only where existing temporal proof authority allows. |
| PRT-IF6 | Non-selected branch contains unsupported kind | Does not fire. |
| PRT-IF7 | Non-selected branch contains `tbackend_read` without backend/as_of | Does not fire. |
| PRT-IF8 | Condition failure | Branches are not evaluated. |
| PRT-IF9 | Non-Bool condition | Fails closed; no truthy/falsy coercion. |
| PRT-IF10 | Malformed `if_expr` | Fails closed. |
| PRT-IF11 | Nested `if_expr` with selected branch using proof RuntimeMachine local kind | Lazy recursion works. |
| PRT-IF12 | Existing non-`if_expr` proof RuntimeMachine fixtures | No regression for `apply`, `field_access`, `tbackend_read`. |
| PRT-IF13 | Direct-require/root-require scan | `lib/igniter_lang.rb` unchanged. |
| PRT-IF14 | RuntimeSmoke closure scan | `runtime_smoke.rb` unchanged; no smoke result/report change. |
| PRT-IF15 | Report/public/release/Spark closure scan | No report/result/API/CLI/release/Spark changes. |

Suggested command matrix for later implementation:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

Optional regression command, only if the implementation review explicitly
includes release-harness regression evidence:

```bash
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
```

That optional command must remain regression evidence only, not release
execution.

---

## Explicit Answers

### Should Slice 2 open an implementation-authorization review later?

Yes, with a condition:

```text
the review must include the evaluator fallback/adapter API amendment or split
that amendment into a prerequisite Slice 2A.
```

Naive delegation is not sufficient for preserving proof RuntimeMachine behavior.

### May proof RuntimeMachine consume the evaluator in a later card?

Yes.

It may consume the evaluator through an adapter boundary that keeps
`apply`, `field_access`, and `tbackend_read` proof RuntimeMachine-owned.

### Do `apply` / `field_access` move into evaluator scope?

No for Slice 2.

They remain proof RuntimeMachine-local. A later general evaluator expansion may
reconsider `field_access` or `apply` separately.

### Does `tbackend_read` remain excluded from evaluator?

Yes.

`tbackend_read` remains temporal/runtime-owned and proof RuntimeMachine-local.
It must not enter evaluator core without separate temporal/runtime authority.

### Is the accepted Slice 1 evaluator API sufficient?

Partly.

It is sufficient for standalone `literal/ref/if_expr` evaluation. It is not
sufficient for robust proof RuntimeMachine consumption where selected branches
may contain `apply`, `field_access`, or `tbackend_read`.

Slice 2 needs a bounded internal fallback/adapter hook or a prerequisite API
amendment.

### Does `RuntimeSmoke` remain closed?

Yes.

No `runtime_smoke.rb` edit, smoke result-shape change, smoke report behavior
change, or smoke-support claim is authorized.

### Does root require remain closed?

Yes.

`lib/igniter_lang.rb` must remain unchanged for Slice 2.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

They must not change for Slice 2.

### Does dynamic dependency tracking remain deferred?

Yes.

No dynamic dependency authority opens.

### Does counterfactual audit remain future pressure only?

Yes.

No counterfactual audit implementation opens.

### Does release lane remain paused?

Yes.

No release execution or release evidence mutation opens.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

No public claims open.

### Do Spark/API/CLI remain closed?

Yes.

No Spark, public API, or CLI surface opens.

---

## C3-A Decision Options

| Option | Meaning | Recommended stance |
| --- | --- | --- |
| Accept design and authorize later implementation-authorization review | Open a bounded Slice 2 review with evaluator fallback/adapter amendment plus proof RuntimeMachine consumer proof | Preferred, if the amendment is included explicitly. |
| Accept design but keep implementation held | Record boundary, but delay consumer work | Acceptable if Architect wants API-amendment review as a separate design card. |
| Conditional accept with blockers | Accept direction, but require fallback/adapter API wording before implementation review | Also viable; use if the API amendment must be separated as Slice 2A. |
| Hold pending more architecture survey | Delay due to RuntimeSmoke/proof RuntimeMachine coupling | Not necessary; the boundary keeps RuntimeSmoke closed. |
| Redirect | Route to general evaluator expansion, cache/dependency tracking, or counterfactual audit first | Not recommended; all are broader than needed. |

Preferred C3-A:

```text
accept design and authorize a later bounded implementation-authorization review
for Slice 2, provided the review explicitly includes a backward-compatible
SemanticIRExpressionEvaluator fallback/adapter hook and keeps apply,
field_access, and tbackend_read proof RuntimeMachine-owned.
```

---

## Closed Surfaces

- implementation in this card;
- `RuntimeSmoke` consumer changes;
- root require changes;
- `CompilerOrchestrator` changes;
- `CompilerResult` changes;
- `CompilationReport` changes;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation outside a
  future proof-owned output directory;
- release harness mutation, release commands, release execution;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Recommendation

Proceed to a later implementation-authorization review, but do not authorize
implementation from this card.

Recommended next boundary:

```text
Slice 2 = evaluator fallback/adapter hook + proof RuntimeMachine consumer proof
```

The proof RuntimeMachine should consume `SemanticIRExpressionEvaluator` for
`literal/ref/if_expr` and keep `apply`, `field_access`, and `tbackend_read`
local. The accepted Slice 1 API needs a small backward-compatible internal hook
before robust consumer integration should be implemented.
