# Track: stage2-round3-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R3-C5-S
Status: done
Date: 2026-05-07
Depends on: S2-R3-C1-P, S2-R3-C2-P, S2-R3-C3-P, S2-R3-C4-P

---

## Scope

Post-round compact map refresh after Stage 2 Round 3.

---

## Proof Inventory — S2-R3 Results

| Experiment | Result | Tracks |
|------------|--------|--------|
| `history_type_proof` | ✅ PASS | option-encoding-normalization-v0, history-type-parser-acceptance-v0 |
| `sparkcrm_bihistory_fixture` | ✅ PASS | bihistory-parser-typechecker-axes-v0 (shared TemporalAccessRuntime) |
| `typechecker_proof` | ✅ PASS | bihistory-parser-typechecker-axes-v0 (4 BiHistory classified cases) |
| `temporal_access_runtime` | ✅ lib | history-temporal-access-runtime-extraction-v0 |
| `production_compiler_cli_proof` | ✅ PASS | diagnostics-implementation, diagnostics-extraction, library-boundary |
| `invariant_severity_proof` | ✅ PASS | invariant-severity-proof-v0 |
| `stage1_close_candidate` | ✅ PASS | no regression (5/5) |
| `lib/igniter_lang/diagnostics.rb` | ✅ require ok | compiler-diagnostics-library-boundary-v0 |

---

## Entry Path Verification

```
README.md         → coherent; Stage 1 CLOSED / Stage 2 OPEN; PROP-022..027 listed
operating-model.md → coherent; ownership, handoff format, anti-drift rules
current-status.md → updated (this track); stale BiHistory/severity gaps removed; 90 lines
spec/README.md    → updated (this track); v0.5; BiHistory axes + severity rows live; gaps refreshed
tracks/README.md  → rebuilt (this track); R3 evidence (9 tracks) + next shapes with roles
```

---

## Stale References Found and Fixed

| Location | Stale | Fixed to |
|----------|-------|---------|
| `current-status.md` | `⏳ axes gap` for BiHistory | ✅ axes typechecked |
| `current-status.md` | Invariant severity `🔵 authored` | ✅ PASS (proof-local) |
| `current-status.md` | `Active priority: BiHistory axes → ...` | `SemanticIR temporal node → production compiler` |
| `current-status.md` | No `temporal_access_runtime` row | Added ✅ MemoryBackend shared |
| `spec/README.md v0.4` | BiHistory `⏳ axes gap` | ✅ fixture PASS ✅ axes typechecked |
| `spec/README.md v0.4` | Invariant severity `deferred Stage 2` | ✅ proof PASS ⏳ parser/TC deferred |
| `spec/README.md v0.4` | Open gaps listed BiHistory axes, runtime extraction | Updated to R3 actual state |

---

## Files Changed

```
docs/current-status.md          rebuilt (R3 scoreboard; open gaps; stale removed)
docs/spec/README.md             updated v0.5 (BiHistory+axes, severity, temporal, coverage)
docs/tracks/README.md           rebuilt (R3 evidence table; next shapes with roles)
docs/tracks/stage2-round3-map-refresh-v0.md   new (this doc)
```

No changes to: `agent-motion.md`, `proposals/README.md`, `meta-proposals/`.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round3-map-refresh-v0
Card: S2-R3-C5-S
Status: done

[D] Decisions
- BiHistory[T] axes gap is CLOSED — typechecker_proof accepts 4 BiHistory classified cases.
- Invariant severity proof is PASS (proof-local); parser/TC ownership is the next slice, not a gap.
- TemporalAccessRuntime::MemoryBackend is now shared; SemanticIR node mapping is the next step.
- Production compiler diagnostics lib extracted to lib/igniter_lang/; package boundary still open.
- current-status.md and spec/README.md accurately reflect R3 state.

[S] Shipped
- current-status.md: R3 scoreboard, open gaps, stale refs cleaned.
- spec/README.md v0.5: BiHistory axes ✅, severity ✅, temporal access row added.
- tracks/README.md: 9 R3 tracks listed; next shapes with roles.
- stage2-round3-map-refresh-v0.md: this track doc.

[T] Tests / Proofs (all verified this session)
- stage1_close_candidate    PASS 5/5
- history_type_proof         PASS
- sparkcrm_bihistory_fixture PASS
- typechecker_proof          PASS
- invariant_severity_proof   PASS
- production_compiler_cli_proof  PASS 9 checks
- lib/igniter_lang/diagnostics.rb  library_require ok

[R] Risks / Recommendations
- SemanticIR temporal_access_node mapping is the logical next step
  (TemporalAccessRuntime API is stable; SemanticIR node shape is proven).
- Invariant severity parser syntax is an open question — track doc has explicit open Q.
  Resolve before writing grammar spec for severity.
- current-status.md is 90 lines — still compact; keep under 100.

[Next] Suggested next slice
  runtime-temporal-access-node-loader-v0    [Research Agent]       ← highest value
  compiler-result-report-boundary-v0        [Research Agent]       ← production compiler gap
  invariant-severity-parser-and-tc-v0       [Compiler/Grammar Expert]
  stream-t-proof-v0                         [Research Agent]       ← PROP-023
```
