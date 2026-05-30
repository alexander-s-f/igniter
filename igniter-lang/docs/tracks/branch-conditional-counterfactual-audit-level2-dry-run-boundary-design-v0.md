# Branch Conditional Counterfactual Audit Level 2 Dry-Run Boundary Design v0

Card: S3-R208-C1-D  
Agent: [Compiler/Grammar Expert]  
Role: compiler-grammar-expert  
Track: branch-conditional-counterfactual-audit-level2-dry-run-boundary-design-v0  
Route: UPDATE  
Depends on: S3-R207-C4-S

## Purpose

Design the Level 2 counterfactual dry-run boundary for expression-level
`if_expr`: whether Igniter-Lang can describe "what would have happened" for a
latent branch without mutating actual runtime results, public reports,
cache/dependency authority, or production behavior.

This is design-only. It authorizes no proof, implementation, runtime behavior,
report/result shape, public API/CLI, release claim, or production claim.

## Neighbor Awareness

Affected neighbor roles:

- Research Agent: would own any future proof-local Level 2 fixture.
- Runtime / Bridge owners: would own isolation, IO refusal, and runtime-policy
  pressure.
- Spec/Status Curator: would own any later spec/body promotion.
- Assumptions owner: would own any premise-capsule or PROP-032 relationship
  change.

This track speaks only as `[Compiler/Grammar Expert]`.

## Inputs Read

- `docs/tracks/stage3-round207-status-curation-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-boundary-decision-v0.md`
- `docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/spec/README.md`
- `docs/dev/semantic-governance-heat-map.md`

## Existing Boundary

R207 accepted Level 1 vocabulary only:

```text
Runtime is lazy.
Audit is aware.
```

Level 1 explains actual and latent branches without evaluating latent branches.
`branch_intention` is proof-local static audit vocabulary. The proof-local
descriptor `if_expr_branch_intention` is non-canonical. Level 2 dry-run remains
closed.

## Level 2 Concept Verdict

Level 2 is conceptually valid for Igniter-Lang, but only as an explicit isolated
counterfactual projection route.

It is not normal runtime behavior. It is not a public runtime feature. It is not
a report/result/receipt/CompatibilityReport field. It is not cache/dependency
authority. It is not production behavior.

The core idea is:

```text
Level 1: describe the latent branch without evaluation.
Level 2: explicitly evaluate a latent branch inside an isolated dry-run context,
         producing a counterfactual projection trace that cannot affect actual
         runtime artifacts.
```

## Vocabulary

Recommended guarded Level 2 vocabulary:

| Term | Status | Meaning |
| --- | --- | --- |
| `counterfactual_dry_run` | Candidate Level 2 term | Explicit isolated evaluation of a latent branch under declared premises. |
| `dry_run_projection` | Candidate Level 2 term | Non-authoritative result envelope for the dry-run. |
| `dry_run_trace` | Candidate Level 2 term | Evaluation trace inside the isolated dry-run context. |
| `assumed_condition` | Candidate Level 2 term | Condition value supplied by the dry-run premise set, not observed actual runtime. |
| `projected_branch` | Candidate Level 2 term | Branch selected in dry-run context. |
| `projected_value` | Candidate Level 2 term | Value produced by an isolated pure dry-run, not actual runtime output. |
| `projected_failure` | Candidate Level 2 term | Failure/refusal observed in the isolated dry-run, not actual runtime failure. |
| `premise_set` | Candidate Level 2 term | Explicit assumptions and inputs used by the dry-run. |
| `isolation_guarantee` | Required boundary term | Assertion that actual runtime artifacts were not mutated. |
| `no_authority` | Required boundary term | Assertion that the projection carries no cache/report/public/production authority. |

Level 1 terms remain valid inputs to Level 2:

- `branch_intention`;
- `actual_branch`;
- `latent_branch`;
- `non_execution_guarantee`;
- `static_branch_metadata`.

Level 2 should not use R207 forbidden `would_*` vocabulary as canonical field
names.

## Non-Vocabulary / Blocked Terms

These remain blocked as positive canonical vocabulary:

```text
would_result
would_output
would_fail
counterfactual result
counterfactual output
counterfactual failure
latent runtime value
latent runtime failure
```

Reason: those phrases blur projection with fact. Level 2 needs guarded terms
such as `projected_value`, `projected_failure`, and `dry_run_trace` because the
result is produced under an explicit premise set and isolation boundary.

