# Branch Conditional If Expr Proof Runtime Consumer Boundary Decision v0

Card: S3-R200-C3-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `branch-conditional-if-expr-proof-runtime-consumer-boundary-decision-v0`  
Route: UPDATE  
Status: done / accepted-design-authorize-later-implementation-authorization-review  
Date: 2026-05-28

Depends on:
- S3-R200-C1-D
- S3-R200-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round199-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## Decision

Decision:

```text
accept Slice 2 proof RuntimeMachine consumer boundary design
authorize a later implementation-authorization review
do not authorize implementation in this card
```

The design is accepted because it correctly identifies that naive delegation is
insufficient: if proof RuntimeMachine delegates a full `if_expr` to
`SemanticIRExpressionEvaluator`, selected branches containing `apply`,
`field_access`, or `tbackend_read` would fail under the Slice 1 evaluator. The
accepted route is an adapter boundary, not a migration boundary.

Accepted Slice 2 direction:

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

Implementation remains closed until a separate authorization review. That review
may open next.

---

## Binding Clarifications From C2-X

S3-R200-C2-X reported 13/13 PASS with two non-blocking notes. This decision
turns the ambiguous parts into binding requirements for the next authorization
review.

### API Amendment Form

The next authorization review must use the per-call keyword form:

```ruby
evaluator.evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)
```

Rationale:

- preserves the accepted Slice 1 call shape when the keyword is omitted;
- keeps evaluator instances stateless;
- makes proof harness expectations explicit per call;
- avoids hidden constructor state for a proof-only consumer bridge;
- allows the same evaluator instance to be used with or without delegation.

Constructor injection is not accepted for Slice 2 unless a later delta review
reopens this choice.

### External Evaluator Exception Policy

If `external_evaluator` raises, the exception must propagate unchanged.

The live evaluator must not swallow, wrap, or convert external proof
RuntimeMachine exceptions into evaluator diagnostics. This keeps the boundary
honest: evaluator-owned errors remain evaluator-owned; proof RuntimeMachine
local errors remain proof RuntimeMachine local.

### Call Trace Policy

The evaluator may pass `call_trace:` through the delegation boundary.

Any trace entries produced by either side remain debug/proof evidence only. They
must not become dependency receipts, cache authority, report fields,
diagnostics, or public API/CLI output.

### PRT-IF5 Temporal Scope

`tbackend_read` remains temporal/proof RuntimeMachine-owned.

For the next proof:

- mandatory: prove structurally that `tbackend_read` is not absorbed into
  evaluator core and is never evaluated in a non-selected branch;
- mandatory: prove selected-path delegation reaches proof RuntimeMachine local
  ownership rather than evaluator core;
- optional: include a full temporal fixture only if existing proof-local
  temporal infrastructure can be used without widening temporal authority.

No new temporal/runtime authority opens from this decision.

---

## Future Authorization Review Boundary

Recommended next card:

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

Candidate future implementation write scope, if authorized by that later card:

```text
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md
```

This write scope is not authorized by this card. It is only the candidate scope
for the next authorization review.

---

## Required Future Proof Matrix

The next authorization review must preserve or tighten this proof matrix:

| ID | Required proof | Expected status |
| --- | --- | --- |
| PRT-IF1 | `.igapp` / contract compute with `if_expr`, condition true | Output from `then_branch`. |
| PRT-IF2 | `.igapp` / contract compute with `if_expr`, condition false | Output from `else_branch`. |
| PRT-IF3 | Selected branch contains `apply` | Handled by proof RuntimeMachine local path through adapter. |
| PRT-IF4 | Selected branch contains `field_access` | Handled by proof RuntimeMachine local path through adapter. |
| PRT-IF5 | Selected-path `tbackend_read` ownership | Structural proof required; full temporal fixture optional under existing proof authority only. |
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

Required command matrix candidate:

```bash
ruby -c igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby -c igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

Release-harness delta regression may be added only as read-only regression
evidence. It must not mutate or relabel accepted release evidence.

---

## Explicit Answers

### Is the proof RuntimeMachine consumer boundary design accepted?

Yes.

The accepted design is adapter-style: centralize lazy `if_expr` selection in
`SemanticIRExpressionEvaluator`, while keeping proof RuntimeMachine expression
kinds local.

### May implementation authorization review open next?

Yes.

A later bounded implementation-authorization review may open after status
curation.

### Is implementation authorized now?

No.

No code, proof harness, RuntimeMachine, evaluator hook, or output write is
authorized by this decision.

### May proof RuntimeMachine consume the evaluator in a later card?

Yes.

It may consume the evaluator through the accepted `external_evaluator:` adapter
boundary if a later authorization review opens implementation.

### Do `apply` / `field_access` move into evaluator scope?

No for Slice 2.

They remain proof RuntimeMachine-local. A later general evaluator expansion may
reconsider this separately.

### Does `tbackend_read` remain temporal/runtime-owned?

Yes.

`tbackend_read` remains proof RuntimeMachine / temporal-owned and must not enter
evaluator core without a separate temporal/runtime authority gate.

### Does `RuntimeSmoke` remain closed?

Yes.

`RuntimeSmoke` is not part of Slice 2. Any incidental effect from editing the
proof RuntimeMachine must not be claimed as RuntimeSmoke support.

### Does root require remain closed?

Yes.

No `igniter-lang/lib/igniter_lang.rb` edit is authorized.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

All remain closed.

### Does dynamic dependency tracking remain deferred?

Yes.

Static dependency union remains the accepted conservative model. Dynamic
selected-branch dependency tracking, path-sensitive cache keys, dependency
receipts, and cache invalidation changes remain deferred.

### Does counterfactual audit remain future pressure only?

Yes.

Runtime remains lazy. Audit remains future-aware but not implemented here.

### Does release lane remain paused?

Yes.

No release execution, release-evidence mutation, publish, yank, tag, push, sign,
or deploy opens.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

Spark, public API, and CLI remain out of scope.

---

## Remaining Closed Surfaces

Remain closed:

- implementation in this card;
- `RuntimeSmoke` integration;
- root require;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation outside a
  future proof-owned output directory;
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

R200-C3-A accepts the Slice 2 proof RuntimeMachine consumer boundary design and
authorizes a later implementation-authorization review, not implementation.

The accepted shape is:

```text
Evaluator owns lazy if_expr selection.
Proof RuntimeMachine keeps apply, field_access, and tbackend_read.
Bridge is a backward-compatible per-call external_evaluator hook.
```

The next authorization review must bind the `external_evaluator:` API,
exception propagation, call trace non-authority, and `tbackend_read` structural
proof scope before any code opens.

---

## Exact Next Dispatch Recommendation

Immediate next card:

```text
Card: S3-R200-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round200-status-curation-v0
Route: UPDATE
Depends on:
- S3-R200-C1-D
- S3-R200-C2-X
- S3-R200-C3-A
```

Recommended next Main Line route after status curation:

```text
Card: S3-R201-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R200-C4-S
```

No implementation may begin until that authorization review explicitly opens it.
