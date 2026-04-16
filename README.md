# Igniter

Igniter is a Ruby gem for expressing business logic as a validated dependency graph and executing that graph with:

- lazy output resolution and selective cache invalidation
- typed input validation with defaults and required fields
- nested contract composition with isolated child executions
- declarative routing (`branch`) and fan-out (`collection`)
- distributed workflows: `await` events across process boundaries
- multi-node deployments via `igniter-stack` and the `remote:` DSL
- AI compute nodes with Ollama, Anthropic, and OpenAI providers
- transport-neutral communication adapters via `Igniter::Channels`
- Rails plugin: ActiveJob, ActionCable, webhook handlers, generators
- runtime auditing, diagnostics reports, and reactive side effects
- graph and runtime introspection (text, Mermaid)
- ergonomic DSL helpers: `const`, `lookup`, `map`, `project`, `aggregate`, `guard`, `export`, `expose`, `effect`, `on_success`, `scope`, `namespace`
- `Igniter::Stack` + `Igniter::App` — standard app runtime/profile with `apps/`, YAML config, autoloading, and scheduler; scaffold generation is an explicit pack behind `igniter-stack new`
- capability-based security: declare executor resource requirements, enforce `Policy` at runtime
- temporal contracts: reproducible historical execution via an explicit `as_of` time input
- content-addressed computation: `pure` executors cached by input fingerprint across executions and processes

## Installation

```ruby
gem "igniter"
```

## Loading Conventions

`Igniter` now uses explicit layer entrypoints. The root `lib/igniter/` directory is
reserved for top-level layer modules, while substantive implementation lives under
layer folders.

| What you want | Require |
|---------------|---------|
| Contract DSL, model, compiler, runtime | `require "igniter"` |
| Actor runtime and tool foundation | `require "igniter/core"` |
| SDK registry / capability activation | `require "igniter/sdk"` |
| Built-in operational tools | `require "igniter/sdk/tools"` |
| Generic built-in agents | `require "igniter/sdk/agents"` |
| Specific core features | `require "igniter/core/tool"`, `require "igniter/core/memory"`, `require "igniter/core/temporal"` |
| App data persistence | `require "igniter/sdk/data"` |
| Behavioral extensions | `require "igniter/extensions/auditing"`, `require "igniter/extensions/capabilities"` |
| AI providers, skills, transcription | `require "igniter/sdk/ai"` |
| Communication transports | `require "igniter/sdk/channels"` |
| HTTP hosting | `require "igniter/server"` |
| Opinionated app profile | `require "igniter/app"` |
| Narrow app runtime | `require "igniter/app/runtime"` |
| Distributed runtime | `require "igniter/cluster"` |
| Rails plugin | `require "igniter/plugins/rails"` |
| View plugin | `require "igniter/plugins/view"` |
| View + Arbre adapter | `require "igniter/plugins/view/arbre"` |
| View + Tailwind helpers | `require "igniter/plugins/view/tailwind"` |

## Terminology

- **Core**: the hard foundation loaded through `require "igniter"` and `require "igniter/core/*"`.
- **Core features**: focused building blocks that still belong to core, such as tools, memory, metrics, temporal support, and caches.
- **Extensions**: opt-in behavioral add-ons loaded from `igniter/extensions/*`.
- **SDK packs**: optional shared capabilities loaded from `igniter/sdk/*`, such as `Igniter::AI`, `Igniter::Agents`, `Igniter::Channels`, `Igniter::Data`, and the built-in tools pack.
- **Hosting layers**: `Igniter::Server` and `Igniter::Cluster`.
- **Profile**: `Igniter::Stack` + `Igniter::App`, a packaged way to assemble an app and run it through host, loader, and scheduler adapters. The public entrypoint is `require "igniter/app"`. The defaults are `host :app`, `loader :filesystem`, and `scheduler :threaded`, and `require "igniter/cluster"` adds `host :cluster_app` for cluster-aware apps.
- **Plugin**: framework or environment integration loaded from `igniter/plugins/*`, such as `Igniter::Rails` or `Igniter::Plugins::View`.

`Igniter::Plugins::View` stays optional by design. Load the base plugin for the
small built-in Ruby HTML DSL, then opt into adapters only where they help:

