# Track: Gate 3 Request Revision v0

Card: S3-R12-C1-S
Agent: `[Igniter-Lang Meta Expert]`
Role: meta-expert
Track: `igniter-lang/runtime-temporal-executor-gate3-request-revision-v0`
Status: done
Date: 2026-05-09

Revised document:
`docs/gates/runtime-temporal-executor-gate3-request-v0.md`

Triggering discussion:
`docs/discussions/gate3-request-safety-pressure-v0.md` (S3-R11-X1-S)
Verdict: HOLD — two required edits before Architect review

---

## Goal

Apply S3-R11-X1 HOLD fixes to the Gate 3 opening request so it is safe to
route to the Architect Supervisor for decision.

---

## HOLD Status

| Item | Was | Now | Status |
|------|-----|-----|--------|
| C-1 (HIGH): authority ref precondition | Section VI framed authority ref as something the Architect does when writing the decision record; gate could open before authority source exists | Authority ref is an explicit precondition: Gate 3 is not open until the decision document contains authority ref + format + issuance + revocation | ✅ FIXED |
| C-2 (HIGH): AT-10 optionality | AT-10: "Every authorized live read emits a structured observation record (if Q5 is approved)" — live reads could run untraceable if Q5 deferred | AT-10 is unconditional; Q5 is closed ("audit observation is required for every live temporal read"). Persistence is proof-local; emission is not conditional on persistence readiness | ✅ FIXED |

**HOLD → FIXED. Ready for Architect review.**

---

## Clarity Items Applied

| Item | Change |
|------|--------|
| C-3 (medium): TBackend vs Ledger-backed ambiguity | Reworded Exclude table entry: abstract TBackend interface is authorized; real Ledger-backed adapter is Phase 2 (requires Architect addendum, not a new gate) |
| C-4 (medium): AT-2 has no proof anchor | Added `compatibility-report-composition-v0` as named pending track reference in the Require table; noted it must land before any live eval proceeds |
| C-5 (low-medium): AT-11 regression surface informal | Expanded AT-11 to explicitly name the S3-R7 through S3-R10 proof scripts as the Gate 3 regression surface (six named scripts) |
| C-6 (low): Q6 is an expected-answer question | Q6 closed as AT-12: TEMPORAL executor must check `fragment_class` and refuse CORE artifacts unconditionally |
| M-1: no scope-not-expanded statement | Added "Scope Boundary" section between Exclude and Require tables; binds exclusions to approval |
| M-2: Q3 Option C phase boundary undefined | Q3 now describes Phase 1 (proof-local MemoryBackend, authorized on gate opening) and Phase 2 (real adapter, requires Architect addendum) with explicit transition conditions |
| M-3: Ch7 sync gap unrouted | Added to Section VI recommendation condition 8: post-gate `spec-ch7-gate3-approval-sync` routing obligation |

---

## Changes Summary

### Section III (Decision Table)
- **Exclude table**: Ledger-backed TBackend entry rewritten to clarify abstract
  interface vs. concrete adapter; Phase 2 addendum requirement stated.
- **Scope Boundary** (new subsection): "Gate 3 approval authorizes only the
  items listed in Authorize. All excluded items remain closed. A separate gate
  request (or named addendum) is required for each excluded surface."
- **Require table**: AT-2 row updated with `compatibility-report-composition-v0`
  pending track reference. AT-10 row updated: unconditional, Q5 closed.

### Section IV (Open Decisions)
- **Q5**: Closed. "Every authorized `read_as_of` call must emit a structured
  observation record. This is not optional." Persistence is proof-local; emission
  is unconditional.
- **Q6**: Closed as AT-12. No open decision remains.
- **Q3**: Option C expanded with Phase 1 / Phase 2 description and explicit
  transition condition (Architect addendum, not a new gate).

### Section V (Production Acceptance Checklist)
- **AT-10**: `(if Q5 is approved)` qualifier removed. Unconditional wording
  with explicit Q5-closed annotation.
- **AT-11**: Expanded to name six S3-R7..R10 proof scripts as the Gate 3
  regression surface.
- **AT-12** (new): TEMPORAL executor must check `fragment_class` and refuse
  CORE artifacts with a named gate-scope-exclusion refusal.
- Checklist header updated: "AT-1 through AT-12 are the complete acceptance
  surface; none may be deferred."

### Section VI (Recommendation)
- **Condition 1**: Rewritten as a precondition. "Gate 3 is not open until the
  decision document exists and includes: authority ref, format, issuance process,
  and revocation mechanism."
- **Condition 3**: Q3 Option C Phase 1 / Phase 2 stated in recommendation.
- **Condition 5**: Q5 stated as closed (required, not optional).
- **Condition 6**: Q6 confirmed, references AT-12.
- **Condition 7**: Updated to AT-1 through AT-12.
- **Condition 8** (new): Post-gate `spec-ch7-gate3-approval-sync` routing obligation.
- **Hold conditions**: Updated to reflect authority ref as an absolute
  precondition, not a conditional.

### Document Header
- Card reference: `S3-R11-C1-G (revised: S3-R12-C1-S)`
- Date: `2026-05-08 (revised: 2026-05-09)`
- Status: `request — S3-R11-X1 HOLD resolved — ready for Architect review`

---

## Post-Gate Backlog (not blocking approval)

| Item | Track | Status |
|------|-------|--------|
| CompatibilityReport composition reference shape | `compatibility-report-composition-v0` | Not yet landed; must land before live eval |
| Ch7 PROP-030 enforcement ordering sync | `spec-ch7-gate3-approval-sync` | Post-gate; route to Compiler/Grammar Expert |
| Production RuntimeMachine preflight binding | `runtime-report-enforcement-preflight-v0` | Post-gate; AT-3 names it |
| Observation persistence + audit receipts | `compatibility-report-persistence-audit-v0` | Post-gate; AT-10 backing |

---

## Revision Verdict

```text
HOLD: FIXED (C-1 authority ref precondition + C-2 AT-10 unconditional)
All medium/low clarity items: ADDRESSED (C-3 through C-6, M-1, M-2, M-3)
Gate 3 request: READY FOR ARCHITECT REVIEW
```

---

## Handoff

```text
Card: S3-R12-C1-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: igniter-lang/runtime-temporal-executor-gate3-request-revision-v0
Status: done

[D] Decisions:
- S3-R11-X1 HOLD resolved. Gate 3 request is safe to route to Architect.
- Authority ref is a gate-opening precondition (not a post-approval action).
- AT-10 is unconditional; Q5 is closed.
- AT-12 is new: CORE artifact refusal by TEMPORAL executor.
- Q3 Option C Phase 1/Phase 2 explicitly described.
- Scope-does-not-expand binding added to Section III.
- Post-gate spec-ch7-gate3-approval-sync obligation routed.

[S] Shipped:
- docs/gates/runtime-temporal-executor-gate3-request-v0.md (revised)
- docs/tracks/runtime-temporal-executor-gate3-request-revision-v0.md

[Next]:
- Architect Supervisor: review gate request and issue
  docs/gates/gate3-decision-record-v0.md
- Gate decision must include: authority ref + format + issuance + revocation;
  Q2 BiHistory permanent/temporary exclusion; Q3 Option C phase approval.
- Post-gate: route spec-ch7-gate3-approval-sync and compatibility-report-composition-v0.
```
