# Documentation Movement Link Ledger: Stage 1 / Stage 2 v0

Card: S3-R37-C7-P2  
Agent: `[Igniter-Lang History Curator]`  
Role: history-curator  
Track: `documentation-movement-link-ledger-stage1-stage2-v0`  
Status: movement/link plan only  
Date: 2026-05-12  

---

## Scope

Create a no-move/no-delete movement and link lifecycle ledger for the Stage 1 /
Stage 2 cleanup source set.

This track does not move, delete, or rewrite broad links. It plans the order in
which source evidence can later be summarized, redirected, archived, or left in
place.

## STALE_REFRESH

`docs/dev/documentation-metabolism.md` is newer than the older History-S12/S16
rotation reports and defines the current pipeline:

```text
fate decision -> movement/linking -> compact memory
Archive/Form  -> History Curator  -> Line Up Summarizer
```

During this pass, the Archive/Form Expert fate inventory for the same cleanup
source set was available:

- `docs/tracks/documentation-fate-inventory-stage1-stage2-v0.md`

This ledger uses that fate inventory as the primary movement input and treats
the existing history reports as supporting archaeology:

- `docs/archive/history/history-s1-snapshot-value-map.md`
- `docs/archive/history/history-s12-archive-rotation-candidate-ledger.md`
- `docs/archive/history/history-s16-playgrounds-rotation-1-approval-packet.md`

If that fate inventory changes, this movement ledger should be refreshed before
execution.

## Inputs Read

- `docs/dev/documentation-metabolism.md`
- `docs/archive/README.md`
- `docs/archive/history/README.md`
- `docs/archive/history/history-s1-snapshot-value-map.md`
- `docs/archive/history/history-s12-archive-rotation-candidate-ledger.md`
- `docs/archive/history/history-s16-playgrounds-rotation-1-approval-packet.md`
- `docs/tracks/documentation-fate-inventory-stage1-stage2-v0.md`
- `docs/lineups/README.md`
- `docs/tracks/README.md`

## Movement Principles

1. Do not move Stage 2 close evidence yet.
2. Do not delete any content-bearing Markdown in this batch.
3. Create Line Ups before redirecting links.
4. Update indexes before moving source paths.
5. Treat `docs/current-status.md`, `docs/agent-context.md`, `docs/spec/`,
   `docs/proposals/`, and `docs/gates/` as no-move anchors.
6. Where snapshot copies already exist, prefer link/index redirection over
   moving active evidence immediately.
7. Follow the fate inventory posture: preserve first, summarize second, move
   only after explicit movement/link planning.

## Movement / Link Ledger

Incoming links below are best-effort, not exhaustive. They are enough to plan
safe redirect/index work before any future movement.

