# Branch Conditional If Expr Runtime Smoke Consumer Boundary Decision v0

Card: S3-R202-C3-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `branch-conditional-if-expr-runtime-smoke-consumer-boundary-decision-v0`  
Route: UPDATE  
Status: done / accepted-design-authorize-later-implementation-authorization-review  
Date: 2026-05-28

Depends on:
- S3-R202-C1-D
- S3-R202-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round201-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`

---

## Decision

Decision:

```text
accept RuntimeSmoke consumer boundary design
authorize a later implementation-authorization review
do not authorize RuntimeSmoke implementation in this card
```

The design is accepted as a proof-owned RuntimeSmoke consumer route, not as a
public runtime route. The next route may be an implementation-authorization
review for a proof harness that exercises existing `RuntimeSmoke.run` against
proof-owned `.igapp` artifacts containing `if_expr`.

No code implementation is authorized by this card.

---

## Accepted Boundary

Accepted design shape:

```text
proof-owned RuntimeSmoke consumer harness
no runtime_smoke.rb edits
no CompilerOrchestrator callback integration
no CompilerResult / CompilationReport mutation
no public API/CLI widening
no release/public/runtime/production claim
```

The accepted hierarchy is binding:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

Transitive evaluator load is accepted as a known consequence of R201:

```text
runtime_smoke.rb loads compiled_program.rb
compiled_program.rb loads semanticir_expression_evaluator.rb
```

This does not count as RuntimeSmoke support by itself.

---

## Binding Clarifications From C2-X

S3-R202-C2-X reported 13/13 PASS, no blockers, and three non-blocking notes.
This decision resolves the notes before any implementation-authorization review
may open.

### RS-IF5 Coverage

RS-IF5 must cover both proof RuntimeMachine-local selected branch kinds:

```text
RS-IF5a: selected branch uses apply through RuntimeSmoke path
RS-IF5b: selected branch uses field_access through RuntimeSmoke path
```

Both are mandatory for the later proof matrix.

### .igapp Artifact Creation Strategy

The next authorization review must require programmatic proof-owned artifact
generation:

```text
write minimal .igapp directories programmatically under
igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/
```

Rationale:

- avoids `CompilerOrchestrator`;
- avoids compiler/result/report coupling;
- avoids borrowing existing accepted release evidence;
- keeps fixtures inside the proof-owned experiment;
- gives the harness exact control over condition true/false and negative cases;
- makes cleanup and closed-surface scans straightforward.

Hand-authored shared fixtures and existing `.igapp` reuse are not accepted for
the first RuntimeSmoke consumer proof unless a later delta review reopens this.

### RS-IF2 Assertion Form

RS-IF2 must include both forms:

```text
source/claim scan:
  proof artifacts must not claim transitive load as RuntimeSmoke support

behavioral assertion:
  requiring/loading RuntimeSmoke without calling RuntimeSmoke.run must not
  execute an if_expr artifact or invoke evaluator evaluation
```

This keeps transitive load and support proof distinct.

### Negative RuntimeSmoke Rescue Case

Add a mandatory negative case:

```text
RS-IF16:
  RuntimeSmoke.run on malformed or non-Bool if_expr returns the existing blocked
  failure shape with trusted: false, without widening diagnostics/report/result
  surfaces.
```

This records the existing `RuntimeSmoke.run` rescue behavior as proof evidence
without changing it.

---

## Future Authorization Review Boundary

Recommended next card:

```text
Card: S3-R203-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R202-C4-S
```

Goal:

```text
Decide whether a bounded proof-owned RuntimeSmoke consumer harness may begin,
with no runtime_smoke.rb edits, no result-shape changes, and no public runtime
claims.
```

Candidate future write scope, if authorized by that later card:

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md
```

Read-only / must remain unchanged:

