# Gate 3 R13-R22 Discussions Line Up v0

Card: S3-R39-C4-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: gate3-r13-r22-discussions-lineup-v0
Status: done
Date: 2026-05-12

Route: STALE_REFRESH
Previous known card: S3-R38-C5-P1
Latest observed round: S3-R39 card assigned by supervisor; Line Up index already
contains first and second Stage 1/2 batches.
Same-role newer work: no newer same-role Line Up observed for R13-R22 before
this card.
Gate/status changes: none made by this card; documentation hoisting only.

---

## Scope

Create the high-risk Gate 3 R13-R22 discussions Line Up without moving,
deleting, or broad link rewriting.

Inputs reread:

- `igniter-lang/handoff/onboarding-line-up-summarizer-v0.md`
- `igniter-lang/handoff/INSTANCE_ROUTING.md`
- `igniter-lang/docs/lineups/README.md`
- `igniter-lang/docs/tracks/documentation-fate-inventory-stage1-stage2-v0.md`
- `igniter-lang/docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md`

Primary source discussions:

- `docs/discussions/gate3-decision-safety-pressure-v0.md`
- `docs/discussions/gate3-decision-safety-pressure-v0-agent-v2-cross-test.md`
- `docs/discussions/phase1-implementation-prep-safety-pressure-v0.md`
- `docs/discussions/runtime-temporal-executor-lib-prep-safety-pressure-v0.md`
- `docs/discussions/live-read-addendum-draft-safety-pressure-v0.md`
- `docs/discussions/gate3-live-read-addendum-pre-signature-pressure-v0.md`
- `docs/discussions/gate3-post-signature-runtime-pressure-v0.md`
- `docs/discussions/phase1-post-signature-audit-registry-pressure-v0.md`
- `docs/discussions/phase1-e2e-and-content-address-pressure-v0.md`

Supporting compression map:

- `docs/archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md`

## Line Up Created

| Line Up | Disposition | Notes |
| --- | --- | --- |
| `docs/lineups/gate3-r13-r22-discussions-spine.md` | `public_archive candidate` | Separates historical pressure, superseded route, accepted decision, current authority, and remaining blockers. |

## Index Update

`docs/lineups/README.md` now includes the Gate 3 R13-R22 discussions row.

## Safety Notes

- No source files moved.
- No source files deleted.
- No broad links rewritten.
- No canon, gate, proposal, spec, or current-status decision made.
- The Line Up includes exact source paths and "source remains authoritative for
  exact proof logs."

## Handoff

```text
Card: S3-R39-C4-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: gate3-r13-r22-discussions-lineup-v0
Status: done

[D] Decisions
- Used STALE_REFRESH because this is a new R39 card after R38 Line Up work.
- Created one compact Gate 3 R13-R22 discussion Line Up.
- Treated discussion records as historical pressure, not current authority.
- Used History-S7 as supporting compression context, not as canon replacement.

[S] Shipped / Signals
- Created `docs/lineups/gate3-r13-r22-discussions-spine.md`.
- Updated `docs/lineups/README.md`.
- Created this track doc.

[T] Tests / Proofs
- Documentation-only validation.
- Checked required Line Up fields: source paths, disposition, current route,
  public/private risk, open questions, and exact-proof-log authority note.
- Ran `git diff --check` on changed docs.

[R] Risks / Recommendations
- Archive/Form should verify no production authority leaked into the summary.
- History Curator should plan discussion-index redirects only after no-zombie
  checks against current gate docs, current-status, and History-S7.

[Next] Suggested next batch
- Syntax/comprehension pressure around Stage 2 close, if still needed by C6.
```
