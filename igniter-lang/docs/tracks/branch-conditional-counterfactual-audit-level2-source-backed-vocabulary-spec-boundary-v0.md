# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Spec Boundary v0

Card: S3-R212-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-boundary-v0
Route: UPDATE
Depends on: S3-R211-C5-S

## Purpose

Design the documentation boundary for the accepted source-backed Level 2
proof-local evidence vocabulary: what internal docs/status may name, what
remains non-canonical, and how to describe source-backed Level 2 without
claiming public runtime/report/API support or live non-selected branch
evaluation.

This card is design-only. It edits no docs/spec and authorizes no proof,
implementation, release execution, or public claim.

## Neighbor Awareness

Affected neighbor roles:

- Research Agent: owns proof evidence naming and future proof-owned summaries.
- Spec/Status Curator: owns any later low-authority docs/status sync.
- Assumptions owner: owns PROP-032 premise-capsule wording.
- Runtime / Release owners: own public/runtime/report/API claim fences.

This track speaks only as `[Compiler/Grammar Expert]`.

## Inputs Read

- `docs/tracks/stage3-round211-status-curation-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`
- `docs/discussions/branch-conditional-counterfactual-audit-level2-source-backed-proof-pressure-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/current-status.md` current R211 wording as read-only context.

## Current Fixed Point

