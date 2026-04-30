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
- R2a field type plan: `/setup/field-type-plan(.json)`
- R2a field type health: `/setup/field-type-health(.json)`
- R2b relation type plan: `/setup/relation-type-plan(.json)`
- R2b relation type health: `/setup/relation-type-health(.json)`
- R2c access path plan: `/setup/access-path-plan(.json)`
- R2c access path health: `/setup/access-path-health(.json)`
- R2d typed effect intent plan: `/setup/effect-intent-plan(.json)`
- R2d typed effect intent health: `/setup/effect-intent-health(.json)`
- tiny Companion/Store convergence sidecar:
  `/setup/store-convergence-sidecar(.json)`
- `schema_version: 1`
- canonical `storage.shape`
- Store/History lowerings as descriptors
- operation descriptors with `boundary: :app`
- relation descriptors with report-only enforcement
- materializer lifecycle as review-only packets
- performance signal: `/setup` slowdown comes from repeated packet
  recomputation and oversized aggregate rendering, not from individual
  persistence packet cost
- command mutation intents can now be reported as future typed
  `store_write` / `store_append` effects without creating runtime effect nodes
- package-level `Igniter::Companion::Store` can round-trip one app-local
  `Reminder` record and one `TrackerLog` history into `igniter-store` facts as
  an ephemeral sidecar proof, including normalized receipts and partition replay

Accepted research evidence:

- contract-native store POC proves content-addressed facts, causation chain,
  time-travel, reactive invalidation, and file-backed WAL replay
- organic model correctly identifies the next architectural move:
  fields should participate in type validation before Store/History become graph
  nodes

## Next Development Slice

Current evidence: **R2a Field Type Validation**,
**R2b Relation Type Compatibility**, **R2c Access Path Sketch**, and
**R2d Typed Effect Intent**, app-local and report-only.

Goal:

- use the R2a-R2d packets as the stable read-before-write ladder
- keep commands lowering to normalized mutation intent
- treat `store_write` / `store_append` as future typed app-boundary effects,
  not current runtime nodes

Likely surface:

- `/setup/effect-intent-plan(.json)`
- `/setup/effect-intent-health(.json)`

Acceptance:

- `/setup/field-type-plan(.json)` reports current field descriptors and seeded
  payload shape
- `/setup/field-type-health(.json)` validates descriptor policy and no-execution
  boundaries
- `/setup/relation-type-plan(.json)` reports join field compatibility over
  `Relation[Store[A], History[B]]`
- `/setup/relation-type-health(.json)` validates non-enforcing/no-FK
  boundaries
- `/setup/access-path-plan(.json)` reports store/history/relation read
  descriptors, key bindings, scope/filter sources, cache hints, and projection
  consumers
- `/setup/access-path-health(.json)` validates no StoreRead node, no runtime
  planner, no cache execution, and non-mutating access-path descriptors
- `/setup/effect-intent-plan(.json)` reports command mutation intents as
  future `store_write` / `store_append` typed effect descriptors
- `/setup/effect-intent-health(.json)` validates no StoreWrite node, no
  StoreAppend node, no Saga execution, and app-boundary-only mutation
- no runtime gate, core DSL promotion, DB schema change, SQL generation, or
  materializer execution
- report explicitly preserves `persist -> Store[T]` and `history -> History[T]`
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
Current Companion surface:

- `/setup/effect-intent-plan(.json)`
- `/setup/effect-intent-health(.json)`
- command `none` remains explicit as `effect: :none`
- mutating effects keep `boundary: :app` and
  `command_still_lowers_to: :mutation_intent`

### Sidecar: Companion / Store Convergence

Tiny report-only bridge over the package stack:

- app-local manifest vocabulary remains the source pressure
- `Igniter::Companion::Record` / `History` provide typed package classes
- `Igniter::Companion::Store` writes into `Igniter::Store::IgniterStore`
- immutable facts prove causation, replay, time-travel, and receipts

Current surface:

- `/setup/store-convergence-sidecar(.json)`

Current pressure:

- choose the next app-local descriptor to mirror into the package facade
- decide whether partition replay should remain package-level filtering or
  become a store access path
- decide the app-local receipt projection before broader adapter migration

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
[D] R1 storage plan, R2 storage migration, R2a field type validation, R2b
relation type compatibility, R2c access path sketch, and R2d typed effect
intent are current app-local evidence.
[D] Next implementation slice is either R3 Materializer Dry Run or a focused
package facade descriptor-mirroring slice.
[D] `packages/igniter-store` is the isolated POC gem for contract-native store
experiments.
[D] Organic Store[T]/History[T] graph nodes are accepted as horizon, not current
core work.
[D] Contract-native store POC stays separate until field/type/relation/access
path descriptors stabilize.
[R] No core graph-node changes, package split, SQL generation, migration
execution, or materializer execution from this track alone.
[S] Use Companion pressure and report-only health packets to decide promotion.
Next: design an app-local materializer dry-run packet that renders proposed
file/binding changes as review data only.
```
