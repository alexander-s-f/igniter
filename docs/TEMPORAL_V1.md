# Temporal Contracts — v1

Temporal contracts make time an explicit, first-class input so that every execution is
fully reproducible. By supplying the original timestamp you can replay any historical
computation and get the identical result — even months later.

## Quick Start

```ruby
require "igniter/core/temporal"

class TaxRateContract < Igniter::Contract
  include Igniter::Temporal

  define do
    input :country

    # `as_of` is injected automatically (default: Time.now)
    temporal_compute :rate, depends_on: :country do |country:, as_of:|
      HISTORICAL_RATES.dig(country, as_of.year) || 0.0
    end

    output :rate
  end
end

# Current rate — as_of defaults to Time.now
TaxRateContract.new(country: "UA").result.rate
# => 0.22

# Reproduce the 2024 rate exactly
TaxRateContract.new(country: "UA", as_of: Time.new(2024, 1, 1)).result.rate
# => 0.20
```

## How It Works

Including `Igniter::Temporal` overrides `define` to inject one extra input before the
user block runs:

```ruby
input :as_of, default: -> { Time.now }
```

The default is a Proc so it is called freshly at execution time — no stale timestamps
if the contract class is reused across requests.

`temporal_compute` is a DSL helper that behaves identically to `compute` but automatically
appends `:as_of` to the `depends_on` list.

## Module Inclusion

```ruby
class MyContract < Igniter::Contract
  include Igniter::Temporal
  # ...
end

MyContract.temporal?  # => true
```

Plain contracts without the mixin return `false` from `respond_to?(:temporal?)`.

## `as_of` Input

The injected input behaves like any other input:

- **Default**: `-> { Time.now }` — evaluated at execution time.
- **Override**: pass `as_of:` when constructing the contract.
- **Type**: any `Time`-like object is accepted (no type constraint).

```ruby
# Explicit as_of
contract = TaxRateContract.new(country: "UA", as_of: Time.new(2024, 6, 1))
contract.result.rate  # => 0.20 (2024 rate)

# Default as_of — Time.now
contract = TaxRateContract.new(country: "UA")
contract.result.rate  # => current rate
```

## `temporal_compute` DSL

`temporal_compute` is equivalent to:

```ruby
compute :name, depends_on: [:original_deps..., :as_of], ...
```

The block receives `as_of:` as a keyword argument alongside the declared dependencies:

```ruby
temporal_compute :result, depends_on: [:amount, :country] do |amount:, country:, as_of:|
  # as_of is available automatically
  rate = RateTable.lookup(country: country, year: as_of.year)
  amount * rate
end
```

You can also mix `temporal_compute` with regular `compute` in the same contract —
only the nodes that need time-awareness need to use `temporal_compute`.

## Class-Based Executors

For class-based compute nodes in temporal contracts, inherit from
`Igniter::Temporal::Executor`. This signals intent and ensures `as_of:` is always
passed as a keyword argument:

```ruby
class TaxRateExecutor < Igniter::Temporal::Executor
  def call(country:, as_of:)
    HISTORICAL_RATES.dig(country, as_of.year) || 0.0
  end
end

class TaxRateContract < Igniter::Contract
  include Igniter::Temporal

  define do
    input :country
    temporal_compute :rate, depends_on: :country, call: TaxRateExecutor
    output :rate
  end
end
```

`Igniter::Temporal::Executor` is a plain subclass of `Igniter::Executor` — it imposes
no additional behaviour, it is purely documentary.

## Reproducibility Pattern

The key property of temporal contracts: given the same inputs **and** the same `as_of`,
the output is always identical. Store the `as_of` alongside your results and you can
replay any historical computation:

```ruby
# At billing time
result     = InvoiceContract.new(customer_id: "c1").result
as_of_used = result.states[:as_of].value   # the Time.now captured during execution
invoice_id = persist(result, as_of: as_of_used)

# Audit replay 6 months later
audit = InvoiceContract.new(customer_id: "c1", as_of: as_of_used).result
audit.total == result.total  # => true
```

## Combining with Other Extensions

Temporal contracts compose with every other Igniter feature:

```ruby
require "igniter/core/temporal"
require "igniter/extensions/content_addressing"

class TaxCalculator < Igniter::Temporal::Executor
  pure                          # content-addressed — same country+as_of → cached result
  fingerprint "tax_v2"

  def call(country:, as_of:)
    HISTORICAL_RATES.dig(country, as_of.year) || 0.0
  end
end
```

When combined with [content addressing](CONTENT_ADDRESSING_V1.md), the `as_of` value
is part of the content key, so the cache is invalidated automatically when time changes.

## Files

| File | Purpose |
|------|---------|
| `lib/igniter/core/temporal.rb` | `Temporal` module, `ClassMethods#define`, `temporal_compute` DSL helper, `Temporal::Executor` base class |
| `lib/igniter/core/runtime/input_validator.rb` | Proc defaults called at execution time (`apply_defaults`, `missing_value!`) |
| `spec/igniter/temporal_spec.rb` | 13 examples |
