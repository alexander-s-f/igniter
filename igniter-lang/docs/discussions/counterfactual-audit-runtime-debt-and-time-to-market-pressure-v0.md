# Counterfactual Audit Runtime Debt And Time To Market Pressure v0

Card: S3-R216-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: counterfactual-audit-runtime-debt-and-time-to-market-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-30

Depends on:
- S3-R216-C1-D
- S3-R216-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-review-v0.md` (C1-D)
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-facts-packet-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round215-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-decision-v0.md` (via R215-C5-S references)

---

## Scope-Check Matrix

| Check | Source(s) | Finding | Safe? |
| --- | --- | --- | --- |
| Recommended next route addresses TTM risk | C1-D decision matrix: artifact-home/authority options rated "High" TTM relief, "Low-medium" risk; C2-P1 route ranking: artifact-home/authority rank 1 | Both documents converge on the same route for TTM relief. TTM 4/10 risk is acknowledged explicitly. The preferred route reduces repeated boundary reconstruction — the identified source of the moderate TTM drag — without opening any live surfaces. | ✅ SAFE |
| Proof quality is preserved | C1-D "Preservation Requirements" and "Do not speed up by" list; C2-P1 "Closed Surfaces To Preserve"; proof counts R199 68/68, R201 56/56, R203 53/53, R211 61/61 sampled | C1-D rates "proof-quality risk from rushing: high" and explicitly warns against using TTM pressure as a shortcut. C2-P1 carries the proof counts forward as evidence anchors, not as promotion evidence. Both lists align with the permanent fence from R215-C1-D. | ✅ SAFE |
| Runtime / report / API implementation remains closed | C1-D "Explicit Answers": "This card authorizes no implementation. This card authorizes no runtime/report/API design."; decision matrix: "Runtime implementation next" = Reject now; C2-P1 route ranking: runtime implementation rank 5 "Premature; not recommended; not authorized" | Closure is unambiguous in both documents and stated multiple times. Report/API boundary survey is rated "Wait" / rank 3. RuntimeSmoke support route is "Reject now" in C1-D. | ✅ SAFE |
| Artifact-home / authority blockers remain visible | C1-D runtime-debt assessment: "authority is undefined for source refs, input snapshots, premise sets, projected values, projected failures, and projection traces"; C2-P1 missing authority table: 11 rows naming each missing authority decision | Both documents correctly surface these as the central gap blocking L3. The missing authority table in C2-P1 is precise: each row names the current state, the exact missing decision, and does not imply a preferred resolution direction that could be read as a pre-authorization. | ✅ SAFE |
| Review calibration — not too conservative | C1-D recommends artifact-home/authority options as preferred and "open next unless C3-X finds a blocker"; "Pause or return to another runtime lane" rated "not preferred, but safe"; C2-P1 rank 1 is an active forward step | The review does not stall at the status quo. It identifies a concrete actionable next route, explains why it directly addresses the debt, and lists the minimum questions that route must answer. "Pause" is available but described as leaving route debt unresolved. | ✅ NOT OVER-CONSERVATIVE |
| Review calibration — not too aggressive | C1-D: no implementation authorized; report/API boundary survey deferred; runtime implementation rejected; RuntimeSmoke support route rejected; C2-P1: every closed surface is explicitly restated | No surface is widened or softened. The review does not treat the existing proof evidence as grounds for opening any design route beyond artifact-home options. | ✅ NOT TOO AGGRESSIVE |
| Public / Spark / API / release claims do not leak | C1-D "Preservation Requirements" and "Do not speed up by" list; C2-P1 "Closed Surfaces To Preserve" | Both documents maintain explicit closed-surface lists covering public API/CLI, release/demo/stable/production claims, Spark data/fixtures/integration, and all-grammar claims. No promotional language is used when describing existing proof evidence. | ✅ SAFE |
| RuntimeSmoke proof-context wording maintained | C1-D: "RuntimeSmoke proof-context wording remains binding"; C2-P1 proof-only facts table: "Known proof harness consequence, not feature support. [...] No public/stable if_expr RuntimeSmoke support claim." | Consistent with the canonical wording pinned in R215-C1-D. The transitive-load framing is stable across both documents. | ✅ SAFE |
| L1 / L2a / L2b distinctions preserved | C1-D "Preservation Requirements": "L1, L2a, and L2b as distinct lane levels"; C2-P1 "Current Fixed Point" accepts R215 lane map as controlling | Neither document collapses the lane levels or uses evidence from one level to authorize another. | ✅ SAFE |

