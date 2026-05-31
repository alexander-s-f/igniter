# Counterfactual Audit Runtime Bridge Architecture Pressure v0

Card: S3-R220-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: counterfactual-audit-runtime-bridge-architecture-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R220-C1-D
- S3-R220-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-architecture-survey-v0.md` (C1-D)
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-authority-facts-packet-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-acceptance-decision-v0.md` (R219-C4-A)
- `igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-acceptance-decision-v0.md` (R218-C4-A)

---

## Risk Matrix

| Risk | Probability | Severity | C1-D / C2-P1 fence | Residual |
| --- | --- | --- | --- | --- |
| Option B promoted to runtime/report/API authority | Low | High | C1-D closes all routes from B into evaluator, smoke, CompilerResult, CompilationReport, diagnostics, and public API; C2-P1 maps each surface with authority-confusion risk | Low |
| Option C creates canon by repetition | Low | Medium | C1-D surface map entry explicitly "not artifact authority"; C2-P1 hotspot: "Index remains discoverability-only" | Low |
| Option D opened prematurely | Very low | Medium | C1-D: "not structurally needed yet"; explicit rationale (no accepted consumer, leakage risk before report/API survey); held in closed-surface matrix | Very low |
| RuntimeSmoke becomes Option B carrier | Medium if unfenced | High | C1-D RuntimeSmoke assessment: "must not carry Option B projections or Option D carrier payloads without separate authority route"; C2-P1 hotspot marks it as "highest accidental promotion path" | Low — fence explicit |
| `CompilerResult.public_result` leaks counterfactual fields | Medium if any field added | High | C1-D: "Any later field design requires a separate report/API boundary decision"; C2-P1: deny-one filtering identified as high-risk vector, exact mechanism named | Low — no fields added; survey queued |
| `CompilationReport.runtime_smoke_failure` promotes projected failure | Low | High | C1-D: "Projected failure is not actual runtime failure; no diagnostics route without separate gate"; C2-P1 hotspot entry with exact mechanism | Low |
| PROP-038 nested-validation precedent misapplied | Very low | Medium | C2-P1 hotspot: "Report-only precedent is not counterfactual field authority"; C1-D does not conflate PROP-038 with counterfactual evidence | Very low |
| Dependency/cache authority inferred from traces | Low | Medium | C1-D: "dependency/cache authority remains closed; traces remain proof/debug only"; C2-P1: `call_trace` hotspot entry "not cache/dependency authority" | Low |
| Runtime/evaluator implementation pressure from TTM | Low | High | C1-D explicitly names and rejects "runtime/evaluator design-only route" as next step, with specific technical reasons (selected-branch boundary already precise; opening blurs projected/actual) | Very low |
| TTM over-conservatism (no forward movement) | Very low | Medium | Report/API boundary survey opens a concrete forward path; C1-D TTM reasoning is sound | Very low |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Option B remains proof-owned / non-canonical / evidence-only | C1-D "Accepted Fixed Point": all 9 no-authority flags false; surface map for Option B: "non-canonical evidence only"; C2-P1 surface authority table: "Proof-owned, non-canonical evidence only / Closed to runtime, report, API, public, Spark, compiler-emitted, cache/dependency, production authority" | Option B's accepted status is correctly carried forward unchanged. Neither document introduces any new authority for Option B artifacts. | ✅ SAFE |
| Option C remains discoverability-only | C1-D surface map: "Accepted only as index; not artifact authority"; C2-P1: "Closed to canonical/artifact authority and all runtime/report/API surfaces" | Option C's accepted class (discoverability aid, not authority) is preserved. | ✅ SAFE |
| Option D justified to remain held | C1-D: "not structurally needed yet"; rationale: no accepted consumer, opening before report/API survey increases leakage risk into CompilerResult/CompilationReport/RuntimeSmoke/receipts; C2-P1: "Held; not root-required, not compiler-consumed, not report/projected" | The hold decision is specific and technically grounded. The absence of a concrete consumer is a clean criterion for holding. Accepted. | ✅ SAFE |
| Report/API boundary survey timing justified | C1-D "Report / API Timing Assessment": three concrete reasons — R215 listed it as gate blocker, R218/R219 give the survey a concrete fencing target, accidental promotion is more immediate than missing carrier; C2-P1 confirms exact promotion mechanisms (deny-one filtering, smoke_failure path, nested validation precedent) | Timing is sound. The survey does not open implementation; it maps risk. Opening it now reduces reconstruction cost without weakening proof quality. | ✅ SAFE |
| Runtime / evaluator implementation remains closed | C1-D "Runtime / Evaluator Recommendation": closed, with specific technical reasons (selected-branch boundary already precise, opening blurs projected_value != actual_output invariant); C2-P1: "runtime/evaluator behavior changes" in closed surfaces | Closure is technically motivated, not just stated. The explanation that opening runtime/evaluator design would blur the projected/actual distinction is exactly right. | ✅ SAFE |
| RuntimeSmoke stays proof-context only | C1-D "RuntimeSmoke Assessment": "must not carry Option B projections or Option D carrier payloads without a separate authority route; result shape unchanged"; C2-P1 hotspot: "RuntimeSmoke already bridges proof RuntimeMachine output into compiler result/smoke failure paths, so it must not carry Option B projection evidence by default" | Correctly identified as the highest accidental promotion vector. Closure is specific and grounded in the existing callback/result-slot architecture. | ✅ SAFE |
| CompilerResult stays closed | C1-D: closed; "public_result strips only report, so any new positive field could leak"; C2-P1: deny-one filtering mechanism named; no counterfactual fields present | Closure is technically accurate. The deny-one risk of `public_result` is a real architectural constraint correctly identified by both documents. | ✅ SAFE |
| CompilationReport stays closed | C1-D: closed; "projected failures must not become actual runtime diagnostics"; C2-P1: `runtime_smoke_failure` path named as hotspot | Closure is technically grounded. The promotion path from projected failure to smoke failure to diagnostics is correctly identified and fenced. | ✅ SAFE |
| Dependency / cache / public / Spark / release claims closed | C1-D closed-surface matrix: all six categories explicitly closed; C2-P1 closed surfaces list | Comprehensive closure across all categories consistent with prior rounds. | ✅ SAFE |
| Next route improves TTM without weakening proof quality | C1-D: report/API boundary survey is read-only/design-only; C2-P1 facts basis maps concrete leakage vectors the survey should address; survey has bounded scope (read-only, no code edits, no field changes) | The survey opens a forward path without implementation. TTM benefit is route clarity, not implementation shortcut. Proof-quality invariants remain intact. | ✅ SAFE |

