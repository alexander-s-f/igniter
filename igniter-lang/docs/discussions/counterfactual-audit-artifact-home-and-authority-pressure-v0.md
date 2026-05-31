# Counterfactual Audit Artifact Home And Authority Pressure v0

Card: S3-R217-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: counterfactual-audit-artifact-home-and-authority-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-30

Depends on:
- S3-R217-C1-D
- S3-R217-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-options-v0.md` (C1-D)
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-artifact-authority-facts-packet-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round216-status-curation-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-decision-v0.md` (R216-C4-A)

---

## Scope-Check Matrix

| Check | Source(s) | Finding | Safe? |
| --- | --- | --- | --- |
| L1 / L2a / L2b separation preserved | C1-D "Preserved Boundaries": "L1 / L2a / L2b separation"; option matrix scoped exclusively to L2b source-backed evidence (R211); C2-P1 "Current Facts" cites R211 as basis only | The artifact-home question is correctly scoped to L2b. L1 (static branch intention) and L2a (isolated projection concept) are not subjects of any option. No level boundaries are blurred or collapsed. | ✅ SAFE |
| Options do not accidentally create runtime / report / API authority | C1-D authority field policy (9 false-defaulting flags for all options); Options E/F rejected as next routes; Option D held with explicit blockers including Bridge review; Option B requires `runtime_authority: false`, `report_authority: false`, `cache_authority: false`, `public_api_authority: false`; C2-P1 independently reproduces same 9 flags | Every option that could carry authority (B, D) requires explicit false-authority fields as a precondition. Options E/F are comparison-only with detailed promotion risks listed. No implicit runtime/report/API authority flows from acceptance of any option. | ✅ SAFE |
| Compiler-emitted artifacts kept comparison-only | C1-D Option E: "comparison only; reject as next route"; promotion risks include breaking compiler/proof separation, `.igapp`/SemanticIR/report pressure, public all-grammar claims; blockers before reconsideration require separate compiler artifact PROP and TypeChecker/SemanticIR/assembler/report boundary decisions; C2-P1 authority inventory: "Compiler-emitted artifacts — Closed — Comparison target only" | Option E is explicitly rejected and detailed promotion risks are enumerated. Neither document softens this designation or creates a future path that would implicitly open it. | ✅ SAFE |
| Report / result / receipt sidecars kept comparison-only | C1-D Option F: "comparison only; reject as next route"; promotion risks include CompilerResult/receipt mutation, runtime support implication, highest overclaim risk; blockers before reconsideration require separate report/result/receipt surface survey, CompatibilityReport boundary review, and persistence/privacy policy; C2-P1 authority inventory: "Report/result/receipt sidecars — Closed — Comparison target only" | Option F is explicitly rejected with the highest-rated claim risk in both documents. Neither document creates a softened path toward these surfaces. | ✅ SAFE |
| Recommended option (B) reduces route debt sufficiently | C1-D: Option B rated "High" route-debt reduction while remaining design/proof only; purpose is to give a stable artifact home for L2b evidence without compiler emission, report fields, or runtime support; C2-P1: Option B "High route-debt reduction / Best next route" | Option B directly addresses the accepted L3 blocker (no accepted non-proof-local artifact home) while remaining proof-owned and non-canonical. The distinction between Option A (permanent proof-local, high reconstruction cost) and Option B (proof-owned home, named once, reduces reconstruction) is well-drawn. Neither overpromises nor underpromises. | ✅ SAFE |
| Assumptions remain premise capsule only | C1-D "Preserved Boundaries": "no branch-level `uses assumptions`", "no PROP-032 amendment", "no receipt `assumption_refs`", "no source syntax expansion"; C2-P1 premise set authority: "Not PROP-032 receipt authority, not branch-level source syntax, not dependency/cache authority" | Four explicit closures in C1-D. C2-P1 confirms from the facts side. No new assumptions pathway is created or implied by any of the six options. | ✅ SAFE |
| RuntimeSmoke proof-context wording remains binding | C1-D "Preserved Boundaries": canonical wording reproduced verbatim from R215-C1-D; C2-P1 "Promotion-Risk Notes": "RuntimeSmoke proof-context paths must not be described as RuntimeSmoke support" | Canonical wording is present in C1-D and the no-support constraint is independently restated in C2-P1. The transitive-load framing is stable. | ✅ SAFE |
| Public / Spark / API / release claims remain closed | C1-D "Closed Surfaces" (comprehensive list); authority flags: `spark_authority: false`, `production_authority: false`, `public_api_authority: false`; C2-P1 "Closed Surfaces" (matching list); C2-P1 route ranking: Option F (Spark/API/demo) "Reject for now" | Closed-surface lists in both documents are consistent with R216-C4-A and prior rounds. No option opens or softens a public/Spark/API/release surface. | ✅ SAFE |

---

## C1-D Assessment: Artifact-Home / Authority Options Design

**Finding: safe to accept.**

The option matrix is correctly structured. Options E/F are comparison-only with
detailed per-area authority analysis and multi-step blocker lists before any future
reconsideration — this is the appropriate treatment for routes that cannot open yet
without separate surface surveys, PROP work, and Bridge review. Including them as named
comparison targets is informative and does not constitute authorization.

