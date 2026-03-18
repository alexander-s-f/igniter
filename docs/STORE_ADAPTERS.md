# Store Adapters

Igniter ships with reference execution stores for:

- memory
- file
- ActiveRecord-style persistence
- Redis-style persistence

All stores implement the same minimal protocol:

- `save(snapshot)`
- `fetch(execution_id)`
- `delete(execution_id)`
- `exist?(execution_id)`

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

Expected client protocol:

- `set(key, value)`
- `get(key)`
- `del(key)`
- `exists?(key)`

Example configuration:

```ruby
redis = Redis.new(url: ENV.fetch("REDIS_URL"))

Igniter.execution_store = Igniter::Runtime::Stores::RedisStore.new(
  redis: redis,
  namespace: "igniter:executions"
)
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
