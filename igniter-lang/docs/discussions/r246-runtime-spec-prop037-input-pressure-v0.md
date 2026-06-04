# R246 Runtime Spec / PROP-037+ Input Slice — External Pressure Review

Card: S3-R246-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: pressure-review
Track: experimental-loops-recursion-runtime-spec-input-pressure-v0

Status: done / conditional-pass
Date: 2026-06-04

Depends on:
- S3-R246-C1-D (experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0.md)
- S3-R246-C2-P1 (experimental-loops-recursion-runtime-spec-current-surface-facts-v0.md)

Also reviewed:
- S3-R245 status curation (stage3-round245-status-curation-v0.md)
- S3-R245-C4-A decision (experimental-loops-recursion-pressure-and-spec-boundary-decision-v0.md)
- PROP-037-external-progression-service-liveness-v0.md
- docs/spec/ch13-managed-recursion.md
- docs/spec/ch8-stdlib.md

---

## Verdict

**CONDITIONAL PASS** — one scoping gap must be explicitly addressed in C4-A before
R247 can safely open. Three caution items do not block acceptance but require
explicit record in C4-A. No authority drift, no lab-to-canon leakage, no
premature implementation routing found in C1-D or C2-P1 directly.

---

## Pressure-Test Results

### 1. Bounded loops, recursion, service loops, and fold_stream remain separated?

**Yes — clean.**

C1-D states explicitly: bounded local loops are a separate managed-local-repetition
surface; `fold_stream` remains stream/window bounded reduction; recursion with
`decreases fuel` is a distinct class from service loops; service loops are
progression-backed liveness surfaces, not execution loops.

C2-P1 separately classifies each surface in its compact matrix and confirms none
collapse into a generic "loop."

PROP-037 §4 preserves the Chapter 13 five-class taxonomy (FiniteLoop,
StructuralRecursion, FuelBoundedRecursion, ConvergentLoop, ServiceLoop) and
explicitly separates them from `fold_stream` (§3). The five-class separation is
intact across all three artifacts.

**Risk level: none found.**

---

### 2. Service-loop ESCAPE / fragment-class authority remains unaccepted?

**Yes — clean.**

C1-D: "no new PROGRESSION fragment class is accepted by this route; lab ESCAPE
classification and clock_tick capability are draft pressure only."

C2-P1: PROP-037 carries metadata/capability-first as the accepted stance with no
PROGRESSION fragment class.

R245-C4-A already records the service-loop ESCAPE classification in the lab
classifier as frontier draft evidence only. That record is correctly inherited by
C1-D/C2-P1, not reopened.

**Risk level: none found.**

---

### 3. OOF naming reconciliation is explicit enough?

**Partly. One scoping gap identified.**

C1-D correctly refuses to mint a new OOF code and routes reconciliation into the
wording sync. It identifies three conflicting candidates:

| Candidate | Source |
| --- | --- |
| `OOF-L6` | Chapter 8 stdlib (existing spec text) |
| `OOF-M1` / `OOF-M2` | Original pressure package (draft) |
| `OOF-L2` | Lab code (frontier draft) |

C2-P1 adds a detailed namespace fact table that correctly shows `OOF-M*` is
already occupied by imports (Ch2), modifiers (Ch10), and effect surfaces (Ch12),
making `OOF-M1/M2` a collision risk rather than a free slot.

**Scoping gap — requires C4-A action:**

C1-D's proposed R247-C2-I write scope includes:

```text
igniter-lang/docs/spec/ch13-managed-recursion.md
igniter-lang/docs/proposals/PROP-037-... (companion/amendment wording only)
igniter-lang/docs/proposals/README.md (if explicitly authorized)
```

It does **not** include:

```text
igniter-lang/docs/spec/ch8-stdlib.md          -- where OOF-L6 lives
igniter-lang/docs/language-covenant.md        -- where OOF-M1 is mentioned
```

If OOF reconciliation is a required goal of the wording sync (and C1-D states it
is), the proposed write scope cannot complete that goal without touching at least
`ch8-stdlib.md`. Accepting the OOF reconciliation task while silently excluding
the file that holds the existing spec OOF entry would either (a) leave the
reconciliation incomplete, or (b) force the wording sync to open scope beyond
what C4-A authorized.

**C4-A must either:**

- explicitly add `ch8-stdlib.md` to the R247-C2-I write scope, or
- constrain the OOF reconciliation goal in R247 to proposal text and errata
  notes only, with `ch8-stdlib.md` edits deferred to a separate errata card.

**Risk level: scoping gap — must be resolved in C4-A before R247 opens.**