Option D (internal non-canonical carrier) is correctly held: it is labeled "promising
later" with a dependency on Option B first and a requirement for Bridge review before
any loader/report/public/API consideration. The promotion risk characterization ("very
easy to overread as implementation route, could become accidental public/internal API")
is accurate and the listed blockers are specific.

Option B is the right scope for the next route: it names a home, establishes no-
authority defaults, and defines the questions that future design must answer without
pulling in compiler, report, runtime, or public surfaces. The nine-field authority flag
policy covers every credible overclaim vector.

Option A (permanent proof-local) is correctly kept as a safe fallback if Portfolio
decides no non-proof-local movement is warranted. Its weakness (high reconstruction
cost) is accurately characterized.

One non-blocking structural note: C1-D describes the next route as both a "design"
and a "proof" route (`counterfactual-audit-proof-owned-artifact-home-design-v0`). In
this lane, "proof" has meant experiments under `experiments/`, not `lib/` changes. The
C1-D blocker list for Option B ("confirm no `.igapp`, manifest, report, result,
receipt, or CompatibilityReport mutation") confirms this scope. C4-A should name this
distinction when dispatching the next card to prevent future ambiguity about whether
"design/proof" can touch `lib/`. See AN-1.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Runtime Artifact Authority Facts Packet

**Finding: safe to accept. Facts are accurate.**

C2-P1 is grounded in a direct JSON read of the R211 proof summary
(`branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json`),
confirming PASS 61/61 and no-authority claim policy. The authority inventory (11 rows)
covers every evidence area that the C1-D option matrix must address, and each row
correctly names what the current proof harness can trust and what must remain false.

The promotion-risk notes are specific:

- "`projected_value` must never be described as actual output" — correct; this is the
  most common overclaim vector for counterfactual evidence.
- "`source_branch_intention_ref` must not become a `CompilerResult` or
  `CompilationReport` field by implication" — correct; docs repetition is exactly the
  canonization-by-drift risk.
- "Digest-addressed proof refs must not be described as cache/dependency authority" —
  correct; digest-addressed evidence and cache key authority are distinct concepts that
  are easy to conflate.

The option comparison table independently arrives at the same recommendation as C1-D
(Option B as best next route, Option A as fallback, D held, E/F rejected). This
convergence from two different perspectives (design options vs facts inventory) is a
positive signal.

**C2-P1 verdict: accept as accurate facts basis.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D safe to accept? | Yes. Option matrix well-structured, E/F comparison-only with detailed blockers, B appropriately bounded, D correctly held. |
| Is C2-P1 accurate enough? | Yes. R211 summary JSON directly sampled, 11-row authority inventory complete and accurate, promotion-risk notes specific. |
| May any artifact-home option be accepted now? | Option A may be accepted as baseline fallback. Option B direction may be accepted — opening a design/proof route, not implementation. Option C may be accepted as companion alongside B. Option D should be held. Options E/F must remain comparison-only. |
| Should all non-proof-local homes remain held? | No — Option B design route may open. It is the bounded, design-only step that directly addresses the L3 blocker. Holding all non-proof-local homes (Option A only) leaves the reconstruction-cost debt in place. |
| Is implementation premature? | Yes. Option B, if accepted, authorizes a design/proof card only, not `lib/` changes. All implementation remains closed until artifact home, authority fields, and closed-surface scan are defined and accepted. |

---

## Non-Blocking Acceptance Note

**AN-1 — C4-A should clarify "design/proof route" scope when dispatching Option B.**

C1-D names the next route as both "design" and "proof." In this lane, "proof" has
consistently meant experiments under `igniter-lang/experiments/`, not `lib/` edits.
C1-D's blocker list for Option B reinforces this: "confirm no `.igapp`, manifest,
report, result, receipt, or CompatibilityReport mutation." The `lib/**` closed-surface
entry applies.

C4-A's dispatch of the next card should state explicitly:

```text
The design/proof route for Option B is design-only and experiments-only.
It may not touch lib/**, compiler pipeline stages, report/result/receipt surfaces,
.igapp, manifests, or any other listed closed surface.
Accepting Option B as the next route is not implementation authorization.
```

This prevents a future author from reading "proof route" as a licence to write
production proof-adjacent code.

---

## Verdict

```text
PASS

C1-D: accept
C2-P1: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. One non-blocking acceptance note (AN-1: C4-A dispatch of Option B should
explicitly name experiments-only / design-only scope to prevent "proof route"
ambiguity).

---

## Recommendation for S3-R217-C4-A

```text
Card: S3-R217-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D artifact-home / authority options matrix
- C2-P1 runtime artifact authority facts packet as accurate facts basis

Accept option directions:
- Option A as baseline fallback (permanent proof-local; no new authority)
- Option B as next bounded design/proof route
- Option C as optional companion/index route alongside or after B
- Option D as held until B clarifies home and authority fields
- Options E/F as comparison-only; not next routes

Open next:
- counterfactual-audit-proof-owned-artifact-home-design-v0

Scope statement for dispatch (AN-1):
  The Option B route is design-only and experiments-only.
  It may not touch lib/**, compiler pipeline stages, report/result/receipt
  surfaces, .igapp, manifests, or any listed closed surface.
  Accepting Option B as the next route is not implementation authorization.

Keep closed:
- runtime / evaluator / RuntimeSmoke feature claims
- compiler-emitted artifact design (Option E)
- report / result / receipt / CompatibilityReport design (Option F)
- internal non-canonical carrier (Option D, held pending B)
- cache / dependency authority
- public API / CLI / Spark / demo / production routes
- all lib/** implementation
```
