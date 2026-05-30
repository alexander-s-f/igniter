# Branch Conditional Counterfactual Audit Level 2 Source Evidence Boundary Decision v0

Card: S3-R210-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0  
Route: UPDATE  
Status: done / accepted-source-evidence-boundary  
Date: 2026-05-30

Depends on:
- S3-R210-C1-D
- S3-R210-C2-P1
- S3-R210-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round209-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
accept Level 2 source/evidence boundary design
accept current source evidence surface survey
accept C3-X pressure verdict: PASS with 3 non-blocking notes
authorize later proof-local source-backed concept proof authorization review
do not authorize proof execution in this card
do not authorize live implementation
```

R210 is accepted as the bridge from R209 hand-authored concept fixtures toward
source-backed proof-local Level 2 projection evidence. The accepted boundary
does not promote any reference shape into canonical schema, report/result
surface, receipt, cache/dependency authority, runtime behavior, public API/CLI,
Spark, or production behavior.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
```

---

## Accepted Boundary

Accepted tier model:

| Tier | Evidence source | Decision |
| --- | --- | --- |
| Tier 0 | Hand-authored branch-intention fixture | Accepted only as concept-proof legacy. Not enough as sole source for the next source-backed proof. |
| Tier 1 | Compiler/SemanticIR static evidence | Preferred next source, read-only structural citation only. |
| Tier 2 | Execution-summary evidence | Allowed narrowly as read-only actual-path citation. |
| Tier 3 | Canonical report/result/receipt/CompatibilityReport evidence | Closed. |
| Tier 4 | Live runtime or production execution | Closed. |

Accepted source/evidence refs remain proof-local and non-canonical:

- `source_branch_intention_ref`;
- `input_snapshot_ref`;
- `premise_set`;
- `premise_set_ref`;
- `execution_summary_ref`;
- `semanticir_ref`;
- `compiler_evidence_ref`.

These may be used as proof-local citation refs only. They do not become
SemanticIR schema, TypeChecker schema, report/result/receipt fields, public API
objects, cache keys, dependency records, or runtime outputs.

---

## C3-X Notes Resolved

### NB-1a: Preferred Source Artifact Type

Resolved:

```text
primary source: proof-owned SemanticIR / TypeChecker output where available
secondary source: proof-owned .igapp contract JSON when SemanticIR/TypeChecker
                  artifact is insufficient or unavailable
```

The next source-backed proof authorization review should prefer deriving
`source_branch_intention_evidence_packet` from proof-owned SemanticIR or
TypeChecker evidence. Proof-owned `.igapp` contract JSON is allowed as secondary
structural source evidence, but it must not be treated as production artifact
schema authority.

### NB-1b: Minimum Digest Convention

Resolved:

```text
digest convention: sha256:<hex>
```

The next source-backed proof must digest-address:

- `source_branch_intention_ref`;
- `input_snapshot_ref`;
- `premise_set_ref`;
- any source artifact cited in `evidence_trace`.

Digest values must be SHA-256 hex strings with the `sha256:` prefix, matching
the convention already used across accepted proof summaries.

### NB-2: Tier 1 Authority Ceiling

Resolved and binding:

```text
Tier 1 source citation is evidence bootstrapping only.
```

Deriving a branch-intention evidence packet from SemanticIR or TypeChecker
evidence does not promote that packet into canonical compiler output. The
derived packet remains:

- proof-local;
- non-canonical;
- digest-linked;
- explanatory only;
- without report/result/receipt/cache/runtime/API authority.

No SemanticIR schema, TypeChecker shape, parser/source syntax, `.igapp` schema,
or compiler public surface is opened by R210.

### NB-3: `assumed_condition_source`

Resolved and binding:

`assumed_condition_source` is required in the next source-backed proof matrix.

Allowed values:

| Value | Meaning |
| --- | --- |
| `explicit_proof_request` | A proof harness explicitly asks for the alternate branch premise. |
| `execution_summary_observation` | A proof-owned execution summary is cited as read-only actual-path context. |

No other values are allowed without a separate boundary review.

---

## Source Evidence Policy

### `source_branch_intention_ref`

Accepted policy:

