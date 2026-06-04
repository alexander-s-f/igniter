# Experimental Loops/Recursion Pressure Boundary — External Pressure Review

Card: S3-R245-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: pressure-review
Track: experimental-loops-recursion-pressure-boundary-pressure-v0

Status: done / conditional-pass
Date: 2026-06-04

Depends on:
- S3-R245-C1-D (experimental-loops-recursion-pressure-and-spec-boundary-v0.md)
- S3-R245-C2-P1 (experimental-loops-recursion-current-surface-facts-v0.md)

---

## Verdict

**CONDITIONAL PASS.**

C1-D and C2-P1 are mutually consistent, correctly scoped, and free of authority
drift. No canonical authority is created. Lab implementation language is not
over-read. `fold_stream` is correctly separated. Service loops are correctly
deferred. `now()` prohibition is precise enough as a design stance. OOF
diagnostics are scoped as draft. All closed surfaces remain closed.

C4-A may accept the loops/recursion boundary as defined by C1-D and verified by
C2-P1. The conditions below are minor — they do not block acceptance but should
be explicitly recorded in C4-A's decision text.

---

## Pressure-Test Results

### Lab implementation language over-read as canonical?

**No.**

C1-D says explicitly: "lab evidence is valuable because it is concrete, but it
remains frontier draft evidence only." C2-P1 says: "generated outputs are stale
or produced by different compiler states/paths — they are useful pressure facts,
but not conformance, certification, or canonical behavior evidence."

Both documents use a consistent boundary: lab code → frontier draft pressure
evidence; not accepted conformance evidence; not implementation authority.

Risk level: **clean**.

---

### `fold_stream` conflated with arbitrary loops?

**No.**

C1-D: "`fold_stream` is already governed by stream/window semantics and does not
prove arbitrary loops."

C2-P1 behavior classification lists `fold_stream` explicitly as "Existing
bounded stream evidence; not arbitrary loop evidence."

The pressure-return document (lab-docs) also correctly distinguishes `fold_stream`
from the arbitrary loop surface — it describes `OP_MAP_REDUCE` (which handles
`fold_stream`/`map`/`filter`) as existing evidence and the managed-loop question
as a separate, at-the-time-full-gap concern.

Risk level: **clean**.

---

### Service loops require progression-fragment decision before specification acceptance?

**Partly deferred; stance is defensible but should be made explicit in C4-A.**

C1-D stance: no new fragment class required before service-loop specification
input; PROP-037 already prefers metadata/capability first. Service-loop
*execution* still requires progression source, materialization, receipt,
checkpoint, and backpressure vocabulary before implementation.

This is a reasonable hold — the progression/fragment-class question is genuinely
open. However, C2-P1 observes that the lab classifier already sets
`required_capability = "clock_tick"` and classifies service loops as ESCAPE.
That is a meaningful implicit answer from lab code: service loops map to ESCAPE
with a capability tag, not to a new fragment class.

**Claim risk:** If C4-A's spec-input route reads lab classifier output as settling
the progression/ESCAPE question, it would over-read lab evidence as canonical. C4-A
should explicitly record:

```text
service loop ESCAPE classification in lab classifier is draft pressure evidence
only, not an accepted fragment-class decision; the progression/fragment-class
question remains open for the spec input route.
```

Risk level: **low — note required in C4-A**.

---

### `now()` prohibition precise enough?

**Yes, as a design-input stance.**

C1-D: "`now()` must not appear as hidden time in contract/function bodies. Time
must be explicit through source/input/as_of/tick binding. The exact OOF code
should be registered in the next specification route."

This is precise as a stance. The exact OOF diagnostic code (OOF-L2 in lab, OOF-
M1/M2 in original pressure package — the two draft names do not match) remains
unregistered and is correctly held for the spec input route.

**Claim risk:** There is one conflation point C2-P1 correctly calls out: lab VM
Rust code uses `chrono::Utc::now()` in pipeline/TBackend-adjacent Rust
implementation code. This is not the Igniter source-level `now()` prohibition.
The two must not be conflated when reading lab evidence. C2-P1 is explicit about
this distinction. C4-A does not need further action beyond what C2-P1 records.

