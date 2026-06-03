# Experimental igc run Slice 1 Quickstart Docs Pressure v0

Card: S3-R244-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-slice1-quickstart-docs-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R244-C1-A
- S3-R244-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-v0.md` (C2-I)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round243-status-curation-v0.md`

Independent verifications:
- `git diff HEAD~1 HEAD -- igniter-lang/docs/`: exactly 3 files (track doc, current-status, docs/README)
- `git diff HEAD~1 HEAD -- igniter-lang/README.md`: 0 lines changed ✓ (root README closed)
- Forbidden wording grep on all 3 changed files: all hits are in negation/non-claim context ✓
- docs/README.md diff: one narrow 10-line block with non-claims inline ✓

---

## Compact Wording Risk Table

| Risk | Assessment | Fence | Residual |
| --- | --- | --- | --- |
| C2-I edited files outside authorized write scope | Zero | git diff HEAD~1..HEAD shows exactly 3 files; root README 0 lines; lib/**, bin, gemspec, experiments, examples, playgrounds all clean | Zero |
| Integer-add overclaim: Slice 1 described as executing Add.igapp successfully | Zero | Track doc authority notice: "not positive Add.igapp integer execution"; Path C section: "VM candidate does not execute Add.igapp"; current-status: "positive Add.igapp integer execution remains unclaimed" | Zero |
| Blocked diagnostics softened or generalized | Zero | QD-S1-4 PASS; both `unsupported_capability_integer_add` and `unsupported_capability_stdlib_integer_add` named exactly in track doc, docs/README pointer, and blocked packet shape | Zero |
| Slice 0 sum=42 presented as Slice 1 success | Zero | QD-S1-5 PASS; dedicated "Slice 0 Compatibility" section: "That result is not Slice 1 VM candidate success"; Slice 0 stays labeled as "separate selector sanity check" | Zero |
| runtime_implementation_id becomes user-facing selector in docs | Zero | QD-S1-6 PASS; track doc: "evidence-facing metadata only ... It is not a user-typed selector and does not create runtime authority" | Zero |
| docs/README.md pointer too broad or claims authority | Zero | Diff shows one 10-line block; pointer labels the entry "pre-v1 / Path C fail-closed evidence only"; includes non-claims inline: "not stable API, not public runtime support, not Reference Runtime support, not production-ready, not release evidence, not Spark integration, not public performance evidence, and not portability authority" | Zero |
| Forbidden wording matches are positive claims (not negations) | Zero | Grep results: all matches are "not public runtime support", "not Reference Runtime support", "not Spark integration" — ALL negation/non-claim context; one pre-existing current-status line ("production runtime remain open") is about parser coordinate syntax, unrelated to R244 | Zero |
| Root README changed | Zero | git diff HEAD~1 HEAD -- igniter-lang/README.md → 0 lines | Zero |
| Adjacent source/conformance artifacts promoted | Zero | QD-S1-12 PASS; dedicated "Adjacent Artifact Exclusion" section names all excluded paths including availability_projection.ig, tenant_availability_projection.ig, out/conformance/ | Zero |
| Public/stable/production/Spark/release/performance/portability claims | Zero | QD-S1-11/13 PASS; claim scan 0 positive hits; 10+ non-claim statements in track doc | Zero |

---

## Pressure-Test Findings

**Write scope:** Git diff confirms exactly 3 files changed: `experimental-igc-run-slice1-quickstart-docs-v0.md`, `docs/current-status.md`, `docs/README.md`. Root README 0 lines changed. No lib/**, no bin, no experiments, examples, or playgrounds changes. Exact match to C1-A authorization.

**Path C is the central docs truth:** The track doc leads with an authority notice that the behavior is "documentation exposure for internal evidence, not positive Add.igapp integer execution." The "Path C Behavior" section is explicit: "the VM candidate does not execute Add.igapp as a successful integer run." The two blocked diagnostics are named exactly and included in the blocked result packet shape.

**Slice 0 / Slice 1 separation:** The dedicated "Slice 0 Compatibility" section correctly presents `outputs.sum=42` as a "separate selector sanity check" and explicitly states "That result is not Slice 1 VM candidate success." The C1-A required wording is met.

**Forbidden wording scan:** All grep hits are in negation/non-claim context. The `docs/current-status.md` match at line 130 ("parser coordinate syntax and production runtime remain open") is a pre-existing line about parser coordinate syntax, not R244 content. No positive claims of any forbidden phrase were found.

**docs/README.md pointer:** The diff adds a single 10-line block that:
- labels the entry "pre-v1 / Path C fail-closed evidence only"
- names the exact selector `delegated-experimental:igniter-vm-candidate`
- names both blocked diagnostic codes inline
- includes 8 "not ..." non-claims directly in the navigation pointer

This is narrow and non-authoritative. C1-A authorized "one narrow navigation pointer" — the change delivers exactly that.

**Adjacent artifact exclusion:** The track doc has a dedicated section listing the excluded conformance artifacts (`availability_projection.ig`, `tenant_availability_projection.ig`, `out/conformance/ruby/` and `out/conformance/rust/` paths). C1-A's R243-C5-S exclusion wording is reproduced correctly.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL PASS / HOLD / REDIRECT? | PASS — unconditional |
| Exact blockers? | None. |
| Docs evidence accepted? | Yes. QD-S1-1..QD-S1-14 PASS. |
| Generated docs are internal quickstart/docs exposure only? | Yes. Authority notice, non-claims, and evidence class are all correct. |
| Creates public runtime support or Reference Runtime support? | No. |
| Stable API / production / Spark / release / public demo / public performance / certification / portability claims closed? | Yes. All closed via explicit non-claims. |
| C4-A may accept or must hold? | C4-A may accept unconditionally. |

---

## Verdict

```text
PASS — unconditional

C2-I Slice 1 quickstart/docs sync: QD-S1-1..QD-S1-14 PASS — accept
Write scope: exactly 3 authorized files; root README 0 lines changed
Forbidden wording scan: 0 positive-claim hits
Path C as central docs truth: confirmed
Slice 0 / Slice 1 separation: confirmed
Adjacent artifact exclusion: confirmed
No blockers
No acceptance notes
C4-A HOLD: release; proceed to unconditional acceptance
```

---

## Recommendation for S3-R244-C4-A

```text
Card: S3-R244-C4-A (final acceptance)
Route: UPDATE
Mode: unconditional acceptance

Accept:
- C2-I Slice 1 quickstart/docs sync
- 3 changed files: track doc, current-status breadcrumb, docs/README pointer
- Path C fail-closed as the central Slice 1 docs truth
- Both blocked diagnostics named exactly in track, README pointer, and packet
- Slice 0 compatibility explicitly labeled as separate selector sanity check
- Adjacent artifact exclusion section present
- All claims closed via explicit non-claims

What this accepts:
- Internal docs exposure for pre-v1 experimental Slice 1 Path C evidence
- Navigation pointer in docs/README.md labeled evidence-only

What this does not accept:
- Positive Add.igapp integer execution
- Public runtime support
- Reference Runtime support
- Stable API or production readiness
- Release evidence
- Any Spark/demo/performance/portability/certification claims
- Root README or ruby-api.md widening

Keep closed:
- root README / ruby-api.md
- all lib/**, bin/igc, gemspec
- experiments/**, examples/**, playgrounds/**
- positive Add.igapp integer execution
- igc run widening beyond Slice 1 Path C
```