The phrase "what would have happened" may appear only as explanatory prose. It
must not become a field name, result status, public claim, or report authority.

## What Level 2 Produces

Level 2 should be modeled as a dry-run trace plus projection, not as an alternate
actual result.

Candidate shape, proof-local only:

```json
{
  "kind": "counterfactual_dry_run_projection",
  "level": 2,
  "source_branch_intention_ref": "proof-local-ref",
  "premise_set": {
    "assumed_condition": true,
    "assumption_refs": ["proof-local-premise"],
    "input_snapshot_ref": "proof-local-snapshot"
  },
  "projected_branch": "then",
  "dry_run_trace": [],
  "projected_value": null,
  "projected_failure": null,
  "isolation": {
    "actual_result_mutated": false,
    "reports_mutated": false,
    "receipts_mutated": false,
    "cache_mutated": false,
    "external_io_performed": false,
    "production_authority": false
  },
  "authority": {
    "dependency_authority": false,
    "cache_authority": false,
    "report_authority": false,
    "runtime_readiness_authority": false,
    "public_claim": false
  }
}
```

This shape is not canonical. It is a candidate proof-local envelope for a future
proof route only.

## Invocation Boundary

Level 2 must be explicitly invoked.

Allowed future invocation sources, in order of preference for first proof:

| Source | Status | Notes |
| --- | --- | --- |
| Proof-local harness request | Preferred first route | No runtime/API/report integration. |
| Internal tool request | Future design candidate | Requires tool authority and no public API widening. |
| Public API/CLI flag | Closed | Needs separate public API/CLI design and authority. |
| Automatic runtime branch evaluation | Rejected for v0 | Violates lazy runtime boundary. |
| Production/runtime automatic dry-run | Closed | Requires separate runtime/production gate. |

First proof, if opened later, should use a proof-local harness and hand-authored
or proof-owned SemanticIR-shaped fixtures.

## Isolation Boundary

Level 2 dry-run must not mutate:

- actual runtime result;
- actual selected-branch output;
- runtime receipts;
- CompilationReport;
- CompilerResult;
- CompatibilityReport;
- `.igapp` artifacts;
- cache state;
- dependency authority;
- public report/status;
- external systems;
- production data.

Any future proof must assert these as explicit negative checks.

## Effect and External IO Policy

Initial Level 2 must be pure-only.

| Surface | Level 2 v0 policy |
| --- | --- |
| `literal` / `ref` / pure arithmetic-like expressions | Candidate allowed in proof-local harness. |
| `if_expr` nested inside dry-run branch | Candidate allowed recursively under the same isolation rules. |
| `apply` | Allowed only if proof-local function is explicitly pure and deterministic; otherwise refusal. |
| `field_access` | Candidate allowed on proof-local immutable values. |
| `escape` / effect / external call | Refuse; do not simulate by default. |
| `privileged` / `irreversible` behavior | Refuse. |
| Runtime callbacks | Refuse unless a later proof designs an isolated pure callback registry. |
| Persistence / network / filesystem side effects | Refuse. |
| Ledger/TBackend live read/write | Refuse. |

Refusal in dry-run is a `projected_failure` / dry-run refusal inside the
projection envelope, not an actual runtime failure.

## `tbackend_read` Policy

`tbackend_read` must remain closed for first Level 2 dry-run proof.

Allowed first-slice treatment:

- record `tbackend_read` as static branch metadata from Level 1;
- if dry-run evaluation reaches it, refuse with a proof-local projected failure;
- do not perform live temporal/backend reads;
- do not bind Ledger/TBackend;
- do not claim temporal runtime readiness.

Future expansion could consider a frozen in-memory proof backend snapshot, but
that needs a separate temporal/runtime design gate because it risks looking like
runtime temporal evaluation.

## Relationship to Assumptions

Assumptions are not strictly required for every dry-run, but every dry-run must
have an explicit `premise_set`.

Recommended rule:

- pure branch flip by `assumed_condition` may use a minimal premise set without
  assumptions;
- domain/world premise changes should cite assumptions-shaped labels;
- assumptions-shaped labels remain proof-local unless a PROP-032 amendment or
  new proposal accepts a canonical relationship.

No branch-level `uses assumptions` syntax opens here. PROP-032 is not amended by
this design.

## Relationship to Level 1

Level 2 must depend on Level 1 rather than replace it.

Level 1 gives:

- actual branch;
- latent branch;
- static branch metadata;
- non-execution guarantee for actual runtime;
- optional premise labels.

