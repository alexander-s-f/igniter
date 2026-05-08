# Track: stage2-round7-map-refresh-v0

Role: `[Igniter-Lang Meta Expert]`
Card: S2-R7-C5-S
Status: done
Date: 2026-05-07
Depends on: S2-R7-C1-P, S2-R7-C2-P, S2-R7-C3-P, S2-R7-C4-P

---

## Scope

Post-round compact map refresh after Stage 2 Round 7.

---

## Proof Inventory — S2-R7 Results

| Experiment / Library | Result | Track |
|----------------------|--------|-------|
| `typechecker_proof` | ✅ PASS | extract-typechecker-module-v0 |
| `lib/igniter_lang/typechecker.rb` | ✅ require ok | extract-typechecker-module-v0 |
| `production_compiler_cli_proof` | ✅ PASS (9 checks) | extract-typechecker-module-v0 |
| `classifier_pass_proof` + `--check-golden` | ✅ PASS | stream-oof-s2-classifier-v0 |
| `source_to_semanticir_fixture --check-golden` | ✅ PASS | stream-oof-s2-classifier-v0 |
| `history_type_proof` | ✅ PASS | runtime-machine-temporal-access-hook-proof-v0 |
| `sparkcrm_bihistory_fixture` | ✅ PASS | runtime-machine-temporal-access-hook-proof-v0 |
| `olap_point_proof` (21 checks) | ✅ PASS | olap-point-parser-implementation-v0 |
| `parser_acceptance_spec` (61 examples) | ✅ PASS | olap-point-parser-implementation-v0 |
| `stage1_close_candidate` | ✅ PASS (5/5) | no regression |

lib/igniter_lang/ after R7 (7 files):
```
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7) — stream + olap_point/dims_record added
temporal_access_runtime.rb (R5/R6/R7) — RuntimeMachineHook wired
classifier.rb             (R6/R7) — OOF-S2 added
typechecker.rb            (R7) — NEW
```

---

## Entry Path Verification

```
README.md         → coherent; PROP table accurate
operating-model.md → coherent; no changes needed
current-status.md → updated (this track); 7 libs; hook PASS; OOF-S2 PASS; OLAP parser PASS; ~100 lines
spec/README.md    → updated (this track); v0.9; typechecker+hook rows; OOF-S2+OLAP parser rows; R7 gaps
tracks/README.md  → rebuilt (this track); R7 evidence; 7-lib inventory; next shapes
```

---

## Stale References Found and Fixed

| Location | Stale | Fixed to |
|----------|-------|---------|
| `current-status.md` | `6 libs ⏳ typechecker next` | `7 libs ⏳ semanticir emitter next` |
| `current-status.md` | Hook spec `⏳ hook proof next` | `✅ hook proof PASS ⏳ production RM next` |
| `current-status.md` | stream `⏳ OOF-S2 classifier` | `✅ OOF-S2 PASS ⏳ OOF-S3 next` |
| `current-status.md` | OLAP `⏳ parser/TC impl next` | `✅ parser impl PASS ⏳ OLAP TC/IR next` |
| `current-status.md` | Gap 1 = typechecker extraction | Gap 1 = SemanticIR emitter extraction |
| `current-status.md` | Gap 2 = OLAP parser impl | Gap 2 = OLAP TypeChecker/SemanticIR boundary |
| `current-status.md` | Gap 3 = OOF-S2 + S3 together | Gap 3 = OOF-S3 only (S2 closed) |
| `current-status.md` | Gap 4 = hook proof | Gap 4 = production RM integration |
| `spec/README.md` | No typechecker module row | Added Ch5 TypeChecker module lib row |
| `spec/README.md` | Hook spec `⏳ proof wiring next` | Split: spec row ✅ + hook proof row ✅ |
| `spec/README.md` | stream classifier `⏳ OOF-S3 TypeChecker next` | Separate OOF-S2 row ✅ |
| `spec/README.md` | OLAP `⏳ parser impl next` | OLAP parser row added ✅ |
| `spec/README.md` | R6 open gaps | R7 open gaps (SemanticIR emitter, OLAP TC, OOF-S3, production RM) |

