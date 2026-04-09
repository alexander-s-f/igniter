# Igniter

Igniter is a Ruby gem for expressing business logic as a validated dependency graph and executing that graph with:

- lazy output resolution and selective cache invalidation
- typed input validation with defaults and required fields
- nested contract composition with isolated child executions
- declarative routing (`branch`) and fan-out (`collection`)
- distributed workflows: `await` events across process boundaries
- multi-node deployments via `igniter-server` and the `remote:` DSL
- LLM compute nodes with Ollama, Anthropic, and OpenAI providers
- Rails integration: ActiveJob, ActionCable, webhook handlers, generators
- runtime auditing, diagnostics reports, and reactive side effects
- graph and runtime introspection (text, Mermaid)
- ergonomic DSL helpers: `const`, `lookup`, `map`, `project`, `aggregate`, `guard`, `export`, `expose`, `effect`, `on_success`, `scope`, `namespace`

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
    input :country,     type: :string
    input :vat_rate,    type: :numeric, default: 0.2

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
contract.result.gross_total   # => 120.0

contract.update_inputs(order_total: 150)
contract.result.gross_total   # => 180.0

contract.diagnostics_text     # compact execution summary
```

## Features

- **Contracts**: declare inputs, compute nodes, outputs, and compositions in a validated graph.
- **Compiler**: validate dependency graphs, types, and cycles before runtime; errors are surfaced at load time.
- **Runtime**: cache resolved nodes and invalidate only affected downstream nodes on input change.
- **Typed inputs**: validate types, defaults, and required fields at execution boundaries.
- **Composition**: execute nested contracts with isolated child executions.
- **Branch**: declarative routing — select one child contract from ordered cases at runtime.
- **Collection**: declarative fan-out — run one child contract per item in an array.
- **Distributed workflows**: `await` external events; resume via `deliver_event`.
- **igniter-server**: host contracts as a TCP/Rack HTTP service; call remote contracts with the `remote:` DSL.
- **LLM integration**: compute nodes powered by Ollama, Anthropic, or OpenAI providers.
- **Rails integration**: Railtie, ActiveJob base class, ActionCable adapter, webhook controller mixin.
- **Auditing**: collect execution timelines and snapshots.
- **Diagnostics**: compact text, Markdown, or structured reports for triage.
- **Reactive**: subscribe declaratively to runtime events with `effect`, `on_success`, `on_failure`.
- **Introspection**: render graphs as text or Mermaid; inspect runtime state.

## Quick Start Recipes

Runnable examples live in [`examples/`](examples) and are smoke-tested by `spec/igniter/example_scripts_spec.rb`.
See [`examples/README.md`](examples/README.md) for a quick index and [`docs/PATTERNS.md`](docs/PATTERNS.md) for composable patterns.

### 1. Basic Pricing Contract

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country,     type: :string

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
    input :country,     type: :string

    compose :pricing, contract: PriceContract, inputs: {
      order_total: :order_total,
      country:     :country
    }

    output :pricing
  end
end

CheckoutContract.new(order_total: 100, country: "UA").result.pricing.gross_total
# => 120.0
```

### 3. Diagnostics and Introspection

```ruby
contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total

contract.result.states
contract.result.explain(:gross_total)
contract.diagnostics.to_h
contract.diagnostics_text
contract.diagnostics_markdown
contract.audit_snapshot

PriceContract.graph.to_text
PriceContract.graph.to_mermaid
```

### 4. Machine-Readable Data

```ruby
contract.result.to_h       # => { gross_total: 120.0 }
contract.result.as_json
contract.execution.as_json
contract.events.map(&:as_json)
```

### 5. Async Store and Resume

```ruby
class AsyncQuoteExecutor < Igniter::Executor
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

contract     = AsyncPricingContract.new(order_total: 100)
deferred     = contract.result.gross_total
execution_id = contract.execution.events.execution_id

resumed = AsyncPricingContract.resume_from_store(
  execution_id, token: deferred.token, value: 150
)
resumed.result.gross_total  # => 180.0
```

### 6. Ergonomic DSL

```ruby
class MarketingQuoteContract < Igniter::Contract
  define do
    input :service,  type: :string
    input :zip_code, type: :string

    const :vendor_id, "eLocal"

    scope :routing do
      map :trade_name, from: :service do |service:|
        %w[heating cooling ventilation].include?(service.downcase) ? "HVAC" : service
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

    compute :quote, with: %i[vendor_id trade zip_code zip_supported] do |vendor_id:, trade:, zip_code:, zip_supported:|
      zip_supported
      { vendor_id: vendor_id, trade: trade[:name], zip_code: zip_code, bid: trade[:base_bid] }
    end

    expose :quote, as: :response
  end

  on_success :response do |value:, **|
    puts "Persist #{value.inspect}"
  end
end
```

Matcher-style guard shortcuts:

```ruby
guard :usa_only,          with: :country_code, eq: "USA",            message: "Unsupported country"
guard :supported_country, with: :country_code, in: %w[USA CAN],      message: "Unsupported country"
guard :valid_zip,         with: :zip_code,     matches: /\A\d{5}\z/, message: "Invalid zip"
```

### 7. Declarative Branching

```ruby
class DeliveryContract < Igniter::Contract
  define do
    input :country
    input :order_total

    branch :delivery_strategy, with: :country, inputs: {
      country:     :country,
      order_total: :order_total
    } do
      on "US", contract: USDeliveryContract
      on "UA", contract: LocalDeliveryContract
      default   contract: DefaultDeliveryContract
    end

    export :price, :eta, from: :delivery_strategy
  end
end
```

### 8. Declarative Collections

```ruby
class TechnicianBatchContract < Igniter::Contract
  define do
    input :technician_inputs, type: :array

    collection :technicians,
               with: :technician_inputs,
               each: TechnicianContract,
               key:  :technician_id,
               mode: :collect

    output :technicians
  end
end
```

In `mode: :collect`, an execution succeeds overall while items may individually fail:

- `result.summary`       — collection-level status (`:partial_failure` when any item failed)
- `result.items_summary` — compact per-item status hash
- `result.failed_items`  — failed-item error details
- `result.successes`     — hash of succeeded items only

See [`examples/collection_partial_failure.rb`](examples/collection_partial_failure.rb).

### 9. Distributed Contracts

Use `await` to suspend execution until an external event arrives. `correlate_by` identifies
which execution should receive the event, so events can be delivered from any process:

```ruby
class LeadWorkflow < Igniter::Contract
  correlate_by :request_id

  define do
    input :request_id

    await :crm_data,     event: :crm_received
    await :billing_data, event: :billing_received

    aggregate :report, with: %i[crm_data billing_data] do |crm_data:, billing_data:|
      { crm: crm_data, billing: billing_data }
    end

    output :report
  end

  on_success :report do |value:, **|
    puts "Report ready: #{value.inspect}"
  end
end

store = Igniter::Runtime::Stores::MemoryStore.new

# Launch — suspends waiting for both events
execution = LeadWorkflow.start({ request_id: "r1" }, store: store)
execution.pending?  # => true

# Deliver events from any process or webhook handler
LeadWorkflow.deliver_event(:crm_received,
  correlation: { request_id: "r1" },
  payload: { company: "Acme Corp", tier: "enterprise" },
  store: store)

LeadWorkflow.deliver_event(:billing_received,
  correlation: { request_id: "r1" },
  payload: { mrr: 500 },
  store: store)
# => prints "Report ready: { crm: ..., billing: ... }"
```

See [`examples/distributed_server.rb`](examples/distributed_server.rb) and [`docs/DISTRIBUTED_CONTRACTS_V1.md`](docs/DISTRIBUTED_CONTRACTS_V1.md).

### 10. igniter-server

Host contracts as an HTTP service and call them from another graph with the `remote:` DSL:

```ruby
# --- Service node on port 4568 ---
require "igniter/server"

class ScoringContract < Igniter::Contract
  define do
    input :value
    compute :score, depends_on: :value, call: ->(value:) { value * 1.5 }
    output :score
  end
end

Igniter::Server.configure { |c| c.port = 4568; c.register "ScoringContract", ScoringContract }
Igniter::Server.start

# --- Orchestrator on port 4567 ---
require "igniter/server"

class PipelineContract < Igniter::Contract
  define do
    input :data
    remote :scored,
           contract: "ScoringContract",
           node:     "http://localhost:4568",
           inputs:   { value: :data }
    output :scored
  end
end

Igniter::Server.configure { |c| c.port = 4567; c.register "PipelineContract", PipelineContract }
Igniter::Server.start
```

**CLI:**

```bash
igniter-server start --port 4568 --require ./contracts.rb
```

**Rack / Puma (`config.ru`):**

```ruby
require "igniter/server"
require_relative "contracts"
Igniter::Server.configure { |c| c.register "ScoringContract", ScoringContract }
run Igniter::Server.rack_app
```

**REST API:**

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/v1/contracts/:name/execute` | Execute a contract synchronously |
| `POST` | `/v1/contracts/:name/events` | Deliver an event to a distributed contract |
| `GET`  | `/v1/executions/:id` | Poll execution status |
| `GET`  | `/v1/health` | Health check with registered contracts list |
| `GET`  | `/v1/contracts` | List contracts with inputs and outputs |

See [`docs/SERVER_V1.md`](docs/SERVER_V1.md) for the full API reference, deployment patterns, and security notes.

### 11. LLM Integration

Use language models as first-class compute nodes. Supported providers: Ollama (local, zero API cost),
Anthropic (Claude), OpenAI (and compatible APIs: Groq, Mistral, Azure OpenAI):

```ruby
require "igniter/integrations/llm"