- `require "igniter/plugins/view"` keeps the dependency surface minimal.
- `require "igniter/plugins/view/arbre"` adds an Arbre integration boundary without making `arbre` a dependency of Igniter itself.
- `require "igniter/plugins/view/tailwind"` adds a Tailwind-friendly page shell for dashboards and admin surfaces.
- `Igniter::Plugins::View::Tailwind::UI` provides reusable dashboard and schema primitives such as metric cards, panels, status badges, banners, action bars, inline actions, key-value lists, field wrappers, form sections, message/error pages, and shared action/link style tokens.
- `Igniter::Plugins::View::Tailwind.render_page(...)` and `render_message_page(...)` also expose built-in visual presets such as `theme: :ops`, `theme: :companion`, and `theme: :schema`, so apps can share a consistent shell while still overriding local layout details when needed.

## Deployment Modes

Igniter scales from a single `require` to a multi-node cluster. Each mode is a strict
superset of the one before it — your domain contracts never change.

| Mode | Use case | Entry point |
|------|----------|-------------|
| **Embed** | Add to Rails / Sidekiq / plain Ruby | `require "igniter"` |
| **Server** | Standalone single-machine app runtime | `require "igniter/app"` |
| **Cluster** | Multi-node with Raft consensus + gossip mesh | `require "igniter/cluster"` |

See [`docs/LAYERS_V1.md`](docs/LAYERS_V1.md) for the layer contract and [`docs/DEPLOYMENT_V1.md`](docs/DEPLOYMENT_V1.md) for scenario-specific setup.
[`docs/SDK_V1.md`](docs/SDK_V1.md) is the canonical reference for optional `sdk/*` packs.
[`docs/PLUGINS_V1.md`](docs/PLUGINS_V1.md) is the canonical reference for `plugins/*`.
[`docs/MODULE_SYSTEM_V1.md`](docs/MODULE_SYSTEM_V1.md) is the top-level map that ties runtime layers, `sdk/*`, and `plugins/*` together.

Layer DSL can opt into SDK packs explicitly:

```ruby
Igniter.use :data

class MyApp < Igniter::App
  use :ai, :tools
end

Igniter::Cluster.use :channels
```

Optional capability packs now load only through `igniter/sdk/*`.
Top-level optional entrypoints such as `igniter/ai`, `igniter/agents`, `igniter/channels`,
`igniter/data`, and `igniter/tools` are no longer part of the public API.

---

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
- **igniter-stack**: host contracts as a TCP/Rack HTTP service; call remote contracts with the `remote:` DSL.
- **AI layer**: compute nodes powered by Ollama, Anthropic, or OpenAI providers.
- **Rails plugin**: Railtie, ActiveJob base class, ActionCable adapter, webhook controller mixin.
- **Auditing**: collect execution timelines and snapshots.
- **Diagnostics**: compact text, Markdown, or structured reports for triage.
- **Reactive**: subscribe declaratively to runtime events with `effect`, `on_success`, `on_failure`.
- **Introspection**: render graphs as text or Mermaid; inspect runtime state.
- **Capabilities**: executors declare what resources they need (`:network`, `:database`, …); `Policy` denies them at runtime.
- **Temporal contracts**: inject `as_of` time input automatically; replay any historical computation with the original timestamp.
- **Content addressing**: `pure` executors get a universal cache key — identical inputs return a cached result across executions, processes, and deployments.
- **Incremental dataflow**: `mode: :incremental` on collection nodes — only added/changed items run, unchanged items reuse cached results, removed items are retracted. O(change) not O(total).

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

Matcher-style branching is also supported:

```ruby
branch :delivery_strategy, with: :country, inputs: { country: :country, order_total: :order_total } do
  on eq: "US",                contract: USDeliveryContract
  on in: %w[CA MX],           contract: NorthAmericaContract
  on matches: /\A[A-Z]{2}\z/, contract: InternationalContract
  default contract: DefaultDeliveryContract
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

### 10. igniter-stack

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
# Generate a new application scaffold
igniter-stack new my_app

# Start a server directly
igniter-stack start --port 4568 --require ./contracts.rb
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
require "igniter/sdk/ai"

Igniter::AI.configure do |c|
  c.default_provider = :anthropic
  c.anthropic.api_key = ENV["ANTHROPIC_API_KEY"]
end

class ClassifyExecutor < Igniter::AI::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Classify feedback into: bug_report, feature_request, question."

  def call(feedback:)
    complete("Classify: #{feedback}")
  end
end

class DraftResponseExecutor < Igniter::AI::Executor
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
class MultiStepExecutor < Igniter::AI::Executor
  def call(text:, prior_analysis:)
    ctx = Context.empty(system: self.class.system_prompt)
      .append_user("Initial: #{text}")
      .append_assistant(prior_analysis)
    chat(context: ctx)
  end
end
```

