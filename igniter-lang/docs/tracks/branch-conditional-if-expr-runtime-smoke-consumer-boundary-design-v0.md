# Branch Conditional If Expr Runtime Smoke Consumer Boundary Design v0

Card: S3-R202-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0`  
Route: UPDATE  
Depends on: S3-R201-C5-S  
Status: done  
Date: 2026-05-28

---

## Purpose

Design whether and how `RuntimeSmoke` may consume the accepted proof
RuntimeMachine `if_expr` path, explicitly handling the transitive evaluator
load, dual-path evaluator question, public non-claims, and closed
compiler/result/report surfaces.

This card does not edit files, does not authorize implementation, does not
authorize release execution, and does not authorize public demo, stable,
production, all-grammar, runtime, Spark, API, or CLI claims.

---

## Inputs Read

- `docs/tracks/stage3-round201-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md`
- `docs/discussions/branch-conditional-if-expr-proof-runtime-consumer-implementation-pressure-v0.md`
- `docs/tracks/stage3-round200-status-curation-v0.md`
- `lib/igniter_lang/runtime_smoke.rb`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`
- `lib/igniter_lang/semanticir_expression_evaluator.rb`
- `experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/out/branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json`
- `docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## Current Accepted State

R201 accepts Slice 2 proof RuntimeMachine consumer implementation:

```text
PRT-IF1..PRT-IF15: PASS
checks_total: 56
checks_pass: 56
checks_fail: 0
```

Accepted technical state:

- `SemanticIRExpressionEvaluator` has the backward-compatible per-call
  `external_evaluator:` hook;
- proof RuntimeMachine can evaluate `if_expr` through the evaluator adapter;
- `literal`, `ref`, and `if_expr` remain evaluator-owned;
- `apply`, `field_access`, and `tbackend_read` remain proof RuntimeMachine-local;
- `tbackend_read` remains temporal/proof RuntimeMachine-owned;
- `RuntimeSmoke` source remains unchanged;
- root require remains unchanged;
- `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, and
  `Diagnostics` remain closed.

R201 also records an important known consequence:

```text
runtime_smoke.rb already loads compiled_program.rb;
compiled_program.rb now loads semanticir_expression_evaluator.rb;
therefore RuntimeSmoke may transitively load the evaluator.
```

That transitive load is not RuntimeSmoke support.

---

## RuntimeSmoke Current Shape

`IgniterLang::RuntimeSmoke` currently:

- requires `experiments/runtime_machine_memory_proof/compiled_program`;
- loads a `.igapp` via `RuntimeMachineMemoryProof::CompiledProgram.load_igapp`;
- validates the program;
- boots `RuntimeMachineMemoryProof::RuntimeMachine`;
- calls `machine.evaluate_program`;
- checkpoints/resumes;
- returns a fixed smoke result hash:

```text
load_status
contract_id
evaluate_status
outputs
compatibility_report_status
trusted
```

Failure path returns:

```text
load_status: "blocked"
error
trusted: false
```

`RuntimeSmoke.callback` returns a lambda that delegates to `run`.

`RuntimeSmoke.eval_input_for` special-cases only contract id `Add`; otherwise it
returns the supplied `sample_input`.

---

## Boundary Decision

RuntimeSmoke may later be proof-tested against the accepted proof RuntimeMachine
`if_expr` path without changing `runtime_smoke.rb`.

Recommended Slice 3 shape:

```text
proof-owned RuntimeSmoke consumer harness
no RuntimeSmoke source edits
no CompilerOrchestrator callback integration
no CompilerResult / CompilationReport mutation
```

The first RuntimeSmoke route should prove:

- existing `RuntimeSmoke.run` can evaluate a proof-owned `.igapp` containing
  `if_expr`;
- existing result shape remains unchanged;
- existing `RuntimeSmoke.callback` behavior remains unchanged;
- existing `RuntimeSmoke.eval_input_for` behavior remains unchanged;
- no public API/CLI or release claim opens.

Do not start by changing `RuntimeSmoke` code.

---

## Distinctions

| Concept | Meaning | Status |
| --- | --- | --- |
| Transitive evaluator load | `RuntimeSmoke` loads `compiled_program.rb`, which loads the evaluator | Accepted consequence, not support. |
| RuntimeSmoke proof consumption | A proof harness explicitly calls `RuntimeSmoke.run` on an `if_expr` `.igapp` | May open later by authorization review. |
| RuntimeSmoke support | Accepted evidence that existing smoke path handles `if_expr` in bounded proof context | Not yet accepted. |
| Public runtime support | User/public promise that `if_expr` runtime evaluation is supported generally | Closed. |
| Production/runtime claim | Production-ready runtime/evaluator guarantee | Closed. |

Transitive load alone must not be counted as support. Support requires a
dedicated proof and acceptance decision.

---

## Proof Route Shape

