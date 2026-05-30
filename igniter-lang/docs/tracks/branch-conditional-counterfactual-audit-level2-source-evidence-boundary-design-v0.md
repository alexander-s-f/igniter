# Branch Conditional Counterfactual Audit Level 2 Source Evidence Boundary Design v0

Card: S3-R210-C1-D  
Agent: [Compiler/Grammar Expert]  
Role: compiler-grammar-expert  
Track: branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0  
Route: UPDATE  
Depends on: S3-R209-C5-S

## Purpose

Design the source/evidence boundary for future Level 2 counterfactual dry-run
projections: how a projection may reference compiler/SemanticIR or
execution-summary evidence instead of hand-authored branch-intention fixtures,
without opening runtime, report/result/receipt, dependency/cache, public API/CLI,
release, production, or Spark authority.

This is design-only. It authorizes no proof, implementation, docs/spec edit,
runtime behavior, report/result shape, public API/CLI, or public claim.

## Neighbor Awareness

Affected neighbor roles:

- Research Agent: would own future source-backed proof-local evidence.
- Runtime / Bridge owners: would review execution-summary and input-snapshot
  boundaries.
- Assumptions owner: would review premise-set and assumptions-shaped refs.
- Spec/Status Curator: would own any later status/spec promotion.

This track speaks only as `[Compiler/Grammar Expert]`.

## Inputs Read

- `docs/tracks/stage3-round209-status-curation-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md`
- `experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json`
- `docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`

Additional read-only evidence:

- `experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb`

## Current Fixed Point

R209 accepts proof-local Level 2 concept evidence:

```text
latent branches can be evaluated inside an experiment-local isolated projection
envelope with no-authority disclaimers, explicit premise_set, and full isolation
block.
```

