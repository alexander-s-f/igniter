# Branch Conditional If Expr Runtime Smoke Consumer Proof Acceptance Decision v0

Card: S3-R203-C4-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0`  
Route: UPDATE  
Status: done / accepted-proof-owned-runtime-smoke-consumer-evidence  
Date: 2026-05-29

Depends on:
- S3-R203-C2-I
- S3-R203-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-smoke-consumer-proof-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/docs/tracks/stage3-round202-status-curation-v0.md`

Additional local verification was run by C4-A:

```bash
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
```

All six commands passed.

---

## Decision

Decision:

```text
accept proof-owned RuntimeSmoke consumer harness closure
accept RS-IF1..RS-IF16: 53/53 PASS
accept proof-context RuntimeSmoke if_expr consumer evidence
do not promote this to public runtime support
do not promote this to production/runtime support
keep runtime_smoke.rb unchanged
keep RuntimeSmoke result shape unchanged
keep CompilerOrchestrator callback integration closed
keep release lane paused
keep public/Spark/API/CLI claims closed
route C5-S status curation next
recommend counterfactual-audit design-only route after status curation
```

The S3-R203-C2-I implementation satisfies the S3-R203-C1-A authorization. The
proof demonstrates that existing `IgniterLang::RuntimeSmoke.run` can consume
proof-owned `.igapp` artifacts containing `if_expr` through the accepted proof
RuntimeMachine path.

This acceptance is intentionally narrow. It accepts proof-context consumer
evidence only.

---

## Accepted Changed Files

Accepted changed/output files:

| File | Accepted status |
| --- | --- |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb` | Accepted proof-owned RuntimeSmoke consumer harness. |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json` | Accepted proof summary, 53/53 PASS. |
| `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/rs-if-proof-v0/igapps/**` | Accepted programmatically generated proof-owned `.igapp` artifacts. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-v0.md` | Accepted implementation/proof track doc. |

No other write scope is accepted by this decision.

Read-only surfaces accepted unchanged:

```text
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

---

## Command Matrix Result

Accepted C4-A local verification:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
=> PASS, 53/53

ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
=> Syntax OK

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_if_expr_proof_runtime_consumer_v0/branch_conditional_if_expr_proof_runtime_consumer_v0.rb
=> PASS, 56/56

ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
=> PASS, 68/68
```

Accepted proof summary:

```text
status: PASS
checks_total: 53
checks_pass: 53
checks_fail: 0
failed_checks: []
summary_sha256: sha256:b866973f0ef0f1463ba28d8e67fe8b77293b163b2159ef5a0ddabe94c6ad9492
```

---

## RS-IF1..RS-IF16 Status

Accepted proof matrix:

| ID | Result | Checks | Acceptance note |
| --- | --- | ---: | --- |
| RS-IF1 | PASS | 3 | Direct-require RuntimeSmoke; root require unchanged. |
| RS-IF2 | PASS | 4 | Transitive evaluator load classified as non-support via source/claim scan and behavioral load-without-eval assertion. |
| RS-IF3 | PASS | 4 | `condition=true` returns trusted output from `then_branch`. |
| RS-IF4 | PASS | 3 | `condition=false` returns trusted output from `else_branch`. |
| RS-IF5a | PASS | 3 | Selected `apply` works through proof RuntimeMachine-local adapter path. |
| RS-IF5b | PASS | 2 | Selected `field_access` works through proof RuntimeMachine-local adapter path. |
| RS-IF6 | PASS | 2 | Non-selected `apply` branch does not fire. |
| RS-IF7 | PASS | 4 | RuntimeSmoke success/failure result key sets unchanged. |
| RS-IF8 | PASS | 3 | RuntimeSmoke callback source/shape unchanged; no orchestrator integration. |
| RS-IF9 | PASS | 3 | `eval_input_for` unchanged; no `if_expr` special case. |
| RS-IF10 | PASS | 3 | Dual-path evaluator preserved; Slice 1 and Slice 2 both work. |
| RS-IF11 | PASS | 4 | CompilerOrchestrator, CompilerResult, CompilationReport remain closed. |
| RS-IF12 | PASS | 2 | Root require remains closed. |
| RS-IF13 | PASS | 2 | Dependency/cache authority remains closed. |
| RS-IF14 | PASS | 2 | Counterfactual audit remains future pressure only. |
| RS-IF15 | PASS | 4 | Release/public/Spark/API/CLI remain closed. |
| RS-IF16 | PASS | 5 | Malformed `if_expr` returns blocked failure shape with `trusted: false`; no diagnostics/report widening. |

Pressure review reported 20/20 PASS, no blockers.

---

## Artifact Status

Accepted `.igapp` artifact policy:

```text
proof-owned
programmatically generated
under igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/
not borrowed from release evidence
not relabeled from prior proof evidence
not shared as a public fixture/golden
```

Accepted generated artifact set:

| Artifact | Purpose |
| --- | --- |
| `rs_if3_cond_true.igapp/` | `if_expr` condition true. |
| `rs_if4_cond_false.igapp/` | `if_expr` condition false. |
| `rs_if5a_selected_apply.igapp/` | Selected `apply`. |
| `rs_if5b_selected_field_access.igapp/` | Selected `field_access`. |
| `rs_if6_non_selected_no_fire.igapp/` | Non-selected branch isolation. |
| `rs_if16_malformed_if_expr.igapp/` | RuntimeSmoke blocked failure rescue. |
| `rs_regression_apply.igapp/` | Non-`if_expr` apply regression baseline. |

---

## RuntimeSmoke Status

Accepted:

- `runtime_smoke.rb` source remains unchanged;
- `RuntimeSmoke.run` result shape remains unchanged;
- success key set remains:
  `compatibility_report_status`, `contract_id`, `evaluate_status`,
  `load_status`, `outputs`, `trusted`;
- failure key set remains: `error`, `load_status`, `trusted`;
- blocked failure path remains `load_status: "blocked"`, `trusted: false`;
- `RuntimeSmoke.callback` behavior remains unchanged;
- `RuntimeSmoke.eval_input_for` behavior remains unchanged;
- no `if_expr` special case is added to `eval_input_for`;
- no `CompilerOrchestrator#compile(..., runtime_smoke:)` path is opened.