Recommended future write scope:

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md
```

Read-only / unchanged surfaces:

```text
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
```

Recommended harness pattern:

1. Direct-require `lib/igniter_lang/runtime_smoke.rb`.
2. Create proof-owned source/artifact inside the experiment directory.
3. Produce or provide `.igapp` under the proof-owned `out/` directory.
4. Call `IgniterLang::RuntimeSmoke.run(...)` directly.
5. Record result shape, trusted status, outputs, and non-claims.

Avoid using `CompilerOrchestrator#compile(..., runtime_smoke:)` in the first
RuntimeSmoke consumer proof. That would entangle smoke proof with compiler
result/report behavior before this boundary accepts any result/report changes.

---

## RuntimeSmoke Method Stance

| Method | Slice 3 stance |
| --- | --- |
| `RuntimeSmoke.run` | May be exercised later; result shape must remain unchanged. |
| `RuntimeSmoke.callback` | Must remain unchanged; first proof should not require orchestrator callback integration. |
| `RuntimeSmoke.eval_input_for` | Must remain unchanged; proof fixture should pass explicit `sample_input`. |
| `RuntimeSmoke.available?` / `ensure_available!` | Must remain unchanged. |

Fixture policy for `eval_input_for`:

- do not add special if_expr contract ids;
- do not change the `Add` special case;
- proof-owned fixtures must pass explicit `sample_input` suitable for their
  contract;
- if a fixture needs defaults, keep them inside the proof harness, not
  `RuntimeSmoke`.

---

## Dual-Path Evaluator Stance

R201 accepts the dual-path evaluator:

```text
external_evaluator absent  -> Slice 1 path
external_evaluator present -> Slice 2 path
```

For RuntimeSmoke Slice 3:

- preserve the dual-path evaluator;
- do not unify paths before RuntimeSmoke work;
- record duplication as future evaluator debt;
- do not disturb Slice 1 structural proof invariants;
- do not turn unification into a prerequisite.

Dual-path duplication does not block RuntimeSmoke proof work.

---

## Expression Ownership Stance

RuntimeSmoke should inherit the accepted proof RuntimeMachine ownership:

| Kind | Owner |
| --- | --- |
| `literal` | `SemanticIRExpressionEvaluator` |
| `ref` | `SemanticIRExpressionEvaluator` |
| `if_expr` | `SemanticIRExpressionEvaluator` |
| `apply` | proof RuntimeMachine local |
| `field_access` | proof RuntimeMachine local |
| `tbackend_read` | proof RuntimeMachine / temporal-owned |

`apply`, `field_access`, and `tbackend_read` must not move into
`RuntimeSmoke`, `CompilerOrchestrator`, or public runtime surfaces.

`tbackend_read` remains temporal/proof RuntimeMachine-owned.

---

## Dependency and Cache Stance

Static dependency union remains accepted and conservative.

Dynamic selected-branch dependency tracking remains deferred.

RuntimeSmoke proof must not introduce:

- path-sensitive dependency receipts;
- dynamic dependency authority;
- path-sensitive cache keys;
- cache invalidation changes;
- freshness state changes;
- runtime report fields implying selected-path dependency authority.

Any evaluation trace remains proof/debug evidence only.

---

## Counterfactual Audit Stance

Counterfactual audit remains future pressure only.

RuntimeSmoke proof must preserve:

- normal runtime is lazy;
- non-selected branch is not executed;
- no counterfactual dry-run;
- no branch comparison report;
- no effect sandboxing;
- no eager latent-branch evaluation;
- no public counterfactual API/CLI.

The phrase from the future-pressure note remains a guide, not an implemented
feature:

```text
Runtime is lazy.
Audit is aware.
```

---

## Future Proof Matrix

Required RuntimeSmoke consumer proof cases:

