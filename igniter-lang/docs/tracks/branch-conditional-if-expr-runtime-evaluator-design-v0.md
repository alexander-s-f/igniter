# Branch Conditional If Expr Runtime Evaluator Design v0

Card: S3-R196-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-runtime-evaluator-design-v0`  
Route: UPDATE  
Depends on: S3-R195-C4-S  
Status: done  
Date: 2026-05-27

---

## Purpose

Design runtime/evaluator semantics for accepted expression-level `if_expr` v0
without authorizing implementation.

This card does not edit runtime/evaluator code, does not authorize
implementation, does not execute release commands, and does not authorize public
demo, stable, production, all-grammar, Spark, API, or CLI claims.

---

## Inputs Read

- `docs/tracks/stage3-round195-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-v0.md`
- `experiments/branch_conditional_if_expr_release_harness_delta_v0/out/branch_conditional_if_expr_release_harness_delta_summary.json`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md`
- `docs/spec/ch2-source-surface.md`
- `docs/spec/ch3-type-system.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch6-semanticir.md`
- `lib/igniter_lang/semanticir_emitter.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/runtime_smoke.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/assembler.rb`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`

Runtime/evaluator discovery used:

```bash
rg -n "Runtime|Evaluator|runtime|evaluate|semantic_ir|if_expr" igniter-lang/lib
```

---

## Current State

R190 accepted internal compiler support for expression-level `if_expr` v0:

- parser already accepts the source shape;
- TypeChecker owns `OOF-IF1..OOF-IF4`;
- `OOF-IF5` remains out/unowned;
- typed SemanticIR lowers to flat recursive `if_expr` shape:
  - `kind`;
  - `condition`;
  - `then_branch`;
  - `else_branch`;
  - `resolved_type`;
- branch dependency union is accepted at the compiler boundary;
- runtime/evaluator behavior remains closed.

R195 accepted a compiler-only release-harness delta:

- evidence label is `if_expr_internal_compiler_delta`;
- proof passed `39/39`;
- runtime/evaluator support remains a non-claim;
- historical first-RC/alpha/release evidence remains unchanged;
- public demo, stable, production, all-grammar, Spark, API, and CLI claims remain
  closed.

Runtime architecture survey:

- `IgniterLang::RuntimeSmoke` is proof-backed and delegates to
  `experiments/runtime_machine_memory_proof`.
- `CompilerOrchestrator#compile` accepts an optional `runtime_smoke:` callback
  after assembly, but does not own expression evaluation.
- `experiments/runtime_machine_memory_proof/compiled_program.rb` has a small
  evaluator for `apply`, `field_access`, `literal`, `ref`, and `tbackend_read`.
  It currently raises on unknown expression kinds.
- No general production `SemanticIR` expression evaluator for `if_expr` is
  present in `igniter-lang/lib`.
- `.igapp` contract files already carry compute node `expression` payloads via
  the assembler, but this artifact carriage is not runtime support.

---

## Runtime Semantics Recommendation

v0 runtime semantics should be lazy.

Evaluation order:

1. Evaluate `condition`.
2. Require the evaluated condition to be the canonical runtime Bool value
   (`true` or `false` in the Ruby/proof runtime representation).
3. If the condition is `true`, evaluate only `then_branch`.
4. If the condition is `false`, evaluate only `else_branch`.
5. Return the selected branch value as the `if_expr` value.

Non-selected branch evaluation is forbidden in v0. Any side effect, runtime
failure, missing reference, unsupported expression, temporal read, or other
observable behavior in the non-selected branch must not fire.

This matches the source-language intuition for conditionals and keeps accepted
compiler rules meaningful: both branches are statically typechecked and included
in static dependency metadata, but runtime execution observes only the selected
path.

---

## Semantics Matrix

| Case | Runtime behavior | Notes |
| --- | --- | --- |
| Condition evaluates to `true` | Evaluate `then_branch`; return its value | `else_branch` must not be touched. |
| Condition evaluates to `false` | Evaluate `else_branch`; return its value | `then_branch` must not be touched. |
| Condition evaluation fails | Fail before branch selection | No branch may be evaluated. |
| Selected branch fails | Propagate selected-branch failure | This is the active execution path. |
| Non-selected branch would fail | No failure | Proof must show the non-selected branch is not evaluated. |
| Condition value is not Bool | Fail closed | TypeChecker should prevent this for compiled input; runtime guards malformed/direct input. |
| Missing condition / then / else | Fail closed | Malformed SemanticIR, not a compile-time OOF at runtime. |
| Unknown expression kind | Fail closed | Existing proof runtime already raises on unknown expression kinds. |
| Nested `if_expr` | Recurse with same rules | Lazy at each nested conditional. |
| Branch type mismatch | Unreachable for typed compiled input | TypeChecker owns `OOF-IF3`; malformed runtime input should fail closed if detected. |

