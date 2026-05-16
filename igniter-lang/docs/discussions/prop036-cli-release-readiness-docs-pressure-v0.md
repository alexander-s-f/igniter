# Discussion: PROP-036 CLI Release Readiness Docs Pressure v0

Card: S3-R53-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: comprehension-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-release-readiness-docs-pressure-v0

Depends on: S3-R53-C1-P1 delivered

Question:

Are all eight R52 documentation content items present and correct in the updated
`docs/ruby-api.md`? Is the outdated blanket CLI closure statement properly
qualified? Do the docs avoid implying any closed surface as open? Does a fresh
caller get an accurate comprehension of the bounded transport scope, refusal
behavior, and what remains closed?

Context:
- C1-P1 (Archive/Form Expert): Updated only `docs/ruby-api.md`; no new CLI doc
  created; no code changes; R52 condition checklist self-reported all 23 items
  as Yes; track recommends external verification before marking condition satisfied
- R52-C1-A: Eight required content items; outdated blanket statement must be
  removed or qualified with bounded exception; verification by pressure or
  curation card required before condition is marked satisfied
- R52-C2-X (prior pressure): Recommended dedicated docs card, not bundled into
  curation; NB-1 on "release-readiness" term orientation

---

## Mechanical Verification of Eight R52 Content Items

Each item is verified against `docs/ruby-api.md` with exact line references.

| # | Required item | Present | Location |
|---|---|---|---|
| 1 | Exact CLI flag shape | ✓ | Lines 12, 139, 176, 269 |
| 2 | `PATH.json` is already-finalized `compiler_profile_id_source` | ✓ | Lines 9, 53, 142 |
| 3 | No-flag legacy behavior | ✓ | `No-Flag Legacy Behavior` section (line 159) |
| 4 | CLI preflight refusal behavior | ✓ | `CLI Preflight Refusals` section (line 183) |
| 5 | Semantic refusal behavior | ✓ | `Semantic Profile-Source Refusals` section (line 209) |
| 6 | Transport-only semantics | ✓ | CLI section (lines 155–157) + `Transport-Only Facade` (line 248) |
| 7 | No discovery/defaulting/finalization | ✓ | Lines 16, 144, 169, 271 |
| 8 | All excluded surfaces remain closed | ✓ | `Non-Authorized Surfaces` section (line 264) |

**All eight items: PRESENT.** ✓

---

## Outdated Blanket Statement Check

**Result: PASS.**

The previous doc stated (paraphrased): CLI profile-source flags and path loading
remain closed. This was accurate before R52 and must now be qualified.

The updated opening section reads:

> "R52 adds one bounded caller-facing CLI exception for transporting an
> already-finalized compiler profile source from a JSON file:
> `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`
>
> All other CLI profile-source input shapes, inline JSON parsing, profile
> discovery, profile defaulting, and profile finalization remain closed."

The blanket prohibition is not removed — it is narrowed. The bounded exception
is named first, then the remaining closures are restated explicitly. A reader
cannot infer that anything beyond the named exception is open. ✓

---

## Prohibited-Surface Closure Check

All prohibited surfaces verified mechanically against the doc:

| Surface | Line | Closed |
|---|---|---|
| Inline JSON | 15, 238, 271 | ✓ |
| Named/generated profile lookup | 240 | ✓ |
| Environment/config/sidecar discovery | 241 | ✓ |
| Loader/report status | 273 | ✓ |
| CompatibilityReport | 274 | ✓ |
| RuntimeMachine | 280 | ✓ |
| Gate 3 | 281 | ✓ |
| Ledger/TBackend | 282 | ✓ |
| BiHistory | 283 | ✓ |
| Stream/OLAP | 284 | ✓ |
| Production cache | 285 | ✓ |
| Production behavior | 286 | ✓ |

Every surface from the R52 non-authorization list has a named entry in the doc.
No implied opening of any closed surface found. ✓

The closing sentence of the doc is:

> "Runtime readiness remains governed by separate runtime compatibility,
> approval, capability, and execution-scope gates."

This correctly separates the release-readiness milestone from production/runtime
authority. ✓

---

## Comprehension Checks (borrowed lens: comprehension-pressure)

### Comprehension check 1 — Fresh CLI caller

A caller new to the CLI flag opens the doc and reads the opening section.
They see the exact flag shape on line 12, the qualification on the old
prohibition, and a pointer forward to the transport semantics. The
"CLI Compiler Profile Source Transport" section gives the complete picture:
what `PATH.json` must be, what the CLI does and does not do, the legacy
path, success behavior, and all refusal shapes.

A fresh caller can answer:
- "What flag do I use?" → lines 12, 139 ✓
- "What does the file need to contain?" → lines 142, 60–112 ✓
- "What happens if the flag is absent?" → `No-Flag Legacy Behavior` ✓
- "What happens if I pass a bad file path?" → `CLI Preflight Refusals` ✓
- "What happens if the JSON is valid but semantically wrong?" → `Semantic Profile-Source Refusals` ✓
- "Is any finalization happening in the CLI?" → line 144 ✓
- "Can I pass inline JSON instead?" → lines 238, 271 explicit: no ✓

