# Track: stage2-round5-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R5-C5-S
Status: done
Date: 2026-05-07
Depends on: S2-R5-C1-P, S2-R5-C2-P, S2-R5-C3-P, S2-R5-C4-P

---

## Scope

Post-round compact map refresh after Stage 2 Round 5.

---

## Proof Inventory — S2-R5 Results

| Experiment / Library | Result | Track |
|----------------------|--------|-------|
| `olap_point_proof` | ✅ PASS | olap-point-proof-v0 |
| `lib/igniter_lang/parser.rb` | ✅ require ok | extract-parser-module-v0 |
| `lib/igniter_lang/temporal_access_runtime.rb` | ✅ require ok | production-runtime-temporal-access-integration-v0 |
| `parser_acceptance_spec` (61 specs) | ✅ PASS | extract-parser-module-v0 |
| `parser_oof_hardening_stage2_proof` | ✅ PASS | extract-parser-module-v0 |
| `production_compiler_cli_proof` | ✅ PASS (9 checks) | extract-parser-module-v0 |
| `stream_t_proof` | ✅ PASS | stream-parser-classifier-boundary-v0 |
| `history_type_proof` | ✅ PASS | production-runtime-temporal-access-integration-v0 |
| `sparkcrm_bihistory_fixture` | ✅ PASS | production-runtime-temporal-access-integration-v0 |
| `stage1_close_candidate` | ✅ PASS (5/5) | no regression |
| `typechecker_proof` | ✅ PASS | no regression |

lib/igniter_lang/ after R5 (5 files):
```
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5) — NEW; includes stream/fold_stream keywords
temporal_access_runtime.rb (R5) — NEW; MemoryBackend + capability helper
```

---

## Entry Path Verification

```
README.md         → coherent; PROP-022..027 listed; current-status links correct
operating-model.md → coherent; no changes needed
current-status.md → updated (this track); OLAPPoint ✅; 5 libs; classifier next; ~115 lines
spec/README.md    → updated (this track); v0.7; OLAPPoint row + stream parser row; R5 gaps
tracks/README.md  → rebuilt (this track); R5 evidence; lib inventory section; next shapes
```

---

## Stale References Found and Fixed

| Location | Stale | Fixed to |
|----------|-------|---------|
| `current-status.md` | OLAPPoint `🔵 authored` | ✅ PASS (proof-local) |
| `current-status.md` | `3 libs extracted` | 5 libs extracted |
| `current-status.md` | `Active priority: parser module → ...` | `classifier module → stream classifier → OLAP parser/TC` |
| `current-status.md` | No stream parser row | stream keywords parsed row added |
| `current-status.md` | Gap 1 = parser extraction | Gap 1 = classifier extraction |
| `current-status.md` | Gap 4 = OLAPPoint no experiment | Gap 4 = RuntimeMachine hook |
| `spec/README.md v0.6` | OLAPPoint `deferred Stage 2` | ✅ proof PASS ⏳ parser/TC boundary |
| `spec/README.md v0.6` | stream T `⏳ parser/classifier next` | split: runtime row ✅ + parser row ✅ keywords |
| `spec/README.md v0.6` | Coverage `OLAPPoint deferred` | `History+BiHistory+stream T+OLAPPoint PASS` |
| `spec/README.md v0.6` | R4 open gaps | R5 open gaps (classifier, SC-1..3, OLAP TC, RuntimeMachine hook) |

---

## Files Changed

```
docs/current-status.md          rebuilt (R5 scoreboard; OLAPPoint ✅; 5 libs; open gaps)
docs/spec/README.md             updated v0.7 (OLAPPoint row, stream parser row, R5 gaps)
docs/tracks/README.md           rebuilt (R5 evidence; lib inventory; next shapes with roles)
docs/tracks/stage2-round5-map-refresh-v0.md   new (this doc)
```

No changes to: `agent-motion.md`, `proposals/README.md`, `meta-proposals/`.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round5-map-refresh-v0
Card: S2-R5-C5-S
Status: done

[D] Decisions
- PROP-024 OLAPPoint is no longer "authored/deferred" — olap_point_proof PASS.
  Proof-local. Parser/TC boundary is the next step, not a missing proof.
- lib/igniter_lang/ has 5 files. The production compiler package boundary is
  advancing steadily (parser + temporal_access_runtime now extracted).
- stream T parser keywords are in lib/igniter_lang/parser.rb.
  Classifier ESCAPE propagation (SC-1..3) is the immediate next slice.
- Active Tier 0 priority shifts to classifier module extraction.

[S] Shipped
- current-status.md: R5 scoreboard; OLAPPoint ✅; 5 libs; stream parser ✅; open gaps updated.
- spec/README.md v0.7: OLAPPoint row, stream T parser row, temporal access lib row, R5 gaps.
- tracks/README.md: R5 evidence (5 tracks); lib inventory; next shapes with roles.
- stage2-round5-map-refresh-v0.md: this track doc.

[T] Tests / Proofs (verified this session)
- stage1_close_candidate PASS 5/5
- olap_point_proof         PASS
- stream_t_proof           PASS
- history_type_proof       PASS
- sparkcrm_bihistory_fixture PASS
- typechecker_proof        PASS
- production_compiler_cli_proof PASS 9 checks
- parser spec 61/0         PASS
- lib/igniter_lang/parser.rb  require ok
- lib/igniter_lang/temporal_access_runtime.rb  require ok

[R] Risks / Recommendations
- stream T classifier ESCAPE (SC-2 in particular: OOF-S4) is highest risk if skipped
  — silent stream misuse in contracts would be undetected.
- OLAPPoint grammar surface is unspecified. Compiler/Grammar Expert should own
  before any runtime/bridge work begins.
- RuntimeMachine temporal hook is blocked on naming decision:
  bitemporal_read vs bihistory_read — resolve before implementation.
- current-status.md is ~115 lines — at acceptable ceiling; avoid adding more rows
  until older ones are consolidated into "closed" list.

[Next] Suggested next slice
  extract-classifier-module-v0                    [Research Agent]       ← Tier 0
  stream-classifier-escape-propagation-v0         [Compiler/Grammar Expert]
  olap-point-parser-typechecker-boundary-v0       [Compiler/Grammar Expert]
  runtime-machine-temporal-access-hook-v0         [Research Agent]
```
