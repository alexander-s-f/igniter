# Line Up Stage 1 / Stage 2 Second Batch v0

Card: S3-R38-C5-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: igniter-lang/line-up-stage1-stage2-second-batch-v0
Status: done
Date: 2026-05-12

Route: STALE_REFRESH
Previous known card: S3-R37-C8-P3
Latest observed round: S3-R38 card assigned by supervisor; R37 Line Up index
already contains first batch rows.
Same-role newer work: no newer Line Up files observed beyond first batch in
`docs/lineups/`.
Gate/status changes: none accepted by this card; documentation hoisting only.

---

## Scope

Continue Stage 1 / Stage 2 context hoisting without moving, deleting, or broad
link rewriting.

Inputs reread:

- `igniter-lang/handoff/onboarding-line-up-summarizer-v0.md`
- `igniter-lang/handoff/INSTANCE_ROUTING.md`
- `igniter-lang/docs/lineups/README.md`
- `igniter-lang/docs/tracks/documentation-fate-inventory-stage1-stage2-v0.md`
- `igniter-lang/docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md`

Assigned source clusters:

- compiler/package spine
- Stage 2 -> Stage 3 typed switch spine
- old pre-Gate-3 discussions spine

## Line Ups Created

| Line Up | Disposition | Notes |
| --- | --- | --- |
| `docs/lineups/stage2-compiler-package-spine.md` | `active_reference -> public_archive candidate` | Summarizes extraction, facade, package boundary, gem skeleton, and gem-native proof without implying release readiness. |
| `docs/lineups/stage2-to-stage3-typed-switch-spine.md` | `active_reference` / `public_archive` for stale parity blockers | Summarizes blocked parity history, `emit_typed` switch, stale headers, and spec syncs. |
| `docs/lineups/old-discussions-pre-gate3-spine.md` | `public_archive after summary` | Summarizes completed R2-R12 discussion pressure and routes; does not include R13-R22 discussion chain. |

## Index Update

`docs/lineups/README.md` now includes rows for the three new Line Ups.

## Safety Notes

- No source files moved.
- No source files deleted.
- No broad links rewritten.
- No canon, gate, proposal, spec, or current-status decision made.
- Each Line Up states that source remains authoritative for exact proof logs.

## Handoff

```text
Card: S3-R38-C5-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: igniter-lang/line-up-stage1-stage2-second-batch-v0
Status: done

[D] Decisions
- Used STALE_REFRESH because this is a new R38 card after the R37 first batch.
- Summarized three requested clusters only; R13-R22 Gate 3 discussions remain a
  separate follow-up batch.
- Treated package/gem proof as package-boundary evidence, not release readiness.
- Treated old discussion outputs as routed pressure, not canon.

[S] Shipped / Signals
- Created three Line Up memory cards.
- Updated `docs/lineups/README.md`.
- Created this track doc.

[T] Tests / Proofs
- Documentation-only validation.
- Checked required Line Up fields: source paths, disposition, current route,
  public/private risk, open questions, and exact-proof-log authority note.

[R] Risks / Recommendations
- Archive/Form should verify no release/runtime/Gate 3 authority leaked into
  summaries.
- History Curator should plan any `tracks/README.md` or discussions index
  grouping only after redirect/no-zombie checks.

[Next] Suggested next batch
- `gate3-r13-r22-discussions-lineup-v0`, linked to History-S7.
```
