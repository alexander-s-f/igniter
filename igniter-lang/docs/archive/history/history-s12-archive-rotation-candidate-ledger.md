# History-S12 Archive Rotation Candidate Ledger

Status: archived history report and rotation-candidate ledger  
Date: 2026-05-09  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S12  
Source posture: aggregate S1-S11 history reports; no files moved or deleted

## Compact Claim

The archive now has enough compact memory to plan cleanup as explicit packets,
not as ad hoc deletion.

The main rotation rule is:

```text
preserve compact history reports as durable memory
-> keep warm source clusters where they still guide current decisions
-> keep cold source clusters as evidence/research
-> only move/delete after a named approval packet with exact paths
```

S12 does not authorize file movement. It provides the ledger for a future
approved rotation stage.

## Source Set

Primary compression layer:

- `igniter-lang/docs/archive/history/origins-arbor-to-igniter-lang.md`
- `igniter-lang/docs/archive/history/history-s1-snapshot-value-map.md`
- `igniter-lang/docs/archive/history/history-s2-playgrounds-docs-rotation-map.md`
- `igniter-lang/docs/archive/history/history-s3-guide-current-absorption-map.md`
- `igniter-lang/docs/archive/history/history-s4-expert-reports-value-map.md`
- `igniter-lang/docs/archive/history/history-s5-research-horizon-compression-map.md`
- `igniter-lang/docs/archive/history/history-s6-dev-process-tracks-legacy-map.md`
- `igniter-lang/docs/archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md`
- `igniter-lang/docs/archive/history/history-s8-legacy-v1-value-extraction-map.md`
- `igniter-lang/docs/archive/history/history-s9-dev-reference-truth-map.md`
- `igniter-lang/docs/archive/history/history-s10-igniter-lang-expert-series-map.md`
- `igniter-lang/docs/archive/history/history-s11-general-expert-corpus-rotation-map.md`

Inventory context:

- `igniter-lang/docs/archive/snapshots/`
- `playgrounds/docs/`
- `igniter-lang/docs/archive/README.md`

## Rotation Ledger

| Area | Current role | Temperature | Rotation candidate | Approval packet |
| --- | --- | --- | --- | --- |
| `igniter-lang/docs/archive/history/` | Durable compact memory | Hot for history tasks | Keep in repo; extend index | No movement |
| `igniter-lang/docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/` | Broad origin archaeology | Deep cold | External/cold storage later after source links are stable | `Archive-Rotation-1` |
| `igniter-lang/docs/archive/snapshots/2026-05-06-stage1-close/` | Stage 1 transition evidence | Cold | Rotate deeper only after Stage 1/2 maps remain enough | `Archive-Rotation-1` |
| `igniter-lang/docs/archive/snapshots/2026-05-07-stage2-close/` | Compact Stage 2 close evidence | Warm | Keep local for now | No immediate movement |
| `igniter-lang/docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/` | Pre-compaction Stage 3 working snapshot | Cold | Candidate for external cold storage after later Stage 3 close map | `Archive-Rotation-1` after newer close exists |
| `playgrounds/docs/dev/process/` | Accepted private process doctrines | Warm | Keep near top; maybe index from dev README | No movement |
| `playgrounds/docs/dev/tracks/tracks.md` | Track entrypoint | Warm/hot for multi-agent dev | Keep in place | No movement |
| `playgrounds/docs/dev/tracks/tracks-history.md` | Closed track summary | Warm | Keep; use before individual track files | No movement |
| `playgrounds/docs/dev/tracks/*-track.md` | Detailed track lineage | Cold by default | Optionally group closed application/capsule/web clusters later | `Playgrounds-Rotation-1` |
| `playgrounds/docs/dev/legacy/` | V1 pressure archaeology | Cold | Keep intact; optionally combine tiny wrappers later | Later narrow packet |
| `playgrounds/docs/dev/full/` | Full historical target plans | Cold | Mark historical if an index is added | No movement |
| `playgrounds/docs/dev/reference/` | Mixed post-core reference memory | Warm/cold by topic | Add small reference index before any deeper cleanup | Later index packet |
| `playgrounds/docs/guide/` | Full guide drafts and old public descendants | Cold source | Add README/status note; compare descendants before deletion | Later guide packet |
| `playgrounds/docs/current/` | Historical platform-current snapshot | Cold source | Add status note or rename only with approval | Later guide/current packet |
| `playgrounds/docs/research-horizon/` | Research lane with supervisor gate | Cold/warm by topic | Add graduated/source status markers if useful | Later research packet |
| `playgrounds/docs/experts/igniter-lang/` | Language-birth expert series | Warm for temporal/OLAP/persistence; cold for theory | Keep; RU files as mirrors | Later bilingual/index packet |
| `playgrounds/docs/experts/*.ru.md` | Bilingual mirrors | Mirror only | Keep or group as bilingual mirrors | Later bilingual packet |
| `playgrounds/docs/experts/application-proposals*` | Product idea pressure | Cold | Group under product proposals or move deeper later | Later product packet |
| `playgrounds/docs/experts/interactive-app-dsl.md`, `igniter-ui-kit.md`, `igniter-plane.md` | Interaction/UI/Plane research | Cold | Keep under research; do not read as current API | Later research packet |
| `playgrounds/docs/external/` | External pressure implementations | Unclassified | Do not rotate yet; needs a dedicated pass | `History-S13` candidate |
| `playgrounds/docs/review/` | Small review evidence | Cold | Keep | No movement |
| `playgrounds/docs/.DS_Store` | Finder artifact | None | Delete only in cleanup packet | `Playgrounds-Rotation-1` |
| `playgrounds/docs/.idea/` | IDE metadata | None | Consider local-only cleanup | `Playgrounds-Rotation-1` |
| `playgrounds/docs/.git/` | Nested repository metadata | Unknown/high caution | Do not touch without explicit decision | Separate explicit approval |