See [`examples/llm/research_agent.rb`](examples/llm/research_agent.rb), [`examples/llm/tool_use.rb`](examples/llm/tool_use.rb), and [`docs/LLM_V1.md`](docs/LLM_V1.md).

### 12. Igniter::App / Igniter::Stack

Package contracts, executors, scheduler, and server config into a stack with leaf apps:

```bash
# Scaffold a new stack
igniter-stack new my_app
igniter-stack new playgrounds/home-lab --profile playground
cd my_app && bundle install && bin/start
```

```ruby
require "igniter/stack"
require_relative "apps/main/app"

module MyApp
  class Stack < Igniter::Stack
    root_dir __dir__
    shared_lib_path "lib"

    app :main, path: "apps/main", klass: MyApp::MainApp, default: true
  end
end

MyApp::Stack.start(:main)
```

```ruby
# apps/main/app.rb
require "igniter/app"
require "igniter/core"

module MyApp
  class MainApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    tools_path     "app/tools"
    skills_path    "app/skills"
    executors_path "app/executors"
    contracts_path "app/contracts"
    agents_path    "app/agents"

    on_boot do
      register "OrderContract", MyApp::OrderContract
    end
  end
end
```

The generator now creates:

```text
my_app/
├── stack.rb
├── apps/
│   └── main/
│       ├── app.rb
│       ├── app.yml
│       ├── app/
│       └── spec/
├── lib/my_app/shared/
├── spec/
├── bin/start
└── bin/demo
```

Use `--profile playground` when you want a proving-ground scaffold layered on top
of the base stack generator. The playground profile adds a small `main +
dashboard` slice without baking that shape into the default scaffold.

`Igniter::Stack` coordinates named apps under `apps/*`. The root `spec/` is for
shared code and integration/stack tests. `Igniter::App` remains the leaf
runtime for each app.

**`apps/main/app.yml`** — base config loaded before the `configure` block (block always wins):

```yaml
app_host:
  port: 4567
  host: "0.0.0.0"
  log_format: json    # text (default) or json
  drain_timeout: 30
```

**Scheduler interval formats:** `30` (seconds), `"30s"`, `"5m"`, `"2h"`, `"1d"`, `{ hours: 1, minutes: 30 }`

See [`docs/APP_V1.md`](docs/APP_V1.md) for the leaf app reference and [`docs/STACKS_V1.md`](docs/STACKS_V1.md) for the standard stack layout.

### 13. Capability-Based Security

Declare what external resources an executor needs, then deny specific capabilities at the
policy level — without touching the executors themselves:

```ruby
require "igniter/extensions/capabilities"

class DbLookup < Igniter::Executor
  capabilities :database

  def call(id:)
    DB.find(id)
  end
end

class PureCalc < Igniter::Executor
  pure  # shorthand for capabilities(:pure)

  def call(x:, y:) = x + y
end

# Inspect the graph's surface area before deploying
MyContract.compiled_graph.required_capabilities
# => { fetch: [:database], total: [:pure] }

# Enforce policy at boot time
Igniter::Capabilities.policy = Igniter::Capabilities::Policy.new(denied: [:database])

MyContract.new(id: 1).resolve_all
# => CapabilityViolationError: Node 'fetch' uses denied capabilities: database
```

See [`docs/CAPABILITIES_V1.md`](docs/CAPABILITIES_V1.md).

### 14. Temporal Contracts

Make time an explicit input so every execution is fully reproducible:

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

# Current rate
TaxRateContract.new(country: "UA").result.rate
# => 0.22

# Reproduce the exact 2024 result
TaxRateContract.new(country: "UA", as_of: Time.new(2024, 1, 1)).result.rate
# => 0.20
```

See [`docs/TEMPORAL_V1.md`](docs/TEMPORAL_V1.md).

### 15. Content-Addressed Computation

`pure` executors are cached by a fingerprint of their logic + inputs. Identical computation
is never repeated — within an execution, across executions, or across processes:

```ruby
require "igniter/extensions/content_addressing"

class TaxCalculator < Igniter::Executor
  pure
  fingerprint "tax_calc_v1"   # bump to invalidate the cache when logic changes

  def call(country:, amount:)
    TAX_RATES[country] * amount
  end
end

# First execution — computes and caches
InvoiceContract.new(country: "UA", amount: 1000).result.tax  # computed

# Second execution — served from cache; TaxCalculator is never called
InvoiceContract.new(country: "UA", amount: 1000).result.tax  # cache hit

