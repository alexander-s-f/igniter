# Track: R31 Governance Map Sync v0

Card: S3-R31-C3-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: r31-governance-map-sync-v0
Status: done
Date: 2026-05-10

---

## Goal

Close R30 documentation drift from heat map, proposals queue, and CSM anchors.
Curation only — no semantic invention, no new PROPs, no compiler changes.

---

## Scope

1. Confirm proposals/README.md reflects GI-1 resolution (PROP-032 = assumptions, new PROP queue)
2. Update `semantic-governance-heat-map.md` stale rows:
   - startup_time freshness override validator: impl → 28/28 PASS
   - V-3 (`observed + temporal → temporal`) dedicated golden: impl → 25/25 PASS
   - GI-1 queue conflict references: close/resolve
3. Confirm CSM `observed` modifier row carries V-3 temporal anchor

---

## Pre-Check: What Was Already Done

| Item | Status before C3-S |
|------|--------------------|
| proposals/README.md — GI-1 renumbering | Done (S3-R30-C6-P): PROP-032=assumptions, PROP-033=via profile, PROP-034=output evidence, PROP-035=profile/authority |
| CSM `observed` modifier — V-3 anchor | Done: `observed_temporal_precedence.classified.json` already present as secondary golden anchor |
| CSM assumptions block status | Done: upgraded from `spec_candidate` to `proposed` (PROP-032 authored) |

No edits needed to proposals/README.md or canonical-semantic-model.md.

---

## What Changed in C3-S

### semantic-governance-heat-map.md

| Location | Before | After |
|----------|--------|-------|
| Header | Card: S3-R30-C4-P | Added: `Last updated: S3-R31-C3-S (2026-05-10)` |
| Domain 2 — `assumptions {}` block row | PROP: `PROP-032‡`; pipeline: all 🔴; debt: `sem/gov` | PROP: `PROP-032`; pipeline: Parse/Class/TC/SIR/RT → 🟡; Au → 🔴; debt: `gov` |
| Domain 2 — `uses assumptions NAME` row | Same as above | Same change |
| Domain 2 — footnote ‡ | "PROP-032 queue conflict … unresolved as of R29." | GI-1 resolved note (S3-R30-C6-P): PROP-032=assumptions, PROP-033=via profile |
| Domain 7 — `via profile binding` PROP | `PROP-032‡ (queue conflict)` | `PROP-033 (queued)` |
| Domain 7 — `output evidence syntax` PROP | `PROP-033 (queued)` | `PROP-034 (queued)` (+1 shift) |
| Domain 7 — `Profile System` PROP | `PROP-034 (queued)` | `PROP-035 (queued)` (+1 shift) |
| Domain 8 — startup_time row | debt: `impl` | debt: `none`, note: `28/28 PASS S3-R31` |
| Domain 8 — V-3 golden row | debt: `impl` | debt: `none`, note: `25/25 PASS S3-R31` |
| Domain 8 — PROP-032 queue conflict row | present (`gov` debt) | removed |
| §Governance Issues — GI-1 | "PROP-032 Queue Conflict (HIGH)" — active | Marked RESOLVED (S3-R30-C6-P) with resolution summary |
| Debt summary — `gov` | 15 | 16 (+2 assumptions rows, −1 queue conflict row) |
| Debt summary — `sem/gov` | 7 (incl. assumptions) | 5 (assumptions rows moved to `gov`) |
| Debt summary — `impl` | 10 (incl. startup_time + V-3) | 8 |
| Debt summary — `none` | 9 | 11 (+startup_time, +V-3) |
| Governance Layer domain heat | 4 open | 3 open |
| R31-1 | "prerequisite — resolve GI-1" | DONE (S3-R30-C6-P) |
| R31-6 | "V-3 golden anchor — add file" | DONE (S3-R31-C3-S) |

---

## Handoff

```text
Card: S3-R31-C3-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: r31-governance-map-sync-v0
Status: done

[D] Decisions
- proposals/README.md and CSM were already up-to-date before this card executed.
  Only the heat map required edits.
- Domain 2 assumptions rows: debt upgraded sem/gov → gov because PROP-032 is now
  authored (formal definition exists). Pipeline stages remain 🟡 until compiler
  implementation lands.
- Domain 8 startup_time and V-3 rows: impl → none (28/28 PASS and 25/25 PASS
  confirmed by card assignment; golden anchor verified in CSM).
- GI-1 closed in §Governance Issues. Queue conflict row removed from Domain 8.
- No new semantics introduced. No compiler changes. Documentation only.

[S] Shipped / Signals
- docs/dev/semantic-governance-heat-map.md: GI-1 resolved, Domain 2 upgraded,
  Domain 7 PROP renumbered, Domain 8 stale rows closed, debt counts updated,
  R31-1 and R31-6 marked done.
- docs/tracks/r31-governance-map-sync-v0.md: this track doc.

[T] Tests / Proofs
- Documentation only. No code changes. No proof surface affected.

[R] Risks / Recommendations
- GI-2 (Effect Surface PROP-035) remains CRITICAL — unchanged by this card.
  Seven postulates block on PROP-035.
- GI-3 (Managed Recursion — loop classes) and GI-4 (P28 OOF gap table) remain open.
- OQ-P28-1 (escape declaration naming enforcement) still routed to
  Compiler/Grammar Expert; blocks PROP-035 scope decision.
- OQ-Filter-1 (PROP Governance Filter vs META-EXPERT-013 §VI) still routed to
  Architect. P-31 in pre-production checklist.

[Next]
- R31-2: assumptions {} block (PROP-032) — Compiler/Grammar Expert to author grammar
  + minimal fixture; unblocked by GI-1 resolution.
- R31-3: OOF-I1/I3/I5 closure — Research Agent focused experiment pass.
- Compiler/Grammar Expert: answer OQ-P28-1 (escape declaration naming).
- Architect: decide OQ-Filter-1 (PROP Governance Filter source-of-truth).
```