R209 does not accept the projection envelope as canonical schema. It uses
hand-authored Level 1 branch-intention fixtures and proof-local snapshots. Those
fixtures are enough for concept proof, but not enough for a source-backed proof
route.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
```

## Source/Evidence Tiers

Recommended tier model:

| Tier | Evidence source | Status | Allowed use |
| --- | --- | --- | --- |
| Tier 0 | Hand-authored branch-intention fixture | Concept proof only | Accepted for R209; should not be the main source for future source-backed reruns. |
| Tier 1 | Compiler/SemanticIR static evidence | Preferred next proof source | May provide `if_expr` structure, branch labels, expression kinds, resolved types, and static refs. |
| Tier 2 | Execution-summary evidence | Optional read-only actual-path source | May provide observed condition value, actual selected branch, actual output summary, and frozen input snapshot refs. |
| Tier 3 | Canonical report/result/receipt/CompatibilityReport evidence | Closed | Must not be mutated or treated as authority without a separate report/schema gate. |
| Tier 4 | Live runtime or production execution | Closed | Must not evaluate non-selected branches or perform live IO. |

Tier 1 and Tier 2 may be referenced as read-only evidence in a future
proof-local route. They do not become projection authority.

## `source_branch_intention_ref` Policy

The R209 proof used bare strings such as:

```text
if:risk_gate_true/latent_else
```

That remains acceptable for concept proof only. A future source-backed proof
should use a structured source ref:

```json
{
  "kind": "source_branch_intention_ref",
  "source_kind": "proof_derived_from_semanticir",
  "source_path": "experiments/.../out/source.semantic_ir.json",
  "source_digest": "sha256:...",
  "if_expr_id": "if:risk_gate_true",
  "branch_label": "else",
  "branch_role": "latent",
  "derivation": "proof-local",
  "canonical": false
}
```

Allowed `source_kind` values for a future proof:

| `source_kind` | Status |
| --- | --- |
| `hand_authored_fixture` | Legacy concept-proof only; do not use as the only source in the next source-backed route. |
| `proof_derived_from_semanticir` | Preferred. |
| `proof_derived_from_typechecker` | Allowed if SemanticIR is insufficient for branch wrappers. |
| `proof_derived_from_execution_summary` | Allowed only for actual-path observations, not latent execution. |

Forbidden `source_kind` values until a separate gate:

- `compilation_report_field`;
- `compiler_result_field`;
- `receipt_field`;
- `compatibility_report_field`;
- `public_api_object`;
- `runtime_output`;
- `production_observation`.

## `input_snapshot_ref` Policy

`input_snapshot_ref` must point to explicit frozen proof input evidence. It must
not imply runtime input mutation or production data authority.

Allowed forms:

| Form | Status | Notes |
| --- | --- | --- |
| Proof-local frozen input packet | Preferred first source-backed route | Include digest and inline/file-backed packet path. |
| Proof-owned execution summary input snapshot | Allowed | Read-only; must carry digest and no-authority disclaimer. |
| Compiler artifact | Not sufficient alone | Compiler artifacts can provide structure, not runtime values. |
| Unresolved snapshot | Allowed only for structural/refusal projections | Cannot produce `projected_value`; may produce unresolved-input projected failure. |
| Production input record | Closed | Requires separate privacy/runtime/production authority. |

Recommended proof-local shape:

```json
{
  "kind": "input_snapshot_ref",
  "source_kind": "proof_local_frozen_packet",
  "path": "experiments/.../fixtures/input_snapshot.json",
  "digest": "sha256:...",
  "mutable": false,
  "authority": {
    "runtime_input_authority": false,
    "production_authority": false,
    "public_claim": false
  }
}
```

## `premise_set` Authority Policy

Every projection must carry an explicit `premise_set`. The premise set explains
why this dry-run was invoked; it does not authorize actual runtime behavior.

Minimum fields for future source-backed proof:

```json
{
  "kind": "counterfactual_premise_set",
  "assumed_condition": true,
  "assumed_condition_source": "explicit_proof_request",
  "input_snapshot_ref": { "...": "see input_snapshot_ref policy" },
  "assumption_refs": [],
  "authority": {
    "runtime_authority": false,
    "dependency_authority": false,
    "cache_authority": false,
    "report_authority": false,
    "public_claim": false
  }
}
```

`assumption_refs` may be assumptions-shaped refs, but only as proof-local
premise labels. They do not create branch-level `uses assumptions`, do not amend
PROP-032, and do not become receipt `assumption_refs`.

## Compiler/SemanticIR Evidence Policy

Compiler/SemanticIR evidence may be referenced as read-only source evidence in a
future proof-local projection route.

Allowed uses:

- locate `if_expr` nodes;
- identify `condition`, `then_branch`, and `else_branch`;
- identify branch labels and latent branch expression;
- cite resolved type and expression kind;
- cite static refs/deps as explanatory-only metadata.

Forbidden uses:

- mutate SemanticIR schema;
- add `branch_intention` fields to SemanticIR;
- add projection fields to `.igapp`;
- treat static refs/deps as runtime dependency/cache authority;
- treat compiler evidence as proof that a latent branch executed.

## Execution-Summary Evidence Policy

Execution-summary evidence may be referenced as read-only source evidence for
actual-path observations only.

Allowed uses:

- observed condition value;
- actual selected branch;
- actual output summary;
- frozen input snapshot source;
- proof-owned RuntimeSmoke or experiment summary citation.

Forbidden uses:

- latent branch execution evidence;
- mutation of RuntimeSmoke result shape;
- mutation of CompilerResult or CompilationReport;
- mutation of receipts or CompatibilityReport;
- public runtime/counterfactual support claims;
- production observation claims.

Execution-summary evidence must be treated as a citation source, not as a new
report surface.

## Emitted Branch-Intention Evidence Requirement

For any future source-backed Level 2 proof, emitted or derived branch-intention
evidence should exist before projection rerun.

This does not require live compiler emission. Acceptable first route:

```text
proof harness reads emitted SemanticIR / TypeChecker proof output
  -> derives a proof-local branch_intention evidence packet
  -> dry-run projection references that packet by digest
