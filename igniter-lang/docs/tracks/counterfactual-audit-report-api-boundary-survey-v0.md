# Counterfactual Audit Report API Boundary Survey v0

Card: S3-R221-C1-D
Skill: IDD Agent Protocol
Agent: [Framework Supervisor]
Role: framework-supervisor
Track: counterfactual-audit-report-api-boundary-survey-v0
Route: UPDATE
Status: done / design-survey-only
Date: 2026-05-31

Depends on:
- S3-R220-C4-A

---

## IDD Lane Classification

Lane:

```text
standard
```

Reason:

- this is a read-only report/API boundary survey;
- it produces one internal track doc;
- it does not edit code, field shapes, runtime behavior, public docs, body spec
  chapters, Spark surfaces, release evidence, or production claims.

---

## IDD Evidence / Decision / Next Contract

Evidence:

- Source: accepted R220 Runtime/Bridge decision and facts packet; current
  `CompilerResult`, `CompilationReport`, `RuntimeSmoke`, and
  `CompilerOrchestrator` source surfaces; prior public-result/diagnostics
  exposure survey precedent.
- Scope: Option B/C counterfactual audit evidence around report/result/API
  exposure points.
- Strongest facts: `CompilerResult.public_result` strips only `report`;
  `CompilerResult.ok` can expose `runtime_smoke`; `CompilationReport` can turn
  failed smoke into diagnostics; RuntimeSmoke remains proof-context only.
- Missing / ambiguous: no accepted report/API consumer exists for Option B
  evidence; no accepted public/internal field contract exists.

Decision:

- Status: pass / hold report-API field design.
- Why: current surfaces are easy to leak through and provide no safe positive
  field path without a separate authority decision.
- Evidence only: Option B artifact home, Option C index, RuntimeSmoke proof
  output, proof RuntimeMachine observations/receipts, PROP-038 report-only
  precedent.
- Authority remains: no report, result, API, receipt, CompatibilityReport,
  RuntimeSmoke shape, public, Spark, release, dependency, cache, or production
  authority.

Next contract:

- Card/doc: `counterfactual-audit-report-api-boundary-decision-v0`.
- Allowed: Portfolio acceptance/hold decision over this survey.
- Closed: code edits, field design, result/report/receipt sidecars,
  RuntimeSmoke changes, public docs/body spec edits, Spark, release/public
  claims.
- Verification: explicit closed-surface matrix and yes/no answers.

---

## Purpose

Survey whether `CompilerResult`, `CompilationReport`, RuntimeSmoke output,
CompatibilityReport, receipt/result sidecars, public API/CLI, and docs/status
surfaces must remain closed around Option B/C counterfactual audit evidence, or
whether any later design-only non-authority route should open.

