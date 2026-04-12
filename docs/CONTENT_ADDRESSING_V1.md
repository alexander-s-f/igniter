# Content-Addressed Computation — v1

Content addressing gives `pure` executors a universal cache key derived from their logic
(fingerprint) and their input values. The same computation — regardless of which
contract, which execution, or which process produced it — always returns the cached result.

This is the Nix/Merkle model applied to contract nodes: **identical inputs → identical
output, fetched from cache**.

## Quick Start

```ruby
require "igniter/extensions/content_addressing"

class TaxCalculator < Igniter::Executor
  pure                        # marks executor as side-effect-free
  fingerprint "tax_calc_v1"   # optional: bumps the cache key when logic changes

  def call(country:, amount:)
    TAX_RATES[country] * amount
  end
end

class InvoiceContract < Igniter::Contract
  define do
    input :country
    input :amount, type: :numeric

    compute :tax, depends_on: %i[country amount], call: TaxCalculator

    output :tax
  end
end

# First execution — computes and caches the result
c1 = InvoiceContract.new(country: "UA", amount: 1000)
c1.result.tax  # => 220.0  (computed)

# Second execution with identical inputs — served from the content cache
c2 = InvoiceContract.new(country: "UA", amount: 1000)
c2.result.tax  # => 220.0  (cache hit — TaxCalculator was never called)
```

## How It Works

For every `pure` executor, the resolver computes a **content key** before calling
the executor:

```
key = SHA-256( fingerprint + "\x00" + stable_serialize(dep_values) )[0..23]
```

- **fingerprint** — the executor class name (or explicit `fingerprint "v1"` string).
- **stable_serialize** — deterministic, order-independent serialization of all dependency
  values: Hash keys are sorted, Array elements are serialized recursively, primitives use
  `inspect`.

The resolver looks up the key in the global `ContentAddressing.cache` before calling the
executor. On a hit it uses the cached value and emits a `:node_content_cache_hit` event.
On a miss it computes the result, stores it, and continues normally.

## Executor DSL

### `pure`

Marks the executor as having no side effects. Enables content-addressed caching.
Shorthand for `capabilities(:pure)`.

```ruby
class MyExecutor < Igniter::Executor
  pure
end
```

### `fingerprint "v1"`

Sets an explicit version string used as the first component of the content key.
Bump the fingerprint whenever the executor logic changes to immediately invalidate
all cached results for this executor.

```ruby
class TaxCalculator < Igniter::Executor
  pure
  fingerprint "tax_calc_v2"   # bumped — old v1 cache entries are ignored
end
```

If `fingerprint` is not set, the executor's class name is used. Anonymous executors
use `"anonymous_executor"`.

## Content Key

`Igniter::ContentAddressing::ContentKey` is an immutable value object:

```ruby
key = Igniter::ContentAddressing::ContentKey.compute(TaxCalculator, { country: "UA", amount: 1000 })

key.hex    # => "8f47805dc6dd7926"  (24-hex digest prefix)
key.to_s   # => "ca:8f47805dc6dd7926"
key == key # => true  (equality by hex, not object identity)
key.frozen? # => true
```

Keys are equal if their hex values match — two keys computed from the same executor and
the same dep values will always be equal, even if produced in separate processes.

## Content Cache

The global cache is a thread-safe in-process Hash by default:

```ruby
Igniter::ContentAddressing.cache          # => #<Igniter::ContentAddressing::Cache ...>
Igniter::ContentAddressing.cache.stats    # => { size: 3, hits: 12, misses: 4 }
Igniter::ContentAddressing.cache.size     # => 3
Igniter::ContentAddressing.cache.clear    # clears entries and resets counters
```

### Distributed Cache (Redis)

Replace the default cache with any object implementing `#fetch(key)` and `#store(key, value)`:

```ruby
class RedisContentCache
  def initialize(redis, ttl: 3600)
    @redis = redis
    @ttl   = ttl
  end

  def fetch(key)
    val = @redis.get(key.to_s)
    val ? Marshal.load(val) : nil
  end

  def store(key, value)
    @redis.setex(key.to_s, @ttl, Marshal.dump(value))
  end
end

Igniter::ContentAddressing.cache = RedisContentCache.new(Redis.new)
```

With a shared Redis cache, results are reused across deployments, canary instances,
and background workers — any process that computes `TaxCalculator(country: "UA", amount: 1000)`
once populates the cache for all others.

## Runtime Events

The resolver emits `:node_content_cache_hit` when a cached result is used:

```ruby
contract.execution.events.select { |e| e.type == :node_content_cache_hit }
# => [#<Event type=:node_content_cache_hit node=:tax ...>]
```

## Loading

```ruby
require "igniter/extensions/content_addressing"
```

This single require:
1. Loads `lib/igniter/core/content_addressing.rb` (ContentKey, Cache, module-level cache accessor).
2. Activates the resolver hooks via `lib/igniter/core/runtime/resolver.rb`.

Non-pure executors are completely unaffected — no overhead, no behavior change.

## Combining with Temporal Contracts

When used with [temporal contracts](TEMPORAL_V1.md), the `as_of` value is part of the
dependency hash and therefore part of the content key. Historical and current timestamps
produce distinct cache entries, and identical timestamps produce cache hits:

```ruby
require "igniter/core/temporal"
require "igniter/extensions/content_addressing"

class TaxRateExecutor < Igniter::Temporal::Executor
  pure
  fingerprint "tax_rate_v1"

  def call(country:, as_of:)
    RATES.dig(country, as_of.year) || 0.0
  end
end
```

Replaying a historical execution with the same `as_of` will hit the cache — the executor
is never called twice for the same (country, year) pair.

## Fingerprint Invalidation Pattern

When you deploy a fix to a `pure` executor, bump the fingerprint so the old cached
results are ignored immediately:

```ruby
# Before fix
class DiscountCalculator < Igniter::Executor
  pure
  fingerprint "discount_v1"
  def call(amount:, code:) = amount * 0.9  # bug: off-by-one in rate
end

# After fix
class DiscountCalculator < Igniter::Executor
  pure
  fingerprint "discount_v2"  # <-- bumped; v1 cache entries are silently ignored
  def call(amount:, code:) = amount * 0.85
end
```

Old cache entries with `"discount_v1"` prefix in the key are never read again.

## Files

| File | Purpose |
|------|---------|
| `lib/igniter/core/content_addressing.rb` | `ContentKey`, `Cache`, module-level `cache` accessor |
| `lib/igniter/extensions/content_addressing.rb` | Entry point (`require "igniter/extensions/content_addressing"`) |
| `lib/igniter/core/executor.rb` | `pure`, `fingerprint`, `content_fingerprint`, `pure?` class DSL |
| `lib/igniter/core/runtime/resolver.rb` | `build_content_key` + cache fetch/store hooks in `resolve_compute` |
| `spec/igniter/content_addressing_spec.rb` | 19 examples |
