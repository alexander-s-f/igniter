# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Docs Sync Acceptance Decision v0

Card: S3-R213-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-acceptance-decision-v0  
Route: UPDATE  
Status: done / accepted-docs-sync  
Date: 2026-05-30

Depends on:
- S3-R213-C2-I
- S3-R213-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-pressure-v0.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/spec/README.md`
- `igniter-lang/docs/tracks/stage3-round212-status-curation-v0.md`

---

## Decision

Decision:

```text
accept docs-sync closure unconditionally
accept C3-X pressure verdict: PASS 10/10, no blockers, no non-blocking notes
do not authorize wording follow-up
do not authorize live implementation
do not authorize runtime/report/API/public/Spark/CLI claims
```

R213 C2-I successfully applied the bounded Option A-min docs-only sync authorized
by C1-A. The vocabulary is now discoverable in low-authority internal navigation
docs without promoting source-backed Level 2 evidence into source syntax,
canonical SemanticIR, runtime behavior, report/result/receipt shape, public API,
or public support.

---

## Exact Changed Files

C2-I docs-sync changed exactly the authorized files:

```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

C3-X additionally recorded pressure evidence in:

```text
igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

The C2-I implementation scope remains exactly compliant with C1-A.

---

## Acceptance Findings

| Check | Status |
| --- | --- |
| A-min target compliance | Accepted. Heat map, spec README, and track doc only. |
| `docs/current-status.md` status | Untouched by C2-I, as required. |
| Forbidden phrase scan | Accepted. Scan 1 CLEAR; Scan 2 only negative/non-claim footnote matches. |
| Proof-local / non-canonical vocabulary | Accepted. Both target docs use proof-local, held, and non-canonical wording. |
| Body spec chapter status | Held and untouched. |
| Public docs status | Held and untouched. |
| PROP-032 status | Untouched; assumptions remain premise capsule only. |
| Runtime/report/API/Spark/CLI/public claim status | Closed; no positive authority wording introduced. |
| Machine-readable authority/result-field drift | None. Negative disambiguation is prose footnote text only. |
| Live implementation status | Closed. |

---

## Accepted Target Effects

### Heat Map

Accepted:

```text
source_backed_dry_run_projection / source-backed Level 2 counterfactual dry-run
```

as a proof-local governance row with all pipeline stages gated and a footnote
that explicitly denies source syntax, canonical SemanticIR, compiler surface,
spec chapter, PROP, runtime/schema, report/receipt/CompatibilityReport, public
API/CLI, Spark, and production authority.

### Spec README

Accepted:

```text
No spec chapter: source-backed Level 2 counterfactual dry-run evidence is
proof-local and non-canonical; body spec chapters, PROP-032, runtime/report/API,
and public claims remain closed.
```

as an index-level pointer only. This is not body spec text.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is docs sync accepted? | Yes. Accepted unconditionally. |
| Is source-backed Level 2 vocabulary now discoverable in internal low-authority docs? | Yes. Heat map and spec README now carry bounded discoverability. |
| Does this create public/runtime/report/API support? | No. It is docs-only, proof-local, non-canonical vocabulary. |
| Do body spec chapters remain held? | Yes. Ch2/Ch5/Ch6/Ch7 remain untouched. |
| Do public docs remain held? | Yes. Public docs remain closed. |
| Does PROP-032 remain untouched? | Yes. No amendment, no branch syntax, no receipt change. |
| May implementation open next? | No. Not from this acceptance. |
| Does live runtime evaluate non-selected branches? | No. Live runtime remains lazy. |
| Are Spark/API/CLI claims opened? | No. Fully closed. |

---

## Remaining Closed Surfaces

Remain closed:

- live implementation;
- `lib/**`;
- parser/grammar/source syntax;
- TypeChecker/SemanticIR schema mutation;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior;
- live non-selected branch evaluation;
- report/result/receipt/CompatibilityReport shape;
- dependency/cache authority;
- `.igapp` schema or golden artifacts;
- body spec chapters;
- `docs/language-spec.md`;
- `docs/proposals/PROP-032-assumptions-block-v0.md`;
- public README/API/CLI/release/runtime/report docs;
- release evidence rewrite or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, demo behavior, or production behavior.

---

## Next Dispatch Recommendation

Immediate handoff:

```text
Card: S3-R213-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round213-status-curation-v0
Route: SUMMARY
Depends on:
- S3-R213-C1-A
- S3-R213-C2-I
- S3-R213-C3-X
- S3-R213-C4-A
```

Goal:

```text
Curate R213 as accepted docs-only low-authority vocabulary sync and record that
source-backed Level 2 vocabulary is discoverable while runtime/report/API/Spark/
public authority remains closed.
```

Recommended next Main Line route after curation:

```text
Card: S3-R214-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-lane-consolidation-boundary-v0
Route: UPDATE
Depends on:
- S3-R213-C5-S
```

Goal:

```text
Design-only consolidation of the counterfactual audit lane now that Level 1
branch_intention, Level 2 proof-local dry-run, and source-backed Level 2
evidence are all documented: decide whether they remain separate rows/terms,
collapse into a single internal lane map, or require a future route map before
any runtime/report/API design is considered.
```

Constraints for R214:

- design-only;
- no implementation;
- no body spec edit unless separately authorized later;
- no public docs;
- no runtime/report/API/Spark claims;
- preserve live lazy runtime;
- keep counterfactual dry-run evidence proof-local and non-canonical.