---

## Files Changed

```
docs/current-status.md          rebuilt (R7 scoreboard; 7 libs; hook PASS; OOF-S2 PASS; OLAP parser PASS)
docs/spec/README.md             updated v0.9 (typechecker+hook proof rows; OOF-S2+OLAP parser rows; R7 gaps)
docs/tracks/README.md           rebuilt (R7 evidence; 7-lib inventory; next shapes)
docs/tracks/stage2-round7-map-refresh-v0.md   new (this doc)
```

No changes to: `agent-motion.md`, `proposals/README.md`, `meta-proposals/`.

---

## Handoff

```
[Igniter-Lang Meta Expert]
Track: stage2-round7-map-refresh-v0
Card: S2-R7-C5-S
Status: done

[D] Decisions
- typechecker.rb extracted (R7) — 7 libs. Tier 0 shifts to SemanticIR emitter extraction.
  Parser, Classifier, TypeChecker now have library boundaries.
- RuntimeMachineHook proof PASS — valid-time history_read and bitemporal bihistory_read both
  wired and PASS in experiments. Production TBackend adapter is the remaining step.
- stream T OOF-S2 PASS — OOF-S3 (ESCAPE in fold fn body) is TypeChecker-owned; safe to
  start after typechecker.rb is stable (it is, as of this round).
- OLAP parser impl PASS — revenue_point.ig parses with live parser. TypeChecker/SemanticIR
  lowering is the bounded next slice (OOF-O2..O5 + olap_access_node).
- Archaeology lane: not reflected in status (as instructed; no accepted map changes).

[S] Shipped
- current-status.md: R7 scoreboard; 7 libs; hook proof ✅; OOF-S2 ✅; OLAP parser ✅.
- spec/README.md v0.9: typechecker lib row, hook proof row, OOF-S2 row, OLAP parser row, R7 gaps.
- tracks/README.md: R7 evidence (5 tracks); 7-lib inventory; next shapes with roles.
- stage2-round7-map-refresh-v0.md: this track doc.

[T] Tests / Proofs (verified this session)
- stage1_close_candidate PASS 5/5
- typechecker_proof       PASS
- typechecker.rb          require ok
- production_compiler_cli_proof PASS 9 checks
- classifier_pass_proof   PASS + golden check PASS
- source_to_semanticir    PASS (golden check)
- history_type_proof      PASS (hook wired)
- sparkcrm_bihistory      PASS (hook wired)
- olap_point_proof        PASS 21 checks
- parser_acceptance_spec  PASS 61/0

[R] Risks / Recommendations
- SemanticIR emitter is proof-local inside source_to_semanticir_fixture.
  Extraction must not break source_to_semanticir_fixture --check-golden (9 goldens).
  Run olap_point_proof + classifier_pass_proof as regression guard too.
- OOF-S3 TypeChecker slice: do not start until SemanticIR emitter extraction is
  underway, so the TypeChecker boundary is confirmed stable.
- OLAP TypeChecker/SemanticIR: olap_access_node lowering + dims_record validation
  must land together (dims_record is a new AST node; emitter must propagate it).
- Production RM temporal: naming decision (bitemporal_read vs bihistory_read)
  must be resolved before TBackend adapter wiring. Track doc has open Q.
- current-status.md is ~100 lines — acceptable.

[Next] Suggested next slice
  extract-semanticir-emitter-module-v0                    [Research Agent]       ← Tier 0
  olap-point-typechecker-semanticir-v0                    [Compiler/Grammar Expert]
  stream-oof-s3-typechecker-v0                            [Compiler/Grammar Expert]
  production-runtime-machine-temporal-access-integration-v0 [Research Agent]
```
