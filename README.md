# Igniter

Igniter is a Ruby gem for expressing business logic as a validated dependency graph and executing that graph with:

- lazy output resolution
- selective invalidation after input updates
- typed input validation
- nested contract composition
- runtime auditing
- diagnostics reports
- reactive side effects
- ergonomic DSL helpers (`with`, `const`, `lookup`, `map`, `guard`, `export`, `expose`, `effect`, `on_success`, `scope`, `namespace`, `branch`, `collection`)
- graph and runtime introspection
- async-capable pending nodes with snapshot/restore
- store-backed execution resume flows

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

contract.diagnostics_text
# => compact execution summary
```

## Features

- Contracts: declare inputs, compute nodes, outputs, and compositions.
- Compiler: validate dependency graphs before runtime.
- Runtime: cache resolved nodes and invalidate only affected downstream nodes.
- Typed inputs: validate types, defaults, and required fields.
- Composition: execute nested contracts with isolated child executions.
- Auditing: collect execution timelines and snapshots.
- Diagnostics: build compact text, markdown, or structured reports for triage.
- Reactive: subscribe declaratively to runtime events.
- Introspection: render graphs as text or Mermaid and inspect runtime state.
- Ergonomics: use compact DSL helpers for common lookup, transform, guard, export, and side-effect patterns.

## Quick Start Recipes

The repository contains runnable examples in [`examples/`](examples).
They also have matching specs, so they stay in sync with the implementation.
The examples folder also has its own quick index in [`examples/README.md`](examples/README.md).
There is also a short patterns guide in [`docs/PATTERNS.md`](docs/PATTERNS.md).

| Example | Run | Shows |
| --- | --- | --- |
| `basic_pricing.rb` | `ruby examples/basic_pricing.rb` | basic contract, lazy resolution, input updates |
| `composition.rb` | `ruby examples/composition.rb` | nested contracts and composed results |
| `diagnostics.rb` | `ruby examples/diagnostics.rb` | diagnostics text plus machine-readable output |
| `async_store.rb` | `ruby examples/async_store.rb` | pending execution, file-backed store, worker-style resume |
| `marketing_ergonomics.rb` | `ruby examples/marketing_ergonomics.rb` | compact domain DSL with `with`, matcher-style `guard`, `scope`/`namespace`, `expose`, `on_success`, and `explain_plan` |
| `collection.rb` | `ruby examples/collection.rb` | declarative fan-out, stable item keys, and `CollectionResult` |
| `collection_partial_failure.rb` | `ruby examples/collection_partial_failure.rb` | `:collect` mode, partial failure summary, and collection diagnostics |
| `ringcentral_routing.rb` | `ruby examples/ringcentral_routing.rb` | top-level `branch`, nested `collection`, per-item routing, and nested diagnostics semantics |

There are also matching living examples in `spec/igniter/examples_spec.rb`.
Those are useful if you want to read the examples in test form.

### 1. Basic Pricing Contract

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :vat_rate, depends_on: [:country] do |country:|
      country == "UA" ? 0.2 : 0.0
    end

    compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end

    output :gross_total
  end
end

PriceContract.new(order_total: 100, country: "UA").result.gross_total
# => 120.0
```

### 2. Nested Composition

```ruby
class CheckoutContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compose :pricing, contract: PriceContract, inputs: {
      order_total: :order_total,
      country: :country
    }

    output :pricing
  end
end

CheckoutContract.new(order_total: 100, country: "UA").result.pricing.gross_total
# => 120.0
```

### 3. Diagnostics And Introspection

```ruby
contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total

contract.result.states
contract.result.explain(:gross_total)
contract.diagnostics.to_h
contract.diagnostics_text
contract.diagnostics_markdown
contract.audit_snapshot
```

### 4. Machine-Readable Data

```ruby
contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total

contract.result.to_h
# => { gross_total: 120.0 }

contract.result.as_json
contract.execution.as_json
contract.events.map(&:as_json)
```

### 5. Async Store And Resume

```ruby
class AsyncQuoteExecutor < Igniter::Executor
  input :order_total, type: :numeric

  def call(order_total:)
    defer(token: "quote-#{order_total}", payload: { kind: "pricing_quote" })
  end
end

class AsyncPricingContract < Igniter::Contract
  run_with runner: :store

  define do
    input :order_total, type: :numeric

    compute :quote_total, depends_on: [:order_total], call: AsyncQuoteExecutor

    compute :gross_total, depends_on: [:quote_total] do |quote_total:|
      quote_total * 1.2
    end

    output :gross_total
  end
end

contract = AsyncPricingContract.new(order_total: 100)
deferred = contract.result.gross_total
execution_id = contract.execution.events.execution_id

resumed = AsyncPricingContract.resume_from_store(
  execution_id,
  token: deferred.token,
  value: 150
)

resumed.result.gross_total
# => 180.0
```

### 6. Ergonomic DSL

