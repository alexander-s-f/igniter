# Track: Docs Value Hoisting Micro Round v0

Card: S3-R7-DOCS-M1-S
Agent: `[Architect Supervisor / Codex]`
Role: architect-supervisor
Track: `docs-value-hoisting-micro-round-v0`
Status: done
Date: 2026-05-08

---

## Goal

Reduce documentation loss risk without deleting history.

The problem is not only stale docs. It is also that valuable ideas can sink into
deep tracks, discussions, and archives. The solution for this micro-round is:

```text
snapshot for safety
  + hoisted value index for visibility
  + archive pointers for archaeology
```

---

## Decisions

[D] This is a docs micro-round, not a stage close.

[D] The snapshot copies active docs into cold archive, but does not move working
documents.

[D] Valuable ideas should hoist into a living top-layer index with links back to
source archaeology.

[D] `value-index.md` is a map of durable ideas, not a replacement for
`current-status.md`, spec, proposals, or track evidence.

[D] Categories are enough for now; no per-category folder split until
`value-index.md` becomes too large.

---

## Shipped

Created snapshot:

```text
igniter-lang/docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/
```

Created living hoisted-value index:

```text
igniter-lang/docs/value-index.md
```

Updated navigation:

```text
igniter-lang/docs/README.md
igniter-lang/docs/archive/README.md
igniter-lang/docs/tracks/README.md
```

---

## Hoisting Model

The model:

```text
deep source docs
  tracks / discussions / proposals / meta-proposals / archive
      |
      v
value-index.md
  compact signal + status + category + source links
      |
      v
current work
  agent-context / current-status / assigned card
```

This gives two ways to survive documentation growth:

- snapshot preserves everything at a moment in time;
- value index preserves the meaning that should remain easy to find.

---

## Categories

Initial categories:

```text
Current Canon
Runtime Boundary
Compiler Boundary
Temporal Model
Agentic System
Syntax Pressure
Applied Pressure
Ledger Bridge
Archaeology Pointer
```

---

## Verification

Snapshot sanity:

```text
find igniter-lang/docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot -type f | wc -l
  -> 339

du -sh igniter-lang/docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot
  -> 4.1M
```

Docs validation:

```text
git diff --check
```

---

## Handoff

```text
Card: S3-R7-DOCS-M1-S
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: docs-value-hoisting-micro-round-v0
Status: done

[D] Decisions
- Snapshot active docs after S3-R7 before further compaction.
- Add value-index.md as the living hoisted-memory layer.
- Keep tracks/proposals/discussions as source evidence, not daily context.
- Use categories to surface durable ideas without moving archaeology.

[S] Shipped / Signals
- archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/
- docs/value-index.md
- README/archive/tracks navigation updates.

[T] Tests / Proofs
- Snapshot file count: 339.
- Snapshot size: 4.1M.
- git diff --check.

[R] Risks / Recommendations
- Add hoisted entries only when a signal is durable beyond a round.
- If value-index.md grows too large, split it into docs/value/*.md by category.
- Future Status Curator rounds should update value-index.md sparingly.
```
