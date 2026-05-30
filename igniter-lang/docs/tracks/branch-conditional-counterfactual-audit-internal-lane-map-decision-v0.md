# Branch Conditional Counterfactual Audit Internal Lane Map Decision v0

Card: S3-R215-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-counterfactual-audit-internal-lane-map-decision-v0
Route: UPDATE
Status: done / accepted-internal-lane-map
Date: 2026-05-30

Depends on:
- S3-R215-C1-D
- S3-R215-C2-P1
- S3-R215-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-internal-lane-map-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round214-status-curation-v0.md`

---

## Decision

Decision:

```text
accept internal Counterfactual Audit Lane map
accept runtime/report/API gate survey
accept C3-X pressure verdict: PASS, no blockers
open runtime-debt / time-to-market review next
do not open artifact-home options immediately
do not authorize docs/map sync in this card
do not authorize implementation
do not authorize runtime/report/API/public/Spark claims
```

R215 accepts the internal lane map as the controlling route-memory artifact for
Counterfactual Audit Lane work.

The next route is runtime-debt / time-to-market review because the lane map has
now closed the immediate consolidation gap and the accepted business pressure
should be handled explicitly before choosing the next technical L3 route.

This is sequencing only. It does not authorize runtime/report/API design or
implementation.

---

## Accepted Lane Map

Accepted model:

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
- L3 must close artifact-home and authority questions before L4 can open.
- L4 remains a future candidate horizon, not an open route.

The lane map is accepted as a grouping and routing artifact, not schema,
runtime, report, API, or public support.

---

## Accepted Gate Survey

C2-P1 is accepted as the current gate inventory.

Accepted blocker structure:

- lane map must be accepted before downstream work;
- artifact-home option must be selected or explicitly held;
- authority model must be defined for refs, snapshots, premise sets,
  projections, and source evidence;
- Runtime/Bridge review must confirm evaluator, proof RuntimeMachine,
  RuntimeSmoke, and non-selected branch isolation boundaries;
- report/result/receipt/CompatibilityReport surfaces remain closed unless a
  later survey/decision opens one design-only route;
- dependency/cache stance remains closed unless separately routed;
- TBackend/effect/external IO refusal remains binding unless a separate
  temporal/effect gate opens;
- public API/CLI/release/Spark gates remain closed.

The survey's artifact-home comparison table is accepted as analysis only.

```text
Compiler-emitted artifact
Report/result/receipt sidecar
```

are comparison entries, not open routes, not authorized candidates, and not
permission to design those surfaces now.

---

## C3-X Acceptance

C3-X verdict:

```text
PASS
no blockers
two non-blocking acceptance notes
```

C3-X confirms:

- C1-D lane map is safe to accept;
- C2-P1 gate survey is safe to accept;
- docs/map sync is not needed before runtime-debt review;
- runtime-debt / time-to-market review may open next;
- implementation routes are premature.

---

## Sequencing Decision

C3-X identified two safe sequencing options:

```text
Option A: runtime-debt / time-to-market review first
Option B: artifact-home options first
```

Portfolio chooses:

```text
Option A: runtime-debt / time-to-market review first
```

Reason:

- R214 already queued runtime-debt / time-to-market review after lane-map
  closure.
- The user-facing pressure is explicit: proof methodology is strong, but
  market speed risk is real.
- A review can evaluate sequencing and debt without opening implementation.
- Artifact-home and authority options remain the likely next technical L3 route,
  but their priority should be confirmed against runtime debt and market risk.

Constraint:

```text
The runtime-debt / time-to-market review must remain non-authorizing.
It may not open runtime/report/API implementation or design before naming the
artifact-home / authority blockers.
```

---

## Carry-Forward Fences

RuntimeSmoke transitive-load wording is accepted:

```text
RuntimeSmoke proof-context paths may transitively load the proof RuntimeMachine
and SemanticIRExpressionEvaluator. This is a known consequence of proof harness
wiring, not RuntimeSmoke feature support, not public runtime support, not API
support, and not a production/runtime claim. RuntimeSmoke result shape remains
unchanged.
```

Permanent "do not speed up by" fence is accepted:

- do not add report/result/receipt fields before an explicit surface gate;
- do not treat RuntimeSmoke proof-context evidence as public runtime support;
- do not turn `call_trace`, selected-path behavior, or projection trace data
  into dependency/cache authority;
- do not make source-backed projection envelopes canonical by implication;
- do not use Spark, public demos, release wording, or product pressure as
  validation shortcuts;
- do not evaluate non-selected branches in live runtime;
- do not widen assumptions from premise capsule to branch syntax;
- do not present internal/proof-only terminology as user-facing feature support.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is internal lane map accepted? | Yes. Accepted as controlling internal lane map. |
| Do L1/L2a/L2b remain distinct? | Yes. They remain semantically distinct. |
| Is internal tool-only use case held or routed? | Held as a future design-only question. It may be considered after runtime-debt review or inside artifact-home/authority options. |
| Is RuntimeSmoke transitive-load wording accepted? | Yes. Known consequence, not support. |
| Is "do not speed up by" fence accepted? | Yes. It becomes permanent lane hygiene. |
| Does runtime-debt / time-to-market review open next? | Yes. |
| Does runtime/report/API implementation remain closed? | Yes. |
| Is docs/map sync authorized now? | No. |

---

## Remaining Closed Surfaces

Remain closed:

- implementation;
- `lib/**`;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- source grammar and branch-level assumptions syntax;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- live non-selected branch evaluation;
- CompilerResult / CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- `.igapp`, manifests, sidecars, artifact hashes, goldens;
- Heat Map, Spec README, current-status, and status index edits;
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- public API/CLI;
- release evidence, public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, demo behavior, or production behavior.

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R216-C1-D
Agent: [Portfolio Architect Supervisor] or [Runtime/Research Analyst]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-runtime-debt-and-time-to-market-review-v0
Route: UPDATE
Depends on:
- S3-R215-C4-A
```

Goal:

```text
Review runtime-debt and time-to-market pressure after the accepted internal
Counterfactual Audit Lane map, decide whether the next technical route should
be artifact-home/authority options, runtime/bridge architecture survey,
report/API boundary survey, or pause.
```

Required constraints:

- non-authorizing review only;
- no implementation;
- no runtime/report/API design authorization;
- preserve L1/L2a/L2b distinctions;
- preserve RuntimeSmoke proof-context/non-support wording;
- keep artifact-home and authority blockers visible;
- keep public/Spark/API/release claims closed.

Likely next technical route after R216, if confirmed:

```text
counterfactual-audit-artifact-home-and-authority-options-v0
```
