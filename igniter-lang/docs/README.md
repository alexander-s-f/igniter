# Igniter-Lang — Documentation

Stage 1 status: **CLOSED** (2026-05-06) — [META-EXPERT-007](meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md)
Stage 2 status: pending governance opening (META-EXPERT-008 not yet written)
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-06

---

## Navigation

```
Language reference             → language-spec.md
Stage 1 spec (frozen)          → spec/  (ch1–ch9)
Stage 1 scoreboard             → current-status.md
Stage 2 active proposals       → proposals/README.md  (PROP-022..025, new from PROP-026)
Accepted Stage 1 PROPs         → proposals/accepted/  (read-only)
Governance                     → meta-proposals/README.md
Stage 1 close snapshot         → archive/snapshots/2026-05-06-stage1-close/
Pre-crystallization archive    → archive/snapshots/2026-05-06-stage1-pre-crystallization/
```

---

## Stage 1 — CLOSED

Goal was: `source.ig → parser → classifier → typechecker → SemanticIR → .igapp/ → RuntimeMachine trusted`

```
Pass               Status      Experiment
─────────────────────────────────────────────────────────────────────────────────
Parser             ✅ partial  experiments/parser/ (61 specs; OOF parse gap — non-blocking)
Classifier         ✅ PASS     experiments/classifier_pass_proof/
SemanticIR Emitter ✅ PASS     experiments/source_to_semanticir_fixture/ --check-golden
TypeChecker        ✅ PASS     experiments/typechecker_proof/ (incl. boundary fixture)
.igapp/ Assembler  ✅ PASS     experiments/igapp_assembler_proof/ (A1-A6 + runtime eval)
RuntimeMachine     ✅ proven   experiments/runtime_machine_memory_proof/
Stdlib execution   ✅ PASS     experiments/stdlib_execution_kernel_stage1/
─────────────────────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:   YES — CLOSE WITH DEFERRED GAP (2026-05-06)
Close evidence:   experiments/stage1_close_candidate/stage1_close_candidate.json
Deferred gaps:    Parser OOF hardening | production compiler pkg | runtime eval surface
```

### Run the full Stage 1 proof suite

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

### Run individual experiments

```bash
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
ruby igniter-lang/experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb
```

---

## Stage 2 — Not Yet Open

Stage 2 governance opens after META-EXPERT-008 is authored.

Active intake baseline (authors of Stage 2 PROPs, start from PROP-026):

| PROP | Topic |
|------|-------|
| [PROP-022](proposals/PROP-022-history-type-constructor-v0.md) | History[T] / BiHistory[T] |
| [PROP-023](proposals/PROP-023-stream-input-surface-v0.md) | stream T / fold_stream |
| [PROP-024](proposals/PROP-024-olap-point-primitive-v0.md) | OLAPPoint[T, Dims] |
| [PROP-025](proposals/PROP-025-invariant-severity-levels-v0.md) | Invariant severity levels |

Do not implement Stage 2 PROPs until META-EXPERT-008 is written and approved.

---

## Governance

| Document | Purpose |
|----------|---------|
| [current-status.md](current-status.md) | Scoreboard (Stage 1 closed state) |
| [meta-proposals/META-EXPERT-007](meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md) | Stage 1 close verdict |
| [meta-proposals/META-EXPERT-007.1](meta-proposals/META-EXPERT-007.1-stage1-close-snapshot-plan-v0.md) | Post-close doc transition plan |
| [meta-proposals/META-EXPERT-003](meta-proposals/META-EXPERT-003-stage1-implementation-governance-v0.md) | Stage 1 policy (historical) |

---

## Archive

```
docs/archive/snapshots/2026-05-06-stage1-close/
  Full documentation state at Stage 1 close (proposals, spec, meta-proposals, status)

docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/
  Pre-crystallization research archive (131 files: tracks, proposals, bridge, meta-proposals)
```