Igniter::LLM.configure do |c|
  c.default_provider = :anthropic
  c.anthropic.api_key = ENV["ANTHROPIC_API_KEY"]
end

class ClassifyExecutor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Classify feedback into: bug_report, feature_request, question."

  def call(feedback:)
    complete("Classify: #{feedback}")
  end
end

class DraftResponseExecutor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "You are a customer success agent. Write one professional response sentence."

  def call(feedback:, category:)
    complete("Feedback: #{feedback}\nCategory: #{category}\nDraft a response.")
  end
end

class FeedbackTriageContract < Igniter::Contract
  define do
    input :feedback

    compute :category, depends_on: :feedback,             with: ClassifyExecutor
    compute :response, depends_on: %i[feedback category], with: DraftResponseExecutor

    output :category
    output :response
  end
end
```

Multi-step reasoning with conversation history:

```ruby
class MultiStepExecutor < Igniter::LLM::Executor
  def call(text:, prior_analysis:)
    ctx = Context.empty(system: self.class.system_prompt)
      .append_user("Initial: #{text}")
      .append_assistant(prior_analysis)
    chat(context: ctx)
  end
end
```

See [`examples/llm/research_agent.rb`](examples/llm/research_agent.rb), [`examples/llm/tool_use.rb`](examples/llm/tool_use.rb), and [`docs/LLM_V1.md`](docs/LLM_V1.md).

## Examples

| Example | Run | Shows |
|---------|-----|-------|
| `basic_pricing.rb` | `ruby examples/basic_pricing.rb` | Basic contract, lazy resolution, input updates |
| `composition.rb` | `ruby examples/composition.rb` | Nested contracts and composed results |
| `diagnostics.rb` | `ruby examples/diagnostics.rb` | Diagnostics text and machine-readable output |
| `async_store.rb` | `ruby examples/async_store.rb` | Pending execution, file-backed store, worker-style resume |
| `marketing_ergonomics.rb` | `ruby examples/marketing_ergonomics.rb` | `const`, `lookup`, `map`, `guard`, `scope`, `namespace`, `expose`, `on_success`, `explain_plan` |
| `collection.rb` | `ruby examples/collection.rb` | Fan-out, stable item keys, `CollectionResult` |
| `collection_partial_failure.rb` | `ruby examples/collection_partial_failure.rb` | `:collect` mode, partial failure summary, collection diagnostics |
| `ringcentral_routing.rb` | `ruby examples/ringcentral_routing.rb` | `branch`, nested `collection`, `project`, `aggregate`, diagnostics |
| `order_pipeline.rb` | `ruby examples/order_pipeline.rb` | `guard` + `collection` + `branch` + `export` in one flow |
| `distributed_server.rb` | `ruby examples/distributed_server.rb` | `await`, `correlate_by`, `start`, `deliver_event`, `on_success` |
| `server/node1.rb` + `node2.rb` | run both, then curl | Two-node igniter-server with `remote:` DSL |
| `llm/research_agent.rb` | `ruby examples/llm/research_agent.rb` | Multi-step LLM pipeline with Ollama |
| `llm/tool_use.rb` | `ruby examples/llm/tool_use.rb` | LLM tool declarations, chained LLM nodes, `Context` |

## Design Docs

- [Architecture v2](docs/ARCHITECTURE_V2.md)
- [Execution Model v2](docs/EXECUTION_MODEL_V2.md)
- [API Draft v2](docs/API_V2.md)
- [Patterns](docs/PATTERNS.md)
- [Branches v1](docs/BRANCHES_V1.md)
- [Collections v1](docs/COLLECTIONS_V1.md)
- [Distributed Contracts v1](docs/DISTRIBUTED_CONTRACTS_V1.md)
- [Store Adapters](docs/STORE_ADAPTERS.md)
- [igniter-server v1](docs/SERVER_V1.md)
- [LLM Integration v1](docs/LLM_V1.md)
- [Concepts and Principles](docs/IGNITER_CONCEPTS.md)

## Development

```bash
rake          # specs + RuboCop
rake spec     # tests only
rake rubocop  # lint only
rake build    # build gem
```

Current feature baseline:

- synchronous runtime + parallel thread-pool runner
- pending / deferred node states with snapshot / restore
- store-backed resume flow (MemoryStore, FileStore)
- compile-time graph validation, typed inputs, cycle detection
- composition, branch, collection, guard, scope / namespace
- distributed workflows: `await`, `correlate_by`, `start`, `deliver_event`
- igniter-server: TCP server, Rack adapter, CLI, `remote:` DSL
- LLM compute nodes: Ollama, Anthropic, OpenAI providers
- Rails integration: Railtie, ActiveJob, ActionCable, webhook controller mixin
- auditing, diagnostics, reactive subscriptions, graph introspection

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
