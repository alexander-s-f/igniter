# Branch Conditional Counterfactual Audit Lane Consolidation Boundary v0

Card: S3-R214-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-lane-consolidation-boundary-v0
Route: UPDATE
Depends on: S3-R213-C5-S

## Purpose

Design the internal counterfactual audit lane consolidation boundary now that
Level 1 branch intention, Level 2 proof-local dry-run, and source-backed Level 2
evidence are all documented in low-authority internal surfaces.

This is design-only. It authorizes no implementation, no spec-body edits, no
runtime/report/API/public claims, and no Spark behavior.

## Neighbor Awareness

Affected neighbor roles:

- Spec/Status Curator: owns any future internal lane map or status/index sync.
- Research Agent: owns future proof evidence and regression matrices.
- Assumptions owner: owns premise-capsule and PROP-032 boundary language.
- Runtime / Bridge / Release owners: own runtime, report/API, public, and
  market-facing claim boundaries.

This track speaks only as `[Compiler/Grammar Expert]`.

## Inputs Read

- `docs/tracks/stage3-round213-status-curation-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`
- `docs/dev/semantic-governance-heat-map.md`
- `docs/spec/README.md`

## Current Fixed Point

The lane has three accepted proof/documentation steps:

1. Level 1 static branch intention is discoverable as proof-local static audit
   vocabulary.
2. Level 2 dry-run concept proof shows isolated proof-local projections can
   produce `projected_value` or `projected_failure` with authority fields false.
3. Source-backed Level 2 proof shows those projections can be backed by
   proof-owned SemanticIR-shaped artifacts, frozen input snapshots, structured
   SHA-256 refs, and explicit premise sets.

The governing phrase is now:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
```

## Compact Lane Model

| Level | Name | Accepted evidence | Evaluation? | Authority |
| --- | --- | --- | --- | --- |
| L0 | `if_expr` compiler/runtime baseline | R190 compiler support; later proof-runtime/evaluator evidence | Live runtime evaluates selected branch only | Internal compiler/runtime proof evidence; no public all-grammar claim |
| L1 | Static branch intention | R205/R207 `branch_intention` docs vocabulary | No latent evaluation | Proof-local static audit only |
| L2a | Isolated dry-run projection concept | R209 `counterfactual_dry_run_projection` proof | Yes, but only experiment-local isolated projection | Proof-local; no report/runtime/cache/API authority |
| L2b | Source-backed isolated projection | R211/R213 source-backed evidence | Yes, but only experiment-local isolated projection from sourced evidence | Proof-local, digest-addressed, non-canonical |
| L3 | Route-map / artifact-home decision | Not opened | Not applicable | Future design only before runtime/report/API design |
| L4 | Runtime/report/API design | Closed | Not authorized | Requires separate lane-map and authority decisions |

## Relationship Between Levels

The levels should not collapse semantically:

- L1 explains latent branch structure without evaluation.
- L2a proves isolated projection mechanics using proof-local fixtures.
- L2b proves source-backed projection evidence using proof-owned artifacts and
  digest chains.

However, the levels should be consolidated operationally into one internal lane
map so future cards do not rediscover the same fences:

```text
Counterfactual Audit Lane
  L1  Static branch intention
  L2a Isolated projection concept
  L2b Source-backed isolated projection
  L3  Route map / artifact home / authority design
  L4  Runtime-report-API candidates
```

This is a lane consolidation, not a schema consolidation.

## Map Row Decision

Current Heat Map has two useful rows:

- `branch_intention` / `if_expr_branch_intention` for L1.
- `source_backed_dry_run_projection` for L2b.

Recommendation:

- Keep separate Heat Map rows for now.
- Add a future internal lane map that groups L1/L2a/L2b under one
  `Counterfactual Audit Lane` heading.
- Do not merge the rows into one Heat Map row until there is a canonical lane
  map with level definitions and route gates.

Reason: separate rows preserve proof maturity and prevent L2 source-backed
evidence from making L1 vocabulary look like runtime support. A lane map can
reduce drift without hiding differences.

## Route Map Requirement

A future route map is needed before any runtime/report/API design.

The route map should answer:

- Is there a canonical artifact home for projection envelopes, or do they remain
  proof-local forever?
- Is a report/result/receipt representation desired at all?
- Which owner decides runtime dry-run eligibility?
- What surfaces remain permanently non-public?
- What is the escalation path from proof-local evidence to internal tool support,
  if any?
- Does any user-facing claim ever become allowed, and under what release gate?

Without this map, a runtime/report/API design would be too easy to misread as
public counterfactual support.

## Assumptions Stance

Assumptions remain premise-capsule-only.

Accepted:

- assumptions-shaped refs may appear in proof-local `premise_set` records;
- they explain a premise behind a projection request;
- they remain labels unless a future PROP-032 amendment says otherwise.

Closed:

- branch-level `uses assumptions`;
- PROP-032 grammar extension;
- receipt `assumption_refs` mutation;
- runtime assumption injection;
- evidence-list validation expansion;
- assumptions as the whole counterfactual audit model.

## Source-Backed Evidence Stance

Source-backed evidence remains proof-local and non-canonical.

Accepted wording:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
```