**Note for spec input route:** The draft OOF names for the `now()` prohibition
differ between the original pressure package (OOF-M1/M2) and the current lab
implementation (OOF-L2). The spec input route should settle a single canonical
name and placement before any registry acceptance.

Risk level: **low — OOF naming discrepancy is pre-existing and correctly deferred**.

---

### OOF diagnostics scoped as draft registry pressure?

**Yes.**

C1-D: "The lab OOF-L draft set is useful, but not accepted as canonical."
Recommends OOF-L1–L5 and OOF-SL1–SL2 as draft registry input only, to be routed
into a specification/diagnostics registry route before implementation authority.

C2-P1: "OOF-L/OOF-SL registry remains unaccepted."

Both are consistent. The draft registry table in C1-D is appropriately labeled
and correctly deferred.

**Caution — OOF-L3 robustness:** C2-P1 notes "current parser path may not
exercise empty-name check robustly." If OOF-L3 for unnamed loops does not
actually fire in practice, it may give a false signal that Postulate 28
enforcement is in place when it is not. This does not block acceptance but should
be noted as a gap to verify in the spec/fixture route.

Risk level: **clean at the authority level; minor robustness gap for later**.

---

### `igc run`, `.igbin`, RuntimeSmoke, public runtime, Reference Runtime, stable API, production, release, Spark, public demo/performance, certification, portability — still closed?

**Yes, uniformly.**

C1-D answers explicitly yes to every item.
C2-P1 answers explicitly yes to every item.

Boundary matrix in C1-D marks `igc run` Slice 1 widening and `.igbin` execution
as closed with "Separate later authorization." No authorized docs, track, or code
change in C1-D or C2-P1 touched any of these surfaces.

Risk level: **clean**.

---

## Claim-Risk Summary

| Risk | Severity | Status |
| --- | --- | --- |
| Lab implementation language over-read as canonical | None found | Clean |
| `fold_stream` conflated with arbitrary loops | None found | Clean |
| Service-loop ESCAPE classification in lab over-read as canonical fragment-class decision | Low | Note required in C4-A |
| `chrono::Utc::now()` in Rust VM code conflated with Igniter source `now()` prohibition | Low | C2-P1 caught; no further action needed |
| OOF diagnostic naming discrepancy (OOF-M1/M2 vs OOF-L2) across documents | Low | Deferred correctly; note for spec route |
| OOF-L3 parser path may not exercise empty-name check robustly | Low | Gap for spec/fixture route; does not block acceptance |
| Stale pressure-return doc records "full gap" for loop/recursion surfaces now implemented in lab | Informational | C2-P1 correctly identifies staleness; pressure-return doc should be treated as superseded by lab code state |
| Conflicting generated outputs (standalone `oof` vs `.igapp` `ok`) | Informational | C2-P1 correctly records conflict; neither may be treated as conformance evidence |
| `break` keyword: lexed and has VM opcode but source-level parser/emitter path unverified | Informational | Not a scope issue; relevant gap for future spec/fixture work |
| Recursive function execution: no VM path found | Informational | C1-D correctly limits recursion to design input only; no execution claims made |
| All closed surfaces (`igc run`, `.igbin`, RuntimeSmoke, public runtime, etc.) | None found | Clean |

---

## Boundary Confirmation

The following boundaries, as stated in C1-D, hold under this review:

| Surface | C3-X finding |
| --- | --- |
| `fold_stream` | Separate; not loop proof | Confirmed |
| `loop Name in coll max_steps: N` | Design input only | Confirmed |
| `decreases fuel` recursion | Design input only; no execution claim | Confirmed |
| Service loop / PROP-037 progression | Correctly deferred; ESCAPE classification in lab is draft only | Confirmed with note |
| `tick.time` explicit temporal binding | Design input only | Confirmed |
| `now()` prohibition | Design input only; OOF code still draft | Confirmed |
| Postulate 28 loop naming | Design input only | Confirmed |
| Lab parser/typechecker/emitter/VM | Frontier draft evidence only | Confirmed |
| `igc run` Slice 1 widening | Closed | Confirmed |
| `.igbin` execution | Closed | Confirmed |
| Compiler passport emission | Closed | Confirmed |
| RuntimeSmoke productization | Closed | Confirmed |
| Public runtime support | Closed | Confirmed |
| Reference Runtime support | Closed | Confirmed |
| Stable API | Closed | Confirmed |
| Production, Spark, release, public demo/performance | Closed | Confirmed |
| Certification and portability guarantees | Closed | Confirmed |

