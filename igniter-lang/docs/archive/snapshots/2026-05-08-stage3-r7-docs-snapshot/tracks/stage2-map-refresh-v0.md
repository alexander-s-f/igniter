# Track: stage2-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Status: done
Date: 2026-05-07

---

## Scope

Refresh Stage 2 map after parser OOF closure (PROP-026), production compiler contract
authoring (PROP-027), and doc cleanup cycle. Verify entry path coherence.

---

## Findings

### Entry path coherence

```
README.md → operating-model.md → current-status.md → assigned track
```

**README.md**: coherent. Navigation table is accurate. Stage 1 CLOSED / Stage 2 OPEN
correctly stated. Operating model linked. tracks/README.md linked.

**operating-model.md**: well-formed. Source of truth table is correct. Handoff format
is defined. Anti-drift rules are explicit. No contradictions found.

**tracks/README.md**: coherent. Recent Stage 2 evidence table is up to date. Suggests
`stage2-map-refresh-v0` as a candidate — this track fulfills it.

**current-status.md**: **needs compaction**. Document is 285 lines.
The following sections are historical and should not be required reading for a new agent:
- `## Stage 1 Deferred Gaps Status` (historical narrative)
- `## Stage 1 Remaining Gap` (superseded by PROP-026 PASS)
- `## Stage 1 Remaining Gap` (Stage 1 is closed)
- `## After Stage 1` (post-close plan — already executed)
- `## Next 3 Slices` (Slice 0/A/B/C — all CLOSED)
- `## Agent Routing` (superseded by META-EXPERT-008)
- `## Do Not Start` / `## Do Start` (superseded by META-EXPERT-008)
- `## Verification Commands` (already in README.md and track docs)

Also: Stage 1 scoreboard parser row still says "[gap] OOF rejection at parse time" —
but PROP-026 closed this gap in Stage 2. Minor wording drift.

### PROP numbering: verified clean

```
PROP-022   History[T]                    active Stage 2 authored
PROP-022A  .igapp assembler contract      Stage 1 frozen (accepted/)
PROP-023   stream T                       active Stage 2 authored
PROP-023A  ClassifiedExpr boundary        Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]              active Stage 2 authored
PROP-025   Invariant severity             active Stage 2 authored
PROP-026   Parser OOF hardening           ✅ PASS (Stage 2, Slice D)
PROP-027   Production compiler diag.      authored, no CLI yet (Tier 0 Gap B)
PROP-028+  next available
```

No new collisions. proposals/README.md §Queued correctly shows PROP-028 as next.

### Stage 2 state: verified

```
STAGE 2 CLOSED: NO
Active Tier 0 gap:  Production compiler package (PROP-027)
Active Tier 1:      History[T] PROP-022, Invariant severity PROP-025
Active Tier 2:      stream T PROP-023, OLAPPoint PROP-024 (depend on PROP-022)
```

No stale "parser OOF deferred" references remain in current-status, META-EXPERT-008,
proposals/README, or docs/README.

---

## Actions Taken

1. Compacted `current-status.md` — removed 7 historical sections; document now ~80 lines.
2. Updated Stage 1 scoreboard parser row — removed stale OOF gap note.
3. Updated Stage 2 scoreboard date header to 2026-05-07.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-map-refresh-v0
Status: done

[D] Decisions
- current-status.md is a compact map, not a narrative log (per operating-model.md rule).
- Historical sections moved out; entry path README → operating-model → current-status → track is coherent.
- PROP numbering clean: no collisions; next available PROP-028.

[S] Shipped / Signals
- current-status.md compacted to ~80 lines.
- Stage 1 parser OOF stale gap note removed.
- Stage 2 scoreboard date updated.
- This track doc written to tracks/.

[T] Tests / Proofs
- All Stage 1 proofs: ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb → PASS
- Stage 2 parser OOF: ruby igniter-lang/experiments/parser_oof_hardening_stage2_proof/... → PASS
- No new proofs in this track (map-only refresh).

[R] Risks / Recommendations
- current-status.md should stay compact (<= 100 lines). Resist adding narrative sections.
- agent-motion.md has a known numbering errata entry appended 2026-05-07. Do not re-raise.
- Production compiler package (PROP-027) is the only active Tier 0 gap. Assign to Research Agent.

[Next] Suggested next slice
- Supervisor: open track `extract-parser-module-v0` or `history-type-proof-v0`.
- Research Agent: production compiler CLI extraction (implement PROP-027 spec).
- New PROPs: start from PROP-028.
```