```ruby
class MarketingQuoteContract < Igniter::Contract
  define do
    input :service, type: :string
    input :zip_code, type: :string

    const :vendor_id, "eLocal"

    scope :routing do
      map :trade_name, from: :service do |service:|
        %w[heating cooling ventilation air_conditioning].include?(service.downcase) ? "HVAC" : service
      end
    end

    scope :pricing do
      lookup :trade, with: :trade_name do |trade_name:|
        { name: trade_name, base_bid: 45.0 }
      end
    end

    namespace :validation do
      guard :zip_supported, with: :zip_code, in: %w[60601 10001], message: "Unsupported zip"
    end

    compute :quote, with: %i[vendor_id trade zip_supported zip_code] do |vendor_id:, trade:, zip_supported:, zip_code:|
      zip_supported
      { vendor_id: vendor_id, trade: trade[:name], zip_code: zip_code, bid: trade[:base_bid] }
    end

    expose :quote, as: :response
  end

  on_success :response do |value:, **|
    puts "Persist #{value.inspect}"
  end
end

contract = MarketingQuoteContract.new(service: "heating", zip_code: "60601")

contract.explain_plan
contract.result.response
```

You can also use matcher-style guards directly:

```ruby
guard :usa_only, with: :country_code, eq: "USA", message: "Unsupported country"
guard :supported_country, with: :country_code, in: %w[USA CAN], message: "Unsupported country"
guard :valid_zip, with: :zip_code, matches: /\A\d{5}\z/, message: "Invalid zip"
```

### 7. Declarative Branching

```ruby
class DeliveryContract < Igniter::Contract
  define do
    input :country
    input :order_total

    branch :delivery_strategy, with: :country, inputs: {
      country: :country,
      order_total: :order_total
    } do
      on "US", contract: USDeliveryContract
      on "UA", contract: LocalDeliveryContract
      default contract: DefaultDeliveryContract
    end

    export :price, :eta, from: :delivery_strategy
  end
end
```

### 8. Branch + Collection Routing

```ruby
class RingcentralWebhookContract < Igniter::Contract
  define do
    input :payload

    scope :parse do
      map :body, from: :payload do |payload:|
        payload.fetch("body", {})
      end

      map :telephony_status, from: :body do |body:|
        body["telephonyStatus"]
      end

      map :active_calls, from: :body do |body:|
        body["activeCalls"] || []
      end
    end

    branch :status_route, with: :telephony_status, inputs: {
      extension_id: :extension_id,
      telephony_status: :telephony_status,
      active_calls: :active_calls
    } do
      on "CallConnected", contract: CallConnectedContract
      on "NoCall", contract: NoCallContract
      default contract: UnknownStatusContract
    end

    export :routing_summary, from: :status_route
  end
end
```

In nested flows, diagnostics stay attached to the execution that actually owns the node:

- the parent execution sees the top-level `branch_selected`
- collection item events live on the selected child execution
- collection summaries are easiest to read from the child contract diagnostics

`branch` is a graph primitive for explicit routing. It selects one child contract from ordered cases and resolves only the chosen branch.

### 8. Declarative Collections

```ruby
class TechnicianBatchContract < Igniter::Contract
  define do
    input :technician_inputs, type: :array

    collection :technicians,
      with: :technician_inputs,
      each: TechnicianContract,
      key: :technician_id,
      mode: :collect

    output :technicians
  end
end
```

`collection` is a graph primitive for explicit fan-out. It runs one child contract per item hash and returns a `CollectionResult` keyed by stable item identity.

In `mode: :collect`, a collection can succeed overall while still containing failed items. In that case:

- `result.summary` gives collection-level status such as `:partial_failure`
- `result.items_summary` gives compact per-item status
- `result.failed_items` gives only failed item details
- `contract.diagnostics_text` and `contract.diagnostics_markdown` include collection failure summaries

See `examples/collection_partial_failure.rb` for a runnable example.

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

  on_success :order_total do |value:, **|
    puts "Resolved #{value}"
  end
end
```

Or attach directly to a node event when you want the node value:

```ruby
class NotifyingContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    output :order_total
  end

  effect "order_total" do |event:, value:, **|
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
contract.explain_plan
contract.execution.to_h
contract.execution.as_json
contract.result.as_json
contract.events.map(&:as_json)
contract.diagnostics.to_h
contract.diagnostics_text
contract.diagnostics_markdown
contract.audit_snapshot
```

## v2 Design Docs

- [Architecture v2](docs/ARCHITECTURE_V2.md)
- [Execution Model v2](docs/EXECUTION_MODEL_V2.md)
- [API Draft v2](docs/API_V2.md)
- [Patterns](docs/PATTERNS.md)
- [Branches v1](docs/BRANCHES_V1.md)
- [Collections v1](docs/COLLECTIONS_V1.md)
- [Store Adapters](docs/STORE_ADAPTERS.md)
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
- parallel thread-pool runner
- pending/deferred runtime states
- snapshot/restore execution lifecycle
- store-backed resume flow
- compile-time graph validation
- typed inputs
- composition
- auditing
- diagnostics reporting
- reactive subscriptions
- graph/runtime introspection

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
