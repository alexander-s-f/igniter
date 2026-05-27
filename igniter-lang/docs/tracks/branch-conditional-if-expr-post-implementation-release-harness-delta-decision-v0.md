# Branch Conditional If Expr Post Implementation Release Harness Delta Decision v0

Card: S3-R192-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-post-implementation-release-harness-delta-decision-v0
Route: UPDATE
Status: done / accept-option-a-proof-summary-hygiene-next
Date: 2026-05-27

Depends on:
- S3-R192-C1-D
- S3-R192-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-post-implementation-release-harness-delta-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round191-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
accept C1-D design
accept C2-X pressure verdict: proceed, 8/8 PASS, no blockers
select Option A
keep accepted release evidence unchanged and explicitly historical
do not open release-harness delta now
open proof-summary hygiene next
hold release-harness delta until hygiene lands and a separate authorization review names a new evidence packet boundary
keep runtime/evaluator closed
keep release lane paused
keep public release/demo/all-grammar claims closed
keep Spark/API/CLI closed
```

R192 chooses the smallest safe next step. The accepted release evidence remains
historical and immutable. The next route should clean the R190/R191 proof-summary
hygiene debt before any future release-harness delta proof is designed or run.

---

## Accepted Design Basis

C1-D design options:

| Option | Decision |
| --- | --- |
| Keep release evidence unchanged and explicitly historical | Accepted as baseline. |
| Open later bounded release-harness delta proof | Viable later, not next. |
| Route proof-summary hygiene first | Accepted as next route. |
| Hold/pause because runtime/evaluator support remains closed | Applied only to runtime/public claims, not to proof-summary hygiene. |
| Redirect to runtime/evaluator design before harness work | Not required before compiler-only evidence work. |

C2-X pressure verdict:

```text
checks total: 8
checks pass: 8
checks fail: 0
blockers: none
```

Accepted pressure notes:

- any future harness delta must actively classify derivative `OOF-TY0` as
  secondary type-propagation when present;
- proof-summary hygiene must preserve the accepted semantic proof count:
  `checks_total == 28` and `checks_pass == 28`.

---

## Release Evidence Disposition

Accepted release evidence remains unchanged and historical:

```text
compiler_release_acceptance_harness_summary.json
official_first_rc_evidence_summary.json
combined_post_prep_smoke_summary.json
```

Preserved historical facts:

- `branch_conditional_if_expr` remains excluded in accepted first-RC / alpha
  evidence;
- exclusion basis remains the historical S3-R164-C4-A first-RC scope decision;
- public claims remain unauthorized;
- production runtime remains unauthorized.

Future wording must distinguish:

```text
historical first-RC/alpha evidence excluded branch_conditional_if_expr
```

from the now-stale broad phrase:

```text
if_expr unsupported
```

The old evidence packets must not be rewritten, relabeled, or reinterpreted as
post-R190 `if_expr` evidence.

---

## New Evidence Packet Decision

May a new evidence packet be designed next?

```text
No, not immediately.
```

A new compiler-only `if_expr` delta evidence packet may be considered only after
proof-summary hygiene lands and a separate authorization review names:

- new experiment directory;
- new evidence label;
- new output scope;
- old-evidence immutability checks;
- explicit non-claims.

Potential later evidence label:

```text
if_expr_internal_compiler_delta
```

That later packet must not be called official first-RC evidence and must not
relabel accepted alpha/release evidence.

---

## Runtime / Evaluator Decision

Does runtime/evaluator closure block release-harness delta?

```text
It blocks runtime, public demo, production, all-grammar, and end-to-end claims.
It does not block a future compiler-only delta proof.
```

Runtime/evaluator design is important future work, but it is not required before
proof-summary hygiene and is not required before a strictly compiler-only delta
evidence design.

Runtime/evaluator implementation remains closed.

---

## Public / Spark / API Decision

Public release/demo/all-grammar claims remain closed.

Spark remains out of scope.

Public API/CLI widening remains closed.

No public wording, Spark fixture, Spark integration, or API/CLI behavior may be
introduced by the next proof-summary hygiene route.

---

## Immediate Next Route

Recommended next route after S3-R192 status curation:

```text
Card: S3-R193-C1-P1
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-proof-summary-hygiene-v0
Route: UPDATE
Depends on:
- S3-R192-C4-S
```

Goal:

```text
Close R190/R191 proof-summary hygiene before any release-harness delta evidence.
```

Allowed write scope:

```text
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md
```

Required changes:

- annotate derivative `OOF-TY0` as secondary type-propagation output where
  present;
- add `oof_ty0_for_if_expr_absent: true` or equivalent explicit field for all
  negative `if_expr` cases;
- add or align `no_spark_claim: true` in proof summary `non_claims`;
- regenerate only proof-owned summary/output files;
- preserve all accepted semantic checks.

Required proof gates:

```text
checks_total == 28
checks_pass == 28
checks_fail == 0
unsupported-if_expr OOF-TY0 absent for all negative cases
derivative OOF-TY0 explicitly labeled secondary where present
no_spark_claim present and true
no release harness/evidence mutation
no runtime/public/API/Spark/doc-spec/code behavior changes
```

Required command matrix:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

Do not authorize:

- TypeChecker/SemanticIR behavior changes;
- release harness/evidence changes;
- public docs/README release claims;
- runtime/evaluator changes;
- Spark/API/CLI changes;
- release execution, publish, yank, tag, sign, or deploy.

---

## Later Route After Hygiene

Only after proof-summary hygiene is accepted, a later authorization review may
consider:

```text
Track: branch-conditional-if-expr-release-harness-delta-proof-v0
Route: UPDATE
Goal: produce a new post-R190 compiler-only if_expr delta evidence packet
```

That later route must:

- use a new evidence label;
- write only to a new experiment/output directory;
- prove old release evidence immutability;
- keep runtime/evaluator, public claims, Spark, API/CLI, and release execution
  closed;
- not mutate accepted release evidence.

No forward commitment to that later route is made by this decision.

---

## Closed Surfaces

Remain closed:

- accepted alpha / first-RC / release evidence mutation;
- release harness mutation;
- release execution, publish, yank, tag, sign, deploy;
- public release/demo/stable/production/all-grammar claims;
- runtime/evaluator implementation or lazy branch execution;
- public API/CLI widening;
- Spark fixtures, integration, public evidence, or production behavior;
- parser/classifier/orchestrator/assembler/root require changes;
- TypeChecker/SemanticIR behavior changes in the hygiene route;
- `.igapp`, manifest, sidecar, artifact-hash, golden migration;
- loader/report, `CompilationReport`, `CompilerResult`, CompatibilityReport;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, production.

---

## Explicit Answers

### Does accepted release evidence remain unchanged?

Yes.

All accepted release/first-RC/alpha evidence packets remain unchanged and
historical.

### May a new evidence packet be designed next?

No.

Proof-summary hygiene must run first. A new compiler-only evidence packet may be
designed later by a separate authorization review.

### Does runtime/evaluator closure block release-harness delta?

It blocks runtime/public/end-to-end claims. It does not block a future
compiler-only delta proof after hygiene.

### Do public release/demo/all-grammar claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

### What is the exact next card boundary?

The exact next boundary is `S3-R193-C1-P1 /
branch-conditional-if-expr-proof-summary-hygiene-v0`, with the write scope and
proof gates listed above.

