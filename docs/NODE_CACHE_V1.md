# Node Cache — v1

Cross-execution TTL cache and in-flight request coalescing for compute nodes.

Activate per-node via `cache_ttl:` and `coalesce:` options on `compute`:

```ruby
compute :available_slots,
        with:       [:vendor, :locations, :availability_mode, :current_time],
        call:       CheckAvailability,
        cache_ttl:  60,     # reuse result for 60 seconds across executions
        coalesce:   true    # deduplicate concurrent in-flight requests
```

Both features are opt-in, zero-overhead for unconfigured nodes, and work independently.

---

## Quick Start

```ruby
require "igniter/core/node_cache"

# In-process memory backend (single Ruby process / single Puma worker)
Igniter.configure do |c|
  c.node_cache     = Igniter::NodeCache::Memory.new
  c.node_coalescing = true   # auto-creates a CoalescingLock
end
```

Or explicitly:

```ruby
Igniter::NodeCache.cache           = Igniter::NodeCache::Memory.new
Igniter::NodeCache.coalescing_lock = Igniter::NodeCache::CoalescingLock.new
```

---

## Feature 1 — TTL Cache (`cache_ttl:`)

Stores the result of a compute node in a shared cache keyed by:

```
"ttl:{ContractName}:{node_name}:{dep_fingerprint_hex}"
```

On the next execution, if the deps haven't changed and the TTL hasn't expired, the cached
value is returned immediately — the executor is never called.

### Usage

```ruby
class AvailabilityContract < Igniter::Contract
  runner :thread_pool, pool_size: 4

  define do
    input  :vendor_id
    input  :zip_code

    compute :vendor,
            with: :vendor_id,
            call: FindVendor

    compute :available_slots,
            with:      [:vendor, :zip_code],
            call:      CheckAvailability,
            cache_ttl: 60    # cache for 60 seconds
    output :available_slots
  end
end
```

### Cache Key

The cache key is a 24-hex SHA-256 digest of the serialized dependency values:

```ruby
dep_hex = Igniter::NodeCache::Fingerprinter.call({ vendor: vendor_obj, zip_code: "10001" })
key     = Igniter::NodeCache::CacheKey.new("AvailabilityContract", :available_slots, dep_hex)
key.hex # => "ttl:AvailabilityContract:available_slots:4a9f1c0e23ab7d88e4c2"
```

