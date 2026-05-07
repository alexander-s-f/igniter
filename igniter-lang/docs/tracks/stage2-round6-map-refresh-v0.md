# Track: stage2-round6-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R6-C5-S
Status: done
Date: 2026-05-07
Depends on: S2-R6-C1-P, S2-R6-C2-P, S2-R6-C3-P, S2-R6-C4-P

---

## Scope

Post-round compact map refresh after Stage 2 Round 6.

---

## Proof Inventory — S2-R6 Results

| Experiment / Library | Result | Track |
|----------------------|--------|-------|
| `classifier_pass_proof` | ✅ PASS | extract-classifier-module-v0 |
| `classifier_pass_golden_check` | ✅ PASS | extract-classifier-module-v0 |
| `source_to_semanticir_fixture --check-golden` | ✅ PASS (9 goldens) | stream-classifier-escape-propagation-v0 |
| `production_compiler_cli_proof` | ✅ PASS (9 checks) | extract-classifier-module-v0 |
| `olap_point_proof` | ✅ PASS (21 checks) | olap-point-parser-typechecker-boundary-v0 |
| `stream_t_proof` | ✅ PASS | no regression |
| `history_type_proof` | ✅ PASS | runtime-machine-temporal-access-hook-v0 |
| `sparkcrm_bihistory_fixture` | ✅ PASS | runtime-machine-temporal-access-hook-v0 |
| `stage1_close_candidate` | ✅ PASS (5/5) | no regression |
| `typechecker_proof` | ✅ PASS | no regression |
| `lib/igniter_lang/classifier.rb` | ✅ require ok | extract-classifier-module-v0 |
| `RuntimeMachineHook smoke` | ✅ ok | runtime-machine-temporal-access-hook-v0 |
| `RuntimeMachineHook capability block` | ✅ ok | runtime-machine-temporal-access-hook-v0 |

lib/igniter_lang/ after R6 (6 files):
```
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5) — stream/fold_stream keywords
temporal_access_runtime.rb (R5/R6) — MemoryBackend + RuntimeMachineHook spec
classifier.rb             (R6) — NEW
```

---

## Entry Path Verification

```
README.md         → coherent; PROP table accurate; current-status link correct
operating-model.md → coherent; no changes needed
current-status.md → updated (this track); Stage 1 block consolidated; SC-1/2/3 ✅; 6 libs; ~100 lines
spec/README.md    → updated (this track); v0.8; classifier + hook rows; stream classifier row; R6 gaps
tracks/README.md  → rebuilt (this track); R6 evidence; lib inventory (6); next shapes
```

---

## Stale References Found and Fixed

| Location | Stale | Fixed to |
|----------|-------|---------|
| `current-status.md` | Long Stage 1 table | Consolidated to single summary line |
| `current-status.md` | `5 libs extracted ⏳ classifier next` | `6 libs extracted ⏳ typechecker next` |
| `current-status.md` | OLAPPoint `⏳ parser/TC boundary next` | `⏳ parser/TC impl next`; grammar spec noted |
| `current-status.md` | stream T `⏳ classifier next` | `✅ SC-1/2/3 PASS ⏳ OOF-S2/S3` |
| `current-status.md` | Gap 1 = classifier extraction | Gap 1 = typechecker extraction |
| `current-status.md` | Gap 3 = OLAPPoint parser/TC boundary | Gap 3 = OOF-S2/S3 |
| `spec/README.md` | No classifier module row | Added Ch6 Classifier module lib row |
| `spec/README.md` | No temporal access hook row | Added Ch7 Temporal access hook spec row |
| `spec/README.md` | stream T `⏳ classifier next` | Two rows: parser ✅ + classifier SC-1/2/3 ✅ |
| `spec/README.md` | OLAPPoint `⏳ parser/TC boundary next` | `✅ grammar spec done ⏳ parser impl next` |
| `spec/README.md` | Coverage summary with Ch3..Ch8 detail | Simplified: `Ch1–Ch8 all PASS; classifier extracted` |
| `spec/README.md` | R5 open gaps | R6 open gaps (typechecker, OLAP impl, S2/S3, hook proof) |

---

## Files Changed

```
docs/current-status.md          rebuilt (R6 scoreboard; Stage 1 consolidated; 6 libs; open gaps)
docs/spec/README.md             updated v0.8 (classifier+hook rows, stream classifier, OLAP spec, R6 gaps)
docs/tracks/README.md           rebuilt (R6 evidence; lib inventory; next shapes)
docs/tracks/stage2-round6-map-refresh-v0.md   new (this doc)
```

No changes to: `agent-motion.md`, `proposals/README.md`, `meta-proposals/`.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round6-map-refresh-v0
Card: S2-R6-C5-S
Status: done

[D] Decisions
- classifier.rb extracted (R6) — 6 libs in lib/. Active Tier 0 shifts to typechecker extraction.
- Stream SC-1/2/3 PASS — ESCAPE propagation is proven. OOF-S2 (missing window) is the
  next small bounded slice; OOF-S3 (ESCAPE in fold fn body) needs TypeChecker boundary first.
- OLAPPoint grammar spec done: dims_record AST node, OOF-O1..O5 owned. Parser impl deferred
  (risk: golden fixture drift in parallel slice area). Implementation is a single bounded next slice.
- RuntimeMachineHook spec + smoke done. Proof wiring is the next step, not a deep redesign.
- Stage 1 scoreboard consolidated into a single summary line — document is ~100 lines again.

[S] Shipped
- current-status.md: R6 scoreboard; Stage 1 consolidated; 6 libs; stream ✅ SC-1/2/3; open gaps.
- spec/README.md v0.8: classifier + hook rows, stream classifier row, OLAP grammar done, R6 gaps.
- tracks/README.md: R6 evidence (5 tracks); lib inventory; next shapes with roles.
- stage2-round6-map-refresh-v0.md: this track doc.

[T] Tests / Proofs (verified this session)
- stage1_close_candidate PASS 5/5
- classifier_pass_proof   PASS + golden check PASS
- source_to_semanticir    PASS (9 goldens)
- olap_point_proof        PASS (21 checks)
- production_compiler_cli_proof PASS 9 checks
- stream_t_proof          PASS
- history_type_proof      PASS
- sparkcrm_bihistory      PASS
- typechecker_proof       PASS
- classifier.rb           require ok
- RuntimeMachineHook smoke + capability block ok

[R] Risks / Recommendations
- OLAPPoint parser implementation: must regenerate golden fixtures.
  Run olap_point_proof + classifier_pass_proof + source_to_semanticir as regression guard.
- OOF-S2 (missing window): small and bounded; do not expand scope into S3 in same slice.
- OOF-S3 (ESCAPE in fold fn): needs TypeChecker boundary; do not start before typechecker.rb
  is extracted, or proof-local TypeChecker must be clearly scoped.
- RuntimeMachineHook naming: bihistory_read vs bitemporal_read — resolve before hook proof
  wires into production RuntimeMachine load path.
- current-status.md ~100 lines — acceptable; Stage 1 block consolidated.

[Next] Suggested next slice
  extract-typechecker-module-v0                      [Research Agent]       ← Tier 0
  olap-point-parser-implementation-v0               [Research Agent]
  stream-oof-s2-classifier-v0                       [Compiler/Grammar Expert]
  runtime-machine-temporal-access-hook-proof-v0     [Research Agent]
```