Accepted maximum claim:

```text
RuntimeSmoke has proof-context consumer evidence for if_expr through the
existing proof RuntimeMachine path.
```

Rejected / still closed:

```text
if_expr public runtime support
if_expr production runtime support
RuntimeSmoke public support for if_expr
stable/all-grammar runtime support
release/demo evidence
Spark/API/CLI integration
```

---

## Support-Claim Stance

The following hierarchy remains binding:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

R203 accepts proof-context consumer evidence only. It does not change public
support language, README claims, release evidence, package metadata, API/CLI
surfaces, or production runtime posture.

---

## Pressure Notes Disposition

C3-X reported no blockers and two non-blocking notes.

### NB-1: Non-selected `field_access`

Disposition:

```text
accepted as proof-hygiene note, not a blocker
```

RS-IF6 explicitly proves non-selected `apply` does not fire. There is no
dedicated non-selected `field_access` case. This is acceptable because:

- RS-IF5b proves selected `field_access` routing through the adapter;
- RS-IF10 preserves the lazy dual-path evaluator structure;
- non-selected branch isolation is structural in the accepted evaluator path;
- adding non-selected `field_access` would be a useful future proof extension,
  but it is not required to accept this closure.

### NB-2: Inherited R201 non-claims

Disposition:

```text
accepted as inherited from R201, not a C2-I gap
```

The smoke-harness summary does not repeat `no_constructor_injection` or
`no_tbackend_read_in_evaluator_core`. Those remain closed under R201 acceptance
and are indirectly protected here by the unchanged evaluator/proof RuntimeMachine
source and passing PRT regression.

---

## Explicit Answers

### Is RuntimeSmoke proof consumer closure accepted?

Yes.

### Can RuntimeSmoke now be said to have proof-context `if_expr` consumer evidence?

Yes, using the exact bounded wording:

```text
RuntimeSmoke has proof-context consumer evidence for if_expr through the
existing proof RuntimeMachine path.
```

### Is this public runtime support?

No.

### Is this production/runtime support?

No.

### Does RuntimeSmoke source remain unchanged?

Yes.

### Does RuntimeSmoke result shape remain unchanged?

Yes.

### Does CompilerOrchestrator callback integration remain closed?

Yes.

### Does root require remain closed?

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

### What next route should open?

Immediate next route:

```text
S3-R203-C5-S status curation
```

Recommended Main Line route after status curation:

```text
branch-conditional-counterfactual-audit-design-boundary-v0
design-only
```

The counterfactual-audit route should remain design-only at first and must not
authorize eager latent-branch execution, dependency/cache authority, public
runtime claims, RuntimeSmoke source changes, API/CLI widening, release claims,
or production behavior.

---

## Remaining Closed Surfaces

Remain closed:

- new implementation beyond accepted proof harness;
- `runtime_smoke.rb` edits;
- root require changes;
- proof RuntimeMachine source changes;
- evaluator source changes;
- `CompilerOrchestrator`;
- `CompilerResult`;
- `CompilationReport`;
- `Diagnostics` centralization or public runtime diagnostics;
- parser, classifier, TypeChecker, SemanticIR emitter, compiler pipeline,
  assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation
  outside the R203 proof-owned output directory;
- release evidence rewrite or relabeling;
- release commands, release execution, RubyGems publish, yank, tag, push, sign,
  deploy;
- public demo/release/stable/production/all-grammar/runtime claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- counterfactual audit implementation, dry-run execution, comparison reports,
  effect sandboxing;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Decision Summary

S3-R203-C4-A accepts the proof-owned RuntimeSmoke consumer harness closure.
RuntimeSmoke now has bounded proof-context `if_expr` consumer evidence through
the existing proof RuntimeMachine path. The accepted proof is 53/53 PASS,
pressure is 20/20 PASS, and local C4-A verification passed.

This remains proof-context evidence only. Public runtime support, production
runtime support, release/demo claims, Spark/API/CLI, counterfactual audit
implementation, dependency/cache authority, and RuntimeSmoke source changes all
remain closed.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R203-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round203-status-curation-v0
Route: UPDATE
Depends on:
- S3-R203-C1-A
- S3-R203-C2-I
- S3-R203-C3-X
- S3-R203-C4-A
```

After C5-S, recommended Main Line route:

```text
Card: S3-R204-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-design-boundary-v0
Route: UPDATE
Depends on:
- S3-R203-C5-S
```

Goal:

```text
Design the counterfactual-audit boundary for if_expr: explain non-selected
branches without evaluating them in the live runtime, without dependency/cache
authority, without public API/CLI widening, and without public runtime claims.
```
