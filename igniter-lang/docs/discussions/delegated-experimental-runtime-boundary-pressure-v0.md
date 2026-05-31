# Delegated Experimental Runtime Boundary Pressure v0

Card: S3-R224-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: delegated-experimental-runtime-boundary-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R224-C1-D
- S3-R224-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-boundary-and-packaging-options-v0.md` (C1-D)
- `igniter-lang/docs/tracks/delegated-experimental-runtime-current-surface-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round223-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md` (R223-C4-A)

---

## Risk Matrix

| Risk | Probability | Severity | C1-D / C2-P1 fence | Residual |
| --- | --- | --- | --- | --- |
| Reusable helper bleeds into `lib/**` or becomes a packaged runtime | Low | High | C1-D: candidate home is `examples/experimental_runtime_helpers/**` or `experiments/`; "extract a tiny helper under examples or experiments, not `lib/**`"; closed surfaces include `lib/**`, gemspec, release | Very low |
| Helper includes unproven adapter/normalizer as reusable behavior | Medium | Medium | C2-P1: "adapter_used: false — not treated as proven reusable behavior"; C1-D candidate shape does not mention adapter in helper scope | Low — see AN-1 |
| RuntimeSmoke collapsed into helper, productizing proof-context smoke | Low | High | C1-D dedicated "Why Not RuntimeSmoke Productization" section; four specific collapse risks named; C2-P1: "quickstart does not pass `runtime_smoke:` into compile — RuntimeSmoke is not the accepted execution surface" | Very low |
| `igc run` opened prematurely by helper scope | Very low | High | C1-D dedicated "Why Not `igc run` Yet" section; 7 specific prerequisites before `igc run` can open; helper scope does not touch bin/igc | Very low |
| Public runtime / Reference Runtime authority created by helper | Very low | Critical | C1-D: closed surfaces explicitly name Reference Runtime, public runtime, stable API, production, Spark; C2-P1: wording coverage confirmed from R223; three-runtime distinction binding | Very low |
| Keeping everything example-local is too timid and loses market momentum | Very low | Medium | C1-D options matrix correctly rates "example-local only" as "Too timid after R223 PASS"; recommended "reusable helper" rated "High TTEU impact, Small size" — not too timid | Very low |
| Reusable helper requires proof RuntimeMachine move to `lib/**` | Low | High | C2-P1: "proof RuntimeMachine lives under experiments/ — core dependency blocker"; C1-D: helper uses proof RuntimeMachine via direct-require, not by moving it; home stays examples/ or experiments/ | Low — must be explicit in authorization review |
| Runtime Specification bypassed, creating unchecked runtime semantics | Very low | Medium | C1-D: "keep Runtime Specification as canonical/normative layer; do not implement it in R224/R225; capture learnings from delegated helper as future spec input" — correct deferral | Very low |
| Reference Runtime boundary survey opened prematurely | Very low | Medium | C1-D: "Too early before delegated helper boundary" in options matrix; R224 closes it explicitly | Very low |
| IDD authorization gate bypassed (C4-A directly authorizes implementation) | Very low | Medium | C1-D: "open a reusable helper authorization review next"; recommended next card is S3-R225-C1-A authorization review, not implementation | Very low |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Route actually increases runtime momentum | C1-D options matrix: "extract reusable helper = High TTEU impact, Small size, Low claim risk"; rationale: future examples won't need to copy the full quickstart harness; "pause = Wrong after executable proof landed" | The recommended route is the correct next size step. R223 proved the pipeline; the helper reduces duplication without widening scope. | ✅ SAFE |
| Delegated / non-canonical status preserved | C1-D: "keep delegated runtime non-canonical"; candidate shape: "keep delegated runtime non-canonical, output example-local or temp-local"; C2-P1: accepted constraints from R223 reproduced verbatim | Non-canonical status is preserved as a binding constraint, not a suggestion. | ✅ SAFE |
| Public runtime / Reference Runtime / stable API claims closed | C1-D closed-surfaces list: lib/**, bin/igc, gemspec, README, RuntimeSmoke, CompilerResult, public API/CLI, igc run, Reference Runtime, Runtime Specification, stable API, production, Spark, release; C2-P1: "still risky if generalized" list identifies exact phrases to guard | Comprehensive. The closed-surfaces list is consistent with R223-C4-A and prior rounds. | ✅ SAFE |
| `igc run` correctly held | C1-D dedicated "Why Not `igc run` Yet" section: 7 prerequisites (helper shape proven, input contract and sample input policy defined, result/output key policy defined, failure/HOLD behavior proven, no-claim wording attached to CLI surface, packaging and gem inclusion stance explicit); C2-P1: CLI run change surface lists 10 required design decisions | Hold is well-justified with specific prerequisites. Not a vague "not yet" — named blockers. | ✅ SAFE |
| Example-local constraint not too timid | C1-D options matrix correctly distinguishes "example-local only = Too timid" from "reusable helper = Best next route"; the helper stays in examples/ or experiments/, not lib/**; it is a developer-experience surface, not a package change | The options matrix correctly calibrates the response to R223. Staying fully example-local after a PASS would waste the momentum. | ✅ SAFE |
| Packaging / extraction appropriately bounded | C1-D: preferred home `examples/experimental_runtime_helpers/**`; alternative `experiments/`; "not lib/**"; "do not open public package, gemspec, or release packaging yet"; C2-P1: "examples and experiments are not included by the gemspec" confirmed from gemspec | Extraction stays pre-package. Gemspec, root require, and public docs are default-closed. | ✅ SAFE |
| Runtime Specification correctly sequenced | C1-D: "Runtime Specification slice first = Parallel/later; not the immediate productization unlock"; spec stays canonical/normative; delegated helper captures learnings for future spec input; "open a Runtime Specification slice after the helper exposes repeated semantics" | Correct sequencing. Spec before helper would add ceremony without product value at this stage. | ✅ SAFE |
| RuntimeSmoke productization remains closed | C1-D: dedicated section; four collapse risks named (proof evidence vs product behavior, callback smoke vs runtime command, internal result shape vs user-facing output, selected example execution vs public runtime support); C2-P1: "quickstart does not pass `runtime_smoke:` into `IgniterLang.compile` — RuntimeSmoke is not the accepted execution surface" | Closure is technically grounded. The R223 quickstart uses proof CompiledProgram directly, bypassing RuntimeSmoke. This distinction is correctly preserved. | ✅ SAFE |
| IDD authorization gate preserved | C1-D: "open a reusable helper authorization review next"; recommended next card is S3-R225-C1-A authorization review | C4-A opens a C1-A review, not direct implementation. IDD flow maintained. | ✅ SAFE |

---

## C1-D Assessment: Boundary and Packaging Options

**Finding: safe to accept. Market-aware.**

The options matrix is well-structured and reaches sound conclusions. Four specific rejection rationales — "igc run too early," "RuntimeSmoke productization collapses boundaries," "Reference Runtime too early before helper boundary," "pause wrong after R223 PASS" — are each technically grounded, not vague.

The recommended route (reusable helper, examples-local) occupies the correct position between "too timid" (example-local only) and "too broad" (public package, CLI, Reference Runtime). The candidate write scope (`examples/experimental_runtime_helpers/**` or `experiments/`) preserves the non-canonical status while enabling cross-example reuse.

The Runtime Specification and Reference Runtime sequencing is correct: capture delegated helper learnings first, then consume them in spec work.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Current Surface Facts

**Finding: safe to accept as accurate facts basis.**

C2-P1 is source-grounded from 17 inputs. Three facts are particularly important for C4-A and the upcoming authorization review:

1. **The R223 quickstart uses proof CompiledProgram directly, not RuntimeSmoke.** `quickstart.rb` does not pass `runtime_smoke:` into `IgniterLang.compile`. The execution surface is `RuntimeMachineMemoryProof::CompiledProgram.load_igapp` + `evaluate_contract`. Any helper extraction must replicate this direct proof-runtime path, not route through RuntimeSmoke.

2. **The adapter/normalizer was not exercised.** `adapter_used: false` in the accepted result. The adapter code in quickstart.rb is an unproven fallback. It should not be included in the reusable helper without a dedicated proof exercising it. This is correctly flagged in C2-P1 and needs an explicit scope decision in the authorization review.

3. **Examples and experiments are not packaged by the current gemspec.** This is a source-grounded fact, not an assumption. A helper under `examples/` or `experiments/` stays outside the gem package boundary by default.

**C2-P1 verdict: accept as accurate facts basis.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D recommendation safe and market-aware? | Yes. Options matrix calibrated, IDD gate preserved, four specific rejection rationales technically grounded, correct helper-first sequencing. |
| Are C2-P1 facts sufficient? | Yes. 17 inputs read, R223 execution surface correctly characterized (proof CompiledProgram, not RuntimeSmoke), adapter not proven, gemspec non-inclusion confirmed. |
| May implementation authorization open next? | Yes — as a C1-A authorization review only, not direct C4-A implementation. |
| What exact route should C4-A prefer? | Accept C1-D + C2-P1. Open `delegated-experimental-runtime-reusable-helper-authorization-review-v0` as S3-R225-C1-A. Do not open igc run, RuntimeSmoke productization, Reference Runtime, Runtime Specification, or public package. |

---

## Non-Blocking Acceptance Note

**AN-1 — Adapter/normalizer fate should be explicitly addressed in C1-A scope.**

The adapter/normalizer code in quickstart.rb (`normalize_to_fixture_format`) was not triggered in R223 (`adapter_used: false`). C2-P1 correctly flags it as "not proven reusable." C1-D's candidate implementation shape does not explicitly address whether the adapter moves to the helper, stays in quickstart.rb, or is removed.

The authorization review (C1-A) should explicitly name one of:
- adapter code stays in quickstart.rb only (helper does not include it);
- adapter code is included in the helper but requires a dedicated mismatch proof;
- adapter code is removed from quickstart.rb if the direct load proves stable.

Leaving this implicit risks two future examples each developing their own adapter independently, which was the exact code-duplication problem the helper route aims to solve.

---

## Verdict

```text
PASS

C1-D Boundary and Packaging Options: accept
C2-P1 Current Surface Facts: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. 1 non-blocking acceptance note (AN-1: adapter/normalizer fate should be explicitly scoped in C1-A authorization review).

---

## Recommendation for S3-R224-C4-A

```text
Card: S3-R224-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D delegated experimental runtime boundary and packaging options
- C2-P1 current surface facts as accurate facts basis

Open next (authorization review only, not implementation):
  Card: S3-R225-C1-A
  Track: delegated-experimental-runtime-reusable-helper-authorization-review-v0
  Preferred home: examples/experimental_runtime_helpers/**
  Alternative home: experiments/delegated_experimental_runtime_helper_v0/**

Note for C1-A scope (AN-1):
  Explicitly address adapter/normalizer fate: stays in quickstart.rb,
  included in helper with dedicated mismatch proof, or removed.

Keep closed:
- igc run (implementation)
- RuntimeSmoke productization
- Reference Runtime implementation
- Runtime Specification implementation
- lib/** changes
- gemspec / README / public docs
- public runtime / stable API / production / Spark / release claims
```
