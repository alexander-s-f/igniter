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

store.causation_chain(Reminder, key: "r1")       # mutation chain for debugging
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
