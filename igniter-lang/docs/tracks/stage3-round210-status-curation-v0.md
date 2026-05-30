# Stage 3 Round 210 Status Curation v0

Card: S3-R210-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round210-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-30

Depends on:
- S3-R210-C1-D
- S3-R210-C2-P1
- S3-R210-C3-X
- S3-R210-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R210.md`

---

## R210 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R210-C1-D | `branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0` | Done; designs source/evidence tiers and proof-local ref policy. |
| S3-R210-C2-P1 | `branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0` | Done; surveys current source evidence surfaces and gaps. |
| S3-R210-C3-X | `branch-conditional-counterfactual-audit-level2-source-evidence-boundary-pressure-v0` | PASS; 11/11 PASS, no blockers, 3 notes resolved by C4-A. |
| S3-R210-C4-A | `branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0` | Accepted source/evidence boundary; authorizes only later proof authorization review. |
| S3-R210-C5-S | `stage3-round210-status-curation-v0` | Done; records source/evidence boundary status and R211 authorization-review route. |

---

## Source / Evidence Boundary Status

R210 status:

```text
accepted-source-evidence-boundary
```

C4-A accepts the bridge from R209 hand-authored concept fixtures toward
source-backed proof-local Level 2 projection evidence. The accepted boundary does
not promote any reference shape into canonical schema, report/result surface,
receipt, cache/dependency authority, runtime behavior, public API/CLI, Spark, or
production behavior.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
```

---

## Accepted Tier Model

| Tier | Evidence source | Curated status |
| --- | --- | --- |
| Tier 0 | Hand-authored branch-intention fixture | Concept-proof legacy only; not enough as sole source for the next source-backed proof. |
| Tier 1 | Compiler/SemanticIR static evidence | Preferred next source; read-only structural citation only. |
| Tier 2 | Execution-summary evidence | Allowed narrowly as read-only actual-path citation. |
| Tier 3 | Canonical report/result/receipt/CompatibilityReport evidence | Closed. |
| Tier 4 | Live runtime or production execution | Closed. |

Accepted proof-local citation refs:

- `source_branch_intention_ref`;
- `input_snapshot_ref`;
- `premise_set`;
- `premise_set_ref`;
- `execution_summary_ref`;
- `semanticir_ref`;
- `compiler_evidence_ref`.

These remain proof-local and non-canonical. They are not SemanticIR schema,
TypeChecker schema, report/result/receipt fields, public API objects, cache
keys, dependency records, or runtime outputs.

---

## Pressure Notes Resolved

C3-X reports:

```text
PASS with 3 non-blocking notes
11/11 PASS, no blockers
```

C4-A resolves the notes as binding policy:

- Preferred source artifact type:
  - primary: proof-owned SemanticIR / TypeChecker output where available;
  - secondary: proof-owned `.igapp` contract JSON when SemanticIR/TypeChecker
    evidence is insufficient or unavailable.
- Minimum digest convention:
  - `sha256:<hex>` for `source_branch_intention_ref`, `input_snapshot_ref`,
    `premise_set_ref`, and every cited source artifact in `evidence_trace`.
- Tier 1 authority ceiling:
  - Tier 1 source citation is evidence bootstrapping only; derived
    branch-intention evidence remains proof-local, non-canonical, digest-linked,
    explanatory-only, and without report/result/receipt/cache/runtime/API
    authority.
- `assumed_condition_source` is required in the next source-backed proof matrix
  with allowed values:
  - `explicit_proof_request`;
  - `execution_summary_observation`.

---

## Remaining Closed Surfaces

Remain closed after R210:

- implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema mutation;
- runtime/evaluator/RuntimeSmoke behavior;
- live non-selected branch evaluation;
- proof RuntimeMachine changes;
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
- release evidence rewrite or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Exact Next Route Recommendation

Recommended next Main Line route:

```text
Card: S3-R211-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-counterfactual-audit-level2-source-backed-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R210-C5-S
```

Goal:

```text
Decide whether a bounded proof-local source-backed Level 2 counterfactual
dry-run concept proof may begin, using proof-owned SemanticIR/TypeChecker or
secondary contract JSON evidence, digest-addressed source refs, a frozen input
snapshot, and an explicit premise_set, while keeping all runtime,
report/result/receipt/cache/API/Spark/public authority closed.
```

Candidate future proof track if authorized in R211:

```text
branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
```

Candidate future write scope if authorized in R211:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md
```

R210 does not authorize this proof. It only authorizes the later authorization
review.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R210 as accepted source/evidence
boundary and routes only R211 source-backed proof authorization review next.
