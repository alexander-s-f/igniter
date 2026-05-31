# Counterfactual Audit Report API Boundary Pressure v0

Card: S3-R221-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: counterfactual-audit-report-api-boundary-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R221-C1-D
- S3-R221-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/counterfactual-audit-report-api-boundary-survey-v0.md` (C1-D)
- `igniter-lang/docs/tracks/counterfactual-audit-report-api-exposure-facts-packet-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-architecture-decision-v0.md` (R220-C4-A)
- `igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-acceptance-decision-v0.md` (R219-C4-A)

---

## Risk Matrix

| Risk | Probability | Severity | C1-D / C2-P1 fence | Residual |
| --- | --- | --- | --- | --- |
| Option B field added to `CompilerResult` becomes public via `public_result` deny-one filter | High if any field proposed | Critical | C1-D: "field_leak_risk: high for any positive CompilerResult/API field; safe_next: hold"; C2-P1: exact 15-key list for `ok`, exact mechanism named (`result.reject { \|key,_\| key == "report" }`) | Very low — no field proposed |
| `projected_failure` routed into `CompilationReport.runtime_smoke_failure` and persisted as refusal | Medium if unfenced | High | C1-D: explicitly forbidden; C2-P1: `runtime_smoke_failure` shape confirmed from source | Low — fence explicit |
| RuntimeSmoke carries Option B/D projection payload into `CompilerResult.ok.runtime_smoke` | Medium if callback misused | High | C1-D: "RuntimeSmoke output must remain selected-execution proof-context only"; C2-P1: both success-payload and failure-diagnostic paths named | Low — no payload route proposed |
| CLI prints new counterfactual key in `public_result` JSON | High if any field added | High | C2-P1: `igc compile` + `cli.rb` source confirms CLI prints `public_result` as JSON; no counterfactual flag exists | Very low — no field, no flag |
| PROP-038 nested-validation precedent misread as Option B/C authorization | Low | Medium | C1-D: "Separate precedent; not Option B authority"; C2-P1: `report_only: true` label confirmed from source; explicitly fenced in both documents | Very low |
| CompatibilityReport readiness vocabulary overstates projection evidence | Low | Medium | C1-D: "Compatibility/readiness vocabulary would overstate counterfactual projection evidence"; C2-P1: only `compatibility_report_status` string key in RuntimeSmoke output | Very low |
| Option D carrier opened prematurely via report/API pressure | Very low | Medium | C1-D boundary matrix: "Held; No consumer; wait until after boundary acceptance"; C1-D design-only assessment: no consumer identified | Very low |
| Receipt/result sidecars acquire persistence authority | Very low | High | C1-D: "No report/result/receipt sidecar design route should open next"; C2-P1: no sidecar currently exists in lane | Very low |
| Option C docs/status index becomes pseudo-public canon | Very low | Medium | C1-D: "internal docs/status remains allowed only as discoverability and route memory"; C2-P1: docs/status pseudo-public drift fenced | Very low |
| Ordinary refusal report sidecar path misread as counterfactual model | Very low | Low | C2-P1: refusal sidecar is existing PROP-038 compiler path; no counterfactual refusal report creation | Very low |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Option B remains proof-owned / non-canonical / evidence-only | C1-D "Accepted Fixed Point" restates R220 accepted posture; surface map: "Closed to runtime, report, API, public, Spark, compiler-emitted, cache/dependency, production authority"; no-authority flags carried from R218 | Fixed point is accurately reproduced. Neither document introduces new authority for Option B. | ✅ SAFE |
| Option C remains discoverability-only | C1-D docs/status surface assessment: "internal docs/status remains allowed only as discoverability and route memory"; C2-P1: "Option C docs/status is accepted as internal discoverability aid only; internal only; public docs/body spec remain closed" | Correctly preserved. | ✅ SAFE |
| `CompilerResult` stays closed to counterfactual fields | C1-D field-leak risk assessment: "field_leak_risk: high / safe_next: hold all report/API field design"; public-result exposure assessment states the exact deny-one code and names four prerequisites for any future field; C2-P1: exact 15-key `ok` and 13-key `refusal` shapes confirmed from source; no counterfactual key in either | Closure is source-grounded and technically justified. The deny-one mechanism is correctly identified as the governing constraint. | ✅ SAFE |
| `CompilationReport` stays closed to projected values / failures | C1-D: "projected failures must not become actual runtime diagnostics"; RuntimeSmoke/report diagnostic promotion section lists six explicitly forbidden routing paths including `projected_failure` into `runtime_smoke_failure`; C2-P1: `runtime_smoke_failure` source behavior confirmed: merges `pass_result: error` and appends `Diagnostics.from_runtime_smoke(smoke)` | Projection/diagnostic promotion path is correctly fenced with source evidence. | ✅ SAFE |
| RuntimeSmoke output stays proof-context only | C1-D: "RuntimeSmoke output must remain selected-execution proof-context only"; C2-P1: success output keys confirmed (load_status, contract_id, evaluate_status, outputs, compatibility_report_status, trusted); no projection key in success output; RuntimeSmoke identified as "highest-risk accidental carrier" | The maximum accepted meaning is accurately preserved. | ✅ SAFE |
| Public-result filtering risk correctly assessed | C1-D quotes actual Ruby code `result.reject { \|key, _value\| key == "report" }`; names exact future prerequisites: public key-set, allow-list, explicit exposure decision, regression proof; C2-P1 confirms: `runtime_smoke` is in `ok` keys and survives `public_result`; CLI prints `public_result` as JSON | Source-grounded. The deny-one risk is the strongest finding in the packet and both documents treat it seriously. | ✅ SAFE |
| Receipt / result / API / CompatibilityReport routes remain closed | C1-D boundary matrix: all six rows closed as "Not next" with specific required triggers; C2-P1: "No counterfactual `CompatibilityReport` object exists; No counterfactual receipt/result sidecar exists" confirmed from lane survey | Closures are accurately stated and source-grounded. | ✅ SAFE |
| Option D carrier remains held | C1-D boundary matrix: "Held; No consumer; wait until after boundary acceptance"; design-only route assessment: "a concrete internal consumer is identified" is listed as a prerequisite before any later design-only route; C2-P1 surface authority table: "Held; no accepted carrier boundary" | Correctly held. No consumer has been identified, satisfying the primary hold criterion. | ✅ SAFE |
| Implementation and public claims remain closed | C1-D closed-surface matrix: 15 rows covering all surfaces; C2-P1 closed surfaces: 20 items; both read-only survey documents, zero file changes in C1-D; C2-P1 workspace confirmed clean before packet | Comprehensive closure in both documents, consistent with R220-C4-A accepted state. | ✅ SAFE |
| No design-only report/API route opens next | C1-D design-only route assessment: "No. All report/API field and sidecar design routes should remain held."; rationale: no accepted consumer, B/C already sufficient, positive field design would trigger public key-set / diagnostics / sidecar decisions; C2-P1 concludes "any future positive counterfactual field must first address public key-set, CLI visibility, RuntimeSmoke carrier risk" | The "hold" decision is well-reasoned: the lane has a stable resting state with B/C, and no trigger exists for opening a design route. This is the correct outcome. | ✅ SAFE |

---

## C1-D Assessment: Report / API Boundary Survey

**Finding: safe to accept.**

The survey correctly maps every exposure point through which Option B evidence could accidentally acquire report/API/public authority. The three most important findings are exact and technically grounded:

1. **`CompilerResult.public_result` deny-one**: the exact Ruby code is quoted, the consequence (all new top-level keys become public by default) is correctly stated, and four specific prerequisites are named for any future field route. This is not generic caution — it is a precise architectural observation that will govern any future work in this area.

2. **RuntimeSmoke dual-path risk**: the full sequence from `RuntimeSmoke.callback` through `CompilerOrchestrator.compile` to either `CompilerResult.ok.runtime_smoke` (success) or `CompilationReport.runtime_smoke_failure` (failure) is mapped and explicitly closed for Option B/C payloads. Both paths are closed.

3. **Design-only route hold**: the "no consumer" criterion for holding the design route is the correct gate. Option B/C provide sufficient internal evidence and discoverability. Without a consumer, opening a design route adds process cost without product benefit.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Report / API Exposure Facts Packet

**Finding: safe to accept as accurate facts basis.**

C2-P1 is the most source-grounded document in the lane. It reads 7 source files (`compiler_result.rb`, `compilation_report.rb`, `runtime_smoke.rb`, `compiler_orchestrator.rb`, `igniter_lang.rb`, `cli.rb`, `bin/igc`) and records exact current shapes.

Three facts are critical for C4-A:

1. **Exact `CompilerResult.ok` key set (15 keys)**: `runtime_smoke` is in the list and survives `public_result`. This means trusted smoke is already CLI-visible. Any future counterfactual field would join `runtime_smoke` in that exposure unless the public-result contract changes.

2. **CLI path is fully confirmed**: `igc compile` → `IgniterLang.compile` → `CompilerResult.public_result(...)` printed as JSON. The chain from any new result key to CLI output is one function call. No ambiguity.

3. **No counterfactual surface currently exists in any shape**: no `projected_value`, no `projected_failure`, no Option B manifest reference, no counterfactual flag appears in any of the 7 source files. The lane is clean.

The PROP-038 precedent fence is correctly handled: `with_compiler_profile_contract_validation` adds `report_only: true` data, which is explicitly labeled as a PROP-038-specific surface and not Option B/C authorization. This closes the most likely misreading.

**C2-P1 verdict: accept as accurate facts basis.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D route recommendation safe? | Yes. Read-only, no code changes, technically grounded decision to hold all report/API field design, correct identification of deny-one and RuntimeSmoke dual-path risks. |
| Are C2-P1 facts sufficient? | Yes. Source-grounded from 7 files, exact key shapes confirmed, CLI exposure chain confirmed, no counterfactual surface found in any shape. |
| Does any blocker require another survey first? | No. The report/API boundary survey is the natural stopping point. No consumer triggers further design work. |
| What exact route should C4-A prefer? | Accept C1-D + C2-P1, hold all report/API field and sidecar design routes, proceed to status curation. No design route should open. |

---

## Verdict

```text
PASS

C1-D Report/API boundary survey: accept
C2-P1 exposure facts packet: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. No non-blocking acceptance notes.

The lane has reached a stable hold point: Option B (proof-owned artifact home), Option C (docs/status index), and the current boundary surveys provide sufficient scoping for now. No consumer has been identified that would justify opening a report/API design route. This is the correct outcome.

---

## Recommendation for S3-R221-C4-A

```text
Card: S3-R221-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D report/API boundary survey
- C2-P1 exposure facts packet as accurate facts basis

Routing decision:
- Hold all report/API field and sidecar design routes
- No design-only report/API route opens from this survey
- Proceed to status curation (stage3-round221-status-curation-v0)

Keep closed:
- CompilerResult Option B fields (deny-one public_result risk)
- CompilationReport projected value/failure diagnostics
- RuntimeSmoke Option B/D payload (success-payload and failure-diagnostic paths)
- CompatibilityReport, receipt/result sidecars
- Public API/CLI counterfactual surface
- Option D carrier (held; no consumer)
- All lib/** implementation
- All public/Spark/API/release claims
```
