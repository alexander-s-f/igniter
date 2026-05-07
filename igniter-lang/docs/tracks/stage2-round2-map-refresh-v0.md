# Track: stage2-round2-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R2-C5-P
Status: done
Date: 2026-05-07

---

## Scope

Map refresh after Stage 2 Round 2 (C1–C4). Verify scoreboard, entry path, PROP
numbering, and spec coverage. Compact update only — no new proofs.

---

## Proof Inventory — S2-R2 Results

| Experiment | Run result | Notes |
|------------|-----------|-------|
| `stage1_close_candidate` | ✅ PASS | All 5 Stage 1 suites still green |
| `parser_oof_hardening_stage2_proof` | ✅ PASS | PROP-026 — 4 checks |
| `production_compiler_cli_proof` | ✅ PASS | 9 checks: compile.add + runtime.evaluate + OOF rejection |
| `history_type_proof` | ✅ PASS | History[Integer] point access + OOF-H1 negative |
| `sparkcrm_bihistory_fixture` | ✅ PASS | OOF-BT1..4 + correction fixture |

---

## Entry Path Verification

```
README.md             → coherent; PROP-022..027 listed; Stage 1 CLOSED / Stage 2 OPEN
operating-model.md    → coherent; ownership table and handoff format correct
current-status.md     → 80 lines; Stage 2 scoreboard already updated by R2 agents; compact ✅
tracks/README.md      → updated (this track); R2 evidence table + next shapes with role assignments
```

---

## Findings

### current-status.md
Already updated by R2 agents with:
- History[T] point proof PASS
- BiHistory fixture PASS
- Production compiler CLI PASS
- Option[T] normalization note
- PROP-022..027 canonical map

No further changes needed to `current-status.md`.

### spec/README.md — stale, fixed
Four stale items found and corrected:
1. `Ch2 OOF rejection gap` → now shows "closed PROP-026"
2. `Ch9 History[T]` → now shows `history_type_proof/ ✅ point proof PASS ⏳ parser gap`
3. `Ch9 BiHistory[T]` → new row added: `sparkcrm_bihistory_fixture/ ✅ fixture PASS ⏳ axes gap`
4. `## Stage 1 Remaining Gap` section → rewritten as Stage 2 open gaps with closed items listed
5. Version bumped 0.3 → 0.4

### PROP numbering: clean
No new collisions. PROP-028 remains next available.

### Option[T] normalization
`current-status.md` already records this as `⚠ normalize next`.
Normalization is **not** blocking; History[T] proof passes in current shape.
Next track: `option-encoding-normalization-v0` before BiHistory axes work.

---

## Files Changed

```
docs/spec/README.md           updated (version 0.4, OOF gap, Ch9 rows, gaps section)
docs/tracks/README.md         rebuilt (S2-R2 evidence table, next shapes with roles)
docs/tracks/stage2-round2-map-refresh-v0.md   new (this track)
```

No changes to: `current-status.md` (already correct), `agent-motion.md`,
`proposals/README.md`, `meta-proposals/`.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round2-map-refresh-v0
Card: S2-R2-C5-P
Status: done

[D] Decisions
- current-status.md was already compact and correct from R2 agents; no edit needed.
- spec/README.md was stale on Ch2 OOF and Ch9 History/BiHistory; now fixed.
- tracks/README.md rebuilt with full R2 evidence table and role-assigned next shapes.
- PROP numbering clean; next available = PROP-028.

[S] Shipped / Signals
- spec/README.md v0.4: Ch2 OOF closed, Ch9 History[T]+BiHistory rows live.
- tracks/README.md: R2 evidence (11 tracks) + 4 next shape candidates with roles.
- stage2-round2-map-refresh-v0.md track doc written.

[T] Tests / Proofs
- stage1_close_candidate PASS (5/5)
- parser_oof_hardening_stage2_proof PASS
- production_compiler_cli_proof PASS (9 checks)
- history_type_proof PASS
- sparkcrm_bihistory_fixture PASS

[R] Risks / Recommendations
- Option[T] encoding normalization should happen before BiHistory axes generalization.
  history_type_proof currently uses {some:v}/{none:true}; canonical is {kind:"some"/"none"}.
- current-status.md is 80 lines — keep it there. No new narrative sections.
- BiHistory axes (parser/typechecker generalization) is the next highest-value slice
  after Option normalization.

[Next] Suggested next slice
  Option[T] normalization:  option-encoding-normalization-v0         [Research Agent]
  BiHistory axes:           bihistory-parser-typechecker-axes-v0     [Compiler/Grammar Expert]
  Diagnostics extraction:   extract-canonical-json-diagnostics-v0    [Research Agent]
  Invariant severity:       invariant-severity-proof-v0              [Research Agent]
```
