# Snapshot: 2026-05-06 — Stage 1 Pre-Crystallization

Date captured: 2026-05-06
Captured by: `[Igniter-Lang Meta Expert]`
Track: `docs-snapshot-and-crystallization-v0`
Status: **cold archive — do not modify**

---

## Why This Snapshot Exists

This snapshot was created immediately before the active documentation was
compacted ("crystallized") to reduce cognitive load during Stage 1 compiler
work. It preserves the full documentation state at the moment when:

1. **Historical archaeology** was completed (META-EXPERT-005): 12 buried ideas
   recovered from `playgrounds/docs/experts/`, 5 formal theoretical identities
   confirmed, domain validation across science/robotics/space/medicine.

2. **Language model revision** was finalized (META-EXPERT-006): Q1–Q5 resolved,
   Stage 2 type constructors reserved (`History[T]`, `stream T`, `OLAPPoint`,
   `BiHistory[T]`, `~T`), invariant severity levels designed, unit types path
   defined.

3. **Stage 2 PROPs authored** (PROP-022..025): formal specification of all four
   Stage 2 primitives, ready to be implemented after Stage 1 closes.

4. **Stage 1 pipeline** is in flight but not yet closed: golden file migration
   is the active blocker; .igapp/ assembler, TypeChecker, and stdlib execution
   are next slices.

---

## What State This Snapshot Captures

### Compiler pipeline status at snapshot time

```text
Parser             PASS  (experiments/parser/, 61 specs)
Classifier         PASS  (PROP-020 proven)
SemanticIR Emitter PASS  (PROP-019.1 canonical envelope proven)
TypeChecker        pending (PROP-021 authored, not yet proven)
.igapp/ Assembler  blocked (golden file migration required)
Stdlib execution   pending (stdlib.numeric.add, fold, map, filter)
RuntimeMachine     partial (load proven; evaluate not yet connected to stdlib)
```

### Active blocker at snapshot time

```text
source_to_semanticir_fixture golden files need PROP-019.1 migration
  → assembler unblocked only after migration
  → do not start Slice A before migration is PASS
```

### Documents captured (131 files)

```
proposals/    25 files  (PROP-001..025 + META-001 + errata)
tracks/       87 files  (all research tracks, proofs, pressure fixtures)
bridge/       15 files  (bridge profiles, alignment notes)
meta-proposals/ 7 files (META-EXPERT-001..006 + README)
current-status.md        (528 lines — full Stage 1 scoreboard)
README.md                (active research index + navigation header)
```

---

## How To Use This Snapshot

**This is cold archaeology context.**

Use it when you need to:
- Find a track or proposal that was removed from the active index
- Trace the origin of a design decision made before crystallization
- Recover research that is "deferred" in the active docs

**Do not**:
- Edit files in this directory
- Reference this directory in active PROP or track documents
- Use this as the working context — use the active docs instead

**Navigation**:

```
proposals/      → PROP-001..025 (all formal decisions, incl. Stage 2 PROPs)
tracks/         → research tracks, proofs, pressure fixtures
bridge/         → bridge profiles and platform alignment
meta-proposals/ → governance and strategy (META-EXPERT-001..006)
current-status.md → Stage 1 scoreboard and blocker state at snapshot
README.md       → full research index with research vectors list
```

---

## Key Documents For Future Archaeology

| Document | What It Contains |
|----------|-----------------|
| `meta-proposals/META-EXPERT-005-project-history-archaeology.md` | 12 buried ideas, 5 formal identities, domain validation |
| `meta-proposals/META-EXPERT-006-language-model-revision-v0.md` | Clean-slate language model revision, Stage 2 type system design |
| `proposals/PROP-022-history-type-constructor-v0.md` | History[T]/BiHistory[T] full spec |
| `proposals/PROP-023-stream-input-surface-v0.md` | stream T, fold_stream, window, KPN grounding |
| `proposals/PROP-024-olap-point-primitive-v0.md` | OLAPPoint[T,Dims], olap_point declaration, cluster scatter-gather |
| `proposals/PROP-025-invariant-severity-levels-v0.md` | invariant severity, label, overridable_with |
| `current-status.md §Stage 1 Progress` | Scoreboard, blocker chain, revised next 3 slices |
| `tracks/polymorphic-add-*.md` | Full compiler proof chain from parser to runtime |

---

## Relation To Active Docs

After this snapshot was taken, the active `igniter-lang/docs/` was crystallized:

- `docs/README.md` → compacted to Stage 1 navigation surface
- `docs/current-status.md` → Stage 1 scoreboard only
- `docs/meta-proposals/README.md` → separated active governance from archaeology

Stage 2 PROPs (PROP-022..025) remain in active `proposals/` — they are written
specifications awaiting implementation, not deferred research.

All other Stage 2+ ideas are documented in `docs/language-spec.md §12`.
