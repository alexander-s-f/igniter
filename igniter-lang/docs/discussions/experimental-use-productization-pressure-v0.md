# Experimental Use Productization Pressure v0

Card: S3-R222-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-use-productization-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R222-C1-D
- S3-R222-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-use-productization-route-options-v0.md` (C1-D)
- `igniter-lang/docs/tracks/experimental-use-current-surface-and-gap-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round221-status-curation-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-report-api-boundary-decision-v0.md` (R221-C4-A)

---

## Risk Matrix

| Risk | Probability | Severity | C1-D / C2-P1 fence | Residual |
| --- | --- | --- | --- | --- |
| Quickstart wording implies stable API / v1 contract | Medium if unfenced | High | C1-D: explicit forbidden wording list (stable API, production-ready, public demo-ready, Spark-ready, runtime-ready, all grammar support, v1 compatibility); required disclaimer inside quickstart boundary | Low — fence built in as authorization requirement |
| Examples directory re-opens `lib/**` or CompilerResult changes | Medium without scope | High | C1-D: default closed: `lib/**`, gemspec, README, public docs, RuntimeSmoke behavior, CompilerResult/CompilationReport fields; C2-P1: package boundary changes deferred | Very low — not in first slice |
| `source/add.ig` chosen but other fixtures added, implying all-grammar support | Medium | Medium | C2-P1: `source/add.ig` labeled "clearest bounded CORE success seed"; other fixtures clearly labeled (parser-only, ESCAPE/TBackend-like pressure, pipeline syntax); C1-D: "source files include usable fixtures but mix parser-only and compiler-accepted semantics that need careful labeling" | Low — fixture labeling required |
| RuntimeSmoke pulled in as product runtime for quickstart | Medium if not fenced | High | C1-D: "Why not runtime first" section; RuntimeSmoke proof-context only per R220/R221; excluded from first slice; C2-P1: RuntimeSmoke facts confirm no product runtime command | Very low |
| Profile-source quickstart implies discovery/defaulting/finalization | Low | Medium | C1-D: profile-source excluded from first slice unless specifically needed; C2-P1: "CLI passes parsed profile-source unchanged; no generator/finalizer/discovery" | Very low |
| Counterfactual report/API or Option D reopened via TTM pressure | Very low | High | C1-D "Fixed Boundaries": R221 closures reproduced explicitly; counterfactual report/API, Option D, runtime/evaluator excluded from route | Very low |
| Authorization review bypassed (direct implementation in C4-A) | Low | Medium | C1-D: "do not authorize implementation directly in C4-A"; recommended next card is C1-A authorization review, not C2-I implementation | Very low — IDD gate preserved |
| Over-proofing: quickstart requires same proof rigor as language proof | Very low | Low | C1-D regression shape is appropriately lightweight: `ruby -c`, local PASS, output confinement, no field changes, forbidden phrase scan; not a 60-check golden proof | Very low |
| Under-proofing: quickstart has no verification and ships unsound claims | Low | High | C1-D: forbidden phrase scan required; local harness PASS required; output confined; no-stable-API disclaimer required inside quickstart | Very low |
| TTM blind spot: quickstart delays by adding process overhead | Very low | Low | C1-D: "open implementation-authorization review next" — one card gate, not a multi-round proof cycle; options matrix correctly rates size as Small | Very low |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Recommended route shortens time to experimental use | C1-D options matrix: experimental quickstart = "High TTEU impact, Small size"; rationale: uses existing `igc compile`, no new API contract, reveals friction before runtime design, gives market-facing direction without market-facing claims; C2-P1: absent `examples/` confirmed as highest-friction gap via `find` command | Route directly addresses the confirmed highest-friction gap. "High TTEU impact" with "Small size" is the correct target quadrant. No survey needed before opening. | ✅ SAFE |
| Route avoids stable API / production / v1 claims | C1-D: explicit forbidden wording list (7 items); required wording inside quickstart: "experimental / alpha / pre-v1 / subject to change / no stable API guarantee / not production-ready"; C2-P1: authority rule "alpha availability != stable API promise" | Forbidden list is comprehensive and must be enforced inside the quickstart boundary itself — not just in release docs. This is the correct location for the disclaimer. | ✅ SAFE |
| Route avoids reopening counterfactual report/API or Option D | C1-D "Fixed Boundaries" reproduces R221 closed posture verbatim; "Do not include in first slice: RuntimeSmoke productization / report/result/API fields / new public CLI flags"; C2-P1: "experimental-use facts should not reopen counterfactual report/API, RuntimeSmoke carrier, Option D, runtime/evaluator, Spark, release, or production authority" | Hard boundaries from R221 are carried forward. The fixed boundaries section ensures the quickstart route cannot become a vector for reopening held surfaces. | ✅ SAFE |
| Proof quality preserved with bounded regression matrix | C1-D regression shape: `ruby -c`, local quickstart PASS, output confined to example-local `out/`, no `lib/**` changes, no CompilerResult/CompilationReport field changes, no RuntimeSmoke behavior changes, no public docs/body spec edits by default, forbidden phrase scan | Regression shape is calibrated to the quickstart scope. Lightweight but sufficient: the forbidden phrase scan is the load-bearing check for claim safety, and local harness PASS is sufficient for scope verification. Not over-engineered. | ✅ SAFE |
| Route is not too small to matter | C2-P1: "highest-friction gap: no curated examples/quickstart path that says: use this source, run this command, expect this output, here is what is not claimed"; `find igniter-lang -maxdepth 2 -type d -name examples` → absent confirmed | The route addresses the single highest-friction gap. A developer with `igc` installed today has no obvious first step. The quickstart closes that gap directly. | ✅ SAFE |
| Route is not too large to finish quickly | C1-D: candidate implementation shape = one directory, one source fixture, one tiny README, one compile script/harness; default closed: lib/**, gemspec, README, public docs, RuntimeSmoke, CompilerResult, CompilationReport; C1-D options matrix: "Small" size | Scope is tightly bounded. Deferred: RuntimeSmoke productization, report/result/API fields, new CLI flags, source grammar widening, profile discovery, Spark, release execution. No `lib/**` changes in first slice means implementation risk is low. | ✅ SAFE |
| RuntimeSmoke correctly held | C1-D "Why not runtime first": RuntimeSmoke proof-context only per R220/R221, runtime productization would reopen selected execution vs proof support ambiguity, no report/API fence authorizes runtime output claims; C2-P1: "RuntimeSmoke remains proof-context only; no product runtime command exists" | Closed consistently with prior round decisions. RuntimeSmoke productization is "Hold" in the options matrix. | ✅ SAFE |
| IDD authorization gate preserved | C1-D: "do not authorize implementation directly in C4-A"; recommended next card is `experimental-use-quickstart-workflow-authorization-review-v0` (C1-A), not direct C2-I implementation; C4-A recommendation explicitly says "open implementation-authorization review next" | The correct IDD flow is preserved. C4-A accepts the route options, then a dedicated authorization review (C1-A) defines the exact write scope before implementation begins. | ✅ SAFE |

---

## C1-D Assessment: Productization Route Options

**Finding: safe to accept. Market-aware.**

C1-D correctly identifies the core market-risk: the alpha package is published but there is no guided first experiment. The options matrix reaches the right conclusion by eliminating the high-risk alternatives (RuntimeSmoke productization = "Hold," pause = "Wrong for market pressure") and landing on the smallest high-impact route.

The reasoning structure is sound in three specific ways:

1. **Route ordering is correct**: quickstart before runtime productization because the compile path already exists and runtime productization would require reopening surfaces closed through R220/R221. The asymmetry in proof burden (Low/Medium vs High) is accurate.

2. **Docs-only correctly rated**: "Medium TTEU impact, Small size, Medium claim risk" — docs-only is acknowledged as not enough because the current gap is "can I try this?" not just "can I read about this?" A quickstart without a runnable/provable path becomes another status artifact.

3. **No-stable-API placement**: requiring the disclaimer *inside the quickstart boundary* rather than only in release docs is the right call. A developer following a quickstart should see the disclaimer at the point of use, not only in external release notes.

One note on IDD hygiene: C1-D recommends the next card as a C1-A authorization review, not a C4-A that directly authorizes implementation. This is the correct IDD sequencing and it is preserved in the C4-A recommendation at the bottom of C1-D. C4-A should not short-circuit this gate.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Current Surface and Gap Facts

**Finding: safe to accept as accurate facts basis.**

C2-P1 is grounded across 13 inputs including bin/igc, gemspec, source/*.ig files, and experiments index. The key facts that C4-A needs are all correct:

1. **`examples/` absent confirmed**: `find igniter-lang -maxdepth 2 -type d -name examples` → no directory. This is a binary, unambiguous gap.

2. **Source fixture labeling is accurate**: `source/add.ig` is correctly identified as the bounded success seed. The other fixtures are correctly characterized — `polymorphic_add.ig` is explicitly parser-only, `availability_projection.ig` has ESCAPE/TBackend-like pressure. The mixed-acceptance-posture risk ("Users may infer all grammar/runtime support") is correctly named.

3. **CLI capability is accurate**: two supported shapes confirmed from source. No `igc run`, no evaluate command, no profile generator. These gaps are factual and complete.

4. **Package/gem facts are accurate**: `0.1.0.alpha.1` published, files list confirmed from gemspec, examples not packaged (because directory absent and gemspec does not include it).

5. **Docs non-claims are already present**: C2-P1 correctly identifies that the non-claims exist in release docs but are not yet at point of use in a quickstart.

The authority rule stated at the top — "alpha availability != stable API promise / proof/runtime evidence != product runtime support / examples/workflows != production readiness" — correctly separates the three distinct levels that could be conflated.

**C2-P1 verdict: accept as accurate facts basis.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D recommendation safe and market-aware? | Yes. Identifies highest-friction gap, routes to smallest high-impact slice, preserves all prior R221 closures, sequences through IDD authorization gate. |
| Are C2-P1 facts sufficient? | Yes. Source-grounded, 13 inputs, examples/ absence confirmed, fixture labeling accurate, CLI gaps complete. |
| May implementation authorization open next? | Yes — as a C1-A authorization review, not direct implementation. C4-A opens the authorization review; the authorization review defines the write scope; implementation follows only after authorization. |
| What exact route should C4-A prefer? | Accept C1-D + C2-P1. Open `experimental-use-quickstart-workflow-authorization-review-v0` as the next C1-A card. Do not authorize implementation in C4-A directly. Keep all R221 closures intact. |

---

## Verdict

```text
PASS

C1-D Productization route options: accept
C2-P1 Current surface facts: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. No non-blocking acceptance notes.

The recommended route is well-scoped, market-aware, and correctly sequenced through the IDD authorization gate. The highest-friction gap (absent `examples/`) is directly addressed. All R221 closures (counterfactual report/API, Option D, RuntimeSmoke, public/Spark/release) are preserved.

---

## Recommendation for S3-R222-C4-A

```text
Card: S3-R222-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D productization route options
- C2-P1 current surface facts as accurate facts basis

Open next (authorization review only, not implementation):
  Card: S3-R223-C1-A
  Track: experimental-use-quickstart-workflow-authorization-review-v0
  Goal: decide whether bounded experimental quickstart/workflow implementation
        may begin using existing igc compile surface

Default closed unless explicitly authorized by C1-A:
  - igniter-lang/lib/**
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/README.md
  - igniter-lang/docs/README.md
  - public docs / body spec
  - RuntimeSmoke behavior / result shape
  - CompilerResult / CompilationReport fields
  - release/tag/publish/deploy

Required inside the quickstart boundary:
  - alpha/pre-v1/no-stable-API disclaimer at point of use
  - forbidden phrase scan (stable API, production-ready, public demo-ready,
    Spark-ready, runtime-ready, all grammar support, v1 compatibility)
  - output confined to example-local out/ or temp directory

Keep closed:
  - stable API / production / Spark / release claims
  - RuntimeSmoke productization
  - counterfactual report/API and Option D reopening
  - runtime/evaluator implementation
  - all lib/** implementation (default closed for first slice)
```
