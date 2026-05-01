# igniter-store

Experimental contract-native store package for Igniter.

Status: POC package, not stable API, not wired into core.

## Owns

- immutable content-addressed facts
- append-only `Store[T]` and `History[T]` fact log experiments
- causation chains (fact-id–based, unambiguous)
- current and time-travel reads
- reactive cache invalidation
- compile-time access path registry experiments
- WAL with CRC32-framed durability

## Does Not Own

- contract DSL integration
- core graph node types
- SQL schema generation
- migration execution
- PostgreSQL sync hub implementation
- cluster consensus
- materializer execution

## Docs

See [`docs/`](docs/) for specifications, progress records, and design iteration history:

- [docs/poc-specification.md](docs/poc-specification.md) — POC spec
- [docs/server-model.md](docs/server-model.md) — StoreServer + NetworkBackend design
- [docs/relations-specification.md](docs/relations-specification.md) — relation manifests
- [docs/progress.md](docs/progress.md) — progress summary
- [docs/research/](docs/research/) — design iteration history

## Why `igniter-store`

This package is broader than persistence. The research direction includes
time-travel, reactive agents, access paths, hot/cold sync, retention, and future
cluster replay. `igniter-persistence` remains reserved for stable durable
capability APIs if they later emerge from this work.

## Example

```ruby
require "igniter-store"

store = Igniter::Store::IgniterStore.new

store.write(
  store: :reminders,
  key: "r1",
  value: { title: "Buy milk", status: :open }
)

store.read(store: :reminders, key: "r1")
```

Run the POC smoke:

```bash
ruby -I packages/igniter-store/lib packages/igniter-store/examples/store_poc.rb
```

Run package specs:

```bash
bundle exec rspec packages/igniter-store/spec
```

## Model Decisions & Pressure Log

### [2026-04-30] Causation: fact.id, not fact.value_hash

**Change**: `IgniterStore#write` now sets `causation: previous&.id` (UUID) instead
of `causation: previous&.value_hash`.

**Why**: `value_hash` is a *content address* — it identifies what a fact *contains*.
`causation` is a *temporal pointer* — it identifies which fact *came before*. Using
`value_hash` for causation creates an ambiguous chain: if the same value is written
twice, `f2.causation == f2.value_hash` (self-referential), and following the chain
by hash lookup returns multiple candidates. `fact.id` (UUID) is an unambiguous
pointer to one specific event.

**Impact on consumers**: `causation_chain` entries now include `id:` and show the
full UUID causation instead of a truncated hash prefix. The companion package
passes `causation_chain(...).length` — count is unaffected.

**Candidate pressure on `igniter-companion`**: the `WriteReceipt` currently
forwards `fact.causation` to app receipts. Now causation is a UUID; if the app
ever exposes it, document as a temporal pointer to a fact identity, not a content
address.

---

### [2026-04-30] WAL format v2: length-prefix + CRC32 framing

**Change**: `FileBackend` replaced JSON-Lines (`puts + readlines`) with a binary
framed format:

```
[4-byte BE uint32: body_len][body_len bytes: JSON][4-byte BE uint32: CRC32(body)]
```

**Why**: JSON-Lines is silently lossy on truncation. A process killed mid-`puts`
leaves a partial line that is indistinguishable from a valid-but-empty line, and
was previously dropped with `rescue JSON::ParserError` — the write appeared
committed but the fact was lost on replay.

The framed format makes truncation *detectable*: a partial frame has a wrong or
missing CRC. Replay stops at the first integrity failure and returns all facts
from complete frames. The last incomplete frame is treated as an uncommitted write.

**Breaking change**: existing v1 JSONL WAL files are not readable by the v2 reader.
This is acceptable at POC stage. A migration path (detect v1 by absence of valid
frame header, warn and skip) can be added under app pressure.

**Candidate pressure on Rust FileBackend** (from plan): the planned Rust FileBackend
uses MessagePack + CRC32 — same framing principle, binary body instead of JSON.
The v2 Ruby format is a stepping stone to that target; the framing structure is
intentionally compatible.

