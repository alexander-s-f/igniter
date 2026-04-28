# Contract Persistence Target Plan

This document captures the accepted direction for persistence as a contract
capability.

It is a target plan, not a stable public API. Igniter is pre-v1, and the first
implementation work stays app-local in the Companion showcase until repeated
pressure justifies a package surface.

## Core Claim

Persistence should be a capability of contracts, not a hand-written store object
that every application has to rebuild.

A persisted contract should declare:

- the durable shape it owns
- the API it guarantees
- the operations it can perform
- the result and mutation semantics of those operations
- the adapter or backend requirements underneath

Backends are implementation detail:

- memory
- files
- SQLite
- Postgres
- Mongo/document
- Redis/KV
- custom adapter classes

## Target Surface

The near-term Ruby shape should be readable and record-like:

```ruby
contract :Reminder do
  persist key: :id, adapter: :sqlite

  field :id
  field :title
  field :due
  field :status, default: :open
end
```

Commands can layer over the declared durable shape:

```ruby
contract :Reminder do
  persist key: :id, adapter: :sqlite

  field :id
  field :title
  field :due
  field :status, default: :open

  command :create do
    validate :title, presence: true
    append title: title, due: "today", status: :open
  end

  command :complete do
    find id
    update status: :done
  end
end
```

Generated or guaranteed API candidates:

- `save`
- `find`
- `update`
- `delete`
- `all`
- `clear`
- named commands such as `create`, `complete`, `rotate`, `append_signal`

## Graph Semantics

The current Companion experiment uses a graph-facing form:

- a command contract receives operation inputs and current state/read handle
- the graph computes validation, result, and mutation intent
- the boundary applies the mutation through the configured adapter
- output includes receipt/action metadata

This keeps side effects out of compute nodes while still making CRUD and signal
logic inspectable as graph behavior.

## Relation To Stores

Existing store adapter docs describe execution snapshot stores:

- save and fetch execution snapshots
- resume pending executions
- query executions by graph or correlation

Contract persistence is different:

- record/entity persistence
- workflow/session persistence
- credential-local pipeline state
- transactional data emitted or consumed by contracts
- signals/events that contracts reason over

Both lines may share adapter infrastructure later, but they should not be
collapsed conceptually.

## Compatibility Ladder

This plan must stay compatible with the larger `Store[T]` and `History[T]`
direction. The relationship is a ladder, not competing APIs.

### `persist`

Ruby product surface for app ergonomics.

Best for:

- readable application code
- fast POC/product iteration
- hiding backend boilerplate
- guaranteed app-facing API

Main limit:

- host-language DSL, not a typed persistence algebra by itself

### `Store[T]`

Typed storage capability behind record/entity persistence.

Example future lowering:

```ruby
store :reminders, Store[Reminder], key: :id, backend: :relational
```

Adds:

- typed storage manifest
- adapter-independent API guarantee
- graph-visible storage capability
- future index, partition, placement, and verification metadata

### `History[T]`

Append-only temporal specialization.

Examples:

```ruby
History[TrackerLog]
History[ReminderEvent]
History[CredentialReadinessSignal]
```

Adds:

- immutable append semantics
- time-range queries
- replay and projection
- auditability
- causality and future bitemporal support

Design rule: `persist` must be sugar that can lower to `Store[T]` for records
and `History[T]` for events, logs, receipts, and signals.

## Persistence Kinds

### Record Contracts

Examples:

- reminder
- tracker
- countdown
- installed capsule registry entry

Primary API:

- point read/write
- list/query
- validation
- command-specific mutations

### Workflow Contracts

Examples:

- daily routine session
- onboarding setup state
- hub install flow
- agent run checkpoint

Primary API:

- append event
- transition state
- resume by id/token
- emit receipt

### Credential-Local Pipeline State

Examples:

- redacted OpenAI readiness
- provider capability status
- live-summary transcript reference

Rules:

- never copy raw secrets into graph outputs
- expose redacted status facts
- route work to the credential owner

### Transactional Data And Signals

Examples:

- tracker logs
- user action facts
- reminder completion event
- hub install receipt
- runtime/provider signal

Primary API:

- append signal
- query by subject/time/type
- project into read model
- feed derived contracts

## Current Implementation Evidence

Companion currently proves the first app-local version:

- `Reminder` declares the target metadata shape with `persist` and `field`
- `ContractRecordSet` turns that metadata into a generated record API
- `DailyFocus` uses the same generated record API for date-keyed daily session
  state
- `Tracker` declares the same record metadata shape and uses the generated API
- `TrackerLog` declares append-only metadata with `history` and `field`
- `ContractHistory` turns that metadata into a generated history API
- Companion persists tracker logs as a first-class top-level history and
  projects them back into tracker read models for UI compatibility
- `TrackerReadModelContract` derives dashboard facts from tracker records plus
  tracker-log history
- `CompanionAction` declares user/runtime receipts as append-only history
- `ActivityFeedContract` derives dashboard activity facts from action history
- `CompanionPersistence` collects generated record/history capabilities and
  read-model projections behind the Store façade
- `ReminderContract` computes create/complete success and refusal
- `TrackerLogContract` computes append-log success and refusal
- command contracts return result plus mutation intent
- `CompanionStore` applies mutation at the state/backend boundary
- smoke proves the metadata manifest plus success and refusal paths

This validates the direction without committing a package API yet.

The important split is intentional:

- durable shape: `contract :Reminder do persist... field... end`
- generated API: `all`, `find`, `save`, `update`, `delete`, `clear`
- append-only shape: `contract :TrackerLog do history... field... end`
- history API: `append`, `all`, `where`, `count`
- projection: UI read models can compose `Store[Tracker]` plus
  `History[TrackerLog]` through a derived contract
- receipts: command/user/runtime outcomes can be modeled as `History[Action]`
- activity feeds: receipt history can project into UI and audit summaries
- behavior: graph command contracts compute validation, result, receipt, and
  mutation intent
- boundary: Store/app adapter applies the mutation

The package-level design should preserve that split unless repeated Companion
pressure shows that one surface can stay readable while expressing both.

`TrackerLog` surfaced an important storage-shape distinction: Companion used to
store logs nested under trackers, but the capability wants to reason over a
first-class append-only stream. The POC now stores tracker logs top-level and
projects them into tracker read models for the UI. That is a useful pressure
signal for `History[T]`: history may project into records, but it should not be
reduced to mutable record CRUD.

The tracker slice now shows the intended composition: the tracker definition is
record-like, while tracker observations are append-only. The dashboard can still
render one tracker card with recent entries, but that card is a projection from
two storage capabilities rather than a single procedural object.

Daily focus adds a workflow/session-shaped record: it is not a catalog entity,
but a date-keyed piece of daily state. This confirms `Store[T]` should cover
small durable app/session records as well as obvious entities.

This makes projections a first-class design concern: record/history capabilities
own durable data, while derived contracts compute read models and summary facts
for product surfaces.

Action receipts are also history-shaped. They are not the same domain stream as
tracker measurements, but they share append-only semantics and query needs:
activity feeds, audit trails, command receipts, and later workflow replay.

As with tracker logs, receipt history should feed projections rather than leak
directly into UI code. `ActivityFeedContract` is the Companion proof that even
small read models can stay graph-owned.

As the app-local shapes repeat, Store should stop manually assembling them.
`CompanionPersistence` is the current proof of a future registry/factory layer:
contract manifests plus app storage bindings produce capability objects and
projection entry points.

## Near-Term Plan

1. Keep persisted-contract experiments app-local in Companion.
2. Keep `ContractRecordSet` app-local until another entity repeats the same
   useful CRUD shape.
3. Keep `ContractHistory` app-local until another signal/log repeats the same
   useful append-only shape.
4. Add one more persisted shape only if it tests a new semantic category.
5. Compare record contracts, command contracts returning mutation intent, and
   event-log contracts plus projections.
6. Promote a package experiment only after at least two Companion entities repeat
   the same useful shape.

## Non-Goals

- no stable public API yet
- no migration generator
- no production database abstraction
- no multi-backend guarantee beyond experiments
- no implicit secret persistence
- no igniter-lang syntax promotion
- no automatic distributed placement

## Related

- [Store Adapters](../guide/store-adapters.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
