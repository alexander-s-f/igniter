# Branch Conditional If Expr Proof Runtime Consumer Implementation Pressure v0

Card: S3-R201-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-proof-runtime-consumer-implementation-pressure-v0

Context: public-github-only
Write access: none
Canon authority: none

Depends on:
- S3-R201-C2-I

---

## Question

Does the S3-R201-C2-I Slice 2 proof RuntimeMachine consumer implementation stay
inside the authorized write scope, add the `external_evaluator:` hook in the
correct per-call keyword form, preserve Slice 1 backward compatibility, route
`apply`/`field_access`/`tbackend_read` ownership correctly, prove lazy
non-selected-branch isolation and exception propagation, pass PRT-IF1..PRT-IF15,
and leave RuntimeSmoke, root require, CompilerOrchestrator, CompilerResult,
CompilationReport, dynamic dependency tracking, counterfactual audit,
release/public/Spark/API/CLI all closed?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-authorization-review-v0.md`
  (S3-R201-C1-A — authorized bounded Slice 2 implementation)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-v0.md`
  (S3-R201-C2-I implementation track doc — 56/56 PASS)
- `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb`
  (proof harness — PRT-IF1..PRT-IF15, 56 checks)
- `igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/out/branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json`
  (proof summary — status PASS, 56/56)
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
  (live evaluator with Slice 2 hook — two-path design)
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
  (proof RuntimeMachine with if_expr adapter and local tbackend_read case arm)
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
  (RuntimeSmoke — unchanged; delegates to compiled_program.rb)
- `igniter-lang/docs/tracks/stage3-round200-status-curation-v0.md`
  (R200 status — accepted design, routed S3-R201 authorization review next)

---

## Scope Check Matrix

