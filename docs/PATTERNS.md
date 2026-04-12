# Igniter Patterns

This document collects recommended orchestration shapes that already have runnable examples in the repository.

The goal is not to introduce new primitives, but to show how the existing DSL composes into readable contracts.

## 1. Linear Derivation

Use this when the flow is a straight dependency chain with no routing or fan-out.

Example:

- [basic_pricing.rb](../examples/basic_pricing.rb)

Use:

- pricing
- totals
- normalization pipelines
- simple business formulas

Shape:

```ruby
input :order_total
input :country

compute :vat_rate, with: :country do |country:|
  country == "UA" ? 0.2 : 0.0
end

compute :gross_total, with: %i[order_total vat_rate] do |order_total:, vat_rate:|
  order_total * (1 + vat_rate)
end

output :gross_total
```

## 2. Stage Composition

Use this when one contract should orchestrate several bounded subgraphs.

Examples:

- [composition.rb](../examples/composition.rb)
- [ringcentral_routing.rb](../examples/ringcentral_routing.rb)

Use:

- reusable business stages
- transport shell + domain pipeline
- larger flows with clear internal boundaries

Guideline:

- keep the parent contract thin
- export child outputs explicitly
- read child diagnostics from the child execution, not from the parent by default

## 3. Scoped Domain Flow

Use this when the graph is still one contract, but a flat node list becomes hard to read.

Example:

- [marketing_ergonomics.rb](../examples/marketing_ergonomics.rb)

Use:

- routing
- validation
- pricing
- response shaping

Shape:

```ruby
scope :routing do
  map :trade_name, from: :service do |service:|
    ...
  end
end

namespace :validation do
  guard :zip_supported, with: :zip_code, in: %w[60601 10001], message: "Unsupported zip"
end
```

Guideline:

- use `scope` and `namespace` for readability first
- do not treat them as runtime boundaries

## 4. Declarative Routing

Use this when control flow depends on a selector value and should stay visible in the graph.

Examples:

- [ringcentral_routing.rb](../examples/ringcentral_routing.rb)

Use:

- vendor routing
- status routing
- country-specific flows
- mode-specific processing

Shape:

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

Guideline:

- keep branch contracts on a shared input interface
- let compile-time validation force interface consistency
- use explicit `export` from the branch node

## 5. Fan-Out With Stable Identity

Use this when a node should run the same child contract for many item inputs.

Examples:

- [collection.rb](../examples/collection.rb)
- [collection_partial_failure.rb](../examples/collection_partial_failure.rb)
- [ringcentral_routing.rb](../examples/ringcentral_routing.rb)

Use:

- technicians
- calls
- locations
- vendors
- external records

Shape:

```ruby
collection :technicians,
  with: :technician_inputs,
  each: TechnicianContract,
  key: :technician_id,
  mode: :collect
```

Guideline:

- feed `collection` an array of item input hashes
- choose a stable `key:`
- keep item logic in the child contract, not in a giant parent `compute`

## 6. Partial Failure Without Failing The Whole Execution

Use `mode: :collect` when you want item-level failures surfaced, but not promoted to parent execution failure.

Example:

- [collection_partial_failure.rb](../examples/collection_partial_failure.rb)

What to read:

- `result.summary`
- `result.items_summary`
- `result.failed_items`
- `contract.diagnostics_text`
- `contract.diagnostics_markdown`

Guideline:

- parent execution can still be `succeeded`
- collection summary may be `:partial_failure`
- diagnostics should be read at collection level, not only at execution status level

## 7. Nested Branch + Collection

Use this when routing chooses a stage, and that stage performs fan-out or per-item routing.

Example:

- [ringcentral_routing.rb](../examples/ringcentral_routing.rb)

Observed semantics:

- parent execution records top-level `branch_selected`
- collection item events belong to the selected child execution
- child diagnostics is usually the best place to inspect collection status

Guideline:

- inspect parent audit for high-level routing
- inspect child audit for item-level fan-out behavior

## 8. Async Resume Flow

Use this when a node cannot complete immediately and should suspend the execution.

Example:

- [async_store.rb](../examples/async_store.rb)

Use:

- external jobs
- long-running enrichment
- async pricing or classification

Guideline:

- model the slow step as a deferred node
- resume with store-backed execution restore
- keep downstream graph pure and resumable

## 9. Distributed Event-Driven Contract

Use this when execution spans multiple external triggers (webhooks, background jobs, async callbacks) that arrive at different times.

Examples:

