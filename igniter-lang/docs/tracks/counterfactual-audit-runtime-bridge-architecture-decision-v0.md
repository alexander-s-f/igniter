# Counterfactual Audit Runtime Bridge Architecture Decision v0

Card: S3-R220-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-runtime-bridge-architecture-decision-v0
Route: UPDATE
Status: done / accepted-runtime-bridge-survey
Date: 2026-05-31

Depends on:
- S3-R220-C1-D
- S3-R220-C2-P1
- S3-R220-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-bridge-architecture-survey-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-bridge-authority-facts-packet-v0.md`
- `igniter-lang/docs/discussions/
  counterfactual-audit-runtime-bridge-architecture-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round219-status-curation-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-docs-status-index-companion-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-report-api-gate-survey-v0.md`

---

## Decision

Decision:

```text
accept Runtime/Bridge architecture survey
accept Runtime/Bridge authority facts packet as current facts basis
accept C3-X pressure verdict: PASS, no blockers, no notes
open report/API boundary survey next
keep Option D carrier held
keep runtime/evaluator implementation closed
```

Acceptance class:

```text
read-only Runtime/Bridge architecture and authority-boundary survey
```

This decision accepts the survey as a route-selection and boundary-fencing
artifact. It does not authorize implementation, runtime/report/API authority,
public claims, Spark authority, release execution, or any field/schema changes.

---

## Accepted Survey Status

Accepted Runtime/Bridge surface map status:

```text
accepted as sufficient for this round
read-only/design-survey only
one internal track doc
no code or public-surface edits
```

Accepted C1-D conclusions:

- Runtime/Bridge survey is sufficient for this round.
- Option D carrier is not structurally needed next.
- Report/API boundary survey should open next.
- Runtime/evaluator implementation remains closed.
- RuntimeSmoke remains proof-context only.
- `CompilerResult` and `CompilationReport` remain closed.
- Dependency/cache authority remains closed.
- Public/Spark/API/release claims remain closed.

---

## Accepted Facts Basis

C2-P1 is accepted as the current Runtime/Bridge authority facts basis.

Load-bearing facts:

- Option B artifact home is proof-owned, non-canonical evidence only.
- Option C docs/status index is discoverability-only.
- Option D carrier is held and has no accepted consumer.
- `RuntimeSmoke` is the highest accidental promotion path because it already
  has a compiler callback path and result slot.
- `CompilerResult.public_result` strips only `report`, so new positive keys
  would be public-risk by default.
- `CompilationReport.runtime_smoke_failure` can turn smoke failure into
  diagnostics, so projected failures must not enter that path by default.
- Proof RuntimeMachine receipts and observations remain proof-local only.
- Evaluator `call_trace` remains proof/debug only.
- PROP-038 nested report-only validation is not counterfactual authority.

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
- no additional survey is required before the next route;
- report/API boundary survey is the natural next route;
- Option D remains held;
- runtime/evaluator implementation remains closed;
- RuntimeSmoke, `CompilerResult`, and `CompilationReport` remain closed;
- dependency/cache/public/Spark/release surfaces remain closed.

---

## Option B / Option C Status

Option B remains:

```text
proof-owned
non-canonical
evidence-only
```

Option C remains:

```text
internal docs/status discoverability aid only
not canonical authority
not artifact authority
```

No accepted wording in this card promotes Option B or Option C into runtime,
report, API, public, Spark, release, cache, dependency, compiler-emitted, or
production authority.

---

## Option D Decision

Decision:

```text
Option D internal non-canonical carrier remains held.
```

Reason:

- Option B now supplies a proof-owned machine-readable evidence home.
- Option C now supplies internal human discoverability.
- No accepted consumer currently requires a normalized internal carrier object.
- Opening a carrier before report/API boundary review would increase leakage
  risk into `RuntimeSmoke`, `CompilerResult`, `CompilationReport`, receipts, or
  public API surfaces.

Option D may be reconsidered only after a later boundary decision identifies a
specific internal consumer and preserves all no-authority flags.

---

## Report / API Decision

Decision:

```text
report/API boundary survey may open next.
```

Scope posture:

```text
read-only/design-only
no code edits
no field changes
no result/report/API implementation
no RuntimeSmoke behavior or result-shape change
no public docs/body spec edits
no Spark/release/public claims
```

Reason:

- R215 identified report/result/receipt/API gates as blockers.
- R218/R219 give the survey a concrete object to fence: Option B evidence plus
  Option C index.
- R220 identifies the most immediate risk as accidental promotion through
  result/report/smoke/API surfaces, not missing runtime behavior.

---

## Runtime / Evaluator Status

Decision:

```text
runtime/evaluator implementation remains closed.
```

Runtime/evaluator design-only route does not open next.

Accepted rationale:

- live evaluator already has a precise selected-branch-only boundary;
- proof RuntimeMachine already supplies proof-context selected-path evidence;
- Option B projections are explanatory counterfactual evidence, not selected
  runtime execution;
- opening runtime/evaluator work now would blur:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

---

## RuntimeSmoke Status

Decision:

```text
RuntimeSmoke remains proof-context only.
```

Accepted maximum meaning:

- RuntimeSmoke can consume proof-owned `.igapp` artifacts in bounded proof
  context through the proof RuntimeMachine.
- RuntimeSmoke output is not public runtime support.
- RuntimeSmoke output shape remains unchanged.
- RuntimeSmoke must not carry Option B projections or Option D carrier payloads
  without a separate authority route.

---

## CompilerResult / CompilationReport Status

Decision:

```text
CompilerResult and CompilationReport remain closed.
```

`CompilerResult` remains closed because:

- it has no counterfactual fields;
- successful results can include `runtime_smoke`;
- `public_result` strips only `report`, so any new positive field could leak;
- no public/API support is authorized.

`CompilationReport` remains closed because:

- it has no counterfactual/projection fields;
- `runtime_smoke_failure` can turn smoke failure into diagnostics;
- projected failures must not become actual runtime diagnostics.

---

## Dependency / Cache Authority Status

Decision:

```text
dependency/cache authority remains closed.
```

Accepted stance:

- evaluator `call_trace` is proof/debug only;
- proof RuntimeMachine execution trace is proof/debug only;
- Option B projection trace is explanatory evidence only;
- static dependency union remains the compiler/runtime baseline;
- no path-sensitive cache key, invalidation, freshness, dependency truth, or
  TBackend read authority is created by Option B/C.

---

## Remaining Closed Surfaces

Closed:

- live implementation;
- code edits and `lib/**` changes;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator edits;
- runtime/evaluator behavior changes;
- proof RuntimeMachine production use;
- RuntimeSmoke behavior/result-shape changes;
- compiler-emitted artifact authority;
- `CompilerResult` fields;
- `CompilationReport` fields;
- report/result/receipt/CompatibilityReport shape changes;
- diagnostics namespace changes;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- public API/CLI;
- public docs, body spec chapters, and PROP-032;
- Spark authority or integration;
- release evidence, release execution, publish, tag, push, deploy;
- production behavior.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is Runtime/Bridge survey accepted? | Yes. |
| Are C2-P1 facts accepted? | Yes, as current facts basis. |
| May Option D carrier boundary open next? | No. It remains held. |
| May report/API boundary survey open next? | Yes, read-only/design-only. |
| Does runtime/evaluator implementation remain closed? | Yes. |
| Does RuntimeSmoke remain proof-context only? | Yes. |
| Do `CompilerResult` and `CompilationReport` remain closed? | Yes. |
| Does dependency/cache authority remain closed? | Yes. |
| Does live implementation remain closed? | Yes. |
| Does runtime/report/API/public/Spark/release authority remain closed? | Yes. |

---

## Next Dispatch Recommendation

Open:

```text
Card: S3-R221-C1-D
Skill: IDD Agent Protocol
Agent: [Framework Supervisor]
Role: framework-supervisor
Track: counterfactual-audit-report-api-boundary-survey-v0

Route: UPDATE
Depends on:
- S3-R220-C4-A

Goal:
Survey whether CompilerResult, CompilationReport, RuntimeSmoke output,
CompatibilityReport, receipt/result sidecars, public API/CLI, and docs/status
surfaces must remain closed around Option B/C counterfactual audit evidence, or
whether any later design-only non-authority route should open.

Scope:
- Read:
  - igniter-lang/docs/tracks/
    counterfactual-audit-runtime-bridge-architecture-decision-v0.md
  - igniter-lang/docs/tracks/
    counterfactual-audit-runtime-bridge-architecture-survey-v0.md
  - igniter-lang/docs/tracks/
    counterfactual-audit-runtime-bridge-authority-facts-packet-v0.md
  - igniter-lang/docs/discussions/
    counterfactual-audit-runtime-bridge-architecture-pressure-v0.md
  - igniter-lang/docs/tracks/
    counterfactual-audit-runtime-report-api-gate-survey-v0.md
  - igniter-lang/lib/igniter_lang/compiler_result.rb
  - igniter-lang/lib/igniter_lang/compilation_report.rb
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
  - igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
- Survey:
  - whether `CompilerResult` must remain closed to Option B fields;
  - whether `CompilationReport` must remain closed to projected values/failures;
  - whether RuntimeSmoke output must remain selected-execution proof-context
    only;
  - whether `CompilerResult.public_result` deny-one filtering requires an
    allow-list or stricter future fence before any positive field design;
  - whether CompatibilityReport, receipt/result sidecars, public API/CLI, and
    docs/status surfaces remain closed;
  - whether any later design-only route is justified, or whether all
    report/API surfaces should remain held.
- Preserve:
  - Option B proof-owned/non-canonical/evidence-only status;
  - Option C discoverability-only status;
  - Option D held;
  - runtime/evaluator implementation closed;
  - RuntimeSmoke proof-context-only status;
  - dependency/cache authority closed;
  - public/Spark/release claims closed.

Do not:
- edit code;
- authorize implementation;
- authorize report/result/API field changes;
- authorize RuntimeSmoke behavior or result-shape changes;
- authorize public docs/body spec edits;
- authorize Spark, release, production, or public claims.

Deliver:
- Survey doc in `igniter-lang/docs/tracks/`
- Compact report/API boundary matrix
- Exact next-route recommendation for Portfolio decision
```

Do not open next:

- Option D carrier design;
- runtime/evaluator design or implementation;
- RuntimeSmoke feature-support route;
- compiler-emitted artifact route;
- report/result/receipt field implementation;
- public API/CLI/Spark/demo/release route.