R211 accepts:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
```

Meaning:

- branch-intention evidence is derived from proof-owned SemanticIR-shaped source
  artifacts;
- refs are SHA-256 digest-addressed;
- input snapshots are frozen;
- premise sets are explicit;
- projection envelopes carry no-authority disclaimers;
- generated output remains proof-local and non-canonical.

R211 does not accept:

- public counterfactual audit support;
- live runtime non-selected branch evaluation;
- report/result/receipt/CompatibilityReport shape;
- SemanticIR/TypeChecker schema changes;
- public API/CLI, release, Spark, or production behavior.

## Vocabulary Table

### Level 1 Vocabulary

| Term | Status | Docs use |
| --- | --- | --- |
| `branch_intention` | Accepted low-authority docs vocabulary | Static audit vocabulary for actual/latent `if_expr` branches. |
| `if_expr_branch_intention` | Proof-local descriptor only | May be named only as non-canonical proof evidence. |
| `actual_branch` | Accepted Level 1 vocabulary | Selected branch in actual path. |
| `latent_branch` | Accepted Level 1 vocabulary | Non-selected branch, not evaluated by live runtime. |
| `non_execution_guarantee` | Accepted Level 1 boundary term | Guarantees latent branch did not run in actual runtime path. |

### Level 2 Vocabulary

| Term | Status | Docs use |
| --- | --- | --- |
| `counterfactual_dry_run` | Accepted proof-local Level 2 vocabulary | Use only with proof-local / isolated qualifiers. |
| `dry_run_projection` | Accepted proof-local Level 2 vocabulary | Projection envelope, not actual result/report. |
| `projected_value` | Accepted proof-local Level 2 field vocabulary | Value projected in isolated proof context; not actual output. |
| `projected_failure` | Accepted proof-local Level 2 field vocabulary | Dry-run refusal/failure; not actual runtime failure. |
| `premise_set` | Accepted proof-local Level 2 vocabulary | Explicit dry-run premise record with no authority. |
| `assumed_condition` | Accepted proof-local Level 2 vocabulary | Condition value supplied by explicit proof request. |
| `assumed_condition_source` | Accepted proof-local Level 2 vocabulary | Required source, currently `explicit_proof_request` or `execution_summary_observation`. |

### Source-Backed Level 2 Vocabulary

| Term | Status | Docs use |
| --- | --- | --- |
| `source-backed proof-local Level 2 counterfactual dry-run evidence` | Accepted internal vocabulary | Preferred exact phrase for R211 evidence. |
| `proof-owned SemanticIR-shaped source artifact` | Accepted internal vocabulary | Emphasize proof-owned and non-canonical. |
| `source_branch_intention_ref` | Accepted proof-local ref vocabulary | Digest-addressed citation ref, not CompilerResult/CompilationReport field. |
| `source_branch_intention_evidence_packet` | Accepted proof-local vocabulary | Derived evidence packet; `canonical:false`. |
| `input_snapshot_ref` | Accepted proof-local ref vocabulary | Frozen input snapshot citation; no runtime/production authority. |
| `premise_set_ref` | Accepted proof-local ref vocabulary | Digest-addressed premise citation. |
| `execution_summary_citation` | Accepted proof-local vocabulary | Actual-path read-only context only. |
| `sha256:<hex>` | Accepted digest convention | Required source/digest chain convention. |

## Forbidden / Over-Broad Vocabulary

Forbidden as positive canonical vocabulary, public feature label, projection
field name, projection value, or release/public claim:

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

Also too broad without qualifiers:

```text
counterfactual audit support
runtime counterfactual support
public counterfactual support
counterfactual runtime
```

Allowed replacement wording:

```text
proof-local source-backed Level 2 counterfactual dry-run evidence
isolated dry-run projection evidence
source-backed proof-local projection
```

## Negative Disambiguation Notes

R211 accepts that metadata `note` fields may name otherwise forbidden terms only
in a negative disambiguation context, for example:

```text
not latent execution evidence
```

Policy:

- allowed only in explanatory metadata notes, pressure docs, or track docs;
- must be visibly negative or contrastive;
- must not appear as projection field names or projection values;
- must not appear as feature labels;
- must not appear in public/release/support claims;
- should be excluded from machine-readable authority fields.

Recommended scan rule for future docs-sync:

```text
forbidden terms may appear only in explicit "forbidden", "non-claim",
"negative disambiguation", or "closed surface" sections.
```

## Internal Docs / Status Wording

Recommended wording:

```text
R211 accepts source-backed proof-local Level 2 counterfactual dry-run evidence:
proof-owned SemanticIR-shaped source artifacts, frozen input snapshots, explicit
premise sets, SHA-256 digest-addressed refs, and no-authority projection
envelopes. This is not public counterfactual audit support, not runtime support,
not report/result/receipt shape, and not live non-selected branch evaluation.
```

Short form:

```text
source-backed proof-local Level 2 evidence; non-canonical; no runtime/report/API authority
```

Avoid:

```text
counterfactual audit support landed
dry-run result support
runtime can evaluate latent branches
source-backed branch intentions are SemanticIR
```

## Spec-Body Stance

Do not edit spec body chapters yet.

Reason:

- source-backed Level 2 is accepted proof-local evidence, not language/runtime
  canon;
- projection envelopes are not SemanticIR, CompilationReport, receipt, or public
  API schema;
- live runtime still does not evaluate non-selected branches;
- source artifacts are proof-owned SemanticIR-shaped JSON, not canonical
  SemanticIR schema.

Spec-body promotion requires a separate gate after at least:

- stable non-canonical vocabulary appears in low-authority docs;
- source/ref vocabulary pressure review passes;
- a decision exists for whether projection envelopes remain proof-local forever
  or need a canonical artifact home;
- report/result/receipt/API surfaces are either explicitly designed or still
  explicitly closed.

## PROP-032 Stance

PROP-032 remains premise-capsule-only and unamended.

Allowed wording:

```text
Assumptions-shaped premise refs may appear in proof-local `premise_set` records
as explanatory labels.
```

Forbidden implication:

- no branch-level `uses assumptions`;
- no PROP-032 grammar extension;
- no receipt `assumption_refs` change;
- no runtime assumption injection;
- no cross-module assumption sharing;
- no evidence-list validation expansion.

## Target Set For Possible Docs Sync

A bounded docs-sync route may open next. Recommended target set:

| Target | Recommendation | Reason |
| --- | --- | --- |
| `docs/current-status.md` | Allowed if status curator wants a compact wording polish | Already has R211 detail; only tighten wording if needed. |
| `docs/dev/semantic-governance-heat-map.md` | Allowed | Add/update low-authority row for source-backed Level 2 proof-local evidence. |
| `docs/spec/README.md` | Allowed | Add coverage/index pointer labeled proof-local / non-canonical / held. |
| New track doc | Required | Record docs-sync result and scans. |
| `docs/language-spec.md` | Held | Too high-authority for this step. |
| `docs/spec/ch2-source-surface.md` | Held | No grammar/source syntax change. |
| `docs/spec/ch5-compiler-pipeline.md` | Held | No compiler pipeline/schema authority. |
| `docs/spec/ch6-semanticir.md` | Held | No SemanticIR schema authority. |
| `docs/spec/ch7-runtime.md` | Held | No runtime support authority. |
| `docs/proposals/PROP-032-assumptions-block-v0.md` | Held | No PROP amendment. |
| Public README / API / release docs | Closed | No public support claim. |

Recommended next route class:

```text
docs-only low-authority vocabulary sync
```

not:

```text
spec-body sync
runtime/report/API design
implementation
release evidence update
```

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is "source-backed Level 2 proof-local evidence" accepted as internal vocabulary? | Yes. Prefer the full phrase `source-backed proof-local Level 2 counterfactual dry-run evidence`. |
| Is "counterfactual audit support" still too broad? | Yes. It implies public/runtime support unless heavily qualified; avoid it as a positive claim. |
| Does "dry-run result" remain forbidden? | Yes. Use `dry_run_projection`, `projected_value`, or `projected_failure`. |
| May Level 2 source-backed vocabulary appear in current-status? | Yes, with proof-local/non-canonical/no-authority qualifiers. |
| May it appear in tracks? | Yes. |
| May it appear in docs index / spec README? | Yes, as a proof-local coverage pointer only. |
| May it appear in spec body chapters? | Not yet. Body chapters remain held. |
| Does PROP-032 remain premise-capsule-only and unamended? | Yes. |
| Do runtime/report/API/public/Spark claims remain closed? | Yes. |

## Recommended Next Route

Open a bounded docs-sync authorization/review route with this target set:

```text
docs/current-status.md                optional polish only
docs/dev/semantic-governance-heat-map.md
docs/spec/README.md
docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

Required checks for that route:

- exact target set compliance;
- forbidden vocabulary appears only in forbidden/negative/non-claim contexts;
- no spec-body chapter edits;
- no PROP-032 edit;
- no public docs/release docs edit;
- no runtime/report/API claim;
- no code/experiment mutation.

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
- `language-spec.md` promotion.
- PROP-032 amendment.
- Public API/CLI.
- Release evidence rewrite or public demo/stable/production/all-grammar claims.
- Spark data, fixtures, ids, integration, or demo behavior.