```text
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

This write scope is not authorized by this card. It is only the candidate scope
for a later authorization review.

---

## RuntimeSmoke Stances

### Result Shape

`RuntimeSmoke.run` result shape must remain unchanged for the first proof route.

Success shape remains:

```text
load_status
contract_id
evaluate_status
outputs
compatibility_report_status
trusted
```

Failure shape remains:

```text
load_status: "blocked"
error
trusted: false
```

### Callback

`RuntimeSmoke.callback` behavior must remain unchanged.

The first proof route must not use `CompilerOrchestrator#compile(...,
runtime_smoke:)` or claim compiler result/report integration.

### eval_input_for

`RuntimeSmoke.eval_input_for` must remain unchanged.

Fixture policy:

- no new `if_expr` contract id special cases;
- keep the existing `Add` special case unchanged;
- proof-owned `.igapp` fixtures must use explicit `sample_input`;
- any fixture defaults belong in the proof harness, not in `RuntimeSmoke`.

---

## Dual-Path Evaluator Stance

The R201 dual-path evaluator remains accepted for this route:

```text
external_evaluator absent  -> Slice 1 path
external_evaluator present -> Slice 2 path
```

RuntimeSmoke design does not require evaluator unification. Dual-path
duplication is known future evaluator debt, not a blocker for proof-owned
RuntimeSmoke consumer proof.

---

## Required Future Proof Matrix

The next authorization review must preserve or tighten this matrix:

| ID | Required proof | Expected status |
| --- | --- | --- |
| RS-IF1 | Direct-require `RuntimeSmoke` | Loads without root require change. |
| RS-IF2 | Transitive evaluator load classified | Source/claim scan plus behavioral load-without-eval assertion. |
| RS-IF3 | `RuntimeSmoke.run` on `if_expr` condition true artifact | `trusted: true`; output from `then_branch`. |
| RS-IF4 | `RuntimeSmoke.run` on `if_expr` condition false artifact | `trusted: true`; output from `else_branch`. |
| RS-IF5a | Selected branch uses proof RuntimeMachine-local `apply` | Output proves adapter path works through smoke. |
| RS-IF5b | Selected branch uses proof RuntimeMachine-local `field_access` | Output proves adapter path works through smoke. |
| RS-IF6 | Non-selected branch would fail / unsupported kind | Does not fire through smoke path. |
| RS-IF7 | Existing `RuntimeSmoke.run` result shape | Exact key set unchanged for success and failure. |
| RS-IF8 | Existing `RuntimeSmoke.callback` behavior | Source unchanged; optional lambda shape unchanged if exercised without orchestrator mutation. |
| RS-IF9 | Existing `RuntimeSmoke.eval_input_for` behavior | No `if_expr` special case; explicit `sample_input` used. |
| RS-IF10 | Dual-path evaluator preserved | No evaluator unification or structural-proof rewrite. |
| RS-IF11 | Compiler/result/report closure | `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, `Diagnostics` unchanged. |
| RS-IF12 | Root require closure | `lib/igniter_lang.rb` unchanged. |
| RS-IF13 | Dependency/cache closure | Dynamic tracking remains deferred; no cache semantics change. |
| RS-IF14 | Counterfactual audit closure | No dry-run/comparison/eager latent branch. |
| RS-IF15 | Release/public/Spark/API/CLI closure | No public/runtime/release claim opens. |
| RS-IF16 | Existing RuntimeSmoke rescue behavior for bad `if_expr` | Returns blocked failure shape with `trusted: false`; no diagnostics/result/report widening. |

Candidate future command matrix:

```bash
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
```

Optional regression:

```bash
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
```

No release command belongs in this route.

---

## Explicit Answers

### Is RuntimeSmoke consumer boundary design accepted?

Yes.

### May implementation authorization review open next?

Yes.

A later implementation-authorization review may open for a proof-owned
RuntimeSmoke consumer harness only.

### Is RuntimeSmoke implementation authorized now?

No.

No code, proof harness, fixture, or output write is authorized by this card.

### Does transitive evaluator load count as RuntimeSmoke support?

No.

It is a known consequence only. Support requires dedicated proof and acceptance.

### May RuntimeSmoke later exercise `if_expr` through proof RuntimeMachine?

Yes, through a proof-owned harness using existing `RuntimeSmoke.run`.

### Does RuntimeSmoke result shape remain unchanged?

Yes.

### Does RuntimeSmoke callback behavior remain unchanged?

Yes.

### Is RuntimeSmoke eval_input fixture policy accepted?

Yes.

Use explicit `sample_input`; do not add `if_expr` special cases to
`eval_input_for`.

### Does dual-path evaluator duplication block next work?

No.

It remains known future debt and does not block a proof-owned RuntimeSmoke
consumer proof.

### Does root require remain closed?

Yes.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

### Does dynamic dependency tracking remain deferred?

Yes.

### Does counterfactual audit remain future pressure only?

Yes.

### Does release lane remain paused?

Yes.

### Do public demo/stable/production/all-grammar/runtime claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

---

## Remaining Closed Surfaces

Remain closed:

- implementation in this card;
- `runtime_smoke.rb` edits;
- root require changes;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation outside a
  future proof-owned output directory;
- release harness mutation, release commands, release execution;
- public demo/release/stable/production/all-grammar/runtime claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit, dry-run, comparison reports, effect sandboxing;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Decision Summary

R202-C3-A accepts the RuntimeSmoke consumer boundary design and authorizes only
a later implementation-authorization review.

The accepted path is a proof-owned harness around existing `RuntimeSmoke.run`,
with no `runtime_smoke.rb` edits and unchanged result/callback/input behavior.
The next proof must programmatically create proof-owned `.igapp` artifacts under
its own `out/` directory, cover both `apply` and `field_access`, and prove the
transitive-load distinction explicitly.

---

## Exact Next Dispatch Recommendation

Immediate next card:

```text
Card: S3-R202-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round202-status-curation-v0
Route: UPDATE
Depends on:
- S3-R202-C1-D
- S3-R202-C2-X
- S3-R202-C3-A
```

Recommended next Main Line route after status curation:

```text
Card: S3-R203-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R202-C4-S
```

No RuntimeSmoke implementation or proof harness may begin until that
authorization review explicitly opens it.