---

## Exact C4-A Recommendation

**Accept.** C4-A should accept the loops/recursion pressure boundary as specified
by C1-D and verified by C2-P1, with the following explicit record items:

1. **Service-loop ESCAPE note.** Record that the lab classifier's ESCAPE
   classification for service loops and `required_capability = "clock_tick"` is
   frontier draft evidence only, not an accepted fragment-class or ESCAPE-class
   decision. The progression/fragment-class question remains open for the spec
   input route.

2. **Stale pressure-return superseded.** Record that
   `loops-and-recursion-pressure-package-return.md` (which describes loop/
   recursion as full gaps across all layers) is superseded by current lab code
   state as documented by C2-P1. C4-A should not cite the pressure-return doc
   as evidence of current lab capability.

3. **Conflicting generated outputs are non-evidence.** Record that the standalone
   `out/loops_and_recursion.compilation_report.json` (`pass_result=oof`) and the
   `.igapp` compilation report (`pass_result=ok`) are inconsistent and neither
   constitutes conformance or canonical behavior evidence.

4. **OOF name disambiguation for spec route.** The spec input route should
   reconcile OOF-M1/M2 (original pressure package naming) with OOF-L2 (current
   lab naming) and settle a single canonical code before any registry entry is
   accepted.

5. **OOF-L3 gap.** The spec/fixture route should verify that the loop naming
   enforcement diagnostic actually fires under the expected source patterns before
   Postulate 28 enforcement is considered complete.

With these items recorded, C4-A should open the next route as recommended by C1-D:

```text
Card: S3-R246-C1-D
Route type: design / specification-input
Goal: Runtime Specification and PROP-037+ input slice covering bounded
local loops, recursion with explicit fuel, service-loop/progression
separation, tick.time binding, now() prohibition, Postulate 28 loop
naming, and draft OOF-L/OOF-SL registry vocabulary.

Closed: implementation, igc run widening, .igbin execution, compiler
passport emission, RuntimeSmoke productization, public runtime support,
Reference Runtime support, stable API, production, Spark, release,
public performance claims, certification, and portability guarantees.
```

---

[Agree]
- C1-D boundary matrix is correct and precise.
- C2-P1 correctly identifies stale pressure-return wording and conflicting
  generated outputs.
- fold_stream / bounded loop / service loop / recursion separation is maintained.
- Lab code is treated as frontier draft evidence throughout.
- All closed surfaces confirmed closed.

[Challenge]
- None that block acceptance. The service-loop ESCAPE classification in the lab
  classifier is the closest open question — not a current authority problem, but
  a wording precision point that C4-A should explicitly record rather than leave
  implicit.

[Missing]
- OOF-L3 robustness: whether the unnamed-loop diagnostic actually fires under
  realistic patterns is unverified. This is a gap for the spec/fixture route.
- OOF naming reconciliation between pressure package (OOF-M1/M2) and lab
  (OOF-L2) — deferred correctly but should be an explicit early task in the
  spec input route.
- `break` source-level path: whether `break` is part of the bounded-loop
  surface or a future extension is unresolved. The spec input route should decide.

[Sharper Question]
- For the next spec input route: does the service-loop surface need a PROP-037
  companion amendment that explicitly answers the progression/fragment-class
  question as metadata-only, or does PROP-037 as written already settle this
  sufficiently for the spec input boundary?

[Route]
- ACCEPT → C4-A with the five noted record items.
- Next: S3-R246-C1-D (Runtime Specification / PROP-037+ input slice).