Level 2 may consume that Level 1 branch-intention record to choose which latent
branch to dry-run. The Level 2 dry-run does not invalidate the Level 1
non-execution guarantee because Level 1 describes the actual runtime path.

## Minimum Evidence Before Proof-Local Route

Before a proof-local Level 2 route opens, the authorization card should require:

| Evidence | Required proof |
| --- | --- |
| Explicit invocation | Dry-run only occurs when proof harness asks for it. |
| Latent isolation | Actual runtime result and selected branch output remain unchanged. |
| Pure success case | A latent pure branch can produce `projected_value`. |
| Pure failure/refusal case | Unsupported expression produces `projected_failure`, not actual failure. |
| Effect refusal | Effect/external IO branch refuses without side effects. |
| `tbackend_read` refusal | Temporal/backend read refuses or remains structural-only. |
| Nested `if_expr` | Recursive dry-run follows same isolated rules. |
| Premise set | Every projection records `assumed_condition` and input/premise source. |
| Authority zeros | Cache/dependency/report/runtime/public authority all false. |
| Closed-surface scan | No code/runtime/report/API/spec/public mutation outside proof scope. |

Suggested future proof path, if authorized later:

```text
experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/**
docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md
```

## Minimum Evidence Before Spec-Body Promotion

Spec-body promotion should wait for at least:

- accepted Level 2 proof-local concept proof;
- independent pressure review that forbidden authority did not leak;
- clear dry-run diagnostic/refusal vocabulary;
- decision on whether projection envelope remains proof-local or becomes a
  canonical artifact;
- explicit no-report/no-result/no-receipt policy or a separate report-shape
  proposal;
- temporal/runtime review for `tbackend_read` if any non-refusal behavior is
  proposed;
- public API/CLI non-claim review.

Until then, Level 2 should remain track-only design language, not spec-body
canon.

## Required Answers

| Question | Answer |
| --- | --- |
| Is Level 2 dry-run conceptually valid for Igniter-Lang? | Yes, as explicit isolated counterfactual projection, not normal runtime. |
| May Level 2 evaluate latent branches in an isolated proof context? | Yes, after a separate proof authorization, for pure/refusal cases only. |
| May live runtime evaluate latent branches? | No. Live runtime remains lazy; selected branch only. |
| Can dry-run output be called `would_result` or `would_fail`? | No as canonical vocabulary. Use guarded terms like `projected_value`, `projected_failure`, and `dry_run_trace`. |
| Can dry-run carry dependency/cache authority? | No for v0. It may record explanatory refs only. |
| Can dry-run mutate reports/receipts/CompatibilityReport? | No. Any report/result/receipt shape requires a separate gate. |
| Are assumptions required as dry-run premises? | No, but every dry-run needs an explicit `premise_set`; assumptions-shaped labels are the candidate capsule for domain/world premises. |
| May a proof-local Level 2 concept proof open next? | Yes, if separately authorized with the minimum evidence matrix above. |

## Recommendation

Accept this Level 2 boundary design and route next to a proof-local concept proof
authorization review, not direct implementation.

Recommended C3-A stance:

```text
accept design;
authorize later proof-local concept proof review only;
keep runtime/report/API/spec-body/public surfaces closed.
```

## Blockers Before Implementation

Implementation must not open before:

- proof-local concept proof passes;
- isolation policy is pressure-reviewed;
- dry-run diagnostic/refusal vocabulary is accepted;
- pure function registry or evaluator boundary is chosen;
- effect/escape refusal policy is accepted;
- `tbackend_read` policy is accepted by temporal/runtime owners;
- report/result/receipt/CompatibilityReport shape is either explicitly closed
  or separately designed;
- public API/CLI remains closed or receives separate authority.

## Closed Surfaces

- Code implementation.
- Proof implementation in this card.
- Parser/grammar/source syntax.
- Branch-level `uses assumptions`.
- Runtime/evaluator/RuntimeSmoke behavior.
- Live non-selected branch evaluation.
- Effect execution, external IO, persistence, Ledger/TBackend live reads.
- Dependency/cache authority.
- CompilationReport / CompilerResult / receipt / CompatibilityReport mutation.
- `.igapp` artifact schema.
- Spec-body promotion.
- Public API/CLI.
- Release evidence or public demo/stable/production/all-grammar claims.
- Spark data, fixtures, ids, integration, or demo behavior.

