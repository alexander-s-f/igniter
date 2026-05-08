# Track: stage2-round4-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R4-C5-S
Status: done
Date: 2026-05-07
Depends on: S2-R4-C1-P, S2-R4-C2-P, S2-R4-C3-P, S2-R4-C4-P

---

## Scope

Post-round compact map refresh after Stage 2 Round 4.

---

## Proof Inventory — S2-R4 Results

| Experiment | Result | Track |
|------------|--------|-------|
| `history_type_proof` | ✅ PASS | runtime-temporal-access-node-loader-v0 |
| `sparkcrm_bihistory_fixture` | ✅ PASS | runtime-temporal-access-node-loader-v0 |
| `production_compiler_cli_proof` | ✅ PASS (9 checks) | compiler-result-report-boundary-v0 |
| `invariant_severity_proof` | ✅ PASS | invariant-severity-parser-and-typechecker-ownership-v0 |
| `stream_t_proof` | ✅ PASS | stream-t-proof-v0 |
| `stage1_close_candidate` | ✅ PASS (5/5) | no regression |
| `typechecker_proof` | ✅ PASS | no regression |
| `lib/igniter_lang/` | ✅ require ok | compiler_result.rb + compilation_report.rb added |

New lib files extracted:
```
igniter-lang/lib/igniter_lang/diagnostics.rb       (R3)
igniter-lang/lib/igniter_lang/compiler_result.rb   (R4, new)
igniter-lang/lib/igniter_lang/compilation_report.rb (R4, new)
```

---

## Entry Path Verification

```
README.md         → coherent; PROP table includes PROP-023..027
operating-model.md → coherent; no changes needed
current-status.md → updated (this track); stream T ✅; temporal node ✅; 3 libs ✅; ~100 lines
spec/README.md    → updated (this track); v0.6; stream T + temporal SemanticIR rows; gaps R4
tracks/README.md  → rebuilt (this track); R4 evidence; next shapes updated
```

---

## Stale References Found and Fixed

| Location | Stale | Fixed to |
|----------|-------|---------|
| `current-status.md` | stream T `🔵 authored` | ✅ PASS (proof-local) |
| `current-status.md` | temporal_access_node missing | Added ✅ evaluated end-to-end |
| `current-status.md` | Only 1 lib extracted | 3 libs extracted |
| `current-status.md` | `Active priority: SemanticIR temporal node ...` | `parser module → stream classifier → OLAP` |
| `current-status.md` | Severity `⏳ impl deferred` without spec note | `✅ spec done ⏳ impl deferred` |
| `spec/README.md` | stream T `deferred Stage 2` | ✅ proof PASS ⏳ parser/classifier next |
| `spec/README.md` | Severity `⏳ parser/TC deferred` | ✅ spec done ⏳ impl deferred |
| `spec/README.md` | No temporal SemanticIR row | Added: temporal_access_node evaluated |
| `spec/README.md` | Open gaps had 4 items (R3 state) | Updated to 5 items (R4 state) |

---

## Files Changed

```
docs/current-status.md          rebuilt (R4 scoreboard; stream T, temporal, libs, open gaps)
docs/spec/README.md             updated v0.6 (stream T, temporal SemanticIR, coverage, gaps)
docs/tracks/README.md           rebuilt (R4 evidence table; next shapes with roles)
docs/tracks/stage2-round4-map-refresh-v0.md   new (this doc)
```

No changes to: `agent-motion.md`, `proposals/README.md`, `meta-proposals/`.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round4-map-refresh-v0
Card: S2-R4-C5-S
Status: done

[D] Decisions
- stream_t_proof PASS — stream T is no longer "deferred"; it is proof-local PASS pending
  parser/classifier boundary.
- temporal_access_node is evaluated end-to-end in history+bihistory proofs via
  TemporalAccessRuntime. Production RuntimeMachine integration is the next step.
- 3 libs now in lib/igniter_lang/ — production compiler package boundary is advancing.
- Invariant severity parser/TC spec done; implementation is Tier 1 (after compiler closes).
- PROP-024 OLAPPoint remains the only fully deferred Stage 2 design PROP.

[S] Shipped
- current-status.md: R4 scoreboard; stream T ✅; temporal node ✅; libs ✅; open gaps updated.
- spec/README.md v0.6: stream T row, temporal SemanticIR row, severity spec note, R4 gaps.
- tracks/README.md: R4 evidence (5 tracks); next shapes with roles.
- stage2-round4-map-refresh-v0.md: this track doc.

[T] Tests / Proofs (verified this session)
- stage1_close_candidate PASS 5/5
- history_type_proof         PASS
- sparkcrm_bihistory_fixture PASS
- typechecker_proof          PASS
- production_compiler_cli_proof PASS 9 checks
- invariant_severity_proof   PASS
- stream_t_proof             PASS
- lib/igniter_lang/ library_require ok (3 files)

[R] Risks / Recommendations
- Production compiler parser extraction is the next highest-value slice.
  Keep production_compiler_cli_proof PASS as regression guard.
- stream T OOF-S1..S5 are defined but unimplemented in parser/classifier.
  Do not widen stream T runtime until classifier boundary is proven.
- invariant severity implementation is Tier 1 — do not start until Tier 0 closes.
- current-status.md is ~100 lines — acceptable; keep under 110.

[Next] Suggested next slice
  extract-parser-module-v0                         [Research Agent]       ← Tier 0, highest value
  stream-parser-classifier-boundary-v0             [Compiler/Grammar Expert]
  production-runtime-temporal-access-integration-v0 [Research Agent]
  olap-point-proof-v0                              [Research Agent]       ← PROP-024
```
