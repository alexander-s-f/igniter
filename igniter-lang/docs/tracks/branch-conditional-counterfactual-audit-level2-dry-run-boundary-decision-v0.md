# Branch Conditional Counterfactual Audit Level 2 Dry-Run Boundary Decision v0

Card: S3-R208-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-dry-run-boundary-decision-v0  
Route: UPDATE  
Status: done / accepted-boundary-proof-authorization-review-next  
Date: 2026-05-30

Depends on:
- S3-R208-C1-D
- S3-R208-C2-P1
- S3-R208-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-boundary-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-adjacent-concepts-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round207-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
accept Level 2 counterfactual dry-run boundary design
accept adjacent-concepts survey as internal analogy map only
accept C3-X pressure verdict: PASS 10/10, no blockers
accept Level 2 as conceptually valid only as explicit isolated proof-local projection
authorize next route: proof-local Level 2 concept proof authorization review
do not authorize proof execution in this card
do not authorize live implementation, runtime/report/API/cache/public/Spark authority
```

Level 2 is accepted as a design boundary, not as implementation and not as
public/runtime support.

The accepted layered principle is:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
```

---

## Boundary Accepted

Level 2 is conceptually valid for Igniter-Lang as:

```text
an explicit isolated counterfactual dry-run projection under an explicit premise set
```

It is not:

- normal runtime behavior;
- live runtime evaluation of non-selected branches;
- public runtime support;
- public counterfactual audit support;
- report/result/receipt/CompatibilityReport shape;
- cache/dependency authority;
- production behavior;
- Spark/API/CLI behavior.

Level 2 consumes Level 1 branch-intention evidence. It does not replace Level 1
and does not invalidate the Level 1 non-execution guarantee for the actual
runtime path.

---

## Analogy Disposition

No single close mainstream language analog exists.

Accepted analogy map:

- symbolic execution is the closest tempting analogy, but too broad and too
  authority-heavy for canonical or public vocabulary;
- abstract interpretation, CFG/SSA, flow typing, proof tools, refinement
  systems, debugger replay, logic programming, database what-if analysis, and
  probabilistic counterfactuals are useful only as internal design pressure;
- database hypothetical planning and debugger isolation are useful narrow
  analogies for no-mutation framing;
- probabilistic/causal counterfactual vocabulary is high-risk for public claims.

Igniter's boundary is distinct because it separates:

```text
actual runtime selection       -> selected branch only
Level 1 branch intention audit -> latent branch described without evaluation
Level 2 dry-run projection     -> explicit isolated no-authority projection
```

No analogy grants authority. Analogies may inform vocabulary and risk controls
only.

---

## Accepted Candidate Vocabulary

The following terms are accepted only as design-level / proof-local candidate
vocabulary:

| Term | Accepted meaning |
| --- | --- |
| `counterfactual_dry_run` | Explicit isolated evaluation of a latent branch under declared premises. |
| `dry_run_projection` | Non-authoritative result envelope for the dry-run. |
| `dry_run_trace` | Evaluation trace inside the isolated dry-run context. |
| `assumed_condition` | Condition value supplied by the dry-run premise set, not actual runtime. |
| `projected_branch` | Branch selected in dry-run context. |
| `projected_value` | Value produced by an isolated pure dry-run, not actual runtime output. |
| `projected_failure` | Refusal/failure observed in isolated dry-run, not actual runtime failure. |
| `premise_set` | Explicit assumptions and inputs used by the dry-run. |
| `isolation_guarantee` | Assertion that actual runtime artifacts were not mutated. |
| `no_authority` | Assertion that the projection carries no cache/report/public/production authority. |

These terms are not public API, not report fields, not receipt fields, not
CompatibilityReport fields, not SemanticIR schema, and not runtime output
contracts.

---

## Forbidden Vocabulary

The following remain forbidden as positive canonical field names or public
claims:

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

The phrase "what would have happened" may appear only as explanatory prose. It
must not become a field name, result status, public claim, or report authority.

---

## Latent Branch Evaluation Stance

Accepted:

- a future proof-local Level 2 concept proof may evaluate a latent branch only
  inside an explicitly invoked isolated proof harness;
- first proof scope, if authorized later, must be pure/refusal-oriented;
- nested `if_expr` may be included only under the same isolation rules.

Rejected / closed:

- live runtime evaluation of non-selected branches;
- automatic runtime dry-run;
- public API/CLI dry-run invocation;
- production/runtime automatic dry-run;
- mutation of actual runtime output or selected-branch result.

---

## Effect / IO / TBackend Stance

First Level 2 slice must be pure-only and refusal-oriented.

Accepted future proof candidates:

- `literal`;
- `ref`;
- pure deterministic proof-local `apply`;
- `field_access` on immutable proof-local values;
- nested `if_expr` under isolation.

Must refuse:

- `escape`;
- external calls;
- privileged or irreversible behavior;
- runtime callbacks;
- persistence;
- network;
- filesystem side effects;
- live Ledger/TBackend reads or writes;
- live `tbackend_read`.