This document is a boundary survey only. It does not authorize implementation,
field changes, result/report/API design, RuntimeSmoke behavior changes, public
docs/body spec edits, Spark, release, production, or public claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round220-status-curation-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-architecture-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-architecture-survey-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-authority-facts-packet-v0.md`
- `igniter-lang/docs/discussions/counterfactual-audit-runtime-bridge-architecture-pressure-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `igniter-lang/docs/tracks/prop038-public-result-and-diagnostics-proof-surface-survey-v0.md`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/internal_profile_assembly.rb`
- `igniter-lang/docs/current-status.md`

---

## Accepted Fixed Point

From R220:

- Runtime/Bridge architecture survey accepted.
- Runtime/Bridge authority facts packet accepted as current facts basis.
- Report/API boundary survey may open next as read-only/design-only.
- Option B remains proof-owned, non-canonical, evidence-only.
- Option C remains internal docs/status discoverability-only.
- Option D remains held.
- Runtime/evaluator implementation remains closed.
- RuntimeSmoke remains proof-context only.
- `CompilerResult` and `CompilationReport` remain closed.
- Dependency/cache authority remains closed.
- Public/Spark/API/release claims remain closed.

This survey does not amend those accepted decisions.

---

## Compact Report / API Surface Map

| Surface | Current shape | Option B/C leak risk | R221 boundary |
| --- | --- | --- | --- |
| `CompilerResult.ok` | Internal success result includes `runtime_smoke` and `report`; no counterfactual fields. | Option B evidence could be added as a positive result key or smuggled through `runtime_smoke`. | Closed to Option B fields. |
| `CompilerResult.refusal` | Refusal result includes `compilation_report_path`, diagnostics, warnings, and internal `report`. | Projected failure could become public refusal evidence or persisted report path. | Closed to projected failure/value fields. |
| `CompilerResult.strict_terminal` | Non-persisting PROP-038 terminal result with explicit diagnostics and no report path. | Could be copied as a model for counterfactual terminal evidence. | PROP-038-only precedent; no counterfactual authority. |
| `CompilerResult.public_result` | Deny-one filter: removes only `report`. | Any new top-level key becomes public by default. | Requires future allow-list or exact public-key-set fence before any positive field design. |
| `CompilationReport.runtime_smoke_failure` | Converts untrusted smoke into diagnostics and error report. | `projected_failure` could be misclassified as actual runtime smoke failure. | Closed; projected failure is not an actual runtime diagnostic. |
| `CompilationReport.with_compiler_profile_contract_validation` | Adds nested `report_only` PROP-038 validation data. | Could tempt nested counterfactual report fields. | Separate precedent; not Option B authority. |
| `RuntimeSmoke.run` | Proof-backed selected execution smoke output: statuses, outputs, compatibility status, trusted boolean. | Could carry Option B projections into result/report surfaces. | Proof-context only; no Option B/Option D payloads. |
| `CompilerOrchestrator.compile` | Optional `runtime_smoke` callback after assembly; failed smoke becomes report refusal. | Option B callback could become compile gate or public result payload. | Do not route Option B evidence through runtime smoke callbacks. |
| CompatibilityReport | Existing docs/proofs use report-only readiness and compatibility concepts in other lanes. | Counterfactual evidence could be mistaken for readiness/compatibility metadata. | Closed to Option B/C. |
| Receipt/result sidecars | Existing compiler and runtime lanes have proof/report/receipt precedents. | Proof projections could gain durable receipt/report authority. | Closed; no sidecar route. |
| Public API/CLI | CLI/public result key shape follows `CompilerResult.public_result`. | New fields or docs could become public support claims. | Closed; no public API/CLI support. |
| Docs/status surfaces | Option C index and current-status entries are internal discoverability only. | Canon by repetition or status wording could imply support. | Internal index/status only; no public docs/body spec edits. |

---

## Field-Leak Risk Assessment

| Risk | Probability if a field is proposed | Severity | Current fence | Assessment |
| --- | --- | --- | --- | --- |
| New `CompilerResult` key becomes public | High | High | `public_result` strips only `report` | No positive field design should open without exact key-set/allow-list decision. |
| Option B via `runtime_smoke` result slot | Medium | High | RuntimeSmoke proof-context-only status | Keep RuntimeSmoke output closed to Option B projections. |
| Projected failure becomes runtime diagnostic | Medium | High | `projected_failure != actual_runtime_failure` | Keep `CompilationReport.runtime_smoke_failure` closed. |
| Nested report-only precedent reused | Medium | Medium | PROP-038-only non-authority precedent | Do not add nested counterfactual report fields. |
| CompatibilityReport treated as safe sidecar | Medium | Medium | CompatibilityReport closed for this lane | Keep closed until a separate report/result/receipt route exists. |
| Internal docs/status becomes public/canonical | Low | Medium | Option C discoverability-only wording | Keep all docs/status references internal and negative-authority. |

Conclusion:

```text
field_leak_risk: high for any positive CompilerResult/API field
safe_next: hold all report/API field design
```

---

## Public Result Exposure Assessment

Current code:

```ruby
def public_result(result)
  result.reject { |key, _value| key == "report" }
end
```

Meaning:

- public result exposure is deny-one, not allow-list;
- `runtime_smoke` is already public on successful results;
- any future top-level counterfactual field would be public unless the
  filtering contract changes first;
- nested data inside non-`report` fields is also exposed by default.

Decision:

```text
CompilerResult must remain closed to Option B fields.
```

Future prerequisite if any positive field route is ever proposed:

- exact public key-set design;
- allow-list or stricter public/private fence;
- explicit decision on whether the field is internal-only, public, persisted,
  or CLI-visible;
- regression proof that existing success/refusal public key sets remain
  unchanged unless explicitly authorized.

This prerequisite is not authorized by this card.

---

## RuntimeSmoke / Report Diagnostic Promotion Assessment

Current path:

```text
RuntimeSmoke.callback
  -> CompilerOrchestrator.compile(runtime_smoke:)
  -> smoke = runtime_smoke.call(...)
  -> CompilerResult.ok(... runtime_smoke: smoke)
  -> if !trusted: CompilationReport.runtime_smoke_failure(...)