- [distributed_server.rb](../examples/distributed_server.rb)

Use:

- multi-step approval workflows
- job application pipelines
- order fulfilment with external vendor callbacks
- KYC / onboarding flows requiring background checks

Key DSL:

```ruby
class ApplicationReviewWorkflow < Igniter::Contract
  correlate_by :application_id       # uniquely identifies an in-flight execution

  define do
    input :application_id
    input :applicant_name

    # Execution suspends here until the named event is delivered
    await :screening_result, event: :screening_completed
    await :manager_review,   event: :manager_reviewed

    compute :decision, depends_on: %i[screening_result manager_review] do |screening_result:, manager_review:|
      manager_review[:approved] && screening_result[:passed] ? :hired : :rejected
    end

    output :decision
  end
end

store = Igniter::Runtime::Stores::MemoryStore.new

# Launch — suspends at the first await
exec = ApplicationReviewWorkflow.start({ application_id: "app-1", applicant_name: "Alice" }, store: store)

# Deliver events as they arrive (order does not matter)
ApplicationReviewWorkflow.deliver_event(:screening_completed,
  correlation: { application_id: "app-1" },
  payload: { passed: true, score: 92 },
  store: store)

final = ApplicationReviewWorkflow.deliver_event(:manager_reviewed,
  correlation: { application_id: "app-1" },
  payload: { approved: true, note: "Strong candidate" },
  store: store)

final.result.decision  # => :hired
```

Guideline:

- choose correlation keys that uniquely identify the in-flight instance
- deliver events from any process; the store is the coordination layer
- keep `await` payloads as plain hashes — they become the node's resolved value
- `on_success` / `on_exit` callbacks fire when the final event resolves the graph

## 10. Remote Contract Composition

Use this when logic lives on a different service node and should be called over HTTP inside a graph.

Examples:

- [examples/server/](../examples/server/)

Key DSL:

```ruby
require "igniter/server"

# ── Service node (runs on port 4568) ─────────────────────────────────────────

class ScoringContract < Igniter::Contract
  define do
    input :value
    compute :score, depends_on: :value do |value:|
      value * 1.5
    end
    output :score
  end
end

Igniter::Server.configure do |c|
  c.port = 4568
  c.register "ScoringContract", ScoringContract
end
Igniter::Server.start  # blocking

# ── Orchestrator node (runs on port 4567) ─────────────────────────────────────

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
```

Guideline:

- validate the `node:` URL at compile time — the graph will reject bad URLs before runtime
- keep remote contracts on a shared input interface so they are easy to swap
- igniter-server is stateless over HTTP; use a shared store for distributed state
- start the service with `bin/igniter-server start --port 4568 --require ./contracts.rb`

## 11. LLM Compute Node

Use this when a step requires a language model — classification, summarisation, drafting, or multi-step agent chains.

Examples:

- [llm/tool_use.rb](../examples/llm/tool_use.rb)

Key DSL:

```ruby
require "igniter/ai"

Igniter::AI.configure do |c|
  c.default_provider = :anthropic
  c.anthropic.api_key = ENV.fetch("ANTHROPIC_API_KEY")
end

class SummarizeExecutor < Igniter::AI::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Return a single concise sentence summary."

  def call(text:)
    complete("Summarize: #{text}")
  end
end

class ArticleContract < Igniter::Contract
  define do
    input :text
    compute :summary, depends_on: :text, call: SummarizeExecutor
    output :summary
  end
end

ArticleContract.new(text: "Long article...").result.summary
```

For multi-turn conversations, use `Igniter::AI::Context`:

```ruby
def call(feedback:, category:)
  ctx = Igniter::AI::Context
    .empty(system: self.class.system_prompt)
    .append_user("Feedback: #{feedback}")
    .append_user("Category: #{category}")
  chat(context: ctx)
end
```

For tool use (Anthropic function calling), declare tools at the class level:

```ruby
class ClassifyExecutor < Igniter::AI::Executor
  tools({
    name: "set_category",
    description: "Record the detected category",
    input_schema: { type: "object", properties: { category: { type: "string" } }, required: ["category"] }
  })

  def call(feedback:)
    complete_with_tools("Classify: #{feedback}")
  end
end
```

Guideline:

- keep prompts inside the executor class, not scattered in the graph
- use `Context` when a step needs multi-turn history rather than a single prompt
- chain LLM executors as normal `compute` nodes — the graph handles ordering and caching
- mock the provider in tests and CI; real API calls belong in integration tests only
