# Contract Persistence Development Track

Status date: 2026-04-30.
Scope: accepted development track from Companion pressure and external expert
research. Not public API, package API, core graph-node change, DB planner, or
materializer execution.

## Claim

The organic persistence research is accepted as the horizon:

```text
persist -> Store[T]
history -> History[T]
field/type descriptors -> storage plan
store_read -> future graph dependency
store_write/store_append -> future typed app-boundary effect
contract-native store -> future optional substrate
```

The development track stays app-local until the vocabulary is stable and the
pressure repeats outside Companion.

## Current Evidence

Already proved in Companion:

- R1 storage plan sketch: `/setup/storage-plan(.json)`
- R1 storage plan health: `/setup/storage-plan-health(.json)`
- R2 storage migration plan: `/setup/storage-migration-plan(.json)`
- R2 storage migration health:
  `/setup/storage-migration-plan-health(.json)`
- `schema_version: 1`
- canonical `storage.shape`
- Store/History lowerings as descriptors
- operation descriptors with `boundary: :app`
- relation descriptors with report-only enforcement
- materializer lifecycle as review-only packets

Accepted research evidence:

- contract-native store POC proves content-addressed facts, causation chain,
  time-travel, reactive invalidation, and file-backed WAL replay
- organic model correctly identifies the next architectural move:
  fields should participate in type validation before Store/History become graph
  nodes

## Next Development Slice

Next slice: **R2a Field Type Validation**, app-local and report-only.

Goal:

- connect `field` declarations to a compact type-validation report
- validate field vocabulary, defaults, enum values, JSON fields, and required
  keys against current Companion manifests and seeded data
- surface type drift before storage, relation, migration, or materializer
  execution expands

Likely surface:

- `/setup/field-type-plan(.json)` or `/setup/persistence-type-plan(.json)`
- `/setup/field-type-health(.json)` or `/setup/persistence-type-health(.json)`

Acceptance:

- no runtime gate
- no core DSL promotion
- no DB schema change
- no SQL generation
- no materializer execution
- report explicitly preserves `persist -> Store[T]` and
  `history -> History[T]`
- failures are review items, not write blockers

## Ladder

### R2a Field Type Validation

Report-only validation of field descriptors, defaults, enum domains, JSON
fields, required keys, and seeded payload shape.

### R2b Relation Type Compatibility

Report-only validation that relation joins connect compatible field types:

```text
Relation[Store[A], History[B]]
join: { A.id -> B.a_id }
```

No FK generation and no relation enforcement.

### R2c Access Path Sketch

Report-only `store_read` descriptor sketch:

- store/history target
- lookup kind
- key binding
- scope/filter source
- cache/coalesce hints
- future reactive consumer hint

No runtime graph node yet.

### R2d Typed Effect Intent

Report-only `store_write` / `store_append` descriptor sketch over existing
command mutation intents.

No Saga execution, no core effect-node change.

### R3 Materializer Dry Run

Render proposed file/binding changes as review data only.

No filesystem writes, git, tests, restart, or capability grant.

### R4 Contract-Native Store Experiment

Keep the POC as a separate experiment under `packages/igniter-store`.

Current package entrypoint:

```ruby
require "igniter-store"
```

Current package smoke:

```bash
ruby -I packages/igniter-store/lib packages/igniter-store/examples/store_poc.rb
```

Owns:

- content-addressed facts
- append-only WAL
- time-travel
- reactive invalidation
- access path registry
- future PostgreSQL sync-hub and retention experiments

Do not wire it into Companion runtime until R2a-R2d are stable.

## Boundaries

Do not do yet:

- add StoreNode/HistoryNode/StoreReadNode/StoreWriteNode to core
- create `igniter-persistence` or `igniter-store`
- replace Companion SQLite JSON state backend
- infer SQL tables as the execution model
- execute migrations
- grant materializer write/git/test/restart capabilities
- add ORM-style class query methods

Do preserve:

- query-as-contract direction
- store injected per execution, never global
- graph computes intent, app/store applies it
- schema versioning as `History[ContractSpecChange]`
- future time-travel and reactive-agent path

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/contract-persistence-development-track.md
Status: development track accepted.
[D] R1 storage plan and R2 storage migration are current app-local evidence.
[D] Next implementation slice is R2a Field Type Validation.
[D] `packages/igniter-store` is the isolated POC gem for contract-native store
experiments.
[D] Organic Store[T]/History[T] graph nodes are accepted as horizon, not current
core work.
[D] Contract-native store POC stays separate until field/type/relation/access
path descriptors stabilize.
[R] No core graph-node changes, package split, SQL generation, migration
execution, or materializer execution from this track alone.
[S] Use Companion pressure and report-only health packets to decide promotion.
Next: implement app-local field/type validation report and health packet.
```
