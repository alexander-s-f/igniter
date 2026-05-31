# Counterfactual Audit Artifact Home And Authority Decision v0

Card: S3-R217-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-artifact-home-and-authority-decision-v0
Route: UPDATE
Status: done / accepted-option-b-next-route
Date: 2026-05-31

Depends on:
- S3-R217-C1-D
- S3-R217-C2-P1
- S3-R217-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/
  counterfactual-audit-artifact-home-and-authority-options-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-artifact-authority-facts-packet-v0.md`
- `igniter-lang/docs/discussions/
  counterfactual-audit-artifact-home-and-authority-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round216-status-curation-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-debt-and-time-to-market-decision-v0.md`

---

## Decision

Decision:

```text
accept C1-D artifact-home / authority options matrix
accept C2-P1 runtime artifact authority facts packet
accept C3-X pressure verdict: PASS, no blockers
accept Option B as the next bounded design/proof route
accept Option A as safe fallback baseline
allow Option C only as companion/index work after or alongside Option B
hold Option D until Option B clarifies home and authority fields
keep Options E/F comparison-only and closed as next routes
do not authorize implementation
do not authorize release execution or public claims
```

Accepted next route:

```text
counterfactual-audit-proof-owned-artifact-home-design-v0
```

This is a design-only and experiments-only route. It may not touch `lib/**`,
compiler pipeline stages, report/result/receipt surfaces, `.igapp`,
manifests, RuntimeSmoke behavior, public API, Spark, release evidence, or any
other closed surface.

---

## Accepted Option

Accepted option direction:

```text
Option B: proof-owned artifact directory with no compiler/report authority
```

Artifact-home status:

```text
accepted as next-route design target, not as implemented home
```

The exact path, manifest/index shape, write scope, and recomputation policy are
not authorized in this card. They must be designed and pressure-reviewed by the
next route.

Authority status:

```text
proof-owned
non-canonical
no runtime authority
no report authority
no cache/dependency authority
no public API authority
no compiler-emitted authority
no Spark or production authority
```

Required default flags for any future Option B artifact:

```text
canonical: false
runtime_authority: false
report_authority: false
cache_authority: false
dependency_authority: false
public_api_authority: false
compiler_emitted: false
spark_authority: false
production_authority: false
```

---

## Authority Stance

Source refs:

- proof-owned evidence refs only;
- digest-addressed evidence anchors;
- not CompilerResult fields;
- not CompilationReport fields;
- not canonical SemanticIR schema.

Input snapshots:

- frozen proof evidence only;
- no runtime input persistence authority;
- no report persistence authority;
- privacy and persistence posture must be designed before any artifact home can
  be written outside proof-local outputs.

Premise sets:

- explicit premise capsules only;
- assumptions remain premise capsule only;
- no PROP-032 widening;
- no branch-level source syntax;
- no receipt authority;
- no dependency/cache authority.

Projection traces:

- proof/debug/explanatory only;
- not runtime readiness evidence;
- not cache keys;
- not dependency truth;
- not report/result/receipt fields.

Projected values and failures:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

Any future artifact must state that projected values/failures are explanatory
counterfactual projections only.

---

## Other Options

Option A:

```text
accepted as safe fallback baseline
```

Permanent proof-local-only evidence remains valid if Option B is later held.

Option C:

```text
allowed only as companion/index route after or alongside Option B
```

Internal docs/status index may improve discoverability but is not enough as the
artifact-home answer and may not become canon by repetition.

Option D:

```text
held
```

Internal non-canonical carrier is promising later, but premature before Option B
defines home, authority fields, ownership, and closed-surface scans.

Option E:

```text
comparison only; closed
```

Compiler-emitted artifacts remain closed and require a separate compiler
artifact route before any future consideration.

Option F:

```text
comparison only; closed
```

Report/result/receipt sidecars remain closed and require a separate
report/result/receipt surface route before any future consideration.

---

## C3-X Acceptance Note

C3-X has one non-blocking acceptance note:

```text
AN-1: clarify design/proof route scope when dispatching Option B
```

Accepted clarification:

```text
The Option B route is design-only and experiments-only.
It may not touch lib/**, compiler pipeline stages, report/result/receipt
surfaces, .igapp, manifests, RuntimeSmoke behavior, or any listed closed
surface.
Accepting Option B as the next route is not implementation authorization.
```

This clarification is binding for the next dispatch.

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R218-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-proof-owned-artifact-home-design-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R217-C4-A
```

Goal:

```text
Decide whether a bounded Option B proof-owned artifact-home design/proof card
may begin, with experiments-only write scope and no implementation authority.
```

Candidate later implementation/proof boundary, if authorized by R218-C1-A:

```text
Card: S3-R218-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: counterfactual-audit-proof-owned-artifact-home-design-v0
Route: UPDATE
```

Candidate allowed write scope for that later card:

```text
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/**
igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-v0.md
```

Candidate required outputs for that later card:

- proof-owned artifact-home proposal;
- no-authority manifest or index shape, if any;
- R211 parity fixture or evidence replay;
- digest recomputation policy;
- source-ref / input-snapshot / premise-set authority flags;
- projection trace and projected value/failure disclaimers;
- closed-surface scan.

Closed for that later card unless separately authorized:

- `lib/**`;
- compiler pipeline stages;
- RuntimeSmoke behavior;
- `.igapp`, manifests outside experiment scope, reports, receipts, result
  objects, CompatibilityReport, API/CLI, Spark, release evidence, public docs,
  cache/dependency authority, and production behavior.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Are artifact-home / authority options accepted? | Yes. |
| Is L2b still proof-local? | Yes, until later acceptance of Option B artifacts. |
| Is an internal non-canonical carrier accepted? | No. Option D is held. |
| Is Option B accepted? | Yes, as next design/proof route target only. |
| Is compiler-emitted artifact closed? | Yes. Option E remains comparison-only. |
| Is report/result/receipt sidecar closed? | Yes. Option F remains comparison-only. |
| Does runtime/report/API implementation remain closed? | Yes. |
| Do public/Spark/API/release claims remain closed? | Yes. |
| Is release execution authorized? | No. |

---

## Forbidden Promotion Paths

Do not promote this lane by:

- editing `lib/**`;
- changing parser, classifier, TypeChecker, SemanticIR, assembler, or
  orchestrator behavior;
- changing runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior;
- evaluating live non-selected branches;
- adding source grammar or branch-level assumptions syntax;
- mutating CompilerResult or CompilationReport;
- adding report/result/receipt/CompatibilityReport fields;
- treating digests as dependency/cache authority;
- treating projection traces as runtime/report authority;
- making `.igapp`, manifest, sidecar, artifact hash, or golden migrations;
- editing body spec chapters, `docs/language-spec.md`, public docs, or
  PROP-032;
- opening public API/CLI, Spark, release, demo, stable, production, or
  all-grammar claims.

---

## Compact Summary

R217 accepts the artifact-home / authority options matrix and chooses Option B
as the next bounded design/proof direction: proof-owned artifact directory with
explicit no-authority fields. Option B is not implemented by this decision.
R218 should first authorize the experiments-only design/proof card. Runtime,
report, API, public, release, and Spark surfaces remain closed.
