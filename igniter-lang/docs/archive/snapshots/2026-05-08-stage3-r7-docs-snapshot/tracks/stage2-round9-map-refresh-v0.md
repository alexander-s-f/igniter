# Track: stage2-round9-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R9-C5-S
Status: done
Date: 2026-05-07
Depends on: S2-R9-C1-P, S2-R9-C2-P, S2-R9-C3-P, S2-R9-C4-P

---

## Scope

Post-round compact map refresh after Stage 2 Round 9.
Note: R8 tracks already landed and were reflected in current-status.md by a prior agent.
This track covers R9 landed evidence and cleans any remaining stale references.

---

## Proof Inventory — S2-R8 (landed before this refresh)

| Experiment / Library | Result | Track |
|----------------------|--------|-------|
| `lib/igniter_lang/semanticir_emitter.rb` | ✅ require ok | extract-semanticir-emitter-module-v0 |
| `olap_point_proof` (OLAP TC/IR checks) | ✅ PASS | olap-point-typechecker-semanticir-v0 |
| stream OOF-S3 (typechecker.rb) | ✅ PASS | stream-oof-s3-typechecker-v0 |
| `history_type_proof` + `sparkcrm_bihistory_fixture` via RM hook | ✅ PASS | production-runtime-machine-temporal-access-integration-v0 |

## Proof Inventory — S2-R9 Results

| Experiment / Library | Result | Track |
|----------------------|--------|-------|
| `lib/igniter_lang/assembler.rb` | ✅ require ok | extract-assembler-module-v0 |
| `production_compiler_cli_proof` | ✅ PASS (9 checks) | extract-assembler-module-v0 |
| `stage1_close_candidate` | ✅ PASS (5/5) | extract-assembler-module-v0 |
| TBackend adapter shape spec | docs-only | production-tbackend-adapter-shape-v0 |
| `olap_point_proof` (OLAP emitter lowering) | ✅ PASS | semanticir-stage2-surface-lowering-v0 |
| all 9 libs require ok | ✅ | verified this session |
| `typechecker_proof` | ✅ PASS | no regression |

lib/igniter_lang/ after R9 (9 files):
```
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7)
temporal_access_runtime.rb (R5–R7)
classifier.rb             (R6/R7)
typechecker.rb            (R7/R8)
semanticir_emitter.rb     (R8/R9) — OLAP lowering added R9
assembler.rb              (R9)    — NEW
```

---

## Entry Path Verification

```
README.md         → coherent; PROP table accurate
operating-model.md → coherent; no changes needed
current-status.md → cleaned (this track): stream row aligned; gap 3 clarified;
                    8 libs → 9 libs; active priority reflects assembler done; ~110 lines
spec/README.md    → updated (this track); v1.0; OOF-S3, OLAP TC/IR, assembler module,
                    emitter module, RM integration rows; R9 gaps; R8/R9 closed list
tracks/README.md  → updated (this track); R9 evidence (4 tracks); 9-lib inventory; next shapes
```

---

## Stale References Found and Fixed

| Location | Stale | Fixed to |
|----------|-------|---------|
| `current-status.md` | `✅ DONE` inside Open Gaps gap 3 | Moved to: gap 3 = "stream/invariant/OLAP rollup emitter lowering" |
| `current-status.md` | stream row alignment (extra space) | Fixed alignment |
| `current-status.md` | gap 3 = old OOF-S3 text | gap 3 = Production SemanticIR surface lowering |
| `spec/README.md v0.9` | R7 gaps (7 items, all stale) | R9 gaps (4 items) |
| `spec/README.md v0.9` | No OOF-S3 row | Added Ch9 stream T OOF-S3 ✅ |
| `spec/README.md v0.9` | No OLAP TC/SemanticIR row | Added Ch9 OLAPPoint TC/SemanticIR ✅ |
| `spec/README.md v0.9` | No SemanticIR emitter module row | Added Ch6 SemanticIR emitter module ✅ |
| `spec/README.md v0.9` | No assembler module row | Added Ch6 Assembler module ✅ |
| `spec/README.md v0.9` | Hook proof `⏳ production RM next` | Separate RM integration row ✅ |
| `spec/README.md v0.9` | Coverage summary stale | Updated: 9 libs, all stream+OLAP PASS |
| `tracks/README.md` | 8 libs | 9 libs; assembler.rb added |
| `tracks/README.md` | Next shapes: extract-assembler (done) | Replaced with: orchestrator, stream emitter, TBackend fixture |

