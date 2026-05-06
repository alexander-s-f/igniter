# Igniter-Lang — Stage 1 Working Surface

Status: crystallized — Stage 1 focus
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-06

> **This is the active working surface.** Full historical research is preserved in
> `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/`.

---

## Navigation

```
Language reference (compact)     → language-spec.md
Formal design decisions          → proposals/README.md  (PROP-001..025)
Stage 1 status + blockers        → current-status.md
Strategic governance             → meta-proposals/README.md
Historical research              → archive/snapshots/2026-05-06-stage1-pre-crystallization/
```

---

## Where We Are Now (Stage 1)

Goal: `source.ig → parser → classifier → typechecker → SemanticIR → .igapp/ → RuntimeMachine trusted`

```
Pass               Status    Blocker / Next Action
───────────────────────────────────────────────────────────────────
Parser             ✅ partial   OOF rejection at parse time (gap)
Classifier         ✅ PASS
SemanticIR Emitter ✅ PASS      ⚠️ golden files need PROP-019.1 migration
TypeChecker        🟡 next      PROP-021 authored; proof pending
.igapp/ Assembler  🔴 BLOCKED   waiting on golden file migration (Slice 0)
RuntimeMachine     ✅ proven    load/evaluate/checkpoint/resume
Stdlib execution   🔴 pending   numeric.add, fold, map, filter not yet connected
───────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:  NO
Active blocker:  PROP-019.1 golden migration → Assembler unblocked
```

**Next 3 slices**:
- **Slice 0**: Migrate golden files to PROP-019.1 shape `[Research Agent]`
- **Slice A**: `igapp_assembler_proof` `[Research Agent]` ← blocked on Slice 0
- **Slice B**: TypeChecker narrow proof `[Research Agent]` (parallel with Slice A)

See `current-status.md` for full scoreboard and migration gate criteria.

---

## Core Stage 1 Documents

### Canonical PROPs (Stage 1 pipeline)

| PROP | Topic |
|------|-------|
| [PROP-003](proposals/PROP-003-grammar-fragment-classification-v0.md) | CORE/ESCAPE/OOF classification |
| [PROP-004](proposals/PROP-004-type-system-v0.md) | Type system v0 |
| [PROP-013](proposals/PROP-013-stdlib-fold-aggregate-v0.md) | Stdlib: fold, map, filter, avg |
| [PROP-014](proposals/PROP-014-source-syntax-semanticir-boundary-v0.md) | Source syntax → SemanticIR boundary |
| [PROP-015](proposals/PROP-015-grammar-module-system-v0.md) | Module system + full BNF |
| [PROP-016](proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md) | Polymorphism, traits |
| [PROP-018](proposals/PROP-018-source-to-semanticir-minimal-pipeline-v0.md) | Minimal pipeline proof plan |
| [PROP-019.1](proposals/PROP-019.1-semanticir-envelope-errata-v0.md) | SemanticIR envelope (canonical, errata) |
| [PROP-020](proposals/PROP-020-classifier-pass-v0-formalization.md) | Classifier pass |
| [PROP-021](proposals/PROP-021-typechecker-pass-v0-formalization.md) | TypeChecker narrow |

### Active experiments

```
igniter-lang/experiments/parser/                       → Parser (61 specs)
igniter-lang/experiments/classifier_pass_proof/        → Classifier PASS
igniter-lang/experiments/source_to_semanticir_fixture/ → SemanticIR Emitter PASS ⚠️ migration needed
igniter-lang/experiments/runtime_machine_memory_proof/ → RuntimeMachine load/eval PASS
```

### Stage 1 governance

| Document | Purpose |
|----------|---------|
| [current-status.md](current-status.md) | Scoreboard, blocker state, next slices |
| [meta-proposals/META-EXPERT-003](meta-proposals/META-EXPERT-003-stage1-implementation-governance-v0.md) | Stage 1 policy |
| [meta-proposals/META-EXPERT-004](meta-proposals/META-EXPERT-004-stage1-scoreboard-reconciliation-v0.md) | Scoreboard reconciliation |

---

## Stage 2 Spec (authored, not yet implemented)

These PROPs are formally authored and will be implemented after Stage 1 closes.
Do not expand or implement during Stage 1.

| PROP | Topic | Deferred reason |
|------|-------|----------------|
| [PROP-022](proposals/PROP-022-history-type-constructor-v0.md) | History[T] / BiHistory[T] | Stage 1 first |
| [PROP-023](proposals/PROP-023-stream-input-surface-v0.md) | stream T / fold_stream | Stage 1 first |
| [PROP-024](proposals/PROP-024-olap-point-primitive-v0.md) | OLAPPoint[T, Dims] | Stage 1 first |
| [PROP-025](proposals/PROP-025-invariant-severity-levels-v0.md) | Invariant severity | Stage 1 first |

Stage 3+ ideas: see [language-spec.md §12](language-spec.md) and
[META-EXPERT-006](meta-proposals/META-EXPERT-006-language-model-revision-v0.md).

---

## Verification Commands

```bash
# Parser
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig

# Classifier
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb

# SemanticIR Emitter (run after golden file migration)
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

---

## Archive

Historical research, tracks, pressure fixtures, bridge profiles from pre-crystallization:

→ `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/`

Contains: 131 files (87 tracks, 25 proposals, 15 bridge, 7 meta-proposals, full current-status).