---

### [2026-04-30] Materialized scope index + scope-aware invalidation

**Change**: `IgniterStore` now maintains a per-scope materialized index in
`@scope_index: { [store, scope] => Set<key> }`, initialized lazily on the
first `query` call for each scope and maintained on every subsequent `write`.

**Before**: `query_scope` scanned O(all keys in store) on every call.  Any write
to a store invalidated ALL scope caches and notified ALL scope consumers —
a thundering herd even when the write touched an unrelated scope.

**After**:
- `query` (non–time-travel): O(matched keys) — reads the Set, fetches latest fact
  per key.  Full scan only on the very first call.
- `write` evaluates scope predicates for the written key only, updating the Set
  in O(registered scopes) per write.
- `ReadCache.invalidate` now accepts `scope_changes: { scope => :changed | :unchanged | :unknown }`.
  Consumers are skipped for `:unchanged` scopes — their membership did not change.
  `:unknown` (index not yet warm) fires conservatively; `:changed` fires normally.

**Time-travel** (`as_of:` non-nil) bypasses the scope index and still does a full
log scan — the index reflects current state only.

**Evidence**: 8 new specs covering index accuracy, lazy init, scope entry/exit,
and suppressed false-positive notifications.

---

### [2026-04-30] History partition index

**Change**: `IgniterStore` now maintains a per-(store, partition_key) materialized index
`@partition_index: { [store, partition_key] => { partition_value => [fact, ...] } }`.
A new `#history_partition` method provides O(partition slice) reads instead of O(total events).
`#append` accepts an optional `partition_key:` parameter; when provided and the index is warm,
the new fact is appended to the correct partition bucket in O(1).

**Before**: `Companion::Store#replay(partition:)` called `@inner.history(...)` (full scan of
all events in the store), then filtered in Ruby. For a store with N total events split across P
partitions, each `replay` was O(N) regardless of partition size.

**After**:
- First `history_partition` call for a (store, partition_key) pair: O(N) full scan that builds
  the index — one-time cost identical to the old path.
- Subsequent `history_partition` calls: O(partition slice) — read the pre-grouped bucket directly.
- New `append` calls: O(1) bucket append when the index is already warm.
- `since:` / `as_of:` time filters applied at read time over the cached slice; they do NOT
  prevent the index from being used.

**Companion impact**: `Companion::Store#append` now passes `partition_key: history_class._partition_key`
to `@inner.append`; `#replay(partition:)` delegates to `@inner.history_partition` when a
partition key is declared. The public API of Companion is unchanged.

**Index correctness edge**: appends without `partition_key:` (or where the event does not
contain the partition field) do NOT update the index. The caller is responsible for passing
`partition_key:` consistently — Companion always does so via `_partition_key`.

---

### [2026-04-30] Read cache LRU cap for time-travel entries

**Change**: `ReadCache` now accepts `lru_cap:` (default: 1 000). All time-travel
cache entries — point reads and scope reads with `as_of: non-nil` — are tracked
in an ordered `@lru_order` hash and evicted LRU when the count exceeds the cap.

**Before**: every unique `as_of` timestamp produced a permanent cache entry.
A workload running time-travel queries across N timestamps (e.g. animation,
audit replay) would accumulate O(N) entries that were never freed, growing
unboundedly until the process restarted.

**After**:
- Time-travel entries are evicted LRU when `@lru_order.size > lru_cap`.
- Accessed entries are promoted to MRU (delete + reinsert in the ordered hash)
  so frequently re-read checkpoints are not the first to be evicted.
- Current-state entries (`as_of: nil`) are **not** counted against the LRU cap
  and are never evicted by this mechanism — they live until `invalidate` is
  called by a normal write, which is the correct existing behaviour.
- `invalidate` removes evicted keys from `@lru_order` so the tracker stays
  consistent when writes race with time-travel reads.

**Tuning**: pass `lru_cap:` to `IgniterStore.new` or `IgniterStore.open` to
override the default. Example: `IgniterStore.new(lru_cap: 5_000)`.

