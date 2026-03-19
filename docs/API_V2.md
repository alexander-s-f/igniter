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

expose :bid_details, as: :response
```

Short dependency alias:

```ruby
compute :zip_code, with: :zip_code_raw do |zip_code_raw:|
  ZipCode.find_by_code!(zip_code_raw)
end
```

Matcher-style guards:

```ruby
guard :usa_only, with: :country_code, eq: "USA", message: "Unsupported country"
guard :supported_country, with: :country_code, in: %w[USA CAN], message: "Unsupported country"
guard :valid_zip, with: :zip_code, matches: /\A\d{5}\z/, message: "Invalid zip"
```

Declarative routing:

```ruby
branch :delivery_strategy, with: :country, inputs: {
  country: :country,
  order_total: :order_total
} do
  on "US", contract: USDeliveryContract
  on "UA", contract: LocalDeliveryContract
  default contract: DefaultDeliveryContract
end
```

Declarative fan-out:

```ruby
collection :technicians,
  with: :technician_inputs,
  each: TechnicianContract,
  key: :technician_id,
  mode: :collect
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

Branch output export:

```ruby
export :price, :eta, from: :delivery_strategy
```

Collection output:

```ruby
output :technicians
```

This returns a `CollectionResult` rather than a plain array.

Nested routing and fan-out can be combined:

```ruby
branch :status_route, with: :telephony_status, inputs: {
  extension_id: :extension_id,
  telephony_status: :telephony_status,
  active_calls: :active_calls
} do
  on "CallConnected", contract: CallConnectedContract
  on "NoCall", contract: NoCallContract
  default contract: UnknownStatusContract
end
```

Inside the selected branch contract:

```ruby
collection :calls,
  with: :call_inputs,
  each: CallEventContract,
  key: :session_id,
  mode: :collect
```

Diagnostics and audit stay local to the execution that owns the node:

- the parent execution records top-level branch selection
- collection item events belong to the selected child execution
- collection summaries should usually be read from the child contract diagnostics

Pass-through or aliased output exposure:

```ruby
expose :bid_details, as: :response
expose :gross_total
```

Grouped node paths:

```ruby
scope :availability do
  lookup :vendor, with: %i[trade vendor_id], call: LookupVendor
  lookup :zip_code, with: :zip_code_raw, call: LookupZipCode
  compute :geo_bids, with: %i[zip_code vendor], call: LookupGeoBids
end

namespace :validation do
  guard :valid_zip, with: :zip_code, matches: /\A\d{5}\z/, message: "Invalid zip"
end
```

`scope` and `namespace` currently improve structure and introspection by prefixing node paths.
They do not yet introduce a separate runtime boundary.

Branch nodes introduce explicit control flow and behave like composition-like nested results.

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

  effect "order_total" do |event:, value:, **|
    AuditLog.create!(path: event.path, value: value)
  end
end
```

Final-output success shorthand:

```ruby
class PersistingContract < Igniter::Contract
  define do
    input :order_total
    compute :gross_total, depends_on: [:order_total] do |order_total:|
      order_total * 1.2
    end
    expose :gross_total, as: :response
  end

  on_success :response do |value:, contract:, **|
    AuditLog.create!(response: value, inputs: contract.execution.inputs)
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