---

## Files Changed

```
docs/current-status.md          cleaned (stream row, gap 3, open gaps tightened)
docs/spec/README.md             updated v1.0 (9 new/updated rows; R9 gaps; R8/R9 closed)
docs/tracks/README.md           updated (R9 evidence; 9-lib inventory; next shapes)
docs/tracks/stage2-round9-map-refresh-v0.md   new (this doc)
```

No changes to: `agent-motion.md`, `proposals/README.md`, `meta-proposals/`.

---

## Remaining Stage 2 Close Blockers

```text
BLOCKER-1  compiler-orchestrator-v0
  All 9 compiler pass libraries extracted. Production wiring (Parser → Classifier →
  TypeChecker → SemanticIREmitter → Assembler → RuntimeSmoke) is not yet a single
  boundary. This is the primary remaining Tier 0 item.

BLOCKER-2  Production SemanticIR stage2 surface lowering
  OLAP boundary proof done. stream_input_node / fold_stream_node / invariant lowering
  not yet in semanticir_emitter.rb. stream-semanticir-surface-lowering-v0 is the next
  slice. Can proceed in parallel with orchestrator.

BLOCKER-3  Production RuntimeMachine TBackend adapter
  Hook proof PASS. TBackend shape spec authored (R9, docs-only). Proof-local
  AdapterRegistry + CompatibilityReport persistence is the next concrete slice.
  NOT blocking compiler orchestrator.

DEFERRED   Invariant severity parser + typechecker implementation
  Tier 1. Start after compiler spine stabilizes.
```

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round9-map-refresh-v0
Card: S2-R9-C5-S
Status: done

[D] Decisions
- assembler.rb extracted (R9) — 9 libs. All compiler pass boundaries now have lib modules.
- Compiler orchestrator is the primary Stage 2 close blocker.
  The full pass pipeline can now be wired without proof-local dependencies.
- OLAP SemanticIR lowering is in semanticir_emitter.rb (R9 partial).
  stream and invariant surface lowering remain.
- TBackend adapter shape spec is docs-only (R9). No production code written.
  Next concrete slice: proof-local AdapterRegistry fixture.
- Stage 2 open gaps condensed to 4 (from 5 in R7); stream OOF-S3 and OLAP TC/IR closed.
- Archaeology lane not reflected in status (no accepted map changes).

[S] Shipped
- current-status.md: cleaned gap 3; stream row aligned; 9 libs.
- spec/README.md v1.0: 9 new/updated rows; R9 open gaps; R8/R9 closed list.
- tracks/README.md: R9 evidence; 9-lib inventory; next shapes updated.
- stage2-round9-map-refresh-v0.md: this track doc.

[T] Tests / Proofs (verified this session)
- stage1_close_candidate PASS 5/5
- all 9 libs require ok (diagnostics → assembler)
- production_compiler_cli_proof PASS 9 checks
- typechecker_proof PASS
- olap_point_proof PASS

[R] Risks / Recommendations
- compiler-orchestrator-v0 is the highest-value next slice.
  Preserve production_compiler_cli_proof as the regression guard throughout orchestration.
- stream SemanticIR lowering: start with stream_input_node (simplest); do not mix
  invariant lowering into same slice.
- TBackend adapter: require schema_fingerprint, explicit axes, and receipt evidence
  in CompatibilityReport (from production-tbackend-adapter-shape-v0 spec).
- Do not start invariant severity parser impl until orchestrator is stable.

[Next] — R10 recommendation
  compiler-orchestrator-v0                    [Research Agent]       ← Stage 2 primary close blocker
  stream-semanticir-surface-lowering-v0       [Compiler/Grammar Expert]
  production-tbackend-adapter-fixture-v0      [Research Agent]
  invariant-severity-parser-impl-v0           [Compiler/Grammar Expert]  ← Tier 1, start last
```