**Candidate pressure on igniter-companion**: `Companion::Store.new` could
expose `lru_cap:` as a top-level option and forward it to the inner store.
Not done here — defer under app pressure.

---

### [2026-04-30] Schema version coercion hook

**Change**: `IgniterStore#register_coercion(store_name) { |value, schema_version| ... }` registers
a read-path migration block. On every read — `read`, `time_travel`, `query`, `history`,
`history_partition` — the block is called with the raw stored value and its `schema_version`.
The return value replaces the value seen by the caller. Raw facts are never mutated.

When a coercion changes the value, the fact is wrapped in a `CoercedFact` struct that
delegates all identity fields (`id`, `key`, `timestamp`, `causation`, `value_hash`,
`schema_version`) to the underlying fact. If the coercion returns the same object
(`equal?`), the original fact is returned unchanged (zero allocation on no-op coercions).

**Why on the read path, not write path**: the schema_version field was written at insert time
and is correct for that version. Mutating facts on write would require migrating all existing
WAL entries and invalidating causation chains. A read-path transform is zero-cost for
unchanged facts and allows progressive migration.

**Pattern — field rename across schema versions**:
```ruby
store.register_coercion(:tasks) do |value, schema_version|
  next value if schema_version >= 2
  # v1 stored :title; v2 renamed to :name
  value.merge(name: value.delete(:title))
end
```

**Candidate pressure on igniter-companion**: `Companion::Store` should expose
`register_coercion` as a passthrough to the inner store, possibly mapped from
schema class migration declarations. Not done here — defer under app pressure.

---

### [2026-04-30] Snapshot checkpoint

**Change**: `IgniterStore#checkpoint` writes all current facts from `FactLog#all_facts`
to a snapshot file (`<wal_path>.snap`) via `FileBackend#write_snapshot`. On subsequent
`IgniterStore.open`, `FileBackend#replay` loads the snapshot first, deduplicates WAL
facts by ID against the snapshot set, and returns `snapshot_facts + delta_wal_facts`
sorted by timestamp. Startup cost is O(snapshot_size + delta) instead of O(total_facts).

**Snapshot file format** (`<wal_path>.snap`):
```
[header frame: JSON { type: "snapshot_header", fact_count: N, written_at: T }]
[fact frame 1] ... [fact frame N]
```
Same CRC32-framed format as the WAL — a corrupt snapshot is detected by a bad CRC on
the header frame and the backend falls back to full WAL replay automatically.

**Atomicity**: `write_snapshot` writes to a `.tmp` file and renames atomically, so a
process kill mid-checkpoint never corrupts an existing snapshot.

**Deduplication**: WAL facts whose `id` is already in the snapshot set are skipped,
not by byte offset or fact count. This tolerates WAL facts that were written
concurrently with snapshot creation.

**Scope / partition indices**: not included in the snapshot — they are rebuilt lazily on
first query after reopen, which is already the lazy-init behaviour.

**Availability**:
- Ruby fallback (`NATIVE = false`): fully implemented and tested (6 specs).
- NATIVE (`NATIVE = true`): Rust `FactLog` does not yet expose `all_facts` — `checkpoint`
  is a no-op. `FileBackend#write_snapshot` is also not implemented in the Rust backend.
  Both are candidate pressures for the Rust tier.

**Candidate pressure on Rust backend**:
- `RubyFactLog`: add `all_facts()` → `Vec<RubyFact>` method exposed to Ruby
- `RubyFileBackend`: add `write_snapshot(facts)` using the same frame format (body = MessagePack)
- Match the snapshot header record structure so Ruby-written snapshots are readable by Rust and vice versa

---

### [2026-04-30] NetworkBackend + StoreServer (Phase 1 transport abstraction)

**Change**: Three new pure-Ruby classes implement the first step of the client-server
projection model:

- `WireProtocol` — shared CRC32-framed encoding module (included by `FileBackend`,
  `NetworkBackend`, and `StoreServer`).