---

## C1-D Assessment: Runtime-Debt / TTM Review

**Finding: safe to accept.**

C1-D is a non-authorizing strategic review by Portfolio Architect, which is the
appropriate role for a sequencing decision of this kind. The review correctly frames
the runtime debt as an authority and routing problem, not a missing implementation
problem. The decision matrix is well-calibrated: one preferred route (artifact-home /
authority options), one useful support route (runtime/bridge architecture survey, after
artifact-home), two routes to defer (report/API boundary survey, pause), and two routes
explicitly rejected (runtime implementation, RuntimeSmoke support).

The debt characterization — "split runtime surfaces, no artifact home, no authority
model, no report/receipt surface, dependency/cache closed, TBackend/effect refused" —
is accurate and consistent with C2-P1's facts.

One structural note: C1-D proposes card identifiers for R217 (C1-D artifact-home
options, C2-P1 support packet, C3-X pressure, C4-A decision). These are route
suggestions, not authorizations. They are useful for Portfolio planning and do not
constitute premature dispatch.

The fallback route (`counterfactual-audit-runtime-bridge-boundary-survey-v0`) is
labeled correctly — "Use only if C4-A decides runtime ownership is more urgent than
artifact home." Since artifact-home is the direct L3 blocker, the bridge survey would
be the less efficient choice. C4-A should not choose the fallback without a specific
reason to prefer runtime ownership over artifact-home clarity.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Runtime-Debt Facts Packet

**Finding: safe to accept. Facts are accurate.**

C2-P1 is grounded in direct source reads of `semanticir_expression_evaluator.rb`,
`compiled_program.rb`, and `runtime_smoke.rb`, plus sampled proof counts from
R199/R201/R203/R211. The live runtime facts are specific and correct: `SUPPORTED_KINDS
= %w[literal ref if_expr]`, the `external_evaluator:` hook is "Slice 2 adapter support,
not public API," and `call_trace` is explicitly fenced as "proof/debug only."

The missing authority table (11 rows) is the most complete authority-gap inventory in
the lane to date. It correctly classifies artifact home as an open L3 blocker, source
refs as proof-owned without stability policy outside experiment outputs, input snapshots
as frozen proof artifacts without snapshot-source/mutability/privacy/persistence model,
and premise sets as explicit proof objects without owner/validation/PROP-032
relationship defined. No row contains a hidden promotion path.

The route ranking (6 entries) is correctly ordered. Rank 1 (artifact-home/authority
options) directly addresses the L3 blocker. Rank 5 (runtime implementation) and rank 6
(public API/CLI/Spark/demo) are explicitly rejected. The justification for each rank is
specific, not vague.

**C2-P1 verdict: accept as accurate facts basis.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D review safe to accept? | Yes. Non-authorizing, well-calibrated, correct debt characterization, clear route recommendation. |
| Is C2-P1 facts packet accurate enough? | Yes. Source-grounded, proof counts sampled, 11-row authority-gap inventory complete, no hidden promotion paths. |
| Should artifact-home / authority options open next? | Yes. Both documents recommend it as the direct L3 blocker and highest TTM relief route. |
| Should runtime/bridge architecture survey open instead? | No. It should follow or support artifact-home options, not precede them. The bridge survey without artifact-home scoping will rediscover the same boundaries. |
| Is any implementation route premature? | Yes. Runtime, report, API, CLI, Spark, and production implementation all remain premature until L3 gates close. |

---

## Verdict

```text
PASS

C1-D: accept
C2-P1: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. No non-blocking acceptance notes.

---

## Recommendation for S3-R216-C4-A

```text
Card: S3-R216-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D runtime-debt / TTM review
- C2-P1 facts packet as accurate facts basis

Open next (preferred):
- counterfactual-audit-artifact-home-and-authority-options-v0

Sequencing note:
- Runtime/Bridge architecture survey should follow or support the artifact-home
  route, not precede it.
- Fallback route (counterfactual-audit-runtime-bridge-boundary-survey-v0) requires
  a named reason to prefer it over artifact-home options; absent that reason,
  artifact-home options is the correct L3 entry point.

Keep closed:
- runtime / evaluator / RuntimeSmoke feature claims
- report / result / receipt / CompatibilityReport fields
- cache / dependency authority
- CompilerResult / CompilationReport mutation
- public API / CLI / Spark / demo / production routes
- all implementation
```
