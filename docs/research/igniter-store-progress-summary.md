# Igniter Store Progress Summary

Status date: 2026-04-30.
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
  -> optional snapshot checkpoint in Ruby fallback
  -> Rust tier pending snapshot parity
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
- File durability moved from old JSONL POC thinking to CRC32-framed WAL.
- Ruby fallback supports snapshot checkpoint/replay; Rust/native tier has this
  as explicit pending pressure.

## Current Test Signal

- `packages/igniter-store`: 60 examples, 0 failures, 6 pending.
- Pending items are expected Rust snapshot parity gaps:
  `FactLog#all_facts` and `FileBackend#write_snapshot`.
- `packages/igniter-companion`: 47 examples, 0 failures.

## Architecture Meaning

`igniter-store` is now best understood as the hot fact engine:

- not an ORM
- not a DB adapter abstraction
- not the public contract persistence API
- yes: append-only truth, time travel, causation, access paths, cache
  invalidation, and hot/cold sync foundation

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

`docs/research/contract-native-store-poc.md` is useful historical context but is
stale in details: it still describes JSON-Lines WAL and value-hash causation in
some sections. The current package README and specs are the canonical Store POC
state until that older POC document is rotated or compacted.

## Next Pressure

Immediate package-facing pressure from Companion is still:

```text
index_metadata
  -> mirror manifest indexes as generated Record metadata
  -> no SQL index promise
  -> no adapter migration
  -> keep scopes as access paths
```

Store-side pressure after index metadata:

- expose a compact access-path metadata snapshot from `SchemaGraph`
- decide whether index descriptors remain facade metadata or become explicit
  `AccessPath` metadata
- finish Rust snapshot parity (`all_facts`, `write_snapshot`)
- keep PostgreSQL sync hub as cold/async circuit, not write-path dependency