- must be structured, not a bare string, in the next source-backed proof;
- must include `kind`, `source_kind`, `source_path` or equivalent source id,
  `source_digest`, `if_expr_id`, `branch_label`, `branch_role`, `derivation`,
  and `canonical: false`;
- must be derived from accepted proof-owned evidence;
- must not be sourced from report/result/receipt/API/runtime/production fields.

Allowed `source_kind` values for the next proof authorization review:

- `proof_derived_from_semanticir`;
- `proof_derived_from_typechecker`;
- `proof_derived_from_contract_json`;
- `proof_derived_from_execution_summary` for actual-path observations only.

Forbidden `source_kind` values remain:

- `compilation_report_field`;
- `compiler_result_field`;
- `receipt_field`;
- `compatibility_report_field`;
- `public_api_object`;
- `runtime_output`;
- `production_observation`.

### `input_snapshot_ref`

Accepted policy:

- preferred form is a proof-local frozen input packet;
- may cite a proof-owned execution summary input snapshot if frozen,
  digest-addressed, and read-only;
- compiler artifacts alone are not sufficient for value-producing projections;
- unresolved snapshots are allowed only for structural/refusal projections;
- production input records remain closed.

Required authority posture:

```text
runtime_input_authority: false
dependency_authority: false
cache_authority: false
report_authority: false
production_authority: false
public_claim: false
```

### `premise_set`

Accepted policy:

- required for each projection;
- must include `assumed_condition`;
- must include required `assumed_condition_source`;
- must link to `input_snapshot_ref`;
- may include assumptions-shaped refs only as proof-local premise labels;
- must not create branch-level `uses assumptions`;
- must not amend PROP-032;
- must not become receipt `assumption_refs`.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is source/evidence boundary accepted? | Yes. Accepted with C3-X notes resolved as binding policy. |
| Is emitted/compiler-backed source evidence required before the next proof-local Level 2 projection? | Yes. The next proof should derive branch-intention evidence from proof-owned SemanticIR/TypeChecker output, with `.igapp` contract JSON allowed as secondary structural source. |
| Is execution-summary-backed evidence allowed, held, or forbidden? | Allowed narrowly as read-only actual-path citation only; forbidden as latent execution, report/result/receipt, runtime, or cache authority. |
| Do hand-authored fixtures remain concept-proof-only? | Yes. Tier 0 remains accepted for R209 legacy concept proof only. |
| Do assumptions remain premise capsule only? | Yes. Assumptions-shaped refs remain proof-local premise labels, not PROP-032 branch syntax or receipt semantics. |
| Does live runtime remain lazy? | Yes. Non-selected branch live evaluation remains closed. |
| Does report/result/receipt/cache authority remain closed? | Yes. |
| Do public runtime/counterfactual/demo claims remain closed? | Yes. |
| Do Spark/API/CLI remain closed? | Yes. |

---

## Next Route

Immediate status handoff:

```text
Card: S3-R210-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round210-status-curation-v0
Route: UPDATE
Depends on:
- S3-R210-C1-D
- S3-R210-C2-P1
- S3-R210-C3-X
- S3-R210-C4-A
```

Recommended next Main Line route after C5-S:

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
dry-run concept proof may begin, using proof-owned SemanticIR/TypeChecker
or secondary contract JSON evidence, digest-addressed source refs, a frozen
input snapshot, and an explicit premise_set, while keeping all runtime,
report/result/receipt/cache/API/Spark/public authority closed.
```

Candidate future proof track, if authorized in R211:

```text
branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
```

Candidate future write scope, if authorized in R211:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md
```

R210 does not authorize this proof. It only authorizes the later authorization
review.

---

## Closed Surfaces

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

## Compact Handoff

R210 accepts the Level 2 source/evidence boundary. Future Level 2 projections
should no longer rely solely on hand-authored fixtures: the next proof route
should derive branch-intention evidence from proof-owned SemanticIR/TypeChecker
output, with contract JSON as a secondary structural source. All refs must be
SHA-256 digest-addressed and explicitly non-canonical. `input_snapshot_ref` and
`premise_set` remain no-authority proof-local evidence. Live runtime stays lazy;
report/result/receipt/cache/API/Spark/public surfaces remain closed.
