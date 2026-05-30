# Branch Conditional Counterfactual Audit Lane Consolidation Decision v0

Card: S3-R214-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-counterfactual-audit-lane-consolidation-decision-v0
Route: UPDATE
Status: done / accepted-lane-consolidation-boundary
Date: 2026-05-30

Depends on:
- S3-R214-C1-D
- S3-R214-C2-P1
- S3-R214-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-boundary-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-lane-consolidation-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round213-status-curation-v0.md`

---

## Supersedes Interim Hold

An interim C4-A HOLD was recorded when the required C3-X pressure verdict was
not yet present. That blocker is now resolved:

```text
S3-R214-C3-X: PASS
C1-D: accept
C2-P1: accept as non-authorizing pressure context
C4-A HOLD: release; proceed to final acceptance decision
```

This document supersedes the interim HOLD state.

---

## Decision

Decision:

```text
accept lane consolidation boundary
accept runtime-debt / time-to-market survey as non-authorizing pressure context
accept C3-X pressure verdict: PASS, no blockers
open internal lane map next
do not open runtime-debt review immediately
do not authorize docs/map sync in this card
do not authorize live implementation
do not authorize runtime/report/API/public/Spark claims
```

R214 accepts the counterfactual audit lane consolidation boundary. The lane
should remain semantically layered, but operationally consolidated through a
future internal lane map.

---

## Accepted Lane Model

Accepted:

```text
Counterfactual Audit Lane
  L1  Static branch intention
  L2a Isolated projection concept
  L2b Source-backed isolated projection
  L3  Route map / artifact home / authority design
  L4  Runtime-report-API candidates
```

Binding interpretation:

- L1, L2a, and L2b remain semantically distinct.
- L1 explains latent branch structure without evaluation.
- L2a proves isolated projection mechanics in proof-local experiments.
- L2b proves source-backed projection evidence with proof-owned artifacts,
  frozen inputs, digest-addressed refs, and explicit premise sets.
- L3 must happen before any runtime/report/API design.
- L4 remains a future candidate horizon, not an open route.

This is a lane consolidation, not a schema consolidation.

---

## Accepted C2-P1 Pressure Context

C2-P1 is accepted as non-authorizing pressure context.

Accepted pressure signals:

```text
Time-to-market risk: 4/10
Execution quality: 8/10
```

Interpretation:

- the risk is real but moderate;
- proof methodology remains valuable and should not be weakened;
- repeated boundary reconstruction is now itself a drag;
- fastest safe move is route clarity, not runtime expansion;
- runtime-debt review should follow lane-map closure, not precede it.

Runtime-debt status accepted:

- live internal evaluator exists, direct-require-only;
- proof RuntimeMachine consumer path exists, experiment-owned;
- RuntimeSmoke proof-context evidence exists, result shape unchanged;
- counterfactual dry-run remains proof-local and experiment-local;
- report/result/receipt/cache/API authority remains closed.

---

## C3-X Acceptance

C3-X verdict:

```text
PASS
no blockers
3 non-blocking acceptance notes
```

C3-X accepted:

- C1-D lane consolidation is safe;
- C2-P1 runtime-debt survey is accurate and not overstated;
- future internal lane map may open next;
- runtime-debt review should open after lane-map closure, not immediately;
- runtime/report/API implementation remains premature;
- public/runtime/API/Spark claims remain closed.

---

## Non-Blocking Notes Carried Forward

These are binding carry-forward notes for the next internal lane map card, not
blockers for R214 acceptance.

AN-1:

```text
The "internal tool-only use case before runtime support" question must remain a
question until the lane map answers it with a named decision.
```

AN-2:

```text
RuntimeSmoke transitive load must be framed as a known consequence, not feature
support.
```

AN-3:

```text
C2-P1's "Do not speed up by" fence must be preserved in the lane map:
do not add report/result/receipt fields, do not treat RuntimeSmoke as public
support, do not turn call_trace into dependency/cache authority, do not make
projection envelopes canonical by implication, and do not use Spark/public demos
as shortcuts.
```

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is the counterfactual audit lane model accepted? | Yes. Accepted as an internal layered lane model. |
| Do Level 1 / Level 2 / source-backed Level 2 remain separate? | Yes. They remain semantically distinct. |
| Should a single lane map be created later? | Yes. Open an internal lane map next. |
| Do assumptions remain premise-capsule-only? | Yes. No PROP-032 amendment opens. |
| Should runtime-debt review open after this layer? | Yes, after the internal lane map closes. |
| Does live implementation remain closed? | Yes. |
| Do runtime/report/API/public/Spark claims remain closed? | Yes. |
| Is docs/map sync authorized now? | No. Only the next design route opens. |

---

## Remaining Closed Surfaces

Remain closed:

- implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema mutation;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- live non-selected branch evaluation;
- effect execution, external IO, persistence, Ledger/TBackend live reads;
- dependency/cache authority;
- CompilerResult / CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- `.igapp` schema or golden artifacts;
- body spec chapter edits;
- `docs/language-spec.md` promotion;
- PROP-032 amendment;
- public API/CLI;
- Spark data, fixtures, ids, integration, demo behavior, or production behavior;
- release evidence rewrite or public demo/stable/production/all-grammar claims.

---

## Exact Next Dispatch Recommendation

Open the internal lane map design route:

```text
Card: S3-R215-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-internal-lane-map-v0
Route: UPDATE
Depends on:
- S3-R214-C4-A
```

Goal:

```text
Create a compact internal Counterfactual Audit Lane map that records level
definitions, accepted evidence anchors, owner handoffs, blocked promotion paths,
and minimum gates before runtime/report/API design.
```

Required carry-forward:

- L1/L2a/L2b remain semantically distinct.
- Heat Map rows remain separate unless the lane map later authorizes a map sync.
- RuntimeSmoke transitive load is known consequence, not feature support.
- Internal tool-only use case remains a question until decided.
- C2-P1 "Do not speed up by" fence must be preserved.
- Runtime-debt / time-to-market review is queued after lane-map closure.

Do not authorize in R215-C1-D:

- implementation;
- runtime/report/API design;
- public docs or claims;
- docs/map sync unless a later authorization card opens it.

Expected route after lane-map closure:

```text
runtime-debt-and-time-to-market-review-v0
```