| Source path | Current incoming links found | Proposed archive target | Required redirect / index update | Line Up needed? | Move/delete approval needed? |
| --- | --- | --- | --- | --- | --- |
| `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/` | `archive/README`, `archive/history/history-s1-*`, `archive/history/history-s12-*` | Keep in place for now; later candidate for external cold archive under `Archive-Rotation-1` | If moved later: update `archive/README`, `archive/history/README`, S1/S12 reports, and any Line Up source path | Yes: `lineups/stage1-pre-crystallization-origin-archaeology.md` | Yes for move; no delete recommended |
| `docs/archive/snapshots/2026-05-06-stage1-close/` | `docs/README`, `current-status`, `archive/README`, S1/S12 history reports | Keep in place until a Stage 1 close Line Up exists; later external/cold candidate | If moved later: update `docs/README`, `current-status` close-evidence pointer, `archive/README`, S1/S12 reports | Yes: `lineups/stage1-close-transition-evidence.md` | Yes for move; no delete recommended |
| `docs/archive/snapshots/2026-05-07-stage2-close/` | `current-status`, `archive/README`, `tracks/README`, S1/S12 reports | **No movement now**; keep local warm evidence | Add read-temperature note only after Line Up exists; no redirect yet | Yes: `lineups/stage2-close-proof-spine.md` | Yes for any future move; current recommendation is no move |
| `docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/` | `archive/README`, S12 report | Out of this Stage 1/2 batch; later Stage 3 close rotation packet | None in this batch | Later | Yes if moved |
| `docs/tracks/stage1-close-candidate-proof-v0.md` | `tracks/README`; many later tracks cite `stage1_close_candidate` generally | Keep in `docs/tracks` until Line Up and index redirect exist; future public archive candidate | Add Line Up row; later `tracks/README` can point to Line Up for Stage 1 proof summary | Yes: include in Stage 1 close Line Up | Yes for move/delete |
| `docs/tracks/stdlib-execution-kernel-stage1-v0.md`, `docs/tracks/runtime-eval-surface-stage1-fixtures-v0.md`, `docs/tracks/igapp-assembler-proof-stage1-v0.md` | `tracks/README`; Stage 1 proof/regression references | Keep in place; group under Stage 1 proof Line Up before any movement | Later `tracks/README` can group under a compact Stage 1 proof row | Yes: same Stage 1 close Line Up | Yes for move/delete |
| `docs/tracks/stage2-close-candidate-planning-v0.md` | `tracks/README`; Stage 2 close context | Keep in place; candidate to read via Stage 2 close Line Up | Add Line Up source row first; no redirect yet | Yes: Stage 2 close Line Up | Yes for move/delete |
| `docs/tracks/stage2-close-candidate-v0.md` | `current-status`, `tracks/README`, many Stage 3 regression references | **Do not move now**; active reference for close evidence | Add Line Up and keep exact source link in `tracks/README` until broad refs are stable | Yes: Stage 2 close Line Up | Yes; current recommendation is no move |
| `docs/tracks/stage2-round*-*.md` | `tracks/README`; current-status history sections indirectly | Keep in place; later group as Stage 2 round-map public archive | Add Line Up summary before any status/index rewrite | Yes: `lineups/stage2-round-map-and-status-curation.md` | Yes for move/delete |
| Stage 2 proof tracks: `history-type-*`, `stream-*`, `olap-point-*`, `invariant-*`, `parser-oof-*`, `semanticir-stage2-*`, `runtime-machine-temporal-access-hook-*` | `tracks/README`, `current-status`, spec sync tracks, later regression tracks | Keep in place; later group under `docs/archive/rotated/stage2-proof-tracks/` only after Line Up + redirect plan | Add proof-spine Line Up; later update `tracks/README` section from many rows to grouped rows if approved | Yes: `lineups/stage2-proof-surface-spine.md` | Yes for move/delete |
| Stage 2 package/bridge tracks: `packageable-compiler-api-v0.md`, `compiler-package-boundary-v0.md`, `compiler-packaging-skeleton-v0.md`, `gem-native-package-boundary-specs-v0.md`, `ledger-tbackend-adapter-*` | `tracks/README`, current-status Stage 2 close/deferred-gap refs | Keep in place; later public archive group after package docs are checked | Add Line Up before any redirect; do not touch package docs in this batch | Yes: include in Stage 2 proof-spine or a package-boundary Line Up | Yes for move/delete |
| `docs/meta-proposals/META-EXPERT-007*`, `META-EXPERT-008*`, `META-EXPERT-009*`, `META-EXPERT-009.1-*` | `meta-proposals/README`, current-status, archive snapshots | Keep in place; governance anchors, not movement candidates until Archive/Form fate decision | Add Line Up only if Meta Expert asks for governance compaction | Optional; not first batch | Yes for move/delete |
| `docs/spec/ch9-stage2-reserved.md` | `spec/README`, current spec navigation, progression scope docs | **Do not move** | No redirect; spec-lag work owns it | No | Yes, but movement should be treated as spec work, not archive cleanup |
| `docs/current-status.md`, `docs/agent-context.md`, `docs/README.md` | Broad current docs | **Do not move** | No movement redirects; only normal status curation may edit | No | Not applicable |
| `docs/archive/history/history-s1-*`, `history-s12-*`, this track | History/movement indexes | **Do not move** | They are the redirect layer for archaeology | No | Yes; not recommended |

## Archive Index Update Recommendations

No archive indexes were edited in this card. Recommended later updates after
Line Ups exist:

1. `docs/archive/README.md`
   - Add a "Movement state" column or note:
     - Stage 1 pre-crystallization: `deep cold / Line Up pending`
     - Stage 1 close: `cold / Line Up pending`
     - Stage 2 close: `warm / keep local`
2. `docs/archive/history/README.md`
   - Add a short "Movement ledgers" subsection linking S12, S16, and this track.
   - Keep history reports as durable memory, not movement targets.
3. `docs/tracks/README.md`
   - After Line Ups exist, add compact group rows for Stage 1 proof, Stage 2
     proof spine, and Stage 2 round curation.
   - Do not remove existing exact track rows until a redirect check confirms no
     important incoming references rely on them.