`tbackend_read` is refuse-only for the first Level 2 slice. Any frozen in-memory
proof backend snapshot requires a separate temporal/runtime design gate.

---

## Report / Result / Receipt / Cache Stance

Level 2 projection must not mutate or authoritatively populate:

- actual runtime result;
- selected-branch output;
- `CompilationReport`;
- `CompilerResult`;
- runtime receipts;
- `CompatibilityReport`;
- `.igapp` artifacts;
- cache state;
- dependency authority;
- public reports/status.

Any report/result/receipt/CompatibilityReport shape requires a separate future
gate.

---

## Binding Conditions For Next Authorization Review

The next route may be an authorization review only. It must carry these binding
conditions before any proof-local Level 2 concept proof can run.

Invocation and isolation:

1. Dry-run occurs only when a proof harness explicitly requests it.
2. Projection envelope must prove:
   - `actual_result_mutated: false`;
   - `reports_mutated: false`;
   - `receipts_mutated: false`;
   - `cache_mutated: false`;
   - `external_io_performed: false`;
   - `production_authority: false`.
3. Authority block must prove false:
   - `dependency_authority`;
   - `cache_authority`;
   - `report_authority`;
   - `runtime_readiness_authority`;
   - `public_claim`.

Behavioral proof expectations:

4. Pure success case produces `projected_value`.
5. Unsupported/effect/external IO case produces `projected_failure`, not actual
   failure.
6. `tbackend_read` is refused in first slice; no live Ledger/TBackend read.
7. Nested `if_expr` dry-run is lazy inside the isolated projection.
8. Level 1 branch-intention is consumed as input, not replaced.
9. Level 2 projection does not invalidate Level 1 actual-runtime
   `non_execution_guarantee`.

Vocabulary and disclaimer requirements:

10. Every projection records `assumed_condition` and `premise_set`.
11. All 14 R206/R207 forbidden terms are absent from proof output fields.
12. Proof outputs must also reject analogy-drift terms such as
    `symbolic_execution`, `causal_estimate`, and `alternate_actual_output`.
13. Projection envelope must explicitly distinguish:
    - `projected_value_is_not_actual_output: true`;
    - `projected_failure_is_not_actual_failure: true`.
14. `projected_value` and `projected_failure` must carry no-authority
    disclaimers.

Closed-surface requirements:

15. No `lib/**`, runtime/evaluator/RuntimeSmoke/report/API/grammar/public claim
    mutation in proof scope.
16. No spec-body promotion before a separate spec-body gate.
17. No Spark/API/CLI behavior or claims.

---

## Required Answers

| Question | Decision |
| --- | --- |
| Does a close analog exist in other languages? | No single close analog. Adjacent traditions exist, but Igniter's three-layer boundary is distinct. |
| Is Level 2 dry-run conceptually accepted? | Yes, as explicit isolated proof-local projection under declared premises. |
| May proof-local Level 2 concept work open next? | Yes, but only an authorization review may open next; the proof itself is not authorized by this card. |
| Does live runtime non-selected branch evaluation remain closed? | Yes. Live runtime remains lazy. |
| Does report/result/receipt/cache authority remain closed? | Yes. |
| Do public counterfactual/runtime/demo claims remain closed? | Yes. |
| Do Spark/API/CLI remain closed? | Yes. |

---

## Next Route

Immediate status handoff:

```text
Card: S3-R208-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round208-status-curation-v0
Route: UPDATE
Depends on:
- S3-R208-C1-D
- S3-R208-C2-P1
- S3-R208-C3-X
- S3-R208-C4-A

Goal:
Curate R208 acceptance, record Level 2 boundary status, analogy disposition,
and exact next Main Line route.
```

Authorized next route after C5-S:

```text
Card: S3-R209-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-counterfactual-audit-level2-concept-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R208-C5-S

Goal:
Decide whether a bounded proof-local Level 2 counterfactual dry-run concept
proof may begin under the R208 isolation, vocabulary, refusal, and no-authority
constraints.
```

Candidate proof track if later authorized by R209-C1-A:

```text
branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0
```

Candidate write scope if later authorized:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md
```

No proof, implementation, or code edit is authorized by R208-C4-A.

---

## Remaining Closed Surfaces

Remain closed after R208:

- code implementation;
- proof execution;
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
- `.igapp` artifact schema;
- spec-body promotion;
- public API/CLI;
- release evidence or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Compact Handoff

R208 accepts Level 2 counterfactual dry-run as a concept boundary only:
explicit, isolated, proof-local projection under an explicit premise set. No
single mainstream language analog matches it; symbolic execution and causal
counterfactuals are internal analogies only and must not become canonical labels.
The next route may be only a proof-local concept proof authorization review.
Live runtime remains lazy, public/runtime/report/cache/API/Spark authority
remains closed, and no proof/code is authorized yet.
