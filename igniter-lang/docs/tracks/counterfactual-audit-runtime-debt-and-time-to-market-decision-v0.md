# Counterfactual Audit Runtime Debt And Time To Market Decision v0

Card: S3-R216-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-runtime-debt-and-time-to-market-decision-v0
Route: UPDATE
Status: done / accepted-next-l3-route
Date: 2026-05-30

Depends on:
- S3-R216-C1-D
- S3-R216-C2-P1
- S3-R216-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-debt-and-time-to-market-review-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-debt-facts-packet-v0.md`
- `igniter-lang/docs/discussions/
  counterfactual-audit-runtime-debt-and-time-to-market-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round215-status-curation-v0.md`

---

## Decision

Decision:

```text
accept runtime-debt / time-to-market review
accept runtime-debt facts packet as accurate facts basis
accept C3-X pressure verdict: PASS, no blockers, no acceptance notes
open artifact-home / authority options next
do not open runtime/bridge survey first
do not open report/API boundary survey first
do not authorize implementation
do not authorize release execution or public claims
```

R216 confirms that the runtime-debt pressure is real, but it is currently an
authority and routing problem rather than a missing runtime-code problem.

The next technical route must therefore be L3 artifact-home / authority
options.

---

## Accepted Runtime-Debt Interpretation

Accepted interpretation:

```text
runtime debt: medium
time-to-market risk: moderate
proof-quality risk from rushing: high
best immediate relief: L3 artifact-home / authority clarity
```

The accepted debt center is:

- source-backed Level 2 has no accepted non-proof-local artifact home;
- authority is undefined for source refs, snapshots, premise sets,
  projections, projected values/failures, and traces;
- runtime evidence is split across internal evaluator, proof RuntimeMachine,
  RuntimeSmoke proof-context consumer, and Level 2 proof routes;
- report/result/receipt/API/cache surfaces remain closed;
- RuntimeSmoke proof-context evidence remains non-support.

This means time-to-market pressure changes sequencing only by forcing the L3
authority question to the front. It does not justify implementation.

---

## Accepted Facts Packet

C2-P1 is accepted as the current facts basis.

Accepted anchors:

- live evaluator support is internal, direct-require-only, selected-branch
  lazy `if_expr` evaluation;
- proof RuntimeMachine consumer remains experiment-owned;
- RuntimeSmoke remains proof-context consumer evidence only;
- `call_trace` remains proof/debug only;
- `apply`, `field_access`, and `tbackend_read` remain outside evaluator core;
- proof counts remain useful evidence anchors:
  - R199: 68/68;
  - R201: 56/56;
  - R203: 53/53;
  - R211: 61/61.

C2-P1's missing-authority inventory is binding input for the next route.

---

## C3-X Acceptance

C3-X verdict:

```text
PASS
no blockers
no non-blocking acceptance notes
```

C3-X confirms:

- C1-D is safe to accept;
- C2-P1 is accurate enough as facts basis;
- artifact-home / authority options should open next;
- Runtime/Bridge survey should follow or support the artifact-home route;
- implementation remains premature.

---

## Route Decision

Chosen route:

```text
counterfactual-audit-artifact-home-and-authority-options-v0
```

Why this route:

- it directly addresses the accepted L3 blocker;
- it reduces repeated boundary reconstruction;
- it can remain design-only;
- it gives later Runtime/Bridge and report/API routes a precise object to
  review or reject;
- it preserves proof quality while responding to time-to-market pressure.

Rejected as next route:

- runtime/bridge architecture survey first;
- report/API boundary survey first;
- docs/map sync authorization review;
- runtime implementation;
- RuntimeSmoke support route;
- public API/CLI/Spark/demo/release route.

Pause remains safe but not preferred.

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R217-C1-D
Agent: [Compiler/Grammar Expert] or [Portfolio Architect Supervisor]
Role: compiler-grammar-expert
Track: counterfactual-audit-artifact-home-and-authority-options-v0
Route: UPDATE
Depends on:
- S3-R216-C4-A
```

Goal:

```text
Design the L3 artifact-home and authority options for source-backed Level 2
counterfactual audit evidence, without opening implementation or runtime,
report, API, cache, dependency, public, release, or Spark authority.
```

Required scope:

- compare proof-local forever, proof-owned artifact directory, internal
  docs/status index, and internal non-canonical carrier;
- decide whether any option is acceptable as a later route, or whether all
  non-proof-local homes remain held;
- define authority questions for source refs, input snapshots, premise sets,
  projections, projected values/failures, and traces;
- state forbidden promotion paths for compiler-emitted artifacts,
  report/result/receipt sidecars, CompatibilityReport, public API/CLI, Spark,
  dependency/cache, runtime implementation, and public claims;
- preserve L1/L2a/L2b separation;
- preserve RuntimeSmoke proof-context / non-support wording;
- preserve live runtime non-selected-branch non-evaluation.

Recommended support packet:

```text
Card: S3-R217-C2-P1
Agent: [Research Agent #1]
Role: research-agent
Track: counterfactual-audit-runtime-artifact-authority-facts-packet-v0
Route: UPDATE
Depends on:
- S3-R217-C1-D
```

Recommended pressure:

```text
Card: S3-R217-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: counterfactual-audit-artifact-home-and-authority-pressure-v0
Route: REVIEW
Depends on:
- S3-R217-C1-D
- S3-R217-C2-P1
```

Recommended decision:

```text
Card: S3-R217-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-artifact-home-and-authority-decision-v0
Route: UPDATE
Depends on:
- S3-R217-C1-D
- S3-R217-C2-P1
- S3-R217-C3-X
```

Recommended curation:

```text
Card: S3-R217-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round217-status-curation-v0
Route: SUMMARY
Depends on:
- S3-R217-C4-A
```

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is runtime-debt / TTM review accepted? | Yes. |
| Does TTM pressure change sequencing? | Yes. L3 artifact-home / authority goes next. |
| Does TTM pressure authorize implementation? | No. |
| Do artifact-home / authority options open next? | Yes. |
| Does runtime/bridge survey open first? | No. It may support or follow L3. |
| Does report/API boundary survey open first? | No. It must wait. |
| Does runtime/report/API implementation remain closed? | Yes. |
| Do public/Spark/API/release claims remain closed? | Yes. |
| Does RuntimeSmoke proof-context wording remain binding? | Yes. |

---

## Closed Surfaces

Remain closed after R216:

- implementation;
- `lib/**`;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- RuntimeSmoke feature/support claims;
- live non-selected branch evaluation;
- source grammar and branch-level assumptions syntax;
- CompilerResult / CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- `.igapp`, manifest, sidecar, artifact hash, golden migration;
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- public API/CLI;
- release execution, release evidence, public demo/stable/production claims;
- Spark data, fixtures, ids, integration, demo, or production behavior.

---

## Compact Summary

R216 accepts runtime-debt / time-to-market review. The pressure is real but
does not authorize implementation. The next safe technical move is L3
artifact-home / authority options, because it resolves the main route debt
without promoting runtime, report, API, cache, public, release, or Spark
surfaces.
