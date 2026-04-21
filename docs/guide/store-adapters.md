# Store Adapters

Igniter ships with reference execution stores for:

- memory
- file
- sqlite
- ActiveRecord-style persistence
- Redis-style persistence

All stores implement the same protocol:

| Method | Description |
|--------|-------------|
| `save(snapshot, correlation: nil, graph: nil)` | Persist a snapshot; build secondary indexes for query |
| `fetch(execution_id)` | Load a snapshot by ID; raises on missing |
| `delete(execution_id)` | Remove a snapshot and clean up indexes |
| `exist?(execution_id)` | Check existence without raising |
| `find_by_correlation(graph:, correlation:)` | Find execution_id by correlation hash |
| `list_all(graph: nil)` | All execution_ids, optionally filtered by graph name |
| `list_pending(graph: nil)` | Execution_ids that have at least one node in `:pending` state |

## Memory Store

Useful for tests and single-process flows.

```ruby
Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new
```

## File Store

Useful for local development and smoke-testing worker flows.

```ruby
Igniter.execution_store = Igniter::Runtime::Stores::FileStore.new(
  root: Rails.root.join("tmp/igniter_executions")
)
```

## SQLite Store

Useful for single-node application profiles that want durable local execution
snapshots without pulling in Redis or ActiveRecord.

```ruby
Igniter.execution_store = Igniter::Runtime::Stores::SQLiteStore.new(
  path: "var/igniter_executions.sqlite3"
)
```

`sqlite3` now ships as a standard Igniter dependency, so this path works out of
the box in the default stack and gem installation shape.

The store keeps one row per execution snapshot and secondary indexes for:

- `graph`
- `pending`
- `(graph, correlation_json)`

## ActiveRecord Store

Expected record shape:

- one unique `execution_id` column
- one text/json column for serialized snapshot payload

Example model:

```ruby
class IgniterExecutionSnapshot < ApplicationRecord
  validates :execution_id, presence: true, uniqueness: true
end
```

Example migration:

```ruby
class CreateIgniterExecutionSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :igniter_execution_snapshots do |t|
      t.string :execution_id, null: false
      t.jsonb :snapshot_json, null: false, default: {}
      t.timestamps
    end

    add_index :igniter_execution_snapshots, :execution_id, unique: true
  end
end
```

Store configuration:

```ruby
Igniter.execution_store = Igniter::Runtime::Stores::ActiveRecordStore.new(
  record_class: IgniterExecutionSnapshot,
  execution_id_column: :execution_id,
  snapshot_column: :snapshot_json
)
```

## Redis Store

`RedisStore` maintains secondary indexes so it can answer all query API calls efficiently:

| Key pattern | Redis type | Purpose |
|-------------|-----------|---------|
| `{ns}:{execution_id}` | String | Serialized snapshot JSON |
| `{ns}:all` | Set | All execution IDs |
| `{ns}:graph:{name}` | Set | Execution IDs for one graph |
| `{ns}:corr:{graph}` | Hash | `JSON(sorted_correlation)` → execution_id |

The client must support these Redis commands:
`set`, `get`, `del`, `exists?`, `sadd`, `srem`, `smembers`, `hset`, `hget`.

The standard [`redis` gem](https://github.com/redis/redis-rb) satisfies this interface.

```ruby
redis = Redis.new(url: ENV.fetch("REDIS_URL"))

Igniter.execution_store = Igniter::Runtime::Stores::RedisStore.new(
  redis: redis,
  namespace: "igniter:executions"   # optional, default shown
)
```

**Query API:**

```ruby
store = Igniter::Runtime::Stores::RedisStore.new(redis: redis)

# Find a pending execution by correlation
execution_id = store.find_by_correlation(
  graph: "OrderContract",
  correlation: { order_id: "o-42" }
)

# List all executions for a graph
ids = store.list_all(graph: "OrderContract")

# List only pending executions (O(n) scan — acceptable for moderate volumes)
pending_ids = store.list_pending(graph: "OrderContract")
```

## Worker Flow

Store-backed contracts should declare:

```ruby
class AsyncPricingContract < Igniter::Contract
  run_with runner: :store
end
```

Producer side:

```ruby
contract = AsyncPricingContract.new(order_total: 100)
deferred = contract.result.gross_total

execution_id = contract.execution.events.execution_id
token = deferred.token
```

Worker side:

```ruby
AsyncPricingContract.resume_from_store(
  execution_id,
  token: token,
  value: 150
)
```

If the resumed execution finishes successfully, the current `StoreRunner` deletes the persisted snapshot automatically.