```

Promotion hazards:

- a successful smoke result can become public through `CompilerResult.ok`;
- a failed smoke result can become report diagnostics and refusal report;
- RuntimeSmoke output names `outputs`, `compatibility_report_status`, and
  `trusted`, which are selected-execution proof-context signals, not
  counterfactual projection signals.

Decision:

```text
RuntimeSmoke output must remain selected-execution proof-context only.
CompilationReport must remain closed to projected values and failures.
```

Forbidden by this survey:

- `projected_value` inside RuntimeSmoke output;
- `projected_failure` inside RuntimeSmoke output;
- Option B manifest/projection payload inside RuntimeSmoke output;
- Option D carrier payload inside RuntimeSmoke output;
- counterfactual projected failure converted to
  `CompilationReport.runtime_smoke_failure`;
- counterfactual projected value/failure converted to top-level diagnostics.

---

## CompatibilityReport / Sidecar / Receipt Assessment

Current evidence:

- CompatibilityReport-like surfaces exist in other tracks as report-only or
  readiness evidence.
- RuntimeSmoke output includes `compatibility_report_status` from proof resume
  status.
- Proof RuntimeMachine may emit receipt-like observations in proof memory.

Decision:

```text
CompatibilityReport, receipt/result sidecars, and durable report surfaces remain closed.
```

Reason:

- Option B is evidence-only, not readiness metadata.
- Proof receipts/observations are proof-local, not durable audit receipts.
- Compatibility/readiness vocabulary would overstate counterfactual projection
  evidence.
- Sidecars would imply persistence/report authority not accepted by B/C.

No report/result/receipt sidecar design route should open next.

---

## Docs / Status Surface Assessment

Option C is accepted as:

```text
internal docs/status discoverability aid only
not canonical authority
not artifact authority
```

Docs/status surfaces may continue to record:

- accepted evidence anchors;
- no-authority flags;
- next route and closed surfaces;
- digest references as evidence anchors.

Docs/status surfaces must not record:

- public support claims;
- canonical artifact claims;
- runtime/report/API support claims;
- Spark support or production readiness;
- public docs/body spec wording;
- positive `CompilerResult` / `CompilationReport` field promises.

Decision:

```text
internal docs/status remains allowed only as discoverability and route memory.
public docs/body spec remain closed.
```

---

## Compact Report / API Boundary Matrix

| Boundary | Status | Later route allowed? | Required trigger |
| --- | --- | --- | --- |
| `CompilerResult` Option B fields | Closed | Not next | Concrete consumer plus public key-set/allow-list gate. |
| `CompilationReport` projected values/failures | Closed | Not next | Separate diagnostics/report schema gate and non-actual wording proof. |
| RuntimeSmoke Option B payload | Closed | Not next | Separate RuntimeSmoke authority route; not recommended. |
| `CompilerResult.public_result` allow-list/fence | Closed as implementation; design prerequisite only | Later, only if a positive field route is proposed | Exact key-set exposure decision. |
| CompatibilityReport metadata | Closed | Not next | Separate compatibility/readiness authority route. |
| Receipt/result sidecars | Closed | Not next | Separate receipt/persistence semantics route. |
| Public API/CLI | Closed | Not next | Public API/CLI authority decision and release/support boundary. |
| Internal docs/status | Open only as discoverability | Yes, for status curation only | Keep no-authority flags and internal scope. |
| Public docs/body spec | Closed | Not next | Separate public/spec route. |
| Option D carrier | Held | Not next | Concrete internal consumer after report/API boundary acceptance. |

---

## Design-Only Route Assessment

Question:

```text
Should any report/API design-only route open next?
```

Answer:

```text
No. All report/API field and sidecar design routes should remain held.
```

Rationale:

- The survey found no accepted consumer requiring report/API fields.
- Option B artifact home already carries proof-owned evidence.
- Option C already carries internal discoverability.
- Option D remains held and has no accepted consumer.
- Positive field design would immediately require public key-set, diagnostics,
  sidecar persistence, and support-claim decisions.
- The lowest-risk next movement is Portfolio acceptance of this boundary and
  status curation, not another design route.

Later design-only route may be justified only if all are true:

- a concrete internal consumer is identified;
- C4-A or later authority decides that proof-owned artifact home plus index are
  insufficient;
- public result exposure is fenced before any result-field proposal;
- projected value/failure wording remains non-actual;
- RuntimeSmoke remains out of the carrier path.

---

## Closed-Surface Matrix

| Surface | R221 status | Reason |
| --- | --- | --- |
| Code / `lib/**` edits | Closed | Survey-only card. |
| `CompilerResult` fields | Closed | Public-result leak risk. |
| `CompilationReport` fields | Closed | Projected failures must not become diagnostics. |
| RuntimeSmoke behavior/result shape | Closed | Proof-context only. |
| CompilerOrchestrator callback behavior | Closed | Option B must not become compile gate. |
| CompatibilityReport | Closed | No readiness/report authority. |
| Receipt/result sidecars | Closed | No persistence/receipt authority. |
| Public API/CLI | Closed | No public support claim. |
| Internal docs/status | Limited-open | Discoverability and route memory only. |
| Public docs/body spec/PROP-032 | Closed | No public/spec mutation. |
| Option D carrier | Held | No consumer; wait until after boundary acceptance. |
| Runtime/evaluator implementation | Closed | Out of scope and already held by R220. |
| Dependency/cache authority | Closed | Traces remain proof/debug only. |
| Spark | Closed | No Spark authority or integration. |
| Release/public claims | Closed | No release evidence/execution or support claim. |
| Production behavior | Closed | No production semantics. |

---

## Exact Explicit Answers

| Question | Answer |
| --- | --- |
| Is report/API boundary survey sufficient for this round? | Yes. It maps exposure points and reaches a hold decision without code or field changes. |
| Must `CompilerResult` remain closed? | Yes. No Option B fields; any future positive field requires public key-set/allow-list gate first. |
| Must `CompilationReport` remain closed? | Yes. No projected values/failures; no counterfactual diagnostics. |
| Must RuntimeSmoke output remain proof-context only? | Yes. Selected-execution proof-context only; no Option B/Option D payload. |
| May any report/API design-only route open next? | No. Hold all report/API field, sidecar, public API, and RuntimeSmoke-carrier design routes. |
| Does Option D carrier remain held? | Yes. |
| Does runtime/report/API authority remain closed? | Yes. |
| Does public/Spark/release authority remain closed? | Yes. |

---

## Recommended Next Route For Portfolio Decision

Open next:

```text
Card: S3-R221-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-report-api-boundary-decision-v0
Route: UPDATE
Depends on:
- S3-R221-C1-D
```

Acceptance recommendation:

```text
accept report/API boundary survey
hold all report/API field and sidecar design routes
keep CompilerResult closed
keep CompilationReport closed
keep RuntimeSmoke proof-context only
keep Option D held
keep internal docs/status as discoverability only
keep public/Spark/API/release claims closed
```

Recommended after C4-A:

```text
stage3-round221-status-curation-v0
```

No implementation or design-field route should open from this survey.

---

## Command / Evidence Matrix

| Command / read | Result |
| --- | --- |
| `sed -n` reads for R220 status, decision, survey, facts packet, pressure, prior gate survey | PASS; R220 accepted report/API survey as next read-only route. |
| `sed -n` reads for `compiler_result.rb`, `compilation_report.rb`, `runtime_smoke.rb`, `compiler_orchestrator.rb` | PASS; result/report/smoke exposure points mapped. |
| `rg -n "CompatibilityReport\|compatibility_report\|receipt\|sidecar\|public_result..." igniter-lang/lib igniter-lang/docs/tracks ...` | PASS; relevant precedents and closed surfaces located. |
| `sed -n` read of `prop038-public-result-and-diagnostics-proof-surface-survey-v0.md` | PASS; deny-one public result and nested diagnostics precedent confirmed. |
| `sed -n` read of `internal_profile_assembly.rb` | PASS; internal-only closed-surface pattern confirmed as analogy only. |

No executable proof was required or run. No code, public docs, body spec
chapters, result/report/API surfaces, RuntimeSmoke behavior, Spark surfaces, or
release artifacts were changed.

---

## Compact Handoff

```text
[Framework Supervisor]
Track: counterfactual-audit-report-api-boundary-survey-v0
Status: done

[D] Decisions:
- Report/API boundary survey is sufficient for this round.
- CompilerResult remains closed.
- CompilationReport remains closed.
- RuntimeSmoke output remains proof-context only.
- No report/API design-only route should open next.
- Option D remains held.
- Runtime/report/API/public/Spark/release authority remains closed.

[R] Recommendation:
- Open C4-A acceptance decision, then status curation.
- Do not open result/report/API field design, RuntimeSmoke carrier design, or
  Option D carrier design yet.

[S] Signals:
- `CompilerResult.public_result` is deny-one and exposes new keys by default.
- `RuntimeSmoke` already has result and failure-diagnostic promotion paths.
- PROP-038 report-only precedent is separate and does not authorize
  counterfactual report fields.

[T] Tests / Proofs:
- Read-only survey only; no executable proof required.

[Files] Changed:
- igniter-lang/docs/tracks/counterfactual-audit-report-api-boundary-survey-v0.md

[X] Rejected / held:
- CompilerResult Option B fields.
- CompilationReport projected value/failure fields.
- RuntimeSmoke Option B/Option D payload.
- CompatibilityReport, receipt/result sidecars.
- Public API/CLI/Spark/release claims.
```