Forbidden implication:

- source-backed evidence is not SemanticIR schema;
- `source_branch_intention_ref` is not CompilerResult or CompilationReport;
- digest-addressed refs are not artifact schema;
- `projected_value` is not actual output;
- `projected_failure` is not actual runtime failure;
- `dry_run_projection` is not runtime support.

## Market Pressure

Time-to-market risk is real.

The lane now has multiple proof and docs-sync layers. If every next step starts
by re-arguing vocabulary, the lane will slow down and drift. That is a product
risk, not just a documentation preference.

Proof methodology remains valuable:

- it prevented public/runtime/report/API claim inflation;
- it forced digest-addressed source evidence before explanation;
- it kept live runtime lazy;
- it protected effect, TBackend, cache, report, API, and Spark boundaries.

Consolidation should reduce future friction, not add ceremony. The next map
should be compact, route-oriented, and focused on preventing repeated boundary
reconstruction.

## Open Questions

| Question | Why it matters |
| --- | --- |
| Should projection envelopes ever get a canonical artifact home? | Determines whether L3 routes to schema design or permanent proof-local status. |
| Should report/result/receipt surfaces remain permanently closed for this lane? | Prevents accidental public support claims. |
| Is there an internal tool-only use case before runtime support? | Could satisfy market pressure without public/runtime exposure. |
| Should `tbackend_read` stay refused forever in dry-run projection? | Temporal/runtime owners must decide any non-refusal path. |
| Should L2a remain visible after L2b exists? | It may be useful as a conceptual proof layer but could be folded into lane history. |
| What evidence would justify public wording later, if any? | Release owners need a clear gate before public claims. |

## C4-A Decision Options

Recommended option: **accept consolidation boundary and route to internal lane
map design**.

| Option | Decision | Consequence |
| --- | --- | --- |
| Accept + route lane map | Preferred | Keeps Heat Map rows separate while creating one compact route map before runtime/report/API work. |
| Accept + hold | Safe | Leaves current docs as-is; future cards may keep reconstructing boundaries. |
| Conditional accept | Useful if Architect wants Bridge/Runtime review first | Adds review before route-map design. |
| Redirect to runtime/report/API design | Not recommended | Too early; risks claim and schema drift. |
| Merge Heat Map rows now | Not recommended | Hides maturity differences between L1 and L2b. |

## Recommended Next Route

Open a design-only internal lane map card:

```text
Track: branch-conditional-counterfactual-audit-internal-lane-map-v0
Write scope:
  docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-v0.md
Optional later low-authority sync:
  docs/current-status.md
  docs/dev/semantic-governance-heat-map.md
  docs/spec/README.md
```

The lane map should be compact and answer only:

- level definitions;
- accepted evidence anchors;
- allowed next routes;
- blocked promotion paths;
- owner handoffs;
- minimum gates before runtime/report/API design.

## Closed Surfaces

- Code implementation.
- Parser/grammar/source syntax.
- Branch-level `uses assumptions`.
- TypeChecker/SemanticIR schema mutation.
- Runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes.
- Live non-selected branch evaluation.
- Effect execution, external IO, persistence, Ledger/TBackend live reads.
- Dependency/cache authority.
- CompilationReport / CompilerResult / receipt / CompatibilityReport mutation.
- `.igapp` artifact schema or goldens.
- Body spec chapter edits.
- `docs/language-spec.md` promotion.
- PROP-032 amendment.
- Public API/CLI.
- Release evidence rewrite or public demo/stable/production/all-grammar claims.
- Spark data, fixtures, ids, integration, or demo behavior.