### Comprehension check 2 — Fresh Ruby API caller

A caller using `IgniterLang.compile` directly sees no new friction. The
`compiler_profile_source:` parameter description is unchanged. The CLI section
is additive: it describes how the CLI surface feeds into the Ruby facade,
not a change to the facade contract.

The `Transport-Only Facade` section (lines 246–261) is unchanged from prior
B8 closure language and continues to correctly describe the facade. ✓

### Comprehension check 3 — Authority-boundary reader

A reader checking whether CLI transport implies broader authority:

- "Does CLI path loading imply profile discovery?" → line 144: "does not
  build, finalize, normalize, discover, infer, or default" ✓
- "Does CLI success imply runtime authority?" → line 280: RuntimeMachine closed,
  line 288: runtime readiness governed by separate gates ✓
- "Does the bounded exception imply more exceptions?" → "All other CLI
  profile-source input shapes... remain closed" on line 15 ✓

### Comprehension check 4 — Refusal vocabulary safety

The "Known semantic refusal families" section lists three qualified terms:
`compiler_profile_source.wrong_kind`, `compiler_profile_source.unfinalized`,
`compiler_profile_source.runtime_authority_forbidden`.

These are labeled "source-validation terms, not loader-status or
runtime-readiness vocabulary" (line 228–229). The word "Known" (not "All")
signals that additional qualified terms could arise from untested invalid
objects — consistent with the existing assembler path. No forbidden bare
token appears as a documented reason. ✓

### Comprehension check 5 — Slot-assignment example truncation

The example JSON at lines 78–109 shows `slot_assignments` with one slot
only. The doc says: "The example truncates `slot_assignments`. A valid
finalized source must carry the finalized slot assignments needed by the
compiler-profile-source validation path."

A caller cannot misread the truncated example as a complete valid artifact
because the warning immediately follows. The doc does not define the exact
count or names of required slots — correctly, since these are owned by the
validation path, not the caller-facing guide. ✓

---

[Agree]

1. **All eight R52 content items are present and correctly stated.** The
   mechanical verification finds every required item at a named location in the
   doc. No item is paraphrased to a weaker form.

2. **The blanket statement qualification is the correct approach.** Retaining
   the overall prohibition and narrowing it with the R52 exception — rather than
   removing the prohibition entirely — preserves the authority boundary for every
   surface not named in the exception.

3. **The doc correctly separates the two caller surfaces (Ruby facade and CLI)**
   as distinct sections. The Ruby facade contract (`IgniterLang.compile`) is
   unchanged; the CLI section is additive. A caller using only the Ruby facade
   does not need to read the CLI section, and vice versa.

4. **The doc ends with the runtime-readiness separation clause.** Closing with
   "Runtime readiness remains governed by separate gates" is the right final
   signal for a caller who might wonder whether this bounded release also
   implies production deployment authority. ✓

5. **R50 NB-1 edge case is documented as accepted behavior.** Lines 200–206
   name the edge case, state the behavior, and note it does not widen authority.
   This satisfies the R52 recommendation ("should be documented if CLI docs add
   detailed refusal examples"). ✓

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the R52 condition is satisfied.

---

[NB-1 — Non-blocking: doc titled "Ruby API" covers significant CLI content]

`docs/ruby-api.md` now contains a substantial CLI section. A developer
searching for CLI documentation might not look in a file named "Ruby API."
The R53-C1-P1 decision not to create a separate CLI doc was reasonable for
keeping the sync scoped, but `docs/README.md` should eventually link the
CLI section explicitly (e.g., "CLI: see ruby-api.md § CLI Compiler Profile
Source Transport") so callers can find it without guessing.

This is a docs-navigation note only. The content is correct and present.
It does not block R52 condition satisfaction.

---

## R52 Docs Condition: Satisfied

**Explicit answer: YES. The R52 documentation condition is satisfied.**

All eight required content items are present and correctly stated in
`docs/ruby-api.md`. The outdated blanket prohibition is properly qualified
with the R52 bounded exception while preserving all other closures. No
prohibited surface is implied as open. The doc is comprehension-sound for
fresh callers on both the Ruby facade and CLI surfaces.

---

[Route]

**Verdict: proceed.**

No blockers. The R52 documentation condition is satisfied by the C1-P1
docs sync. NB-1 is a future docs-navigation improvement, not a gap in the
current required content.

**Status curation (C3-S) may record:**
- R53 complete;
- R52 condition `conditional-release-readiness-doc-sync-required` is now
  satisfied;
- bounded PROP-036 CLI transport is fully release-ready within the R52 scope;
- `docs/ruby-api.md` is the authoritative caller-facing reference for both
  the Ruby facade and the bounded CLI transport.
- Production/runtime authority remains a separate, future question.

**For R54:**
- No implementation work is open from this round.
- If a future caller or integration requires the CLI transport to be exercised
  outside the proof context, a production-promotion or release-engineering
  card is the correct next shape.
- NB-1 docs-navigation improvement (`docs/README.md` link to CLI section)
  can be bundled into any near-future status curation or minor docs card.
