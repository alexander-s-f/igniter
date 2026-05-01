# Igniter Store Progress Summary

Status date: 2026-05-01.
Audience: Architect Supervisor, Package Agent, Research.
Scope: compact checkpoint for `packages/igniter-store` and its pressure on
`igniter-companion` / Companion.

## Read Model

```text
Store[T] record write
  -> immutable Fact(id, store, key, value, value_hash, causation, timestamp)
  -> FactLog append
  -> current read / time-travel read
  -> scope query via registered AccessPath
  -> scope cache invalidation + scope-aware consumers

History[T] append
  -> immutable Fact(key=uuid, value=event)
  -> replay all / replay partition
  -> partition index when partition_key is known

File backend
  -> CRC32-framed WAL
  -> snapshot checkpoint/replay support

Network backend
  -> CRC32-framed request/response transport
  -> StoreServer owns durable facts
  -> clients replay facts and rebuild local read indices
  -> native-aware Fact.from_h deserialisation path
```

## What Is Strong Now

- Facts are immutable and content-addressed by `value_hash`.
- Causation uses previous fact `id`, not `value_hash`, so repeated identical
  writes still produce an unambiguous temporal chain.
- Current reads and time-travel reads are structural features, not app-local
  patches.
- Scope access paths are registered ahead of data and backed by a lazy
  materialized scope index.
- Scope invalidation is membership-aware: unchanged scope membership suppresses
  false-positive consumers.
- History partition replay is backed by a lazy partition index and maintained on
  append when `partition_key:` is passed.
- Time-travel cache entries have an LRU cap; current-state cache entries remain
  invalidation-driven.
- Schema version coercion exists as a read-path hook; raw facts are never
  mutated.
- `SchemaGraph#metadata_snapshot` exposes compact access-path routing metadata
  without leaking callback bodies or promising a query planner.
- `SchemaGraph` now also registers projection descriptors and derivation rules
  as inspectable metadata, still without becoming a query planner.
- `ProjectionPath` mirrors app projection descriptors into Store-side graph
  vocabulary.
- `DerivationRule` proves the first reactive derivation shape with a lineage
  API and causation proof hash.
- `ScatterRule` adds partitioned 1-source to 1-index-entry derivations for
  relation/read-model indexes, with cycle protection separate from gather rules.
- `RetentionPolicy` and `compact` add first hot-log lifecycle control:
  permanent, ephemeral, and rolling-window retention with compaction receipts.
- File durability moved from old JSONL POC thinking to CRC32-framed WAL.
- Snapshot checkpoint/replay exists across the current Ruby/native-aware package
  surface.
- `NetworkBackend` + `StoreServer` prove the first transport abstraction:
  app/client code can talk to a remote durable fact host through the same
  backend interface.
- `WireProtocol` is now shared framing vocabulary for WAL and network transport.
- The server model keeps contract computation in the app and moves durable fact
  projection to the store server.

## Current Test Signal

- `packages/igniter-store`: 200 examples, 0 failures.
- `packages/igniter-companion`: 47 examples, 0 failures.

## Architecture Meaning

`igniter-store` is now best understood as the hot fact engine:

- not an ORM
- not a DB adapter abstraction
- not the public contract persistence API
- yes: append-only truth, time travel, causation, access paths, cache
  invalidation, hot/cold sync foundation, retention/compaction, and now a first
  store-server transport path

`igniter-companion` is the typed facade:

- maps app/contract manifests to Record/History classes
- turns raw store facts into typed records/events and normalized receipts
- should keep package receipts from leaking fact internals into app history

Companion app-local proof is the product pressure:

- asks for manifest-generated classes
- asks for portable field metadata
- asks for index metadata
- asks later for command/effect metadata and relation metadata

## Important Drift Note

Older thread references to `docs/research/contract-native-store-poc.md` are
historical context only. The current package README and specs in
`packages/igniter-store/docs/` are the canonical Store POC state.

## Next Pressure

Immediate package-facing pressure from Companion is now:

```text
projection_descriptor_mirroring
  -> closed: app-local Companion projection descriptors now mirror through
     igniter-companion into Store SchemaGraph projection_snapshot
  -> /setup/companion-store-schema-graph-metadata-sidecar.json now proves
     app scope access paths lower to Store SchemaGraph metadata_snapshot
  -> no query planner or adapter projection execution yet
  -> keep projections inspectable above Store[T] / History[T]

reactive_derivation
  -> active: prove whether projection/read-model updates can lower to
     derivation metadata and normalized operation intent
  -> Store already has DerivationRule, ScatterRule, derivation_snapshot,
     scatter_snapshot, retention_snapshot, and lineage(...)
  -> next app pressure should avoid moving business contract logic into Store
```

Store-side pressure after index metadata:

- keep `SchemaGraph#metadata_snapshot` as metadata evidence, not a planner API
- decide whether index descriptors remain facade metadata or become explicit
  `AccessPath` metadata
- use `/setup/companion-store-server-topology-sidecar.json` as app-local pressure
  when discussing StoreServer topology from Companion
- StoreServer has moved from transport proof to operational proof:
  `ServerConfig`, `ServerLogger`, `SubscriptionRegistry`,
  `igniter-store-server`, `wait_until_ready`, graceful drain, `stats`, and
  `subscribe/fact_written`; Companion should treat this as lifecycle/delivery
  capability, not as a contract-logic RPC surface
- finish true native fact reconstruction if stable `id` / `timestamp` fidelity
  becomes required over the network
- keep `NetworkBackend` as a transport/backend swap, not as RPC for contract
  logic
- keep PostgreSQL sync hub as cold/async circuit, not write-path dependency