---

### 4. `break` is safely included or deferred?

**Yes — clean.**

C1-D: "Treat break as a future extension. First spec slice should model
termination through collection exhaustion, max_steps/fuel, structural decreases,
convergence, or service cancellation/suspension obligations."

C2-P1: "break remains draft pressure only and should stay excluded from the first
spec input slice."

Both are explicit and consistent. `break` is not in the spec input matrix and
carries no canonical status.

**Risk level: none found.**

---

### 5. Chapter 13 / PROP-039+ routing is precise enough?

**Mostly — one caution item.**

C1-D correctly separates local managed loops/recursion (→ Chapter 13 errata +
PROP-039+ or later) from service-loop/progression mapping (→ PROP-037
companion/amendment). The ownership split is stated explicitly.

**Caution — PROP-036+ stale reference in enforcement-path track:**

C2-P1 notes that `docs/tracks/covenant-promise-enforcement-path-rule-v0.md`
still names the future managed-recursion placeholder as `PROP-036+`, while
`docs/proposals/README.md` now uses `PROP-039+ or later`. Since PROP-036 is
reserved for `compiler_profile_id` manifest identity (PROP-037 header confirms
this), routing managed-recursion/loop-class extensions to `PROP-036+` is a
numbering error in the enforcement-path track.

C1-D does not flag this inconsistency. If C4-A accepts C1-D's dispatch as-is and
the wording-sync card or a future authoring card reads the enforcement-path track
as authoritative, it would inherit the wrong proposal slot.

**C4-A should record:**

```text
The enforcement-path track reference to PROP-036+ as a managed-recursion
placeholder is a stale naming error. PROP-039+ or later is the correct managed
local recursion / loop-class proposal slot, as confirmed by docs/proposals/README.md.
Any R247 authoring that touches loop-class proposal routing must use PROP-039+
or later, not PROP-036+.
```

**Risk level: low — stale reference in a non-authoritative track doc; C4-A
record required to prevent propagation.**

---

### 6. Chapter 13 §13.5 semantic conflict with PROP-037?

**Caution — stale equivalence claim must be called out explicitly in wording sync.**

Chapter 13 §13.5 states:

> `clock.every(N.duration)` ... is semantically equivalent to a `Stream[DateTime]`.

PROP-037 §3 explicitly says:

> A progression source is not a CORE value.
> Progression must not weaken OOF-S1..OOF-S5.

And PROP-037 §1:

> `Progression` is not a stream fold, not a local recursion class.

This is a direct semantic conflict. Chapter 13 §13.5 models `clock.every` as a
`Stream[DateTime]`, while PROP-037 places `clock.every` as a `source_kind` in the
Progression descriptor.

C2-P1 records this conflict: "it says clock.every(...) is semantically equivalent
to Stream[DateTime], while PROP-037 separates progression from stream/fold
surfaces." C1-D also notes Chapter 13 contains stale `now()` examples, but
neither document calls out §13.5 as a specific conflict requiring targeted errata
rather than general cleanup.

The wording-sync card must be scoped to fix §13.5 explicitly — not just "clean up
stale now() examples" — because the equivalence claim would undermine the
progression/stream separation that PROP-037 relies on.

**C4-A should add to R247 required authoring goals:**

```text
Correct Chapter 13 §13.5: clock.every must be classified as a progression
source_kind, not as semantically equivalent to Stream[DateTime]. This removes
a direct conflict with accepted PROP-037 wording.
```

**Risk level: low — Chapter 13 is deferred/draft so no runtime authority is
created now, but the fix is load-bearing for any future errata canonicalization.**

---

### 7. Lab implementation evidence remains frontier only?

**Yes — clean.**

C1-D: consistent use of "frontier draft evidence only" throughout. Explicit
answer: "Yes."

C2-P1: "Lab behavior remains frontier pressure only." Explicit answer: "Yes."

The language is explicit, consistent, and inherited from R245-C4-A without
weakening.

**Risk level: none found.**

---

### 8. All closed runtime/public/release/performance/certification surfaces remain closed?

**Yes — clean.**

C1-D gives explicit "yes" answers for every closed surface listed in the round
mandate: implementation authorization, `igc run` widening, `.igbin` execution,
compiler passport emission, RuntimeSmoke productization, public runtime support,
Reference Runtime support, stable API, production, Spark, release, public
performance, certification, and portability.

C2-P1 gives identical explicit "yes" answers.

The proposed R247-C2-I write scope explicitly marks `lib/**`, `bin/igc`,
gemspec, `source/**`, `out/**`, `experiments/**`, and `playgrounds/**` as closed.