| ID | Proof case | Expected result |
| --- | --- | --- |
| RS-IF1 | Direct-require `RuntimeSmoke` | Loads without root require change. |
| RS-IF2 | Transitive evaluator load classified | Recorded as load consequence, not support by itself. |
| RS-IF3 | `RuntimeSmoke.run` on `if_expr` condition true artifact | `trusted: true`; output from `then_branch`. |
| RS-IF4 | `RuntimeSmoke.run` on `if_expr` condition false artifact | `trusted: true`; output from `else_branch`. |
| RS-IF5 | Selected branch uses proof RuntimeMachine local `apply` | Output proves adapter path works through smoke. |
| RS-IF6 | Non-selected branch would fail / unsupported kind | Does not fire through smoke path. |
| RS-IF7 | Existing `RuntimeSmoke.run` result shape | Exact key set unchanged. |
| RS-IF8 | Existing `RuntimeSmoke.callback` behavior | Source shape unchanged; optional lambda smoke shape unchanged if exercised without orchestrator mutation. |
| RS-IF9 | Existing `RuntimeSmoke.eval_input_for` behavior | No if_expr special-case added; explicit sample_input used. |
| RS-IF10 | Dual-path evaluator preserved | No evaluator unification or structural-proof rewrite. |
| RS-IF11 | Compiler/result/report closure | `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, `Diagnostics` unchanged. |
| RS-IF12 | Root require closure | `lib/igniter_lang.rb` unchanged. |
| RS-IF13 | Dependency/cache closure | Dynamic tracking remains deferred; no cache semantics change. |
| RS-IF14 | Counterfactual audit closure | No dry-run/comparison/eager latent branch. |
| RS-IF15 | Release/public/Spark/API/CLI closure | No public/runtime/release claim opens. |

Suggested command matrix for later proof card:

```bash
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
```

Optional regression command:

```bash
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
```

No release command belongs in the RuntimeSmoke proof route.

---

## Explicit Answers

### Is RuntimeSmoke consumer boundary design ready to accept?

Yes.

The accepted proof RuntimeMachine path is enough to design a proof-only
RuntimeSmoke consumer route with no `runtime_smoke.rb` changes.

### May a later implementation-authorization review open?

Yes.

Recommended next review: authorize a proof-owned RuntimeSmoke consumer harness
only, with no `RuntimeSmoke` source edit.

### Is RuntimeSmoke implementation authorized now?

No.

This design card authorizes nothing.

### Does transitive evaluator load count as RuntimeSmoke support?

No.

It is an accepted consequence of `RuntimeSmoke` loading `compiled_program.rb`.
Support requires a dedicated proof and acceptance decision.

### May RuntimeSmoke later exercise `if_expr` through proof RuntimeMachine without public API/CLI changes?

Yes.

Use the existing `RuntimeSmoke.run` shape in a proof-owned harness. Do not add
public API methods or CLI flags.

### May `RuntimeSmoke.run` result shape change?

No.

It must remain unchanged for the first RuntimeSmoke consumer proof.

### May `RuntimeSmoke.callback` change?

No.

It must remain unchanged. The first proof should not require orchestrator
callback integration.

### May `RuntimeSmoke.eval_input_for` change?

No.

Use explicit proof-owned `sample_input`; do not add if_expr fixture defaults.

### Does dual-path evaluator duplication block RuntimeSmoke work?

No.

Preserve the dual path for Slice 3 and keep unification as future debt.

### Do `apply`, `field_access`, and `tbackend_read` remain proof RuntimeMachine-local?

Yes.

They remain inherited proof RuntimeMachine ownership.

### Does `tbackend_read` remain temporal/proof RuntimeMachine-owned?

Yes.

No temporal authority expands.

### Does root require remain closed?

Yes.

`lib/igniter_lang.rb` remains closed.

### Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed?

Yes.

The first RuntimeSmoke proof should not use compiler result/report integration.

### Does dynamic dependency tracking remain deferred?

Yes.

No path-sensitive dependency/cache behavior opens.

### Does counterfactual audit remain future pressure only?

Yes.

No counterfactual audit implementation opens.

### Does release lane remain paused?

Yes.

No release execution opens.

### Do public demo/stable/production/all-grammar/runtime claims remain closed?

Yes.

Even accepted RuntimeSmoke proof would be proof-context evidence, not public
runtime support.

### Do Spark/API/CLI remain closed?

Yes.

No Spark, public API, or CLI surface opens.

---

## C3-A Decision Options

| Option | Meaning | Recommended stance |
| --- | --- | --- |
| Accept design and authorize later implementation-authorization review | Open a proof-owned RuntimeSmoke consumer harness review with no `runtime_smoke.rb` edits | Preferred. |
| Accept design but keep implementation held | Record boundary and wait | Acceptable if Architect wants another pressure pass on transitive load wording. |
| Conditional accept with exact blockers | Require exact fixture/artifact policy before review | Viable if proof-owned `.igapp` creation policy is considered underspecified. |
| Hold pending more runtime architecture survey | Delay due to smoke/proof RuntimeMachine coupling | Not necessary; design keeps code and claims closed. |
| Redirect to counterfactual audit design-only route | Move to branch audit pressure first | Not recommended; audit is future pressure only. |
| Redirect to another compiler/language route | Pause RuntimeSmoke path and move elsewhere | Acceptable only if mainline wants to stop runtime proof progression. |
| Pause | No next action | Not recommended. |

Preferred C3-A:

```text
accept design and authorize a later implementation-authorization review for a
proof-owned RuntimeSmoke consumer harness only. The review should require no
runtime_smoke.rb edit, unchanged RuntimeSmoke.run/callback/eval_input_for shape,
closed CompilerOrchestrator/CompilerResult/CompilationReport, closed
release/public/Spark/API/CLI claims, and explicit wording that transitive
evaluator load is not support by itself.
```

---

## Closed Surfaces

- implementation in this card;
- `runtime_smoke.rb` edits;
- root require changes;
- `CompilerOrchestrator` changes;
- `CompilerResult` changes;
- `CompilationReport` changes;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler changes;
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

## Compact Recommendation

Accept the design and open a later implementation-authorization review for a
proof-owned RuntimeSmoke consumer harness, not for `RuntimeSmoke` source
changes.

RuntimeSmoke may later exercise `if_expr` through the already accepted proof
RuntimeMachine adapter path using existing `RuntimeSmoke.run`. The proof must
make the distinction explicit:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```