---

## C1-D Assessment: Runtime / Bridge Architecture Survey

**Finding: safe to accept.**

The survey is well-scoped (one track doc, read-only) and correctly distinguishes between where runtime execution meaning and evidence meaning exist. The seven-row accidental promotion path table is valuable — it names each leak vector with enough specificity to serve as a fence for the subsequent report/API boundary survey.

The Option D "not structurally needed yet" decision is correctly grounded in two independent reasons: no accepted internal consumer and leakage risk before the report/API survey closes. Both reasons would independently justify holding.

The "Why now" reasoning for the report/API boundary survey is the strongest part of C1-D: it connects the prior gate requirement (R215), the newly available fencing target (Option B/C evidence), and the immediate risk (promotion through existing result/smoke surfaces). This is the right sequencing logic.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Runtime Bridge Authority Facts Packet

**Finding: safe to accept as accurate facts basis.**

The facts are grounded in direct reads of six source files (evaluator, compiled_program, runtime_smoke, compiler_orchestrator, compiler_result, compilation_report). The 18-row surface authority table covers every surface that could create accidental authority for Option B evidence.

Three facts stand out as particularly important for C4-A:

1. **RuntimeSmoke callback + result slot**: RuntimeSmoke already has a compiler callback boundary and a `CompilerResult.ok` result slot. This means adding Option B evidence to RuntimeSmoke would require no new plumbing — it could happen by accident through an unreviewed callback assignment. The explicit fence ("must not carry Option B projections without a separate gate") is load-bearing.

2. **CompilerResult.public_result deny-one filtering**: New positive keys in `CompilerResult` are exposed by default because `public_result` only strips `report`. This is an architectural constraint that makes future positive counterfactual fields automatically high-risk. The report/API boundary survey is the right instrument to map this before any field is proposed.

3. **PROP-038 nested-validation fence**: C2-P1 correctly identifies that the nested report-only validation pattern exists for PROP-038 but explicitly states it does not authorize counterfactual nested report fields. This is a subtle but important fence: a future author could look at PROP-038's `with_compiler_profile_contract_validation` and see a template for counterfactual nested data. The fence prevents that misreading.

**C2-P1 verdict: accept as accurate facts basis.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D route recommendation safe? | Yes. Read-only, one track doc, technically grounded decisions on Option D, report/API survey timing, and runtime/evaluator closure. |
| Are C2-P1 facts sufficient? | Yes. Source-grounded, 18-row surface table, confusion hotspots name exact promotion mechanisms. Particularly strong on RuntimeSmoke callback path, CompilerResult deny-one risk, and PROP-038 non-precedent fence. |
| Does any blocker require another survey first? | No. The report/API boundary survey is the natural next step. No intervening survey is needed. |
| What exact route should C4-A prefer? | Accept C1-D + C2-P1, open `counterfactual-audit-report-api-boundary-survey-v0` as read-only/design-only. Keep Option D held. Keep runtime/evaluator implementation closed. Keep RuntimeSmoke proof-context only. Keep CompilerResult/CompilationReport closed. Keep all public/Spark/API/release surfaces closed. |

---

## Verdict

```text
PASS

C1-D Runtime/Bridge architecture survey: accept
C2-P1 authority facts packet: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. No non-blocking acceptance notes.

---

## Recommendation for S3-R220-C4-A

```text
Card: S3-R220-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D Runtime/Bridge architecture survey
- C2-P1 authority facts packet as accurate facts basis

Open next:
- counterfactual-audit-report-api-boundary-survey-v0
  (read-only/design-only; no code edits, no field changes, no runtime
  integration, no public docs/body spec edits, no Spark, no release claims)

Keep closed:
- Option D carrier (held; no accepted consumer)
- runtime/evaluator implementation
- RuntimeSmoke feature/support claims
- CompilerResult / CompilationReport fields
- cache/dependency authority
- PROP-038 report-only precedent as counterfactual authorization
- public API/CLI/Spark/demo/production
- all lib/** implementation
```
