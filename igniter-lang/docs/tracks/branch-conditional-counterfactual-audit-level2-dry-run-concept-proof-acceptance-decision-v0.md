# Branch Conditional Counterfactual Audit Level 2 Dry-Run Concept Proof Acceptance Decision v0

Card: S3-R209-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0  
Route: UPDATE  
Status: done / accepted-proof-local-level2-concept-evidence  
Date: 2026-05-30

Depends on:
- S3-R209-C2-I
- S3-R209-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-concept-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb`
- `igniter-lang/docs/tracks/stage3-round208-status-curation-v0.md`

Additional local read:

```bash
git show --name-only --oneline --no-renames 1d17334f
git status --short
```

---

## Decision

Decision:

```text
accept proof-local Level 2 counterfactual dry-run concept proof
accept L2-DRY-1..L2-DRY-15 / 52 checks PASS
accept C3-X pressure verdict: PASS 12/12, no blockers, no notes
accept generated output as proof-local Level 2 counterfactual dry-run concept evidence only
do not promote projection envelope to canonical schema/report/API/runtime surface
keep live runtime lazy and public/runtime/report/cache/API/Spark authority closed
```

The proof satisfies the R209-C1-A authorization boundary. It demonstrates that a
latent `if_expr` branch can be evaluated inside an experiment-local isolated
projection envelope while preserving no-authority disclaimers, explicit
premise-set recording, laziness inside the dry-run, and closed surfaces.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
```

---

## Accepted Changed Files

C2-I primary commit:

```text
1d17334f feat(igniter-lang): add S3-R209-C2-I Level 2 counterfactual dry-run
```

Accepted changed files:

| File | Acceptance status |
| --- | --- |
| `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md` | Accepted proof track doc. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb` | Accepted experiment-local isolated dry-run proof harness. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json` | Accepted proof summary, 52/52 PASS. |

No `lib/**`, spec chapter, PROP-032, RuntimeSmoke, proof RuntimeMachine,
report/result/receipt/CompatibilityReport, public API/CLI, Spark, or prior
evidence file change is accepted.

---

## Command Matrix Result

Accepted C2-I command matrix:

```text
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
=> PASS branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0
=> checks_total=52 checks_pass=52 checks_fail=0
```

Accepted summary anchor:

```text
sha256:9463d8dc2ecce570423cf4e1385d1d40f0e4e0231b854d93a4db5fd5848ae8ba
```

C3-X pressure result:

```text
PASS — 12/12 PASS, no blockers, no non-blocking notes
```

---

## L2-DRY Matrix Status

| ID | Result | Checks | Acceptance note |
| --- | --- | ---: | --- |
| L2-DRY-1 | PASS | 3 | Projection requires explicit proof harness invocation. |
| L2-DRY-2 | PASS | 4 | Level 1 branch-intention consumed as input, not replaced. |
| L2-DRY-3 | PASS | 3 | Pure latent branches produce `projected_value`. |
| L2-DRY-4 | PASS | 1 | `projected_value_is_not_actual_output: true`. |
| L2-DRY-5 | PASS | 3 | Selected actual result remains unchanged. |
| L2-DRY-6 | PASS | 3 | Unsupported selected dry-run expression produces `projected_failure`, not actual failure. |
| L2-DRY-7 | PASS | 1 | `projected_failure_is_not_actual_failure: true`. |
| L2-DRY-8 | PASS | 3 | Effect/external IO refused with no side effect. |
| L2-DRY-9 | PASS | 3 | `tbackend_read` refused; no live Ledger/TBackend read. |
| L2-DRY-10 | PASS | 3 | Nested `if_expr` dry-run is lazy inside isolated projection. |
| L2-DRY-11 | PASS | 4 | `premise_set` records assumed condition and input/premise source. |
| L2-DRY-12 | PASS | 6 | Isolation block proves mutation/IO/production fields false. |
| L2-DRY-13 | PASS | 6 | Authority block proves dependency/cache/report/runtime/public authority false. |
| L2-DRY-14 | PASS | 3 | Forbidden vocabulary scan passes across proof output fields. |
| L2-DRY-15 | PASS | 6 | Closed-surface scan proves no `lib/**`, spec, report/API, RuntimeSmoke, Spark/API/CLI, or public claim mutation. |

Total:

```text
checks_total: 52
checks_pass: 52
checks_fail: 0
```

---

## Projection Envelope Status

Accepted as proof-local only:

```text
counterfactual_dry_run_projection
```

Required fields are present in proof output:

- `premise_set`;
- `assumed_condition`;
- `dry_run_trace`;
- `projected_value`;
- `projected_failure`;
- `projected_value_is_not_actual_output: true`;
- `projected_failure_is_not_actual_failure: true`;
- isolation block;
- authority block;
- no-authority disclaimer.

This envelope remains non-canonical. It is not:

- SemanticIR schema;
- public API;
- report/result/receipt shape;
- CompatibilityReport;
- RuntimeSmoke output;
- `.igapp` artifact schema;
- runtime output contract;
- public counterfactual support.

---

## Isolation And Authority Status

Accepted isolation block status:

```text
actual_result_mutated: false
reports_mutated: false
receipts_mutated: false
cache_mutated: false
external_io_performed: false
production_authority: false
```

Accepted authority block status:

```text
dependency_authority: false
cache_authority: false
report_authority: false
runtime_readiness_authority: false
public_claim: false
```

C3-X confirms these are structurally strong in the proof harness: the blocks are
frozen constants and all projections report clean isolation and authority.

---

## Behavior Accepted

Accepted pure projection cases:

- `ref("fallback")` with proof-local snapshot -> `projected_value: 99`;
- pure `apply(add, a, b)` -> `projected_value: 15`;
- `field_access` on immutable proof-local hash -> `projected_value: 77`;
- nested `if_expr` with an escape trap in the non-selected dry-run branch ->
  `projected_value: 7`, `projected_failure: nil`.

Accepted refusal cases:

- `tbackend_read("accounts/active")` -> `projected_failure` with
  `tbackend_read_refused_in_dry_run`;
- `escape("ExternalService")` -> `projected_failure`;
- refusals are dry-run projection refusals, not actual runtime failures.

`tbackend_read` remains refuse-only. Any non-refusal `tbackend_read` behavior
requires a separate temporal/runtime gate.

---

## Forbidden Vocabulary Status

Accepted:

- the proof scans 17 terms: the 14 R206/R207 forbidden terms plus
  `symbolic_execution`, `causal_estimate`, and `alternate_actual_output`;
- scan result is `CLEAR` for projection field names and values;
- C3-X independently confirms matches exist only in the `terms_checked` array
  and an explanatory harness comment, not projection fields.

Forbidden terms remain forbidden as positive canonical/public/projection field
names:

```text
would_result
would_output
would_fail
counterfactual result
counterfactual output
counterfactual failure
latent runtime value
latent runtime failure
latent execution
latent branch execution
simulated branch result
dry-run result
branch replay
replayed branch value
symbolic_execution
causal_estimate
alternate_actual_output
```

---

## Claim Policy

Accepted maximum claim:

```text
Proof-local Level 2 counterfactual dry-run concept evidence: latent branches
can be evaluated inside an experiment-local isolated projection envelope with
no-authority disclaimers, explicit premise_set, and full isolation block.
```

Binding non-equivalences:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
dry_run_projection != public_runtime_support
Level2_proof != public_counterfactual_support
Level2_proof != live_non_selected_evaluation
```

Generated output may be called only:

```text
proof-local Level 2 counterfactual dry-run concept evidence
```

It must not be called public/runtime/report/API support.

---

## Required Answers

| Question | Answer |
| --- | --- |
| Is proof-local Level 2 concept proof accepted? | Yes. Accepted unconditionally. |
| May generated output be called proof-local Level 2 counterfactual dry-run evidence only? | Yes. |
| Is this public/runtime/report/API support? | No. |
| Does live runtime remain lazy? | Yes. Live runtime non-selected branch evaluation remains closed. |
| Does report/result/receipt/cache authority remain closed? | Yes. |
| Do Spark/API/CLI remain closed? | Yes. |

---

## Next Route

Immediate status handoff:

```text
Card: S3-R209-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round209-status-curation-v0
Route: UPDATE
Depends on:
- S3-R209-C1-A
- S3-R209-C2-I
- S3-R209-C3-X
- S3-R209-C4-A

Goal:
Curate R209 acceptance, record proof-local Level 2 concept proof evidence,
preserve closed surfaces, and record the exact next Main Line route.
```

Recommended next Main Line route after C5-S:

```text
Card: S3-R210-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0
Route: UPDATE
Depends on:
- S3-R209-C5-S

Goal:
Design-only boundary for moving Level 2 dry-run proof from hand-authored
branch-intention fixtures toward emitted compiler/SemanticIR or actual execution
summary evidence, including `input_snapshot_ref` authority, without opening
live runtime, report/result/receipt, cache/dependency, public API/CLI, or Spark
surfaces.
```

Rationale:

The accepted proof uses hand-authored Level 1 branch-intention fixtures and a
proof-local `input_snapshot_ref`. Before runtime/evaluator or spec-body work,
the Main Line needs a design-only source/evidence boundary for emitted compiler
artifacts and actual execution summaries. This is the safer bridge from concept
proof to system integration.

---

## Remaining Closed Surfaces

Remain closed after R209:

- live implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema/canon mutation;
- runtime/evaluator/RuntimeSmoke behavior;
- proof RuntimeMachine changes;
- live non-selected branch evaluation;
- effect execution;
- external IO;
- persistence;
- Ledger/TBackend live reads/writes;
- `tbackend_read` non-refusal behavior;
- dependency/cache authority;
- `CompilationReport`, `CompilerResult`, receipt, `CompatibilityReport`
  mutation;
- `.igapp` artifact schema or goldens;
- spec-body promotion;
- public API/CLI;
- release evidence or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Compact Handoff

R209 accepts the proof-local Level 2 counterfactual dry-run concept proof:
52/52 checks PASS and pressure 12/12 PASS. Latent branches can be evaluated
inside an experiment-local isolated projection envelope with explicit
`premise_set`, no-authority disclaimers, isolation block, and authority block.
This remains proof-local evidence only. Live runtime stays lazy, `tbackend_read`
is refuse-only, and report/result/receipt/cache/API/Spark/public authority
remains closed. Recommended next route is design-only source/evidence boundary
before any runtime/evaluator or spec-body route.
