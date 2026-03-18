# Igniter

Igniter is a Ruby gem for expressing business logic as a validated dependency graph and executing that graph with:

- lazy output resolution
- selective invalidation after input updates
- typed input validation
- nested contract composition
- runtime auditing
- reactive side effects
- graph and runtime introspection

The repository now contains a working v2 core built around explicit compile-time and runtime boundaries.

## Installation

```ruby
gem "igniter"
```

## Quick Start

```ruby
require "igniter"

class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string
    input :vat_rate, type: :numeric, default: 0.2

    compute :effective_vat_rate, depends_on: %i[country vat_rate] do |country:, vat_rate:|
      country == "UA" ? vat_rate : 0.0
    end

    compute :gross_total, depends_on: %i[order_total effective_vat_rate] do |order_total:, effective_vat_rate:|
      order_total * (1 + effective_vat_rate)
    end

    output :gross_total
  end
end

contract = PriceContract.new(order_total: 100, country: "UA")

contract.result.gross_total
# => 120.0

contract.update_inputs(order_total: 150)
contract.result.gross_total
# => 180.0
```

## Features

- Contracts: declare inputs, compute nodes, outputs, and compositions.
- Compiler: validate dependency graphs before runtime.
- Runtime: cache resolved nodes and invalidate only affected downstream nodes.
- Typed inputs: validate types, defaults, and required fields.
- Composition: execute nested contracts with isolated child executions.
- Auditing: collect execution timelines and snapshots.
- Reactive: subscribe declaratively to runtime events.
- Introspection: render graphs as text or Mermaid and inspect runtime state.

## Composition Example

```ruby
class PricingContract < Igniter::Contract
  define do
    input :order_total, type: :numeric

    compute :gross_total, depends_on: [:order_total] do |order_total:|
      order_total * 1.2
    end

    output :gross_total
  end
end

class CheckoutContract < Igniter::Contract
  define do
    input :order_total, type: :numeric

    compose :pricing, contract: PricingContract, inputs: {
      order_total: :order_total
    }

    output :pricing
  end
end

CheckoutContract.new(order_total: 100).result.pricing.gross_total
# => 120.0
```

## Reactive Example

```ruby
class NotifyingContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    output :order_total
  end

  react_to :node_succeeded, path: "order_total" do |event:, **|
    puts "Resolved #{event.path}"
  end
end
```

## Introspection

```ruby
PriceContract.graph.to_text
PriceContract.graph.to_mermaid

contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total

contract.result.states
contract.result.explain(:gross_total)
contract.audit_snapshot
```

## v2 Design Docs

- [Architecture v2](docs/ARCHITECTURE_V2.md)
- [Execution Model v2](docs/EXECUTION_MODEL_V2.md)
- [API Draft v2](docs/API_V2.md)
- [Concepts and Principles](docs/IGNITER_CONCEPTS.md)

## Direction

The v2 rewrite is based on these rules:

- model, compiler, runtime, DSL, and extensions are separate layers
- graph validation happens before runtime
- auditing and reactive behavior are extensions over events, not runtime internals
- the first target is a deterministic synchronous kernel

## Status

The public Ruby surface in `lib/` now contains only the v2 core exposed from `require "igniter"`.

## Development

```bash
rake spec
```

Current baseline:

- synchronous runtime
- compile-time graph validation
- typed inputs
- composition
- auditing
- reactive subscriptions
- graph/runtime introspection

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
