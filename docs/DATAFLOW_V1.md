# Incremental Dataflow — `mode: :incremental`

> **Status**: v1 shipped (2026-04)
> **Require**: `require "igniter/extensions/dataflow"`

---

## Overview

Incremental dataflow adds **O(change)** execution to `collection` nodes.
Instead of re-running every child contract on every `resolve_all`, the runtime:

1. Computes a **Diff** — which item keys were added, removed, or changed since the last call.
2. **Skips** child contracts for unchanged items (reuses cached results).
3. **Retracts** removed items from the result automatically.
4. **Applies sliding-window filtering** before the diff so memory stays bounded.

This is inspired by differential dataflow (Frank McSherry / Materialize) adapted to
Igniter's contract-graph model. It makes sensor pipelines, live analytics, and
event-driven workflows dramatically more efficient without any API changes to the
child contracts.

---

## Quick Start

```ruby
require "igniter/extensions/dataflow"

class SensorAnalysis < Igniter::Contract
  define do
    input  :sensor_id
    input  :value, type: :numeric
    compute :status, depends_on: :value do |value:|
      value > 75 ? :critical : value > 25 ? :warning : :normal
    end
    output :status
  end
end

class SensorPipeline < Igniter::Contract
  define do
    input :readings, type: :array

    collection :processed,
               with: :readings,
               each: SensorAnalysis,
               key:  :sensor_id,
               mode: :incremental,
               window: { last: 1000 }  # optional

    output :processed
  end
end

pipeline = SensorPipeline.new(readings: initial_batch)
pipeline.resolve_all

# Push a diff — only changed sensors re-run
pipeline.feed_diff(:readings,
  add:    [{ sensor_id: "new-1", value: 10 }],
  update: [{ sensor_id: "tmp-2", value: 90 }],
  remove: ["hum-1"]
)
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
diff.added      # => ["new-1"]
diff.changed    # => ["tmp-2"]
diff.removed    # => ["hum-1"]
diff.unchanged  # => ["tmp-1", ...]
diff.processed_count  # => 2  (new-1 + tmp-2)
```

---

## DSL: `collection` with `mode: :incremental`

```ruby
collection :name,
           with: :input_name,   # source input (must be Array)
           each: ChildContract,  # child contract class
           key:  :field_name,    # unique key field in each item Hash
           mode: :incremental,   # enables differential execution
           window: { last: N }   # optional: keep last N items
           # window: { seconds: 60, field: :ts }  # optional: time window
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `with:` | Symbol | yes | Input name that holds the Array |
| `each:` | Class | yes | Child contract class |
| `key:` | Symbol | yes | Hash field used as unique item identifier |
| `mode:` | Symbol | yes | `:incremental` to enable differential execution |
| `window:` | Hash | no | Sliding window filter (see below) |

---

## Sliding Window

The window is applied **before** diff computation, so items outside the window
are treated as if they were never present. This bounds both memory and latency.

### `{ last: N }`

```ruby
window: { last: 500 }
```

Keeps the **last N items** from the input array.

### `{ seconds: N, field: :sym }`

```ruby
window: { seconds: 60, field: :ts }
```

Keeps only items where `item[:ts] >= Time.now - 60`. The `:ts` field must
hold a `Time` object (or something that responds to `>=` for comparison with
`Time.now - N`).

---

## `#feed_diff` — event-style push

Instead of replacing the full input array, push only the delta:

```ruby
contract.feed_diff(:input_name,
  add:    [{ sensor_id: "x", value: 5 }],      # new items
  remove: ["old-sensor"],                        # keys to remove
  update: [{ sensor_id: "tmp-2", value: 90 }]  # replace by key
)
```

