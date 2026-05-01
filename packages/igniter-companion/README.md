# igniter-companion

Application-level Record/History DSL backed by `igniter-store`.

## Purpose

This package is the **consumer of `igniter-store` from application code**.

It serves two goals:

1. **User-facing surface** — shows what working with facts looks like from contract/application code: typed `Record` objects, append-only `History` streams, scope queries, and reactive subscriptions.

2. **Pressure on the core** — every new capability at this level surfaces gaps, friction, or bugs in `igniter-store`. This is intentional. Insights are recorded in the [Pressure & Insights](#pressure--insights) section below.

### The Tunnel Metaphor

```
examples/application/companion   ←── app-level contracts, manifests, materializer
                   │
                   │  digging toward each other
                   ▼
  packages/igniter-companion      ←── typed DSL on top of igniter-store
                   │
                   ▼
  packages/igniter-store          ←── facts, WAL, scope, reactive (Rust/Ruby FFI)
```

**Convergence point**: when `PersistenceSketchPack` in `examples/application/companion`
drives its records through `Igniter::Companion::Store` instead of blob-JSON in SQLite.

## Docs

See [`docs/`](docs/) for status summaries, manifest glossary, and performance signals:

- [docs/current-status.md](docs/current-status.md) — current implementation status
- [docs/app-status.md](docs/app-status.md) — app-local persistence proof status
- [docs/manifest-glossary.md](docs/manifest-glossary.md) — persistence manifest glossary
- [docs/performance.md](docs/performance.md) — contract performance signal notes

---

## Architecture

```
lib/igniter/companion/
  record.rb    — Record mixin: store_name, field, scope DSL → typed objects
  history.rb   — History mixin: history_name, field → append-only events
  store.rb     — Store: register, write, read, scope, append, replay, on_scope
```

### `Record`

Wraps `Store[T]` from igniter-store. The latest written value is the current state.

```ruby
class Reminder
  include Igniter::Companion::Record
  store_name :reminders

  field :title
  field :status, default: :open
  field :due,    default: nil

  scope :open, filters: { status: :open }
  scope :done, filters: { status: :done }, cache_ttl: 30
end
```

### `History`

Wraps `History[T]` from igniter-store. Append-only; keys are auto-generated.

```ruby
class TrackerLog
  include Igniter::Companion::History
  history_name :tracker_logs
  partition_key :tracker_id   # enables partition replay

  field :tracker_id
  field :value
  field :notes, default: nil
end
```

### `Store`

Orchestrator — holds the `IgniterStore` instance, knows about registered schemas.

```ruby
store = Igniter::Companion::Store.new            # in-memory (default)
store = Igniter::Companion::Store.new(           # file-backed WAL
  backend: :file,
  path:    "/tmp/companion.wal"
)

store.register(Reminder)   # registers an AccessPath for each declared scope

store.write(Reminder, key: "r1", title: "Buy milk", status: :open)
store.read(Reminder,  key: "r1")                 # => #<Reminder key="r1" ...>
store.scope(Reminder, :open)                     # => [#<Reminder ...>, ...]
store.scope(Reminder, :open, as_of: checkpoint)  # time-travel

store.append(TrackerLog, tracker_id: "t1", value: 8.5)
store.replay(TrackerLog)                         # => [#<TrackerLog ...>, ...]
store.replay(TrackerLog, since: cutoff)          # time-filtered
store.replay(TrackerLog, partition: "sleep")     # filtered by partition_key value

store.causation_chain(Reminder, key: "r1")       # mutation chain for debugging
```

### Normalized receipts

`write` and `append` return receipt objects carrying mutation metadata.
They delegate unknown methods to the underlying record/event:

```ruby
receipt = store.write(Reminder, key: "r1", title: "Buy milk")
receipt.mutation_intent          # => :record_write
receipt.fact_id                  # => "550e8400-..."
receipt.value_hash               # => "a3b1c2..."
receipt.causation                # => nil (first write) or previous value_hash
receipt.title                    # => "Buy milk"  (delegated to Reminder)
receipt.record                   # => #<Reminder ...>

receipt = store.append(TrackerLog, tracker_id: "sleep", value: 8.5)
receipt.mutation_intent          # => :history_append
receipt.timestamp                # => 1714483200.123
receipt.value                    # => 8.5  (delegated to TrackerLog)
receipt.event                    # => #<TrackerLog ...>
```

### Reactive subscriptions

```ruby
store.on_scope(Reminder, :open) do |store_name, scope|
  # fires when the scope cache is invalidated by a write
  puts "#{store_name}/#{scope} changed — refresh your view"
end
```

The subscriber is **not** called on every write — only when the scope cache was
warmed by a prior query and then invalidated by the next write. This is the
lazy-invalidation semantics from igniter-store (see [Insights](#pressure--insights)).

---

## Running tests

```bash
# Compile igniter-store first (once):
cd ../igniter-store
PATH="$HOME/.cargo/bin:$PATH" bundle exec rake compile

# Run the companion suite:
cd ../igniter-companion
bundle exec rake spec
```

---

## Pressure & Insights

This section is a living log. Every time the companion layer surfaces a mismatch
or bug in the underlying store, it is recorded here with date, symptom, root cause,
fix, and lesson learned.

---

### [2026-04-30] Float coercion in `ruby_to_json_inner`

**Symptom**: a test storing `TrackerLog#value = 7.0` received Integer `7` back.

**Root cause**: `fact.rs` used `i64::try_convert(val)` to detect numeric type.
Magnus routes this through Ruby's `to_i` coercion protocol, so `Float(7.0).to_i`
returns `7`, and `Float(8.5).to_i` returns `8`.

**Fix** (in `igniter-store/ext/igniter_store_native/src/fact.rs`):
```rust
// Before (inaccurate — coerces Float via to_i):
if let Ok(i) = i64::try_convert(val) { return serde_json::json!(i); }
if let Ok(f) = f64::try_convert(val) { return serde_json::json!(f); }

// After (exact Ruby type check):
if let Some(int) = RbInteger::from_value(val) {
    if let Ok(n) = int.to_i64() { return serde_json::json!(n); }
}
if let Some(flt) = RbFloat::from_value(val) {
    return serde_json::json!(flt.to_f64());
}
```

**Lesson**: Magnus's `T::try_convert` goes through Ruby's coercion protocol.
Use `RbInteger::from_value` / `RbFloat::from_value` for exact type dispatch.

---

### [2026-04-30] Lazy scope cache invalidation semantics

**Observation**: `on_scope` consumer does not fire on the first write — only after
the scope cache has been warmed by a query.

**This is intentional**: `ReadCache` removes scope entries on invalidation, but if
the cache is cold there is nothing to remove and therefore no entries → no notifications.

**Implication for companion**: `on_scope` should be documented as
"notification of a warmed-cache change", not "notification of every mutation".
For reacting to every mutation regardless of cache state, a different mechanism
is needed (event bus / WAL tail).

**Open question for igniter-store**: should `AccessPath` support an `eager: true`
option that registers the consumer as a point-write listener independent of
cache state?

---

### [2026-04-30] History partition queries

**Capability added**: `partition_key :field_name` on a `History` class; `Store#replay(partition: "value")` filters events by that field.

**Implementation**: partition key lives in the value payload (not in the fact key), so filtering happens at the Ruby layer after `@inner.history(...)` returns all events for the store. No new `AccessPath` registration required.

**Convergence check**: `history_partition_query` check in `StoreConvergenceSidecarContract` passes with `partition_replay_count == 2` and `partition_replay_values == [7.0, 8.5]`.

---

### [2026-04-30] Normalized store receipts (`WriteReceipt` / `AppendReceipt`)

**Capability added**: `Store#write` returns a `WriteReceipt`; `Store#append` returns an `AppendReceipt`. Both carry `mutation_intent`, `fact_id`, `value_hash` and delegate unknown methods to the wrapped record/event.

**Pressure surfaced**: the raw `IgniterStore` returns a `FactData`-like object with `id`/`value_hash`/`causation`/`timestamp`. Wrapping this in typed receipts at the companion layer avoids leaking store internals into application code.

**Next open question** (`pressure.next_question`): `:manifest_generated_record_history_classes` — auto-generate `Record`/`History` classes from a `persistence_manifest` declaration without committing to a final DSL.

---

### [2026-04-30] Manifest-generated Record/History classes

**Capability added**: `Igniter::Companion.from_manifest(manifest, store:)` generates an anonymous `Record` or `History` class from an app-local `persistence_manifest` hash. Dispatches on `manifest[:storage][:shape]` (`:store` → `Record`, `:history` → `History`).

```ruby
# From an app-local Igniter contract that declares `persist :reminders`:
klass = Igniter::Companion.from_manifest(
  Companion::Contracts::Reminder.persistence_manifest,
  store: :reminders
)
# klass includes Record, has all fields + scopes declared

klass = Igniter::Companion.from_manifest(
  Companion::Contracts::TrackerLog.persistence_manifest,
  store: :tracker_logs
)
# klass includes History, has partition_key + all fields
```

**What gets generated from the manifest**:
- Fields: `name` + `default:` (if `attributes[:default]` present)
- Scopes (Record only): `name` + `filters:` (from `attributes[:where]`)
- Partition key (History): `history.key` falling back to `storage.key`

**This gap was resolved immediately**: see next entry.

---

### [2026-04-30] Store name in manifest (`storage.name`)

**Gap resolved**: `persistence_manifest_for` now derives the store name from the contract class name via snake_case + naive pluralisation (`Reminder` → `:reminders`, `TrackerLog` → `:tracker_logs`) and includes it as `storage[:name]`.

```ruby
manifest[:storage]  # => { shape: :store, name: :reminders, key: :id, adapter: :sqlite }
```

**`from_manifest` is now zero-argument for the store name**:

```ruby
klass = Igniter::Companion.from_manifest(Contracts::Reminder.persistence_manifest)
klass.store_name  # => :reminders  (from manifest)

klass = Igniter::Companion.from_manifest(manifest, store: :override)
klass.store_name  # => :override  (explicit wins)
```

Raises `ArgumentError` if manifest has no `storage.name` and `store:` is not given — keeps the old API path working.

**Next open question** (`pressure.next_question`): `:companion_store_backed_app_flow` — wire `Igniter::Companion::Store` into the actual app layer so `persist :reminders` flows through facts/WAL instead of blob-JSON/SQLite.

---

### [2026-04-30] Portable field types

**Capability added**: `field` DSL now accepts `type:` and `values:` kwargs. `from_manifest` mirrors them from `attributes[:type]` and `attributes[:values]` in the manifest descriptor.

```ruby
# Hand-written:
field :status, type: :enum, values: %i[open done], default: :open
field :title,  type: :string
field :score,  type: :float

# Generated from manifest (Article contract with typed fields):
klass = Igniter::Companion.from_manifest(Contracts::Article.persistence_manifest)
klass._fields[:status]  # => { type: :enum, values: [:draft, :published, :archived],
                         #      default: :draft }
klass._fields[:title]   # => { type: :string, values: nil, default: nil }
```

**Supported vocabulary** (mirrors app-local `PersistenceFieldTypePlanContract`):
`:string`, `:integer`, `:float`, `:boolean`, `:datetime`, `:enum`, `:json`, `:unspecified` / nil (no-op)

**Annotation only**: `type:` is stored as metadata in `_fields` but does not coerce values during read. Coercion is a separate future concern.

**Evidence**: app-flow sidecar 13/13 stable — `typed_fields_mirrored`, `enum_values_mirrored`, `typed_record_round_trip` all pass.

**Next open question** (`pressure.next_question`): `:mutation_intent_to_app_boundary` — should `WriteReceipt.mutation_intent` feed the app-local action history model directly, or does it need a projection layer?

---

### [2026-04-30] Mutation intent to app boundary

**Capability proven**: `[Architect Supervisor / Codex]` implemented `CompanionReceiptProjectionSidecar` on the app side, proving the projection pattern 12/12 stable.

**Answer**: A projection layer is required. `WriteReceipt` does NOT flow directly to action history. Instead:

```ruby
# Package receipt (internal)
receipt = store.write(reminder_class, ...)
# receipt.mutation_intent  => :record_write
# receipt.fact_id          => "uuid..."      ← NOT exposed upward
# receipt.value_hash       => "blake3..."    ← NOT exposed upward

# App projection (boundary pattern)
app_receipt = {
  kind:              :store_write_receipt,
  source:            :igniter_companion_store,
  target:            :reminders,
  subject_id:        "reminder-1",
  status:            :recorded,
  mutation_intent:   receipt.mutation_intent,   # ← preserved
  store_fact_exposed:  false,
  value_hash_exposed:  false
}
# action_event shape → { index:, kind:, subject_id:, status: :recorded }
```

**Boundary**: `fact_id` and `value_hash` are store internals — they stop at the package boundary. `mutation_intent` crosses the boundary because it describes the operation semantics, not the storage internals.

**Evidence**: `companion_receipt_projection_sidecar` 12/12 checks stable (`strategy: :small_app_receipt`).

**Next open question** (`pressure.next_question`): `:index_metadata` — should index declarations from the manifest (unique, composite) be mirrored into the generated class descriptor?

---

### [pending] `nil` vs absent field semantics on read

**Hypothesis** (untested): if a field was not stored in the value hash (e.g. an
optional field added after the first writes), `Record#initialize` applies the
`default:` from the declaration. But if `nil` was explicitly written, `nil` is
returned rather than the default. The distinction between *absent* and *explicitly nil*
is not currently modelled. Worth testing and potentially encoding as a separate concept.

---

### [pending] Nested Hash values

The current DSL has no nested type declarations. For example:

```ruby
field :address  # { city: "Moscow", zip: "101000" }
```

After a round-trip through igniter-store the keys are Symbols (`:city`, `:zip`).
This is correct. But there is no way to declare the structure of the nested object.
Candidate for a future DSL addition: `embedded :address do ... end`.

---

### [pending] Convergence with `examples/application/companion`

The current `CompanionStore` in `examples/application/companion/services/companion_store.rb`
uses blob-JSON over SQLite. The target path:

```
PersistenceSketchPack (DSL: persist/history/field/scope)
  → generates Record/History classes
  → stores via Igniter::Companion::Store
  → backed by Igniter::Store::IgniterStore (facts + WAL)
```

When the first real `persist :reminders` flows through this stack end-to-end,
the two tunnels will meet.
