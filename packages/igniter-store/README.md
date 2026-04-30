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

## Open Pressure (Tier 2 remaining / Tier 3)

| Pressure | Status | Description |
|----------|--------|-------------|
| `scope_materialized_index` | ✅ done | per-scope Set index, O(1) query |
| `scope_aware_invalidation` | ✅ done | suppress unchanged scope consumers |
| `history_partition_index` | ✅ done | `History[T]` partition index, O(partition slice) query |
| `read_cache_lru_cap` | open | time-travel cache entries never evicted; needs LRU capacity limit |
| `schema_version_hook` | open | `schema_version` field on Fact is inert; read path needs a coercion hook point |
| `snapshot_checkpoint` | open | WAL replay is O(total facts); needs snapshot + replay-since-checkpoint for fast startup |

---

## Research Track

- [Contract-Native Store Research](../../docs/research/contract-native-store-research.md)
- [Contract-Native Store POC](../../docs/research/contract-native-store-poc.md)
- [Contract-Native Store Sync Hub](../../docs/research/contract-native-store-sync-hub.md)
- [Contract Persistence Development Track](../../docs/research/contract-persistence-development-track.md)