| SC | Scope check | Result | Evidence |
|----|-------------|--------|----------|
| SC-1 | Implementation stayed within C1-A authorized write scope | PASS | 5 changed files: evaluator, compiled_program, proof harness, summary JSON, track doc. All within C1-A allowed scope. Track doc states "No other files changed." |
| SC-2 | Hook uses per-call keyword form, not constructor injection | PASS | `evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)` — kwarg only. `SemanticIRExpressionEvaluator.new` takes no arguments. C1-A required kwarg form; constructor injection rejected. |
| SC-3 | Evaluator API is backward-compatible when `external_evaluator:` is omitted | PASS | `external_evaluator: nil` default → dispatches to Slice 1 `eval_expr` path unchanged. PRT-IF12 sub-check `slice1_evaluator_behavior_preserved_without_external_evaluator` machine-asserts literal/ref/if_expr/apply-raises all unchanged. Slice 1 regression 68/68 PASS, SHA sha256:8e72338e... unchanged. |
| SC-4 | External evaluator exceptions propagate unchanged | PASS | `eval_expr_ext` else branch: `external_evaluator.call(expr, values)` — no rescue wrapping. PRT-IF8 sub-check `condition_failure_via_external_evaluator_propagates` verifies RuntimeError propagates with exact message. |
| SC-5 | No external evaluator call for non-selected branch | PASS | Structural: `eval_if_expr_ext` uses mutually exclusive arms (line A-ext / line B-ext) — only selected branch hash is ever passed to `eval_expr_ext`. PRT-IF6 uses call_count=0 assertion for both condition=true and condition=false with apply in non-selected branch. PRT-IF7 verifies tbackend_read in non-selected branch with nil backend does not raise. |
| SC-6 | No external evaluator call before condition evaluation | PASS | `eval_if_expr_ext` evaluates condition first via `eval_expr_ext(...condition...)`, then Bool guard, then branch selection. PRT-IF8 `malformed_condition_fails_before_branches` asserts call_count==0 when condition raises. |
| SC-7 | `apply` and `field_access` remain proof RuntimeMachine-local | PASS | Source: `compiled_program.rb` has explicit `when "apply"` and `when "field_access"` case arms in local `eval_expr`. Neither kind added to evaluator `SUPPORTED_KINDS`. External_evaluator callback routes unsupported selected-path kinds back to compiled_program's `eval_expr`, which handles them locally. |
| SC-8 | `tbackend_read` remains temporal/proof RuntimeMachine-owned | PASS | `SUPPORTED_KINDS = %w[literal ref if_expr].freeze` — no `tbackend_read`. Local `when "tbackend_read"` case arm in `compiled_program.rb` is not routed through `if_expr_evaluator`. PRT-IF5: 4 sub-checks machine-assert structural ownership (kind absent from SUPPORTED_KINDS, UnsupportedExpressionKindError without ext_ev, ArgumentError from ext_ev not evaluator core, tbackend_read case arm present in source not routed through evaluator). |
| SC-9 | PRT-IF1..PRT-IF15 all pass | PASS | 56/56 checks PASS. 15/15 PRT-IF items PASS. summary SHA sha256:73f259c3... |
| SC-10 | Command matrix passes | PASS | All 6 required commands (3 syntax checks + 3 proof runner runs) plus optional harness delta all reported PASS or Syntax OK. |
| SC-11 | Existing LRT proof still passes | PASS | 68/68 PASS, SHA sha256:8e72338e... unchanged. PRT-IF15 sub-check `prior_evaluator_proof_sha_unchanged` machine-asserts. |
| SC-12 | Existing proof-local runtime/evaluator proof still passes | PASS | 54/54 PASS, SHA sha256:62be7c1c... unchanged. Reported in command matrix. |
| SC-13 | RuntimeSmoke file unchanged and no RuntimeSmoke support claim | PASS | PRT-IF14 (4 sub-checks): `runtime_smoke_not_loaded_by_proof` (not in $LOADED_FEATURES), `runtime_smoke_not_modified` (no SemanticIRExpressionEvaluator / semanticir_expression_evaluator / external_evaluator in source), `runtime_smoke_contains_no_if_expr_dispatch`, `no_smoke_result_report_change`. Track doc non-claims include `no_runtime_smoke_integration: true`. |
| SC-14 | Root require unchanged | PASS | PRT-IF13 (4 sub-checks): root require not edited, evaluator not auto-loaded by root, compiled_program uses require_relative, proof script uses require_relative. |
| SC-15 | CompilerOrchestrator, CompilerResult, CompilationReport unchanged | PASS | PRT-IF15 `compiler_orchestrator_not_modified` scans source for SemanticIRExpressionEvaluator and external_evaluator — absent. PRT-IF14 `no_smoke_result_report_change` scans compiler_result.rb and compilation_report.rb. Closed-surface scan table confirms all three files clear. Non-claims: `no_compiler_orchestrator_change`, `no_compiler_result_change`, `no_compilation_report_change` all true. |
| SC-16 | Dynamic dependency/cache authority remains closed | PASS | No path-sensitive dependency receipts, dynamic dependency authority, cache keys, invalidation changes, or runtime report fields. `call_trace` remains debug evidence only. Non-claim `no_dynamic_dependency_tracking: true`. |
| SC-17 | Counterfactual audit remains future pressure only | PASS | No counterfactual evaluator, dry-run, comparison report, effect sandboxing, eager latent-branch evaluation. Evaluator is lazy; only selected branch is ever evaluated. Non-claim `no_counterfactual_audit: true`. |
| SC-18 | Release/public/Spark/API/CLI closed | PASS | PRT-IF15 (7 sub-checks): diagnostics_not_loaded, evaluator_has_no_public_api_widening, spark_not_referenced_in_code, release_commands_absent_in_proof_script, compiler_orchestrator_not_modified, release_harness_delta_sha_unchanged, prior_evaluator_proof_sha_unchanged. Non-claims block (13 keys) all true. |

**Verdict: proceed — 18/18 PASS, no blockers, 3 non-blocking notes.**

---

## Key Technical Verifications

### Two-Path Design Rationale

The implementation introduces a two-path design to preserve Slice 1 structural
proof invariants:

```
evaluate(expr, values, call_trace:, external_evaluator:)
  │
  ├── external_evaluator nil → eval_expr(expr, values, call_trace)
  │     [Slice 1 path: original methods, unmodified]
  │
  └── external_evaluator present → eval_expr_ext(expr, values, call_trace, ext_ev)
        [Slice 2 path: parallel methods with delegation for unsupported kinds]
```