- `NetworkBackend` — client-side backend implementing the same `write_fact` / `replay` /
  `write_snapshot` interface as `FileBackend`, but transmitting calls over a TCP or
  Unix socket connection.
- `StoreServer` — minimal TCP/Unix server wrapping durable storage (`:memory` or `:file`).
  Each incoming connection is handled in a separate thread; writes are serialised by
  `@write_mutex`; reads snapshot `@in_memory_facts` under the same lock.

**Usage** — swap the backend without changing application code:

```ruby
# Server process (or background thread)
server = Igniter::Store::StoreServer.new(
  address: "127.0.0.1:7400", backend: :file, path: "/var/lib/igniter/store.wal"
)
server.start_async

# Application process — identical API to :memory and :file
store = Igniter::Companion::Store.new(
  backend: :network, address: "127.0.0.1:7400"
)
store.register(Task)
store.write(Task, key: "t1", title: "Hello", status: :open)
```

**Wire protocol**: CRC32-framed JSON, one request frame + one response frame per RPC.
Reuses the same framing as the WAL file format — the same `WireProtocol` module is
shared across both, ensuring consistency.

**Replay on reconnect**: a new `NetworkBackend` client sends a `replay` request on
first use (explicitly called by `Companion::Store.new(backend: :network)`).  The
`IgniterStore` on the client side rebuilds all in-memory indices (scope index,
partition index, cache) from the replayed facts — identical to the `:file` path.

**Availability**:
- Ruby fallback (`NATIVE = false`): fully implemented. 8 specs (all skipped when NATIVE).
- NATIVE (`NATIVE = true`): `NetworkBackend` and `StoreServer` both have NATIVE guards —
  they are skipped because `Fact.new(**h)` is not available with the Rust extension.
  Phase 2 will add Rust-native fact deserialisation.

**Playground**: demo 07 (`07_network.rb`) exercises the full two-client round-trip
(write via client 1, reconnect as client 2, verify fact visibility and scope queries).

**Candidate pressure on Rust backend**:
- `RubyFact`: expose a class-level `deserialize(hash)` method that constructs a Fact
  from existing id/timestamp/value_hash fields (without re-generating them via `build`).
  This is the only blocker for NATIVE NetworkBackend support.

---

## Open Pressure (Tier 2 remaining / Tier 3)

| Pressure | Status | Description |
|----------|--------|-------------|
| `scope_materialized_index` | ✅ done | per-scope Set index, O(1) query |
| `scope_aware_invalidation` | ✅ done | suppress unchanged scope consumers |
| `history_partition_index` | ✅ done | `History[T]` partition index, O(partition slice) query |
| `read_cache_lru_cap` | ✅ done | LRU cap on time-travel cache entries; default 1 000, configurable |
| `schema_version_hook` | ✅ done | `register_coercion` hook; `CoercedFact` wrapper on all read paths |
| `snapshot_checkpoint` | ✅ done (Ruby) | `checkpoint` + snapshot-aware replay; Rust backend is candidate pressure |
| `network_backend_phase1` | ✅ done (Ruby) | `NetworkBackend` + `StoreServer`; pure-Ruby; Rust wire-deserialise is Phase 2 |
| `subscription_registry` | ⬜ planned | Phase 2: `on_scope` → persistent `SubscriptionRecord`; pluggable event-bus adapters |
| `replication_log` | ⬜ planned | Phase 3: append-only replication fan-out; replica bootstrap via snapshot |
| `consistency_annotation` | ⬜ planned | Phase 4: per-store `:strong`/`:eventual` routing in NetworkBackend write path |

---

## Research Track

- [Contract-Native Store Research](docs/research/store-iterations.md)
- [Contract-Native Store POC](docs/poc-specification.md)
- [Contract-Native Store Sync Hub](docs/research/sync-hub-iterations.md)
- [Contract Persistence Development Track](../../docs/research/contract-persistence-development-track.md)
- [Contract-Native Store: Server Model](docs/server-model.md)
