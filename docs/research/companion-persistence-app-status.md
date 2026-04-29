# Companion Persistence App Status

Status date: 2026-04-29.
Scope: Companion application proof only. No core, package, stable API, grammar,
or migration-generator promotion.

## Current Claim

Companion now validates contract persistence as an app-local capability model:
persistent shapes are declared by contracts, behavior is computed by graph
contracts, and side effects are applied at the app/store boundary.

The proof is strong enough to guide the next research slice. It is not yet a
public Igniter persistence API.

## App-Local Surface

`Companion::Contracts::PersistenceSketchPack` adds report-only DSL keywords:

- `persist`
- `history`
- `field`
- `index`
- `scope`
- `command`

These keywords compile to metadata operations in Companion contract manifests.
They do not change the core contracts runtime.

Current record capabilities:

- `Reminder`: `persist`, fields, `index :status`, `scope :open`, command
  metadata for `complete`
- `Tracker`: `persist`, fields
- `DailyFocus`: `persist`, date-keyed workflow/session record
- `Countdown`: `persist`, fields

Current history capabilities:

- `TrackerLog`: `history`, append-only tracker measurements
- `CompanionAction`: `history`, append-only user/runtime receipts

Current projection contracts:

- `TrackerReadModelContract`: `Tracker` records plus `TrackerLog` history
- `CountdownReadModelContract`: countdown records to dashboard facts
- `ActivityFeedContract`: action history to activity facts

Current command contracts:

- `ReminderContract`: create/complete, success/refusal, mutation intent
- `CountdownContract`: create, success/refusal, mutation intent
- `TrackerLogContract`: append, success/refusal, mutation intent

Current operation algebra:

- `record_append`
- `record_update`
- `history_append`
- `none`

## Registry Shape

`CompanionPersistence` is now the app-local capability registry/factory.

It owns:

- record bindings
- history bindings
- projection bindings
- command operation manifests
- validation errors
- readiness projection
- setup manifest projection

It validates:

- record bindings have `persist`
- history bindings have `history`
- record classes cover declared fields
- indexes reference declared fields
- command metadata uses supported operations
- command metadata changes declared fields
- projection contracts compile

## Runtime Boundary

`CompanionStore` remains the mutation boundary:

- graph command contracts compute results and mutation intents
- `CompanionStore#apply_persistence_mutation` applies normalized operations
- app backend persists the whole Companion state
- command/user/runtime receipts append to `CompanionAction` history

This keeps compute nodes side-effect-free while still making persistence behavior
inspectable.

## Product Proof

Current Companion product flows use the persistence model:

- dashboard reads open reminders through `ContractRecordSet#scope(:open)`
- tracker cards are projections from tracker records plus tracker-log history
- countdown cards are projections from countdown records
- activity feed is a projection from action history
- Today quick action is graph-owned and can invoke tracker-log append or
  reminder-complete flows without the UI owning persistence semantics
- `/setup` and `/setup/manifest` expose readiness and manifest state

## Validated Concepts

- `persist` is viable Ruby product sugar for `Store[T]`.
- `history` is viable Ruby product sugar for `History[T]`.
- `index`, `scope`, and `command` metadata can be reported before DB planning or
  runtime enforcement.
- Generated record/history APIs can be app-local and tiny.
- Projections should be graph-owned, not hidden in UI code.
- Mutation intents need a small operation algebra, not ad hoc symbols.
- Store should shrink toward a boundary facade, not grow into an ORM.

## Boundaries

Not accepted yet:

- public package API
- core DSL keywords
- runtime database abstraction
- migration generator
- automatic SQL indexes
- relation enforcement
- distributed placement
- `Igniter::Lang` grammar syntax
- treating histories as mutable CRUD

## Next Research Move

The next natural research slice is `contract persistence relations`.

Start app-locally with the already-proven relation:

```text
Store[Tracker] + History[TrackerLog] -> TrackerReadModelContract
```

The first safe move is a relation manifest, not new behavior:

- name the relation
- declare endpoints
- declare join keys
- declare cardinality
- validate endpoint and field existence
- expose it through setup manifest/readiness
- keep enforcement false

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/companion-persistence-app-status.md
Status: current Companion app-level persistence proof summarized.
[D] Persistence stays app-local while the concept settles.
[D] Current validated shape is records + histories + projections + command
operation intents + registry/readiness/manifest.
[R] Do not promote `persist`, `history`, `index`, `scope`, or `command` into core
from this proof alone.
[R] Preserve `persist -> Store[T]` and `history -> History[T]`.
[S] Reminder now proves metadata beyond fields: index, scope, and command
metadata are reportable and usable by app-local generated APIs.
Next: research and app-local proof for relation manifests, starting with
Tracker to TrackerLog to TrackerReadModel.
Block: none.
```