4. `docs/lineups/README.md`
   - Add first batch rows created by Line Up Summarizer.

## First Safe Batch For Line Up Summarizer

The fate inventory recommends six Line Ups. This card narrows the first safe
movement batch to the Stage 1 / Stage 2 close and proof-spine subset so link
lifecycle work can begin without mixing in discussions, Gate 3, or syntax
pressure.

Batch id:

```text
LineUp-Stage1-Stage2-1
```

Source set:

1. `docs/archive/snapshots/2026-05-06-stage1-close/README.md`
2. `docs/archive/snapshots/2026-05-07-stage2-close/README.md`
3. `docs/tracks/stage1-close-candidate-proof-v0.md`
4. `docs/tracks/stage2-close-candidate-v0.md`
5. Stage 2 proof-spine group:
   - `history-type-proof-v0.md`
   - `stream-t-proof-v0.md`
   - `olap-point-proof-v0.md`
   - `invariant-severity-proof-v0.md`
   - `parser-oof-hardening-stage2-proof-v0.md`
   - `semanticir-stage2-surface-lowering-v0.md`
   - `runtime-machine-temporal-access-hook-proof-v0.md`

Requested Line Ups:

| Proposed Line Up | Sources | Disposition | Purpose |
| --- | --- | --- | --- |
| `stage1-close-transition-evidence.md` | Stage 1 close snapshot README + close candidate track | `public_archive` | Compact what Stage 1 closed and what later Stage 2 superseded. |
| `stage2-close-proof-spine.md` | Stage 2 close snapshot README + close candidate track | `active_reference` | Compact the Stage 2 proof spine agents still cite. |
| `stage2-proof-surface-spine.md` | History/BiHistory, stream, OLAP, invariant, parser OOF, SemanticIR, runtime hook proof tracks | `active_reference` | Compact the proof surfaces so future agents do not read seven old tracks by default. |
| `stage2-round-map-and-status-curation.md` | `stage2-round*-*.md` status/map tracks | `public_archive` | Compact round-map curation history and route future agents to current-status first. |

Line Up constraints:

- Do not make canon claims beyond current `current-status`.
- Include "source remains authoritative for exact proof logs."
- Mark Stage 2 close as warm/active-reference, not deep cold.
- Mark Stage 1 close as public archive / transition evidence.
- Do not summarize proposals/spec chapters in the same batch.
- Leave the remaining fate-inventory Line Ups for follow-up batches:
  compiler/package spine, Stage 2 -> Stage 3 typed switch, old pre-Gate-3
  discussions, and Gate 3 R13-R22 discussions.

## Approval Gates

Safe without additional approval:

- Create Line Ups.
- Add Line Up index rows.
- Add this track to `docs/tracks/README.md` if assigned.
- Add non-destructive archive index notes.

Requires explicit approval:

- Any `git mv`.
- Any deletion.
- Any broad link rewrite.
- Any change to `current-status`, `agent-context`, `spec`, `proposals`, or
  `gates`.
- Any movement of Stage 2 close snapshot.

## Stage-Close Handoff

Compact claim:

- Stage 1 / Stage 2 cleanup should begin with Line Ups and index notes, not
  movement. Stage 2 close remains local warm evidence. Stage 1 close can later
  rotate deeper only after compact summaries and redirects exist.

Source set:

- documentation metabolism docs;
- Archive/Form fate inventory for Stage 1 / Stage 2;
- archive README/history index;
- S1/S12/S16 history reports;
- Stage 1 / Stage 2 archive snapshots;
- Stage 1 / Stage 2 tracks and track index.

Movement categories applied:

- `do_not_move`
- `active_reference`
- `public_archive`
- `external_archive_candidate`
- `line_up_needed`
- `approval_required`

Archive index update recommendations:

- add movement-state notes only after Line Ups exist;
- do not collapse exact source links before redirect verification;
- keep `history/` reports as durable memory.

First safe batch:

- `LineUp-Stage1-Stage2-1`, four Line Ups listed above.

Unresolved questions:

- Should Stage 1 pre-crystallization move to external cold storage after Line Up
  creation, or remain local until Stage 3 close?
- Should `docs/tracks/README.md` keep all old exact Stage 2 proof rows forever,
  or eventually group them under Line Up links?
- Should the Line Up Summarizer follow the narrower first safe batch in this
  ledger first, or start with all six batches from the fate inventory?

Changed files:

- `docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md`
