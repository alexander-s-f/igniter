# Branch Conditional Counterfactual Audit Level 2 Source-Backed Proof Authorization Review v0

Card: S3-R211-C1-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-source-backed-proof-authorization-review-v0  
Route: UPDATE  
Status: done / authorized-bounded-proof-local-source-backed-proof  
Date: 2026-05-30

Depends on:
- S3-R210-C5-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round210-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md`

---

## Decision

Decision:

```text
authorize bounded proof-local source-backed Level 2 counterfactual dry-run proof
authorize C2-I in this round
authorize only experiment-local proof harness and proof-local evidence packets
do not authorize live implementation
do not authorize lib/runtime/report/result/receipt/cache/API/Spark/public authority
```

R210 established a sufficient source/evidence boundary for a first
source-backed proof. The next proof may derive branch-intention evidence from
proof-owned SemanticIR/TypeChecker output, with proof-owned `.igapp` contract
JSON allowed as a secondary structural source. It must digest-address all source
refs, freeze input evidence, make `premise_set` explicit, and preserve
no-authority semantics.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
```

---

## Authorized Next Card

```text
Card: S3-R211-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
Route: UPDATE
Depends on:
- S3-R211-C1-A
```

Allowed write scope:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md
```

Read-only / must remain unchanged:

```text
igniter-lang/lib/**
igniter-lang/docs/spec/**
igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
accepted R209/R210 docs and evidence, except read-only citation
```

No other file writes are authorized.

---

## Source Artifact Policy

Source priority:

| Priority | Source | Status |
| --- | --- | --- |
| Primary | Proof-owned SemanticIR / TypeChecker output | Required where available. Read-only structural citation only. |
| Secondary | Proof-owned `.igapp` contract JSON | Allowed when primary source is insufficient or unavailable. Read-only structural source only. |
| Optional citation | Proof-owned execution-summary evidence | Actual-path context only; not latent execution authority. |
| Legacy fallback | Hand-authored fixture | Allowed only as Tier 0 comparison label or fallback annotation; not sole proof authority. |

C2-I must not derive source authority from:

- `CompilerResult`;
- `CompilationReport`;
- receipt;
- `CompatibilityReport`;
- RuntimeSmoke result shape;
- cache/dependency tracker;
- live runtime observation;
- production data;
- Spark/API/CLI/public surfaces.

---

## Required Evidence Shapes

### `source_branch_intention_ref`

Required minimum shape:

```json
{
  "kind": "source_branch_intention_ref",
  "source_kind": "proof_derived_from_semanticir",
  "source_path": "experiments/.../source.json",
  "source_digest": "sha256:<hex>",
  "if_expr_id": "if:...",
  "branch_label": "then|else",
  "branch_role": "latent|actual",
  "derivation": "proof-local",
  "canonical": false,
  "authority": {
    "semanticir_schema_authority": false,
    "report_authority": false,
    "runtime_authority": false,
    "cache_authority": false,
    "public_claim": false
  }
}
```

Allowed `source_kind` values:

- `proof_derived_from_semanticir`;
- `proof_derived_from_typechecker`;
- `proof_derived_from_contract_json`;
- `proof_derived_from_execution_summary` for actual-path observations only.

Forbidden `source_kind` values:

- `compilation_report_field`;
- `compiler_result_field`;
- `receipt_field`;
- `compatibility_report_field`;
- `public_api_object`;
- `runtime_output`;
- `production_observation`.

### `input_snapshot_ref`

Required minimum shape:

```json
{
  "kind": "input_snapshot_ref",
  "source_kind": "proof_local_frozen_packet",
  "path": "experiments/.../input_snapshot.json",
  "digest": "sha256:<hex>",
  "mutable": false,
  "authority": {
    "runtime_input_authority": false,
    "dependency_authority": false,
    "cache_authority": false,
    "report_authority": false,
    "production_authority": false,
    "public_claim": false
  }
}
```

Compiler artifacts alone are not sufficient for value-producing projections.
Unresolved snapshots are allowed only for structural/refusal projections.

### `premise_set`

Required minimum shape:

```json
{
  "kind": "counterfactual_premise_set",
  "assumed_condition": true,
  "assumed_condition_source": "explicit_proof_request",
  "input_snapshot_ref": { "...": "digest-addressed ref" },
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

`assumed_condition_source` is required.

Allowed values:

- `explicit_proof_request`;
- `execution_summary_observation`.

`assumption_refs` may be assumptions-shaped refs only as proof-local premise
labels. They do not create branch-level `uses assumptions`, do not amend
PROP-032, and do not become receipt `assumption_refs`.

---

## Required Digest Convention

All source refs must use:

```text
sha256:<hex>
```

C2-I must digest-address:

- every source artifact used in `evidence_trace`;
- `source_branch_intention_ref`;
- `input_snapshot_ref`;
- `premise_set_ref`;
- generated source-backed projection summary.

Digest values must be stable across repeat proof runs on identical source
inputs.

---

## Required Proof Matrix

C2-I must satisfy:

| ID | Required proof |
| --- | --- |
| SB-1 | Source artifact loaded/read as proof-owned evidence only. |
| SB-2 | `source_branch_intention_evidence_packet` derived from source artifact, with `canonical:false`. |
| SB-3 | `source_branch_intention_ref` is structured and digest-addressed. |
| SB-4 | Frozen `input_snapshot_ref` is digest-addressed and no-authority. |
| SB-5 | `premise_set_ref` is digest-addressed, includes `assumed_condition`, required `assumed_condition_source`, and authority false fields. |
| SB-6 | Pure latent branch produces `projected_value` with `projected_value_is_not_actual_output:true`. |
| SB-7 | Unresolved snapshot produces `projected_failure`, not actual failure. |
| SB-8 | Effect/escape/external IO expression is refused; no side effect. |
| SB-9 | `tbackend_read` is refused; no live Ledger/TBackend read. |
| SB-10 | Nested `if_expr` projection remains lazy inside isolated dry-run. |
| SB-11 | Execution-summary citation, if present, remains actual-path read-only context only. |
| SB-12 | Hand-authored fixture is absent or clearly marked Tier 0 legacy fallback, not sole proof authority. |
| SB-13 | Forbidden vocabulary scan passes. |
| SB-14 | Source/digest chain is complete and stable. |
| SB-15 | Closed-surface scan proves no `lib/**`, spec, report/API, RuntimeSmoke, Spark/API/CLI, public claim, or production mutation. |

C2-I may add sub-checks, but it must report all `SB-*` results in the proof
track and summary JSON.

---

## Command Matrix

Required:

```bash
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
```

C2-I may run read-only source/digest/vocabulary/closed-surface scans.

Optional read-only comparison:

```bash
ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
```

The optional comparison must not mutate accepted R209 outputs.

---

## Required Answers

| Question | Answer |
| --- | --- |
| May C2-I begin in this round? | Yes. |
| Is proof-owned SemanticIR/TypeChecker evidence required? | Yes, where available; it is the primary source. |
| Is secondary proof-owned `.igapp` contract JSON allowed? | Yes, as secondary structural source when primary evidence is insufficient or unavailable. |
| May current hand-authored fixtures be used? | Only as Tier 0 comparison/fallback annotations, never as sole proof authority. |
| May execution-summary evidence be cited? | Yes, narrowly as actual-path read-only context only. |
| Must `source_branch_intention_ref`, `input_snapshot_ref`, and `premise_set_ref` use `sha256:<hex>`? | Yes. |
| Is `assumed_condition_source` required? | Yes; allowed values are `explicit_proof_request` and `execution_summary_observation`. |
| Does report/result/receipt/cache/API/Spark/public authority remain closed? | Yes. |
| Does live runtime remain lazy and non-selected branch live evaluation remain closed? | Yes. |

---

## Closed Surfaces

Remain closed during C2-I:

- live implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema mutation;
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
- release evidence rewrite or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Compact Handoff

S3-R211-C2-I is authorized as a bounded proof-local source-backed Level 2 proof.
It must derive branch-intention evidence from proof-owned SemanticIR/TypeChecker
output where available, may use proof-owned contract JSON as secondary
structural source, and must produce digest-addressed source refs, frozen input
snapshot refs, explicit premise_set refs, and a no-authority projection
envelope. It must preserve live runtime laziness and all report/result/cache/API/
Spark/public closed surfaces.
