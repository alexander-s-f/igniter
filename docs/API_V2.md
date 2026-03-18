# Igniter v2 API Draft

## Public API Goals

The public API should be:

- small
- explicit
- inspectable
- stable

The user should understand Igniter through three concepts:

- declare a contract
- execute it with inputs
- inspect outputs and events

## Contract Shape

Recommended public entry point:

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total
    input :country

    compute :vat_rate, depends_on: [:country], call: :resolve_vat_rate
    compute :gross_total, depends_on: [:order_total, :vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end

    output :gross_total
  end

  def resolve_vat_rate(country:)
    country == "UA" ? 0.2 : 0.0
  end
end
```

### Why `define`

`define` clearly communicates compile-time declaration.

It is preferable to a more ambiguous `context` name because the graph being created is a model definition, not a runtime scope.

## Contract Runtime API

```ruby
contract = PriceContract.new(order_total: 100, country: "UA")

contract.result.gross_total
contract.result.to_h
contract.success?
contract.failed?
contract.pending?

contract.update_inputs(order_total: 120)
contract.result.gross_total
```

Suggested instance methods:

- `result`
- `resolve`
- `resolve_all`
- `update_inputs`
- `events`
- `execution`
- `explain_plan`
- `diagnostics`
- `success?`
- `failed?`
- `pending?`

## Result API

`Result` is a read facade over outputs and execution state.

Suggested methods:

- output readers by name
- `to_h`
- `as_json`
- `success?`
- `failed?`
- `pending?`
- `errors`
- `states`
- `explain`

Avoid relying on `method_missing` as the main implementation mechanism if explicit generated readers are practical.

## DSL Draft

### Inputs

```ruby
input :order_total
input :country
```

Optional later extension:

```ruby
input :order_total, type: :decimal, required: true
```

### Compute Nodes

Block form:

```ruby
compute :gross_total, depends_on: [:order_total, :vat_rate] do |order_total:, vat_rate:|
  order_total * (1 + vat_rate)
end
```

Method form:

```ruby
compute :vat_rate, depends_on: [:country], call: :resolve_vat_rate
```

Executor registry form:

```ruby
Igniter.register_executor("pricing.multiply", MultiplyExecutor)

compute :gross_total,
        depends_on: %i[order_total multiplier],
        executor: "pricing.multiply"
```

Ergonomic helper forms:

```ruby
const :vendor_id, "eLocal"

lookup :trade, depends_on: [:trade_name] do |trade_name:|
  Trade.enabled.find_by!(name: trade_name)
end

map :normalized_trade_name, from: :service do |service:|
  service.downcase == "heating" ? "HVAC" : service
end

guard :business_hours_valid, depends_on: %i[vendor current_time], message: "Closed" do |vendor:, current_time:|
  current_time.between?(vendor.start_at, vendor.stop_at)
end
```

Rules:

- one compute node has one callable
- dependencies are explicit
- runtime injects only declared dependencies

### Outputs

```ruby
output :gross_total
output :vat_rate
```

Optional alias form:

```ruby
output :total, from: :gross_total
```

### Composition

```ruby
compose :pricing, contract: PriceContract, inputs: {
  order_total: :order_total,
  country: :country
}

output :pricing, from: :pricing
```

Child output export:

```ruby
output :gross_total, from: "pricing.gross_total"
```

Bulk child output export:

```ruby
export :gross_total, :vat_rate, from: :pricing
```

Collection composition can be added later, but should not complicate the first kernel API.

## Introspection API

Recommended API:

```ruby
PriceContract.graph
PriceContract.graph.to_h
PriceContract.graph.to_mermaid

contract.execution.states
contract.execution.plan
contract.explain_plan
contract.execution.to_h
contract.execution.as_json
contract.result.as_json
contract.events.map(&:as_json)
contract.diagnostics.to_h
contract.diagnostics.to_text
contract.diagnostics.to_markdown
contract.snapshot
```

The main rule is that introspection reads stable compile/runtime objects rather than poking through private internals.

## Events API

Suggested access patterns:

```ruby
contract.events.each do |event|
  puts "#{event.type} #{event.path}"
end

contract.events.map(&:to_h)
contract.events.map(&:as_json)
```

Or:

```ruby
contract.subscribe(auditor)
```

Reactive side-effect shorthand:

```ruby
class LoggingContract < Igniter::Contract
  define do
    input :order_total
    output :order_total
  end

  effect "order_total" do |event:, contract:, **|
    AuditLog.create!(path: event.path, value: contract.result.order_total)
  end
end
```

Async/store-backed flow:

```ruby
contract = AsyncPricingContract.new(order_total: 100)
deferred = contract.result.gross_total

AsyncPricingContract.resume_from_store(
  contract.execution.events.execution_id,
  token: deferred.token,
  value: 150
)
```

Reference store adapters:

```ruby
Igniter.execution_store = Igniter::Runtime::Stores::ActiveRecordStore.new(
  record_class: IgniterExecutionSnapshot
)
```

```ruby
Igniter.execution_store = Igniter::Runtime::Stores::RedisStore.new(
  redis: Redis.new(url: ENV.fetch("REDIS_URL"))
)
```

Where a subscriber responds to:

```ruby
call(event)
```

## Errors API

Suggested public behavior:

```ruby
begin
  contract.result.gross_total
rescue Igniter::ResolutionError => e
  puts e.message
end
```

Result-level inspection should still expose node failures without forcing exception-driven control flow for every error path.

Each Igniter error also carries structured context when available:

- `graph`
- `node_id`
- `node_name`
- `node_path`
- `source_location`

## Roadmap API Decisions

### Include in the first rewrite

- `Igniter::Contract`
- `define`
- `input`
- `compute`
- `output`
- `result`
- `update_inputs`
- `events`
- graph introspection

### Postpone

- collection composition
- advanced typed schemas
- retries
- Rails-specific DSL sugar

### Now Present In v2 Core

- executor registry
- schema-driven graph compilation
- thread-pool runner
- deferred/pending executor protocol
- execution snapshot/restore
- store-backed resume flow
