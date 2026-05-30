# Counterfactual Audit Runtime Debt And Time To Market Review v0

Card: S3-R216-C1-D
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-runtime-debt-and-time-to-market-review-v0
Route: UPDATE
Status: done / review-only
Date: 2026-05-30

Depends on:
- S3-R215-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round215-status-curation-v0.md`
- `igniter-lang/docs/tracks/
  branch-conditional-counterfactual-audit-internal-lane-map-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md`
- `igniter-lang/docs/discussions/
  branch-conditional-counterfactual-audit-internal-lane-map-pressure-v0.md`

---

## Fixed Point

This card is a non-authorizing review.

It does not open implementation, runtime/report/API design, docs/map sync,
release work, public claims, Spark work, or live counterfactual execution.

R215 accepted the internal Counterfactual Audit Lane map:

```text
L1  Static branch intention
L2a Isolated projection concept
L2b Source-backed isolated projection
L3  Route map / artifact home / authority design
L4  Runtime-report-API candidates
```

R216 evaluates sequencing pressure only.

---

## Runtime-Debt Assessment

Runtime debt is real but not currently blocking market movement by missing
runtime code.

The debt is concentrated in authority and routing:

- accepted runtime evidence is split across internal evaluator, proof
  RuntimeMachine, RuntimeSmoke proof-context consumer, and Level 2 proofs;
- source-backed Level 2 evidence has no accepted non-proof-local artifact home;
- authority is undefined for source refs, input snapshots, premise sets,
  projected values, projected failures, and projection traces;
- RuntimeSmoke can exercise proof-context artifacts, but that remains
  non-support wording;
- report/result/receipt/API surfaces remain closed and should stay closed
  until artifact-home and authority decisions exist.

Current interpretation:

```text
runtime debt: medium
time-to-market risk: moderate
proof-quality risk from rushing: high
best immediate relief: L3 artifact-home / authority clarity
```

The fastest safe path is not to widen runtime. It is to stop rebuilding the
same "where does this evidence live and what does it authorize?" argument in
every later card.

---

## Time-To-Market Assessment

Accepted pressure:

```text
Time-to-market risk: 4/10
Execution quality: 8/10
```

Interpretation:

- the project is not failing from lack of proof quality;
- the market risk comes from slow convergence from proof evidence to an
  understandable internal product/runtime story;
- runtime implementation before L3 would likely increase drift, because it
  would create live surfaces before authority is named;
- report/API design before L3 would be worse, because it would force schema and
  public-support questions too early.

Time-to-market should therefore be handled by reducing route ambiguity, not by
skipping authority gates.

---

## Compact Decision Matrix

| Route Option | TTM Relief | Risk | Result |
| --- | --- | --- | --- |
| Artifact-home / authority options next | High | Low-medium | Preferred. |
| Runtime/Bridge architecture survey first | Medium | Medium | Later or support. |
| Report/API boundary survey first | Low-medium | High | Wait. |
| Pause counterfactual work | Low | Low | Safe fallback. |
| Runtime implementation next | Medium | High | Reject now. |
| RuntimeSmoke support route next | Low | High | Reject now. |
| Docs/map sync next | Low | Low | Optional later. |

Notes:

- Runtime/Bridge survey is useful after artifact-home scope is named.
- Report/API boundary work has too much undefined authority right now.
- RuntimeSmoke proof-context wording remains binding.

---

## Route Reviews

### Artifact-Home / Authority Options

Recommendation:

```text
open next unless C3-X finds a blocker
```

Why:

- directly addresses the main runtime-debt source;
- gives L2b source-backed evidence a clear "home or no home" decision;
- can remain design-only and avoid implementation;
- lets later Runtime/Bridge and report/API surveys ask narrower questions.

Minimum next-route questions:

- Does source-backed Level 2 stay proof-local forever, stay proof-owned for
  now, or receive an internal non-canonical home?
- What authority does each ref have?
- Are projected values/failures explanatory only forever, or candidates for a
  future internal artifact?
- What fields are forbidden from becoming report/result/cache/API authority?

### Runtime/Bridge Architecture Survey

Recommendation:

```text
do after artifact-home / authority options, or as C2-P1 support for that route
```

Why:

- the evaluator / proof RuntimeMachine / RuntimeSmoke split is real;
- however, a survey without artifact-home framing will rediscover the same
  boundaries and may not converge;
- it should review runtime ownership after L3 has named what, if anything,
  could move beyond proof-local evidence.

### Report / API Boundary Survey

Recommendation:

```text
wait
```

Why:

- report/result/receipt/API surfaces require an authority object first;
- opening them now risks promoting proof envelopes by implication;
- C2-P1 already has enough gate inventory for this stage.

### Pause Or Return To Another Runtime Lane

Recommendation:

```text
not preferred, but safe
```

Why:

- the counterfactual lane has reached a natural L3 question;
- pausing now would preserve safety but leave route debt unresolved;
- returning to another runtime lane may help general TTM only if Portfolio has
  a higher-priority runtime objective.

---

## Preservation Requirements

Any next route must preserve:

- L1, L2a, and L2b as distinct lane levels;
- live runtime selected-branch laziness;
- no evaluation of non-selected branches in live runtime;
- RuntimeSmoke proof-context wording as non-support;
- source-backed Level 2 as proof-local/non-canonical until L3 says otherwise;
- no report/result/receipt/API/cache/dependency authority;
- no Spark/API/CLI/release/public/demo/stable/production claim.

Do not speed up by:

- adding report/result/receipt fields;
- treating proof-context RuntimeSmoke evidence as support;
- treating projection traces or `call_trace` as dependency/cache authority;
- making source-backed envelopes canonical by docs wording;
- using Spark or demo pressure as validation shortcut;
- widening assumptions from premise capsule to branch syntax.

---

## Recommended Next Route Options For C4-A

Preferred:

```text
Card: S3-R217-C1-D
Track: counterfactual-audit-artifact-home-and-authority-options-v0
Route: UPDATE
Mode: design-only
```

Boundary:

- compare proof-local forever, proof-owned artifact directory, internal
  docs/status index, and internal non-canonical carrier;
- define authority for source refs, input snapshots, premise sets, projections,
  projected values/failures, and traces;
- explicitly keep compiler-emitted artifacts, report/result/receipt sidecars,
  public API/CLI, Spark, dependency/cache, and runtime implementation closed.

Support packet:

```text
S3-R217-C2-P1
Track: counterfactual-audit-runtime-artifact-authority-facts-packet-v0
```

Pressure:

```text
S3-R217-C3-X
Track: counterfactual-audit-artifact-home-and-authority-pressure-v0
```

Decision:

```text
S3-R217-C4-A
Track: counterfactual-audit-artifact-home-and-authority-decision-v0
```

Fallback safe route:

```text
counterfactual-audit-runtime-bridge-boundary-survey-v0
```

Use only if C4-A decides runtime ownership is more urgent than artifact home.

Hold route:

```text
pause counterfactual lane and return to another runtime/language objective
```

Use only if Portfolio wants to reduce lane pressure without resolving L3 now.

---

## Explicit Answers

- Runtime debt is not blocking market movement by missing implementation. It
  blocks clarity and repeatable routing.
- Artifact-home / authority options should open next as the preferred technical
  route.
- Runtime/Bridge architecture survey should not open first. It should follow or
  support artifact-home authority work.
- Report/API boundary survey should wait because it needs an authority object
  first.
- Pausing counterfactual work is safe but not preferred. L3 is the natural next
  step.
- This card authorizes no implementation.
- This card authorizes no runtime/report/API design.
- L1/L2a/L2b distinctions remain binding.
- RuntimeSmoke proof-context wording remains binding.
- Public/Spark/API/release claims remain closed.

---

## Command Matrix

| Command | Result |
| --- | --- |
| Read R215 curation | PASS |
| Read R215 lane-map decision | PASS |
| Read R215 internal lane map | PASS |
| Read runtime/report/API gate survey | PASS |
| Read runtime-debt / TTM pressure survey | PASS |
| Read R215 pressure verdict | PASS |

No proof or runtime commands were required. No code was changed.

---

## Compact Handoff

Runtime-debt / TTM review accepts the pressure but does not use it to widen
runtime. The strongest next step is design-only L3 artifact-home and authority
options. Runtime/Bridge survey should follow or support that route.
Report/API/runtime implementation remains closed.