Slice 1 private methods (`eval_expr`, `eval_if_expr`) retain their original
3-argument signatures unchanged. This is correct: `LRT-IF12` scans for exact
source patterns in `eval_if_expr`, and any signature change would break those
structural assertions. The two-path design is intentional and architecturally
documented.

### Proof RuntimeMachine Adapter Correctness

`compiled_program.rb` `eval_expr` routes `if_expr` through the evaluator adapter
and all other kinds through local case arms:

```ruby
when "if_expr"
  ext_ev = ->(sub_expr, sub_vals) { eval_expr(sub_expr, sub_vals, backend: backend, as_of: as_of) }
  if_expr_evaluator.evaluate(expr, values, external_evaluator: ext_ev)
when "apply"    ... local ...
when "field_access" ... local ...
when "literal"  ... local ...
when "ref"      ... local ...
when "tbackend_read" ... local ...
```

The `external_evaluator` closure captures `backend` and `as_of`, preserving
access to proof RuntimeMachine state for any delegated selected-path kind.
Exceptions from the closure propagate through `evaluate` unchanged.

### PRT-IF5 Structural Proof Completeness

PRT-IF5 covers `tbackend_read` temporal authority via structural proof:

1. `SUPPORTED_KINDS` does not include `tbackend_read` (constant scan) ✓
2. Without `external_evaluator:`, selected-path `tbackend_read` raises
   `UnsupportedExpressionKindError` from evaluator core ✓
3. With `external_evaluator:`, error is `ArgumentError` from the
   external_evaluator callable, proving `tbackend_read` reached the external
   evaluator and not evaluator core ✓
4. Source scan confirms `tbackend_read` case arm in `compiled_program.rb` is
   NOT routed through `if_expr_evaluator` ✓

The C1-A decision (NB-2 closure from R200): full temporal fixture is optional;
structural ownership proof is mandatory. PRT-IF5 satisfies the mandatory
requirement without requiring additional temporal infrastructure.

### PRT-IF7: Non-Selected `tbackend_read` with nil Backend

PRT-IF7 verifies that `tbackend_read` in a non-selected branch (condition=false
with `tbackend_read` in `then_branch`, and condition=true with `tbackend_read`
in `else_branch`) never fires. The `compiled_program.rb` adapter wires `if_expr`
through the evaluator, which guarantees the non-selected branch hash is never
passed to `eval_expr_ext`. The `ext_ev` closure is never called for the
non-selected branch, so the `tbackend_read` local case arm is never reached.

---

## Non-Blocking Notes

**NB-1 (minor/cosmetic): `no_constructor_injection` absent from JSON non_claims dictionary.**

The proof summary JSON `non_claims` block has 13 keys; the track doc non-claims
table has 14 entries (the 14th being `no_constructor_injection: true`). This is
covered by `semantics.constructor_injection: false` in the JSON summary and
by the actual absence of constructor injection in the source. The substance is
correct; this is a proof-hygiene inconsistency only. C4-A may acknowledge as-is
or request a follow-up hygiene pass; it is not a blocker.

**NB-2 (structural observation): Two-path duplication is managed but future-facing.**

The two-path design introduces code duplication: `eval_expr` / `eval_if_expr`
(Slice 1) and `eval_expr_ext` / `eval_if_expr_ext` (Slice 2) are parallel
implementations sharing only `eval_literal` and `eval_ref` helpers. This is
intentional and correctly preserves Slice 1 structural proof invariants. Future
Slice 3+ work (RuntimeSmoke consumer authorization, if opened) should decide
whether to unify the paths or continue the dual-path design. C4-A should record
this as a known architectural debt observation for the next evaluator evolution.

**NB-3 (transitive load, informational): RuntimeSmoke transitively loads the evaluator.**