**Risk level: none found.**

---

### 9. Service-loop / progression conflation?

**No — clean.**

C1-D §3 states the service-loop stance precisely: service loop is a surface,
progression is the semantic substrate. A PROP-037 companion/amendment is needed
to map source-level service-loop syntax to progression descriptors. This companion
does not create a new runtime authority.

C2-P1 confirms PROP-037 settles enough service-loop/progression vocabulary for a
companion source-syntax/descriptor-mapping input route, but not enough for
implementation or runtime execution.

The proposed combined wording sync guards PROP-037 edits with "only as
companion/amendment wording if C1-A explicitly authorizes" — which is a
reasonable conditional gate.

**One caution — ownership split must be preserved in R247 authorization:**

C4-A should require that the R247-C1-A authorization explicitly state which parts
of the combined wording sync belong to local loop/recursion territory (Chapter 13
+ PROP-039+) versus service-loop/progression territory (PROP-037 companion). If
R247-C2-I is issued a single unscoped wording-sync card, a single authoring pass
could accidentally blur the ownership split by using Chapter 13 errata to
implicitly resolve the PROP-037 companion question without a formal companion
being drafted.

**Risk level: low — mitigated if C4-A requires explicit scope guards in R247-C1-A.**

---

### 10. Proposal-numbering confusion?

**Minor — C4-A action recommended.**

C1-D writes out proposed R247 card numbers (S3-R247-C1-A, S3-R247-C2-I) and a
full dispatch recommendation in its own text. This is a design card writing
C4-A's decision in advance, which is structurally over-reaching for its role,
though it is framed as a recommendation only.

More importantly, the proposed next card says:

> `Track: experimental-loops-recursion-spec-prop037-wording-sync-authorization-review-v0`

This is an authorization review, not an authoring card — which is correct. But
C4-A must not auto-adopt the R247 card numbers from C1-D without independently
confirming them, since C4-A is the authority that dispatches next cards.

**Risk level: informational — no authority drift in C1-D since it is labeled
recommendation; C4-A must treat it as input only.**

---

## Claim-Risk Summary

| Risk | Severity | Status |
| --- | --- | --- |
| Bounded loop / recursion / service loop / fold_stream conflation | None found | Clean |
| Service-loop ESCAPE / fragment-class authority over-read | None found | Clean |
| OOF-L6 / OOF-M1/M2 / OOF-L2 reconciliation — proposed write scope excludes ch8 and Covenant | **Scope gap** | **C4-A must act** |
| PROP-036+ stale reference in enforcement-path track | Low | C4-A record required |
| Chapter 13 §13.5 `clock.every` = `Stream[DateTime]` conflict with PROP-037 | Low | C4-A must add explicit errata goal to R247 scope |
| Combined wording sync may blur Chapter 13 / PROP-037 companion ownership | Low | C4-A must require explicit ownership guards in R247-C1-A |
| C1-D writes out proposed R247 card numbers in advance | Informational | C4-A should treat as recommendation input only |
| `break` included in spec input | None found | Clean — deferred correctly |
| Lab evidence authority | None found | Clean |
| All closed surfaces | None found | Clean |

---

## Boundary Confirmation

| Surface | C3-X finding |
| --- | --- |
| `fold_stream` | Separate; not loop proof | Confirmed |
| Bounded local loops | Design input only; correctly separated from fold_stream | Confirmed |
| `decreases fuel` recursion | Design input only; execution unproven | Confirmed |
| Service loop / PROP-037 progression | Correctly scoped; ESCAPE classification in lab is draft only | Confirmed |
| `tick.time` explicit temporal binding | Design input only; ambiguity re: scheduled_at vs materialized_at acceptable at this stage | Confirmed |
| `now()` prohibition | Design input only; OOF reconciliation deferred correctly but write scope gap identified | Confirmed with scope-gap note |
| Postulate 28 loop naming | Design input only; OOF-L3 robustness unproven (inherited from R245) | Confirmed |
| `break` | Excluded from first slice; correctly deferred | Confirmed |
| OOF-L / OOF-SL registry | Draft input only; no registry acceptance | Confirmed |
| Lab compiler/VM | Frontier draft evidence only | Confirmed |
| `igc run` widening | Closed | Confirmed |
| `.igbin` execution | Closed | Confirmed |
| Compiler passport emission | Closed | Confirmed |
| RuntimeSmoke productization | Closed | Confirmed |
| Public runtime / Reference Runtime | Closed | Confirmed |
| Stable API / production / Spark / release | Closed | Confirmed |
| Public performance / certification / portability | Closed | Confirmed |