## Safe Future Cleanup Packets

These are planning packets only.

| Packet | Scope | Safe first moves | Must not do |
| --- | --- | --- | --- |
| `Playgrounds-Rotation-1` | Metadata and indexes | Remove agreed metadata artifacts; add small README/index files; report before/after file counts | Delete content-bearing Markdown |
| `Archive-Rotation-1` | Old snapshots | Move only exact approved snapshot folders to external/cold storage after history links are stable | Touch Stage 2 close before replacement evidence exists |
| `Guide-Current-Index-1` | `playgrounds/docs/guide` and `playgrounds/docs/current` | Add status notes marking them full/cold or historical | Claim old drafts are current public truth |
| `Dev-Reference-Index-1` | `playgrounds/docs/dev/reference` | Add topic index and current-check warnings | Promote old package paths/APIs without code/doc check |
| `Expert-Bilingual-Index-1` | RU mirrors and expert read rules | Mark RU files as mirrors and add read temperatures | Treat translations as separate evidence by default |
| `Product-Proposals-Cold-1` | Large application proposal catalogs | Group as product pressure/source ideas | Treat proposal catalogs as roadmap |

## No-Move Zones

Do not move these without a new, explicit request:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/spec*`
- `igniter-lang/docs/proposals/`
- `igniter-lang/docs/gates/`
- active package/source files
- any archive/history report already serving as a compact index

## Read Temperature Rules

Hot:

- current `igniter-lang/docs/agent-context.md`
- current `igniter-lang/docs/current-status.md`
- current `igniter-lang/docs/value-index.md`
- archive history index and exact S-report for a history task

Warm:

- Stage 2 close snapshot
- process doctrines
- track entrypoints
- Gate 3 S7 map for Phase 1/live-read work
- temporal/OLAP/persistence expert sources when a proposal needs origin evidence
- capsule/evidence/security references when activation or transfer is in scope

Cold:

- full snapshots
- individual closed track files
- V1 legacy docs
- old guide/current drafts
- research-horizon proposals
- product proposal catalogs
- UI/Plane/interactive app DSL reports

Mirror only:

- RU duplicates unless bilingual wording recovery is needed

Unclassified:

- `playgrounds/docs/external/`, especially Agent-A/Agent-B pressure docs. These
  should not be cleaned from S12. They need their own source pass because they
  contain many hypothetical domain implementations and external pressure tests.

## Accepted Rotation Doctrine

- Compact reports are the durable memory layer.
- Full source archives are evidence, not default working context.
- Research docs do not authorize implementation.
- Old roadmap/status docs are historical unless current docs confirm them.
- Bilingual mirrors reduce read priority but can preserve author intent.
- Cleanup should start with metadata and index/status notes, not Markdown
  deletion.
- Every destructive move needs exact paths, rationale, and approval.

## Stage-Close Handoff

Compact claim:

S12 converts S1-S11 into a future cleanup ledger. The archive is ready for
planned rotation, but not for bulk deletion. The next safe cleanup is metadata
and index/status-note work; the next history discovery is likely
`playgrounds/docs/external/`.

Source set:

- archive history reports S1-S11 plus origins
- archive snapshot inventory
- playground docs inventory

Categories applied:

- accepted_canon
- implemented
- superseded_history
- research_unrealized
- rejected / parked
- values
- rotation_candidate
- no_move
- unclassified

Values preserved:

- compact history over broad context
- source evidence remains recoverable
- approval before destructive cleanup
- current docs remain first read
- research stays gated
- mirrors are wording support, not duplicate evidence

Accepted/implemented signals:

- history reports are now the archive entrypoint
- active/warm/cold read discipline
- process docs and track entrypoints remain warm
- Gate 3 S7 map is the Phase 1/live-read archaeology layer
- temporal/OLAP/persistence expert sources remain high-value origin evidence

Superseded/rejected signals:

- full snapshots as working context
- old playground `current` as active status
- V1 docs as API truth
- expert reports as roadmap/API
- product proposals as commitments
- translations as separate conceptual sources

Research still alive:

- external pressure implementation corpus
- product proposal mining
- UI/Plane/interactive app authoring
- runtime observatory/agent handoff
- critical-domain primitives
- distributed OLAP/persistence/backend lines

Duplicate/rotation recommendations:

- start with metadata cleanup and status indexes only
- do not delete content-bearing Markdown in first cleanup
- keep Stage 2 close local
- consider external/cold rotation for old broad snapshots later
- group product proposal catalogs later
- mark RU files as mirrors if an expert index is edited
- run a dedicated S13 for `playgrounds/docs/external/`

Unresolved questions:

- Should the first approved cleanup packet be `Playgrounds-Rotation-1` metadata
  cleanup or index/status-note work?
- Should `playgrounds/docs/current/` be renamed, or is a status note enough?
- Should old snapshots move to a separate archive repository after S13/S14, or
  remain in-place until a larger docs migration?
- How should `playgrounds/docs/external/` be classified: product pressure,
  domain benchmark, research corpus, or all three?

Changed files:

- `igniter-lang/docs/archive/history/history-s12-archive-rotation-candidate-ledger.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S13 should classify `playgrounds/docs/external/` as an external
pressure corpus: what became accepted pressure, what is domain benchmark
material, what is speculative/rejected, and what can later rotate cold.