For stable cross-execution keys, dependency objects should implement `#igniter_fingerprint`
(see [AR Fingerprinting](#ar-fingerprinting) below).

### Runtime Event

When a cached value is returned the resolver emits `:node_ttl_cache_hit`:

```ruby
contract.execution.events.events.select { |e| e.type == :node_ttl_cache_hit }
# => [#<Event type=:node_ttl_cache_hit node=:available_slots ...>]
```

### Memory Backend

`NodeCache::Memory` is a thread-safe in-process store:

```ruby
cache = Igniter::NodeCache::Memory.new
cache.stats    # => { size: 4, hits: 11, misses: 3 }
cache.size     # => 4
cache.prune!   # removes expired entries (call periodically to reclaim memory)
cache.clear    # removes all entries and resets counters
```

Entries are automatically expired on `fetch` — no background thread needed.

### Custom / Redis Backend

Replace `Memory` with any object implementing `#fetch(key)` and `#store(key, value, ttl:)`:

```ruby
class RedisNodeCache
  def initialize(redis)
    @redis = redis
  end

  def fetch(key)
    raw = @redis.get(key.hex)
    raw ? Marshal.load(raw) : nil
  end

  def store(key, value, ttl:)
    @redis.setex(key.hex, ttl.to_i, Marshal.dump(value))
    value
  end
end

Igniter::NodeCache.cache = RedisNodeCache.new(Redis.new)
```

A Redis-backed cache shares results across Puma workers and multiple server instances.

---

## Feature 2 — Request Coalescing (`coalesce: true`)

When two (or more) executions race to compute the same `coalesce: true` node with
identical dependency values, only one actually runs — the **leader**. The others become
**followers** and wait for the leader's result.

This eliminates redundant work in auction / multi-vendor scenarios where N vendors submit
requests for the same lead within milliseconds of each other.

### Usage

```ruby
compute :available_slots,
        with:     [:vendor, :locations],
        call:     CheckAvailability,
        cache_ttl: 60,
        coalesce:  true   # concurrent requests with same deps share one computation
```

`coalesce: true` requires `cache_ttl:` to be set (the completed result is stored in the
TTL cache so followers can retrieve it) and `NodeCache.coalescing_lock` to be configured.

### Leader / Follower Flow

```
Thread A (leader)                Thread B (follower)
────────────────                 ─────────────────────
acquire(:hex) → :leader          acquire(:hex) → :follower
call CheckAvailability           wait(flight) ← blocks
finish!(:hex, value: result)  →  unblocked, gets result
```

If the leader raises an error, `finish!` is called with `error:` — all followers receive
the error and raise it themselves. A follower that times out (30 s) recomputes independently.

### CoalescingLock API

```ruby
lock = Igniter::NodeCache::CoalescingLock.new

role, flight = lock.acquire(hex)      # → [:leader, flight] or [:follower, flight]
lock.finish!(hex, value: result)      # called by leader on success
lock.finish!(hex, error: exception)   # called by leader on failure
value, error = lock.wait(flight)      # called by follower

lock.in_flight_count  # => 3
```

---

## AR Fingerprinting

Cache keys are built from the fingerprints of dependency values. For stable keys that
survive process restarts (required for Redis-backed caches), dependency objects must
implement `#igniter_fingerprint`.

### `Igniter::Fingerprint` mixin

Include in any class whose instances are passed as node dependencies:

```ruby
class Trade < ApplicationRecord
  include Igniter::Fingerprint
  # default fingerprint: "Trade:42:1712345678"  (class:id:updated_at_unix)
end
```

The default implementation:
- **With `updated_at`**: `"ClassName:id:updated_at_unix"` — cache is invalidated on record update.
- **With `id` only**: `"ClassName:id"`.
- **Fallback**: `"ClassName:object_id"` — stable within a process, not across restarts.

### Custom fingerprints

Override `#igniter_fingerprint` for non-AR objects or custom invalidation logic:

```ruby
class PricingConfig
  include Igniter::Fingerprint

  def igniter_fingerprint
    "PricingConfig:#{version}:#{market}"
  end
end
```

### Rails Railtie

When using the `igniter-rails` integration, `Igniter::Fingerprint` is automatically
included in `ApplicationRecord` — no per-model setup required.

---

## `runner` Class Macro

The `runner` macro sets the default execution strategy for a contract class, replacing
the more verbose `run_with`:

```ruby
class MyContract < Igniter::Contract
  runner :thread_pool, pool_size: 4

  define do
    # ...
  end
end
```

Equivalent to `run_with(runner: :thread_pool, max_workers: 4)`. Accepts `pool_size:` or
`max_workers:` interchangeably.

---

## Full Example

```ruby
require "igniter"
require "igniter/core/node_cache"

Igniter.configure do |c|
  c.node_cache      = Igniter::NodeCache::Memory.new
  c.node_coalescing = true
end

class Vendor
  include Igniter::Fingerprint
  attr_reader :id, :updated_at
  def initialize(id) = (@id = id; @updated_at = Time.now)
end

class FetchSlots < Igniter::Executor
  def call(vendor:, zip_code:)
    puts "  → computing for vendor=#{vendor.id} zip=#{zip_code}"
    rand(10)
  end
end

class SlotContract < Igniter::Contract
  runner :thread_pool, pool_size: 2

  define do
    input  :vendor
    input  :zip_code
    compute :slots, with: [:vendor, :zip_code], call: FetchSlots,
                    cache_ttl: 60, coalesce: true
    output :slots
  end
end

vendor = Vendor.new(42)

c1 = SlotContract.new(vendor: vendor, zip_code: "10001").resolve
c2 = SlotContract.new(vendor: vendor, zip_code: "10001").resolve

puts c1.result.slots   # => 7  (computed)
puts c2.result.slots   # => 7  (TTL cache hit — FetchSlots not called)
```

---

## Setup Reference

```ruby
Igniter.configure do |c|
  c.node_cache      = Igniter::NodeCache::Memory.new   # or custom Redis backend
  c.node_coalescing = true                             # auto-creates CoalescingLock
end
```

| Option                     | Default | Description |
|----------------------------|---------|-------------|
| `node_cache=`              | `nil`   | TTL cache backend; `nil` = disabled |
| `node_coalescing=`         | `nil`   | `true` creates a `CoalescingLock`; `nil`/`false` = disabled |

---

## Files

| File | Purpose |
|------|---------|
| `lib/igniter/core/node_cache.rb` | `CacheKey`, `Memory`, `CoalescingLock`, `Fingerprinter` |
| `lib/igniter/core/fingerprint.rb` | `Igniter::Fingerprint` mixin |
| `lib/igniter/core/model/compute_node.rb` | `cache_ttl`, `coalesce?` readers |
| `lib/igniter/core/runtime/resolver.rb` | TTL cache + coalescing hooks in `resolve_compute` |
| `lib/igniter.rb` | `node_cache=`, `node_coalescing=` in configure API |
| `spec/igniter/node_cache_spec.rb` | 42 examples |
| `examples/elocal_webhook.rb` | Real-world usage — eLocal auction webhook migration |