---

## Exact C4-A Recommendation

**CONDITIONAL ACCEPT** with the following required actions.

### Required C4-A action — OOF reconciliation write-scope gap

Either:

(a) Add `igniter-lang/docs/spec/ch8-stdlib.md` and `igniter-lang/docs/language-covenant.md`
to the R247-C2-I authorized write scope, with explicit guidance that OOF
reconciliation for `now()` must update the existing OOF-L6 entry or add a
cross-reference note; or

(b) Remove OOF reconciliation from the combined wording sync goal and route it
as a separate errata card with explicit write scope for ch8 and the Covenant.

Accepting C1-D's OOF reconciliation goal without one of these two resolutions
would create a task the wording-sync card cannot complete within its authorized
scope.

### Required C4-A record items

1. **PROP-036+ correction.** Confirm that PROP-039+ or later is the correct
   managed local recursion / loop-class proposal slot. Record that the
   enforcement-path track's PROP-036+ reference is a stale naming error and
   must not be used by R247 authoring.

2. **Chapter 13 §13.5 errata scope.** Add to R247 required authoring goals:
   `Correct Chapter 13 §13.5 to classify clock.every as a progression source_kind,
   not as semantically equivalent to Stream[DateTime].`

3. **Chapter 13 / PROP-037 ownership guard.** Require that R247-C1-A explicitly
   assigns ownership: Chapter 13 errata scope covers local managed loops and
   recursion (bounded loop grammar, max_steps, decreases fuel, OOF rules),
   while PROP-037 companion scope covers only source-syntax-to-progression
   descriptor mapping and tick.time binding. The two must not be collapsed into
   one pass without an explicit ownership boundary in the authorization card.

4. **R247 card numbers.** C4-A should treat the S3-R247 card numbers proposed by
   C1-D as recommendation input only. C4-A is the authority for next dispatch.

5. **OOF-L3 robustness gap.** Inherited from R245-C4-A: loop-naming enforcement
   diagnostic (OOF-L3) is not proven to fire under realistic source patterns. This
   gap must be flagged in R247 authoring as a future fixture requirement, not a
   current spec guarantee.

### Accept / open

With the above five items recorded and the OOF scope gap resolved, C4-A should
accept the R246-C1-D input slice and open:

```text
Card: S3-R247-C1-A
Route type: authorization review for docs/proposal/spec authoring only
Goal: authorize combined Runtime Spec + PROP-037+ wording sync with the
      write scope and ownership boundaries specified by C4-A
Required boundary:
  no implementation
  no igc run widening
  no .igbin execution
  no compiler passport emission
  no RuntimeSmoke productization
  no public runtime / Reference Runtime support
  no stable API / production / Spark / release claims
  no performance / certification / portability claims
  no lab behavior accepted as canon
```

Do not open R247-C2-I directly from C4-A. The authorization review (C1-A) must
set the exact write scope and ownership guards before a wording-sync authoring
card can run.

---

[Agree]
- C1-D boundary matrix is correct and precise.
- C2-P1 correctly captures the OOF namespace conflict and the Chapter 13 /
  PROP-037 stream-equivalence conflict.
- fold_stream / bounded loop / service loop / recursion separation is maintained.
- `break` is correctly excluded.
- Lab code is treated as frontier draft evidence throughout.
- All closed surfaces confirmed closed.

[Challenge]
- The proposed R247-C2-I write scope does not include the files where the
  conflicting OOF entries live (ch8-stdlib.md, language-covenant.md). This is
  the primary structural gap in C1-D's recommendation.
- Chapter 13 §13.5 conflict with PROP-037 is noted in C2-P1 but not explicitly
  added as a targeted errata goal in C1-D's wording sync scope. This should be
  explicit.

[Missing]
- Explicit confirmation that PROP-039+ (not PROP-036+) is the managed-recursion
  proposal slot.
- Explicit errata scope item for §13.5.
- Explicit scope resolution for OOF ch8 editing.

[Sharper Questions for C4-A]
- Should OOF reconciliation for `now()` be in the combined wording sync or a
  separate errata card? Bundling it without ch8 write scope access makes the
  goal unreachable.
- Does Chapter 13 §13.5 need targeted errata in the first wording sync pass, or
  can it be deferred to a second pass after the companion wording is settled?

[Route]
- CONDITIONAL ACCEPT → C4-A with five record items and OOF scope gap resolved.
- Next: S3-R247-C1-A (authorization review), not S3-R247-C2-I directly.