```

Unacceptable first route:

```text
projection directly invents branch_intention refs by hand
```

The derived branch-intention packet remains proof-local and non-canonical unless
a later schema/report/API gate says otherwise.

## Minimum Link / Trace Shape

A future source-backed projection should link these three refs:

```json
{
  "source_branch_intention_ref": {
    "kind": "source_branch_intention_ref",
    "source_kind": "proof_derived_from_semanticir",
    "source_digest": "sha256:...",
    "if_expr_id": "if:...",
    "branch_label": "then",
    "branch_role": "latent"
  },
  "input_snapshot_ref": {
    "kind": "input_snapshot_ref",
    "source_kind": "proof_local_frozen_packet",
    "digest": "sha256:..."
  },
  "premise_set_ref": {
    "kind": "counterfactual_premise_set_ref",
    "digest": "sha256:..."
  },
  "evidence_trace": [
    {
      "kind": "semanticir_source",
      "digest": "sha256:...",
      "authority": "read_only"
    },
    {
      "kind": "execution_summary_source",
      "digest": "sha256:...",
      "authority": "read_only"
    }
  ]
}
```

Every linked ref must preserve:

```text
dependency_authority: false
cache_authority: false
report_authority: false
runtime_readiness_authority: false
public_claim: false
```

## Forbidden Promotion Paths

The source/evidence boundary must not be used to promote Level 2 into:

- SemanticIR schema;
- TypeChecker schema;
- RuntimeSmoke output contract;
- CompilerResult field;
- CompilationReport field;
- receipt field;
- CompatibilityReport field;
- `.igapp` artifact schema;
- public API/CLI object;
- release evidence rewrite;
- production runtime behavior;
- Spark evidence or demo behavior.

Any of those promotions requires a separate gate with its own proof and pressure
review.

## Required Answers

| Question | Answer |
| --- | --- |
| Do hand-authored fixtures remain acceptable? | Yes, but only for concept proof / Tier 0. Future source-backed proof should not rely on them as the sole source. |
| Should future Level 2 proof require emitted/compiler-backed source? | Yes. It should derive proof-local branch-intention evidence from emitted SemanticIR/TypeChecker output or accepted execution summaries. |
| Can `input_snapshot_ref` be proof-local frozen input packet? | Yes, preferred. |
| Can `input_snapshot_ref` be a compiler artifact? | No, not by itself; compiler artifacts provide structure, not runtime values. |
| Can `input_snapshot_ref` be an execution summary? | Yes, if proof-owned, frozen, read-only, and digest-addressed. |
| Can `input_snapshot_ref` remain unresolved? | Only for structural/refusal projections; not for value-producing projection. |
| May `premise_set` use assumptions-shaped refs? | Yes, as proof-local premise labels only; not PROP-032 branch syntax or receipt semantics. |
| Do SemanticIR/schema/report/result/receipt changes remain closed? | Yes. |
| Does live runtime non-selected branch evaluation remain closed? | Yes. |
| Do public/API/Spark claims remain closed? | Yes. |

## Recommended Next Route

Open a proof-authorization review for a source-backed Level 2 projection proof,
not implementation.

Candidate proof route:

```text
Track: branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
Write scope:
  experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/**
  docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md
```

Minimum proof matrix:

- compile or load proof-owned source to emitted SemanticIR / TypeChecker output;
- derive proof-local branch-intention evidence from emitted output;
- digest-address `source_branch_intention_ref`;
- use proof-local frozen `input_snapshot_ref`;
- optionally cite execution-summary evidence for actual condition/branch;
- produce `projected_value` for a pure latent branch;
- produce `projected_failure` for unresolved snapshot, effect/escape, and
  `tbackend_read`;
- prove no mutation to SemanticIR schema, reports, receipts, RuntimeSmoke,
  CompilerResult, CompilationReport, `.igapp`, public API/CLI, Spark, or
  runtime behavior;
- preserve all authority fields false.

## Recommendation

Accept this source/evidence boundary design.

The next route should be a proof-local source-backed authorization review. It
should require proof-derived branch-intention evidence and digest-addressed input
snapshots, while keeping all live/report/public/runtime surfaces closed.

## Closed Surfaces

- Code implementation.
- Parser/grammar/source syntax.
- Branch-level `uses assumptions`.
- TypeChecker/SemanticIR schema mutation.
- Runtime/evaluator/RuntimeSmoke behavior.
- Live non-selected branch evaluation.
- Effect execution, external IO, persistence, Ledger/TBackend live reads.
- Dependency/cache authority.
- CompilationReport / CompilerResult / receipt / CompatibilityReport mutation.
- `.igapp` artifact schema or goldens.
- Spec-body promotion.
- Public API/CLI.
- Release evidence rewrite or public demo/stable/production/all-grammar claims.
- Spark data, fixtures, ids, integration, or demo behavior.