`runtime_smoke.rb` already `require_relative`s `compiled_program.rb`. Because
`compiled_program.rb` now `require_relative`s `semanticir_expression_evaluator.rb`,
loading RuntimeSmoke transitively loads the evaluator. C1-A explicitly addresses
this: "If the proof RuntimeMachine change incidentally affects a path RuntimeSmoke
can load, that is not accepted as RuntimeSmoke support." PRT-IF14 proves that
`runtime_smoke.rb` itself contains no `SemanticIRExpressionEvaluator` reference,
no `if_expr` dispatch, and no `external_evaluator` reference. The transitive load
is an expected consequence of the authorized design, not a new surface opening.
C4-A acceptance record should note this for the Slice 3 RuntimeSmoke
authorization surface when that route eventually opens.

---

## [Agree]

- The two-path design correctly preserves Slice 1 proof invariants while adding
  Slice 2 delegation. Slice 1 methods are structurally unchanged.
- The `external_evaluator:` per-call keyword form is correct and matches the
  C1-A selected form.
- Expression-kind ownership table is implemented exactly as authorized: evaluator
  owns `literal`, `ref`, `if_expr`; proof RuntimeMachine keeps `apply`,
  `field_access`, `tbackend_read`.
- Lazy semantics through the adapter boundary are preserved: `eval_if_expr_ext`
  uses mutually exclusive arms and passes only the selected branch to
  `eval_expr_ext`. PRT-IF6/PRT-IF7 machine-assert this with call_count probes.
- Exception propagation is clean: no rescue wraps the `external_evaluator.call`
  in `eval_expr_ext`.
- PRT-IF5 structural proof is sufficient and correct for the C1-A NB-2 closure.
- Regression proofs (Slice 1 68/68, RT proof 54/54, release harness delta 39/39)
  are all SHA-stable.
- RuntimeSmoke is untouched at the source level; C1-A's incidental-load clause
  correctly scopes the transitive load.

---

## [Challenge]

No significant challenges. The implementation follows the C1-A boundary closely.

One architectural observation (not a blocker): The `if_expr_evaluator` in
`compiled_program.rb` is a lazy-initialized singleton (`@if_expr_evaluator ||=`).
This is efficient and correct for stateless evaluation. It is worth noting that
the evaluator instance is shared across all `evaluate_contract` calls, which is
safe since the evaluator is stateless (no instance variables that accumulate
state between calls). The implementation is correct.

---

## [Missing]

Nothing required is missing. PRT-IF1..PRT-IF15 all pass with the required
sub-check counts. Command matrix is complete. Closed-surface scan is
comprehensive. Non-claims block covers all C1-A required surfaces.

---

## [Sharper Question]

The smallest better question for the next stage is:

> Should the Slice 1 / Slice 2 dual-path duplication be kept for a potential
> Slice 3 RuntimeSmoke authorization, or should it be unified into a single
> path with an optional external_evaluator: parameter, with Slice 1 structural
> proof adapted to scan for the unified pattern?

This is a future design decision, not a current blocker.

---

## [Route]

Proceed. Route to:

```text
Card: S3-R201-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Route: ACCEPTANCE DECISION
Track: branch-conditional-if-expr-proof-runtime-consumer-v0
Depends on:
- S3-R201-C3-X
```

C4-A acceptance conditions:

1. Accept S3-R201-C2-I as Slice 2 proof RuntimeMachine consumer implementation.
2. Accept PRT-IF1..PRT-IF15 / 56/56 PASS as proof evidence.
3. Record the three non-blocking notes as-is (NB-1 cosmetic, NB-2 future design
   debt, NB-3 transitive load authorized by C1-A).
4. Record the SHA anchor:
   `summary_sha256: sha256:73f259c3a0a2fa3b1956a4e77083cd7b7807c04af6841455e1a2cfe96060b374`
5. Confirm that RuntimeSmoke, root require, CompilerOrchestrator, CompilerResult,
   CompilationReport, dynamic dependency tracking, counterfactual audit,
   release/public/Spark/API/CLI remain closed.
6. Record NB-3 transitive load as a known consequence of the accepted adapter
   boundary design, not as a new RuntimeSmoke surface opening.
7. Do not open Slice 3 (RuntimeSmoke consumer) without a separate authorization
   review.