`remove:` accepts either **keys** (scalars) or **full Hash items** (the key is
extracted automatically using the collection node's `key_name`).

Returns `self` for chaining.

**Raises** `ArgumentError` when no incremental collection node uses the given input name.

---

## `#collection_diff` — inspect what changed

```ruby
diff = contract.collection_diff(:collection_node_name)
```

Returns `nil` before the first `resolve_all`, or an `Igniter::Dataflow::Diff`:

| Attribute | Type | Description |
|-----------|------|-------------|
| `added` | `Array` | Keys of items added in the last resolve |
| `removed` | `Array` | Keys of items removed in the last resolve |
| `changed` | `Array` | Keys of items whose content changed |
| `unchanged` | `Array` | Keys of items that were identical — no child contract re-run |
| `any_changes?` | Bool | `true` if anything was added, changed, or removed |
| `processed_count` | Int | `added.size + changed.size` — number of child contracts that ran |
| `explain` | String | Human-readable summary |
| `to_h` | Hash | Serialisable representation |

---

## `IncrementalCollectionResult`

The `output` value for an incremental collection is an `IncrementalCollectionResult`
(inherits from `CollectionResult`), which adds:

```ruby
result = contract.result.collection_name  # => IncrementalCollectionResult
result.diff         # => Igniter::Dataflow::Diff
result.summary      # extends base summary with :added/:removed/:changed/:unchanged counts
result.as_json      # extends base JSON with :diff key
```

All existing `CollectionResult` methods work as before:
`result["key"]`, `result.keys`, `result.successes`, `result.failures`, etc.

---

## Internal Architecture

```
resolve_incremental_collection(node)
  │
  ├─ Resolve source items (same as :collect)
  ├─ Apply WindowFilter (if node.window present)
  ├─ DiffState#compute_diff → Diff
  │     ├─ partition items into added / changed / unchanged
  │     └─ identify removed keys (in @snapshots but not in current)
  │
  ├─ For each UNCHANGED key → reuse @cached_items[key]
  ├─ For each REMOVED  key → DiffState#retract!(key)
  ├─ For each ADDED/CHANGED key → run child contract → DiffState#update!(key, ...)
  │
  └─ Return NodeState(IncrementalCollectionResult)
```

### `DiffState`

One `DiffState` instance per collection node, stored on `Execution#diff_states`.
Persists across `update_inputs` calls for the lifetime of the contract execution.

```
@snapshots    Hash{ key => fingerprint }   change detection
@cached_items Hash{ key => Item }          cached child results
```

The **fingerprint** is content-based (order-independent for Hash items), so
reordering keys in an item Hash does not trigger a re-run.

---

## Compiler Validation

The compiler validates `window:` options at definition time:

```ruby
# Accepted
window: { last: 100 }
window: { seconds: 60, field: :ts }

# Rejected at compile time (raises CompileError)
window: { bogus: 1 }           # unknown key
window: { seconds: 60 }        # missing :field
window: { last: -1 }           # non-positive integer
```

---

## Load Guard

If `mode: :incremental` is used without requiring the extension:

```
Igniter::ResolutionError: Incremental dataflow requires the dataflow extension.
  Add: require 'igniter/extensions/dataflow'
```

---

## Performance Characteristics

| Scenario | Child contracts run |
|----------|-------------------|
| First resolve (N items) | N |
| All items unchanged | 0 |
| K items changed | K |
| K items added | K |
| K items removed | 0 (retraction only) |
| Mixed (K changed + M added) | K + M |

The `window:` filter caps the maximum work per round at `window_size`, not total dataset size.

---

## File Reference

| File | Purpose |
|------|---------|
| `lib/igniter/core/dataflow.rb` | Entry point |
| `lib/igniter/core/dataflow/diff.rb` | `Diff` struct |
| `lib/igniter/core/dataflow/diff_state.rb` | Per-node mutable state |
| `lib/igniter/core/dataflow/window_filter.rb` | `WindowFilter` — `last:` and `seconds:` |
| `lib/igniter/core/dataflow/incremental_collection_result.rb` | Result type with `.diff` |
| `lib/igniter/extensions/dataflow.rb` | Extension — patches `Contract` with `feed_diff`, `collection_diff` |
| `lib/igniter/core/runtime/resolver.rb` | `resolve_incremental_collection` |
| `lib/igniter/core/runtime/execution.rb` | `diff_state_for(node_name)` |
| `spec/igniter/dataflow_spec.rb` | 33 examples |
| `examples/dataflow.rb` | Sensor pipeline demo |