# Distributed cache (Redis) — shared across all nodes
Igniter::ContentAddressing.cache = RedisContentCache.new(Redis.new)
```

See [`docs/CONTENT_ADDRESSING_V1.md`](docs/CONTENT_ADDRESSING_V1.md).

### 16. Incremental Dataflow — O(change) Collection Processing

`mode: :incremental` on a collection node makes the runtime diff the input array on
every `resolve_all`. Only added/changed items have their child contract re-run;
unchanged items reuse the cached result; removed items are retracted automatically.

```ruby
require "igniter/extensions/dataflow"

class SensorPipeline < Igniter::Contract
  define do
    input :readings, type: :array

    collection :processed,
               with: :readings,
               each: SensorAnalysis,
               key:  :sensor_id,
               mode: :incremental,
               window: { last: 1000 }   # bounded memory

    output :processed
  end
end

pipeline = SensorPipeline.new(readings: initial_batch)
pipeline.resolve_all  # all N items run once

# Push only the delta — no full-array replacement needed
pipeline.feed_diff(:readings,
  add:    [{ sensor_id: "new-1", value: 10 }],
  update: [{ sensor_id: "tmp-2", value: 90 }],
  remove: ["hum-1"]
)
pipeline.resolve_all  # only 2 child contracts run (new-1 + tmp-2)

diff = pipeline.collection_diff(:processed)
diff.processed_count  # => 2
diff.unchanged.size   # => N - 2
```

See [`docs/DATAFLOW_V1.md`](docs/DATAFLOW_V1.md).

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
| `server/node1.rb` + `node2.rb` | run both, then curl | Two-node igniter-stack with `remote:` DSL |
| `llm/research_agent.rb` | `ruby examples/llm/research_agent.rb` | Multi-step LLM pipeline with Ollama |
| `llm/tool_use.rb` | `ruby examples/llm/tool_use.rb` | LLM tool declarations, chained LLM nodes, `Context` |
| `companion/bin/demo` | `ruby examples/companion/bin/demo` | Stack-based voice assistant demo with `apps/main` + `apps/inference` |
| `companion_legacy/bin/demo` | `ruby examples/companion_legacy/bin/demo` | End-to-end voice AI pipeline reference during workspace migration |
| `dataflow.rb` | `ruby examples/dataflow.rb` | Incremental sensor pipeline: `mode: :incremental`, `feed_diff`, sliding window |

## Design Docs

- [Architecture Index](docs/ARCHITECTURE_INDEX.md)
- [Deployment Scenarios v1](docs/DEPLOYMENT_V1.md)
- [Architecture v2](docs/ARCHITECTURE_V2.md)
- [Execution Model v2](docs/EXECUTION_MODEL_V2.md)
- [API Draft v2](docs/API_V2.md)
- [Patterns](docs/PATTERNS.md)
- [Branches v1](docs/BRANCHES_V1.md)
- [Collections v1](docs/COLLECTIONS_V1.md)
- [Distributed Contracts v1](docs/DISTRIBUTED_CONTRACTS_V1.md)
- [Store Adapters](docs/STORE_ADAPTERS.md)
- [igniter-stack v1](docs/SERVER_V1.md)
- [LLM Integration v1](docs/LLM_V1.md)
- [App scaffold v1](docs/APP_V1.md)
- [Stacks v1](docs/STACKS_V1.md)
- [Capabilities v1](docs/CAPABILITIES_V1.md)
- [Temporal Contracts v1](docs/TEMPORAL_V1.md)
- [Content Addressing v1](docs/CONTENT_ADDRESSING_V1.md)
- [Incremental Dataflow v1](docs/DATAFLOW_V1.md)
- [Concepts and Principles](docs/IGNITER_CONCEPTS.md)

## Development

```bash
rake          # specs + RuboCop
rake architecture # architectural boundary guards
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
- igniter-stack: TCP server, Rack adapter, CLI, `remote:` DSL
- AI layer: Ollama, Anthropic, OpenAI providers
- Rails plugin: Railtie, ActiveJob, ActionCable, webhook controller mixin
- `Igniter::Stack` + `Igniter::App`: stack scaffold, YAML config, autoloading, scheduler, generator (`igniter-stack new`)
- auditing, diagnostics, reactive subscriptions, graph introspection
- capability-based security: `capabilities`, `pure`, `Policy`, `CapabilityViolationError`
- temporal contracts: `include Igniter::Temporal`, `temporal_compute`, `as_of` input, historical reproduction
- content-addressed computation: `pure`, `fingerprint`, universal `ContentKey`, pluggable `ContentCache`
- incremental dataflow: `mode: :incremental`, `window:`, `feed_diff`, `collection_diff`, `DiffState`, `IncrementalCollectionResult`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