---

## Bool Requirement

The compiler boundary already requires canonical Bool conditions:

```text
{"name":"Bool","params":[]}
```

Runtime should assume compiled `SemanticIR` is already typed, but future
evaluator code should still guard direct or malformed input:

- accept only runtime boolean values for branch selection;
- fail closed for non-Bool values;
- do not reinterpret truthy/falsy Ruby values such as strings, numbers, arrays,
  hashes, or `nil`.

This avoids silently widening language semantics beyond the TypeChecker rule.

---

## Failure Propagation

Failure propagation should be path-sensitive at evaluation time:

| Failure source | v0 policy |
| --- | --- |
| Condition failure | Propagate immediately; no branch evaluation. |
| Selected branch failure | Propagate as the `if_expr` failure. |
| Non-selected branch failure | Must not occur; proof should place a would-fail expression in the non-selected branch and confirm no failure. |
| Malformed `if_expr` node | Fail closed before partial evaluation when required fields are absent. |
| Unsupported nested expression in selected path | Propagate as selected-path runtime failure. |
| Unsupported nested expression in non-selected path | Must not fire. |

---

## Diagnostics and Error Vocabulary

No new `OOF-RT-*` vocabulary should be introduced in this design card.

Rationale:

- `OOF-*` currently belongs to compiler/language boundary diagnostics.
- Runtime malformed input and evaluator failures are runtime errors/refusals, not
  fragment classification or TypeChecker OOF.
- The existing proof runtime uses direct failure strings such as
  `Unknown expression kind: ...`.

Design-only candidate runtime codes, if a later implementation card needs a
structured result shape:

| Candidate code | Meaning | Layer |
| --- | --- | --- |
| `runtime.if_expr_malformed` | Missing required `condition`, `then_branch`, `else_branch`, or invalid shape | Runtime/evaluator |
| `runtime.if_expr_condition_failed` | Condition expression raised or refused | Runtime/evaluator |
| `runtime.if_expr_condition_not_bool` | Condition produced a non-Bool value | Runtime/evaluator |
| `runtime.if_expr_branch_failed` | Selected branch raised or refused | Runtime/evaluator |
| `runtime.expression_unsupported` | Selected path contains unsupported expression kind | Runtime/evaluator |

These are not accepted diagnostics yet. A future implementation review should
prefer existing runtime error surfaces if they are sufficient.

---

## Dependency and Cache Policy

Static compiler dependency union remains accepted.

Runtime execution may dynamically touch only the selected branch, but this does
not revise compiler dependency metadata in v0.

Policy:

- TypeChecker/SemanticIR dependency metadata remains conservative and includes
  condition plus both branches.
- `.igapp` compute node dependencies may remain static union dependencies.
- Cache invalidation remains conservative under the static dependency union.
- Dynamic selected-branch dependency tracking is deferred.
- Path-sensitive cache keys, invalidation, freshness, or dependency receipts are
  out of scope until a separate cache/runtime design authorizes them.

This keeps runtime laziness from becoming a hidden cache semantics migration.

---

## Placement Options

| Option | Candidate write scope later | Value | Risk | Recommendation |
| --- | --- | --- | --- | --- |
| A. Proof-local evaluator experiment | `experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/**` plus track | Proves lazy semantics without live runtime changes | Does not deliver live support | Preferred first implementation-authorization review. |
| B. Internal direct-require evaluator helper | New internal file such as `lib/igniter_lang/semanticir_expression_evaluator.rb`, proof harness | Reusable internal boundary | Opens live lib surface, naming, require, and result-shape questions | Later, after proof-local semantics. |
| C. Extend `runtime_machine_memory_proof` evaluator | `experiments/runtime_machine_memory_proof/compiled_program.rb` plus focused proof | Closest to current `RuntimeSmoke` path | May blur proof runtime with broader runtime support | Viable only with explicit proof-runtime authorization. |
| D. Wire through `RuntimeSmoke` / `CompilerOrchestrator` | `lib/igniter_lang/runtime_smoke.rb` or orchestrator smoke path | End-to-end smoke possible | Risks implying public/runtime support and report behavior changes | Not first. |
| E. Modify assembler / `.igapp` artifact shape | `assembler.rb`, artifact goldens | None needed for current flat expression shape | Unnecessary artifact migration | Do not pursue for v0 runtime semantics. |

Recommended first route: Option A, a proof-local evaluator experiment, followed
by a separate acceptance review. Live library/runtime implementation should wait
until the proof shows lazy branch behavior, malformed-node failure, and
closed-surface isolation.

---

## Future Proof Matrix

A future implementation-authorization review should require at least:

| ID | Proof case | Expected result |
| --- | --- | --- |
| RT-IF1 | Condition `true` | Only `then_branch` evaluated; value returned. |
| RT-IF2 | Condition `false` | Only `else_branch` evaluated; value returned. |
| RT-IF3 | Non-selected `then_branch` would fail | No failure when condition is `false`. |
| RT-IF4 | Non-selected `else_branch` would fail | No failure when condition is `true`. |
| RT-IF5 | Condition expression fails | Branches are not evaluated; condition failure propagates. |
| RT-IF6 | Selected branch fails | Selected-branch failure propagates. |
| RT-IF7 | Condition returns non-Bool | Runtime fails closed; no truthy/falsy coercion. |
| RT-IF8 | Missing condition / then / else | Runtime fails closed as malformed SemanticIR. |
| RT-IF9 | Unknown selected-path expression kind | Runtime fails closed. |
| RT-IF10 | Unknown non-selected-path expression kind | No failure. |
| RT-IF11 | Nested `if_expr` | Lazy semantics apply recursively. |
| RT-IF12 | Static dependency union vs dynamic touch trace | Static deps remain union; runtime trace touches selected path only. |
| RT-IF13 | Closed-surface scan | No public API/CLI, release, Spark, runtime production, `.igapp` artifact migration, or spec/canon mutation. |

Suggested command matrix for a proof-local route:

```bash
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

Optional read-only regression checks:

```bash
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

No release commands should be part of the runtime/evaluator proof route.

---

## Explicit Answers

### Should v0 runtime semantics be lazy or eager?

Lazy.

Eager evaluation would incorrectly fire non-selected branch failures and side
effects, and would make branch conditionals operationally weaker than their
source-level meaning.

### Is non-selected branch evaluation forbidden?

Yes.

Non-selected branch evaluation is forbidden for v0 runtime semantics.

### Does static dependency union remain accepted?

Yes.

The compiler/runtime boundary keeps static dependency union as conservative
metadata. Runtime laziness does not require changing TypeChecker, SemanticIR, or
`.igapp` dependencies.

### Is dynamic selected-branch dependency tracking required now?

No.

It is deferred. A runtime proof may record selected-path touch traces, but cache
invalidation remains conservative and static unless a later cache/runtime design
opens path-sensitive dependency tracking.

### Do runtime diagnostics need `OOF-RT-*`?

No for v0.

Use runtime error/refusal surfaces first. If structured runtime diagnostics are
needed later, use runtime-owned codes such as `runtime.if_expr_malformed`, not
compiler OOF names, unless a separate diagnostic governance decision says
otherwise.

### Should malformed SemanticIR fail closed or remain unreachable?

Both:

- unreachable under accepted compiled input assumptions;
- fail closed when a runtime/evaluator is given malformed or direct SemanticIR.

The evaluator must not silently default missing branches or coerce invalid
conditions.

### May implementation authorization review open next?

Yes, but only for a bounded proof-local runtime/evaluator experiment.

Live library/runtime integration, `RuntimeSmoke`, `CompilerOrchestrator`,
assembler, `.igapp`, public API/CLI, release evidence, and production runtime
remain closed unless a later review explicitly opens them.

### Does release lane remain paused?

Yes.

Runtime/evaluator design does not reopen release execution or mutate accepted
release evidence.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

No public claims open from this design.

### Do Spark/API/CLI remain closed?

Yes.

No Spark data, Spark fixtures, public API methods, CLI flags, or public docs
claims are authorized.

---

## C3-A Decision Options

| Option | Meaning | Recommended stance |
| --- | --- | --- |
| Accept design and authorize later implementation-authorization review | Open a future review for a proof-local runtime/evaluator experiment only | Preferred. |
| Accept design but keep implementation held | Record lazy semantics, but wait before any proof implementation | Acceptable if runtime architecture pressure wants more survey. |
| Conditional accept with blockers | Require a stronger runtime result-shape or diagnostics decision first | Not required for proof-local route. |
| Hold pending more architecture survey | Delay because live runtime placement is unclear | Not necessary; proof-local route avoids live placement risk. |
| Redirect | Move to cache/path-sensitive dependency design before evaluator proof | Not recommended; cache path sensitivity is not required for v0. |

Preferred C3-A:

```text
accept design and authorize a later implementation-authorization review for a
proof-local if_expr runtime/evaluator semantics experiment; keep live runtime,
release, public, Spark, API/CLI, artifact, and production surfaces closed.
```

---

## Closed Surfaces

- runtime/evaluator code implementation;
- live `RuntimeSmoke` or `CompilerOrchestrator` behavior changes;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- release harness mutation or release command execution;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Recommendation

Accept the design and route the next card as an implementation-authorization
review for a proof-local evaluator experiment only.

The implementation review should explicitly keep live runtime/library wiring
closed until proof-local lazy branch semantics, malformed-node failure behavior,
and closed-surface isolation have passed.
