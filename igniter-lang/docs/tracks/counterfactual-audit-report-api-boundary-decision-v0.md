# Counterfactual Audit Report API Boundary Decision v0

Card: S3-R221-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-report-api-boundary-decision-v0
Route: UPDATE
Status: done / accepted-report-api-boundary-survey
Date: 2026-05-31

Depends on:
- S3-R221-C1-D
- S3-R221-C2-P1
- S3-R221-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/
  counterfactual-audit-report-api-boundary-survey-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-report-api-exposure-facts-packet-v0.md`
- `igniter-lang/docs/discussions/
  counterfactual-audit-report-api-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round220-status-curation-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-bridge-architecture-decision-v0.md`

---

## Decision

Decision:

```text
accept report/API boundary survey
accept report/API exposure facts packet as accurate facts basis
accept C3-X pressure verdict: PASS, no blockers, no notes
hold all report/API field and sidecar design routes
hold Option D carrier boundary
proceed to status curation
```

Acceptance class:

```text
read-only report/API boundary survey and exposure facts packet
```

This decision accepts the boundary survey as a stable fence around
counterfactual audit evidence. It does not authorize implementation, field
design, result/report/API shape changes, RuntimeSmoke changes, public claims,
Spark authority, release execution, or production behavior.

---

## Accepted Boundary Status

Accepted report/API boundary status:

```text
accepted as sufficient for this round
read-only/design-survey only
no code edits
no field changes
no implementation route opened
```

Accepted C1-D conclusions:

- report/API boundary survey is sufficient for this round;
- `CompilerResult` remains closed;
- `CompilationReport` remains closed;
- RuntimeSmoke output remains proof-context only;
- no report/API design-only route should open next;
- Option D remains held;
- runtime/report/API authority remains closed;
- public/Spark/release authority remains closed.

---

## Accepted Exposure Facts Basis

C2-P1 is accepted as the current report/API exposure facts basis.

Load-bearing facts:

- `CompilerResult.ok` currently includes `runtime_smoke` and private `report`;
- `CompilerResult.public_result` removes only `report`;
- CLI prints `CompilerResult.public_result(...)` as JSON;
- any future top-level counterfactual key would become public/CLI-visible by
  default unless a separate public key-set or allow-list gate changes that;
- `CompilationReport.runtime_smoke_failure` can turn failed smoke into
  diagnostics and a refusal report;
- RuntimeSmoke has both success-payload and failure-diagnostic paths;
- no counterfactual report, result, receipt, CompatibilityReport, API, CLI, or
  sidecar surface currently exists in this lane;
- Option C docs/status remains internal discoverability only.

---

## Pressure Verdict

C3-X verdict:

```text
PASS
no blockers
no non-blocking acceptance notes
```

C3-X confirms:

- C1-D route recommendation is safe;
- C2-P1 facts are sufficient;
- no blocker requires another survey first;
- no design route should open from this survey;
- all report/API field and sidecar design routes should remain held;
- Option D carrier remains held;
- implementation and public claims remain closed.

---

## CompilerResult Status

Decision:

```text
CompilerResult remains closed to Option B/C fields.
```

Reason:

- current success result includes `runtime_smoke`;
- current `public_result` strips only `report`;
- new top-level fields are public-result and CLI-visible by default;
- no accepted counterfactual public/private key-set exists;
- no accepted report/API consumer exists.

Any future positive field route would first require:

- exact public key-set or allow-list design;
- public/private exposure decision;
- CLI visibility decision;
- regression proof for existing public result shapes;
- separate pressure review.

None of that is authorized here.

---

## CompilationReport Status

Decision:

```text
CompilationReport remains closed to projected values and failures.
```

Reason:

- current reports have no counterfactual/projection fields;
- `runtime_smoke_failure` can convert smoke failure into diagnostics;
- projected failures must not become actual runtime diagnostics;
- projected values must not become report outputs or report evidence.

Binding disclaimer remains:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

---

## RuntimeSmoke Output Status

Decision:

```text
RuntimeSmoke output remains selected-execution proof-context only.
```

RuntimeSmoke must not carry:

- Option B manifest/projection payloads;
- Option D carrier payloads;
- `projected_value`;
- `projected_failure`;
- counterfactual report metadata;
- public support claims.

RuntimeSmoke behavior and result shape remain unchanged.

---

## CompatibilityReport / Receipt / Sidecar Status

Decision:

```text
CompatibilityReport, receipt/result sidecars, and durable report surfaces remain closed.
```

Reason:

- no counterfactual CompatibilityReport exists;
- no counterfactual receipt/result sidecar exists;
- readiness/compatibility vocabulary would overstate proof-owned projections;
- sidecars would imply persistence/report authority not accepted by Option B/C.

No sidecar design route opens next.

---

## Public API / CLI Status

Decision:

```text
public API/CLI counterfactual surfaces remain closed.
```

Current public exposure facts are accepted only as risks:

- `IgniterLang.compile` returns orchestrator result hash;
- CLI prints `CompilerResult.public_result(...)`;
- no counterfactual parameter, CLI flag, command, output key, or public support
  claim exists.

No public API/CLI design route opens next.

---

## Docs / Status Pseudo-Public Claim Status

Decision:

```text
internal docs/status remains allowed only as discoverability and route memory.
```

Allowed:

- accepted evidence anchors;
- no-authority flags;
- closed surfaces;
- next-route memory;
- digest references as evidence anchors.

Closed:

- public docs;
- body spec chapters;
- PROP-032 amendment;
- public support claims;
- runtime/report/API support claims;
- Spark support or production readiness wording.

---

## Option D Decision

Decision:

```text
Option D internal non-canonical carrier remains held.
```

Reason:

- no concrete internal consumer has been identified;
- Option B artifact home already carries proof-owned evidence;
- Option C already carries internal discoverability;
- report/API exposure is now fenced as closed;
- opening a carrier now would add shape pressure without product benefit.

Option D may be reconsidered only if a later card identifies a concrete
internal consumer and preserves all no-authority flags.

---

## Implementation Status

Decision:

```text
live implementation remains closed.
```

Closed:

- code edits and `lib/**` changes;
- field/schema changes;
- report/result/API implementation;
- RuntimeSmoke carrier behavior;
- public API/CLI behavior;
- compatibility/receipt/sidecar implementation;
- runtime/evaluator behavior;
- compiler pipeline changes.

---

## Dependency / Cache Authority Status

Decision:

```text
dependency/cache authority remains closed.
```

Accepted stance:

- evaluator traces remain proof/debug only;
- RuntimeSmoke output remains proof-context only;
- Option B projection trace is explanatory evidence only;
- no path-sensitive cache key, invalidation, freshness, dependency truth, or
  TBackend read authority is created.

---

## Public / Spark / Release Claim Status

Decision:

```text
public, Spark, API, release, and production claims remain closed.
```

No public counterfactual support claim is authorized. No release evidence,
release execution, publish, tag, push, deploy, Spark integration, or production
behavior is authorized.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is report/API boundary survey accepted? | Yes. |
| Are C2-P1 exposure facts accepted? | Yes, as accurate facts basis. |
| May any report/API design-only route open next? | No. |
| May Option D carrier boundary open next? | No. |
| Does live implementation remain closed? | Yes. |
| Does runtime/report/API authority remain closed? | Yes. |
| Does public/Spark/release authority remain closed? | Yes. |
| Is status curation the next dispatch? | Yes. |

---

## Next Dispatch Recommendation

Open status curation only:

```text
Card: S3-R221-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round221-status-curation-v0

Route: SUMMARY
Depends on:
- S3-R221-C4-A

Goal:
Curate R221 outcome and update Main Line status after the accepted report/API
boundary survey.

Scope:
- Read all R221 outputs.
- Produce compact status curation:
  - report/API boundary accepted status;
  - CompilerResult closed status;
  - CompilationReport closed status;
  - RuntimeSmoke proof-context-only status;
  - CompatibilityReport / receipt/result sidecar closed status;
  - public API/CLI closed status;
  - Option D held status;
  - no-next-design-route status;
  - closed surfaces and exact handoff.
- Update `igniter-lang/docs/current-status.md` only if warranted by C4-A.

Deliver:
- `igniter-lang/docs/tracks/stage3-round221-status-curation-v0.md`
- Optional compact current-status update if warranted
```

After status curation:

```text
pause counterfactual audit implementation/design expansion
do not open report/API design route
do not open Option D carrier route
resume another Main Line route only by explicit new Portfolio card
```
