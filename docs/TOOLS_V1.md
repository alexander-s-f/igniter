# Igniter::Tool — AI-Callable Tools — v1

`Igniter::Tool` bridges declarative Igniter primitives with LLM function-calling APIs.
Each tool is an `Igniter::Executor` subclass enriched with metadata — so it can be
used both as a standard compute node in any `Igniter::Contract` graph AND as an
AI-callable function with auto-generated JSON schemas for Anthropic / OpenAI.

---

## Overview

```
Igniter::Tool < Igniter::Executor
│
├── description "..."        ← for LLM context
├── param :name, type:, ...  ← auto-generates JSON Schema
├── requires_capability :x   ← capability guard (enforced before call)
│
├── to_schema(:anthropic)    ← Anthropic tool definition Hash
├── to_schema(:openai)       ← OpenAI tool definition Hash
│
└── def call(**kwargs)       ← implementation
```

---

## Defining a tool

```ruby
require "igniter/core/tool"

class DatabaseLookup < Igniter::Tool
  description "Look up a product by SKU in the catalog"

  param :sku,    type: :string,  required: true,  desc: "Product SKU identifier"
  param :fields, type: :array,   default: nil,    desc: "Fields to return (nil = all)"

  requires_capability :database_read   # LLM executor must declare this capability

  def call(sku:, fields: nil)
    product = ProductCatalog.find(sku)
    fields ? product.slice(*fields) : product
  end
end
```

## Built-in system introspection tool

Igniter can also expose a safe host snapshot tool for environment-aware agents:

```ruby
require "igniter/tools"

result = Igniter::Tools::SystemDiscoveryTool.new.call_with_capability_check!(
  allowed_capabilities: [:system_read],
  include_environment: true,
  environment_keys: %w[HOME PATH SHELL],
  utility_candidates: %w[ruby git rg sqlite3 pio docker],
  scan_path_entries: false
)
```

`Igniter::Tools::SystemDiscoveryTool` does not shell out. It inspects the current
Ruby runtime, host metadata, `PATH`, and executable presence using standard
library facilities only. This makes it a good default discovery/introspection
tool for agent-style applications that need to understand their local
environment before selecting workflows or tools.

Igniter also includes a companion selector tool:

```ruby
selection = Igniter::Tools::LocalWorkflowSelectorTool.new.call_with_capability_check!(
  allowed_capabilities: [:system_read],
  goals: %w[esp32 hardware],
  include_discovery: false
)
```

`Igniter::Tools::LocalWorkflowSelectorTool` builds on `SystemDiscoveryTool` and
returns concrete workflow recommendations with missing-utility diagnostics. It
is useful as a bootstrap step for agents that should adapt to the current node
instead of assuming that `docker`, `pio`, `ollama`, `ffmpeg`, or `sqlite3` are
available everywhere.

For more opinionated setup guidance, Igniter also includes:

```ruby
plan = Igniter::Tools::AgentBootstrapTool.new.call_with_capability_check!(
  allowed_capabilities: [:system_read],
  goal: "cluster_debug"
)
```

`Igniter::Tools::AgentBootstrapTool` turns a named goal such as
`esp32_bringup`, `cluster_debug`, `local_ai_node`, or `dashboard_dev` into a
concrete bootstrap plan with recommended workflows, steps, and success
criteria. It is a good fit for agent onboarding and environment-aware startup
flows.

### Supported param types

| Symbol | JSON type |
|--------|-----------|
| `:string` | `"string"` |
| `:integer` | `"integer"` |
| `:float` | `"number"` |
| `:boolean` | `"boolean"` |
| `:array` | `"array"` |
| `:object` | `"object"` |

---

## Schema generation

```ruby
DatabaseLookup.tool_name   # => "database_lookup"  (ClassName → snake_case)

# Intermediate format (used internally by Igniter, processed by normalize_tools)
DatabaseLookup.to_schema
# => { name: "database_lookup", description: "...", parameters: { ... } }

# Provider-specific final formats
DatabaseLookup.to_schema(:anthropic)
# => { name: "database_lookup", description: "...", input_schema: { ... } }

DatabaseLookup.to_schema(:openai)
# => { type: "function", function: { name: "database_lookup", ... } }
```

---

## `Igniter::AI::ToolRegistry` — discovery and schema export

```ruby
require "igniter/ai"

# Global registration (typically in an initializer)
Igniter::AI::ToolRegistry.register(Calculator, DatabaseLookup, SendEmail)

# Discovery
Igniter::AI::ToolRegistry.all                               # => [Calculator, DatabaseLookup, SendEmail]
Igniter::AI::ToolRegistry.find("calculator")                # => Calculator

# Capability filtering — only tools the agent is authorized to call
Igniter::AI::ToolRegistry.tools_for(capabilities: [:database_read])
# => [Calculator, DatabaseLookup]   (SendEmail needs :email_send)

# Schema export
Igniter::AI::ToolRegistry.schemas                           # intermediate, all tools
Igniter::AI::ToolRegistry.schemas(:anthropic)               # Anthropic format, all
Igniter::AI::ToolRegistry.schemas(:openai, capabilities: [:database_read])  # filtered
```

---

## Capability guard

`requires_capability` declares what the calling agent must be allowed to do.
The guard runs **before `call`** — if the agent lacks a required capability,
`Igniter::Tool::CapabilityError` is raised immediately.

```ruby
class SendEmail < Igniter::Tool
  description "Send an email to a recipient"
  param :to,      type: :string, required: true
  param :subject, type: :string, required: true
  param :body,    type: :string, required: true
  requires_capability :email_send

  def call(to:, subject:, body:)
    EmailService.deliver(to: to, subject: subject, body: body)
    { sent: true }
  end
end

# Direct guard check
SendEmail.new.call_with_capability_check!(
  allowed_capabilities: [:email_send],
  to: "user@example.com", subject: "Hello", body: "..."
)
# => { sent: true }

SendEmail.new.call_with_capability_check!(
  allowed_capabilities: [],         # missing :email_send
  to: "user@example.com", ...
)
# => Igniter::Tool::CapabilityError:
#    Tool "send_email" requires capabilities [:email_send] but agent only has []
```

The agent's capabilities come from the `Igniter::Executor.capabilities` DSL
inherited by `AI::Executor`:

```ruby
class SupportAgent < Igniter::AI::Executor
  capabilities :database_read, :email_send   # what this agent may do
  tools DatabaseLookup, SendEmail
  ...
end
```

---

## AI::Executor — automatic tool-use loop

When `tools` DSL contains `Igniter::Tool` subclasses, `#complete` runs an
automatic loop:

```
LLM request + tool schemas
        │
        ▼
 ┌─────────────────┐
 │  LLM response   │── text only ──► return text
 └─────────────────┘
        │ tool_use blocks
        ▼
 CapabilityGuard.check!        ← raises CapabilityError if cap missing
        │
        ▼
 Tool#call(**arguments)        ← error text returned if StandardError
        │
        ▼
 Append :tool_results message
        │
        └──► repeat (up to max_tool_iterations)
```

```ruby
class ProductAssistant < Igniter::AI::Executor
  provider :anthropic
  model "claude-haiku-4-5-20251001"
  system_prompt "You are a product assistant. Use tools when needed."

  tools Calculator, DatabaseLookup, SendEmail
  capabilities :database_read, :email_send   # authorizes these tools
  max_tool_iterations 8                       # default: 10

  def call(question:)
    complete(question)
    # complete() automatically:
    # 1. Sends tool schemas to Anthropic API
    # 2. Handles tool_use responses in a loop
    # 3. Returns final text when LLM stops calling tools
  end
end

assistant = ProductAssistant.new
answer    = assistant.call(question: "What's the price of SKU-001 and apply 15% discount?")
puts answer
# "Widget Pro (SKU-001) costs $29.99. With a 15% discount, the final price is $25.49."
```

### Error handling in the loop

| Situation | Behaviour |
|-----------|-----------|
| Tool raises `CapabilityError` | Re-raised immediately — loop stops |
| Tool raises any other error | Error message string returned as tool result; LLM can recover |
| Unknown tool name in response | `"Unknown tool: ..."` returned as tool result |
| Loop exceeds `max_tool_iterations` | `Igniter::AI::ToolLoopError` raised |

---

## Tool as a Contract compute node

`Tool < Executor` — full backward compatibility. Use a tool anywhere an executor is used:

```ruby
class PriceReport < Igniter::Contract
  define do
    input :sku

    compute :product,  with: :sku,     call: DatabaseLookup
    compute :discount, with: :product, call: DiscountCalculator
    compute :report,   with: [:product, :discount], call: ReportFormatter

    output :report
  end
end

report = PriceReport.new(sku: "SKU-002")
report.resolve_all
puts report.result.report
```

The tool's `requires_capability` is not enforced in Contract graphs — it only
applies when the tool is invoked through the LLM tool-use path (via
`call_with_capability_check!`). Regular `call` (Executor protocol) is unrestricted.

---

## Provider message format

The tool-use loop produces provider-agnostic messages that each provider's
`normalize_messages` converts:

```ruby
# Executor sends (provider-agnostic)
{ role: "assistant", content: "", tool_calls: [{ id: "id1", name: "calculator", arguments: { expression: "2+2" } }] }
{ role: :tool_results, results: [{ id: "id1", name: "calculator", content: "4" }] }

# Anthropic receives
{ "role" => "assistant", "content" => [{ "type" => "tool_use", "id" => "id1", ... }] }
{ "role" => "user",      "content" => [{ "type" => "tool_result", "tool_use_id" => "id1", "content" => "4" }] }

# OpenAI receives
{ "role" => "assistant", "tool_calls" => [{ "id" => "id1", "type" => "function", ... }] }
{ "role" => "tool",      "tool_call_id" => "id1", "content" => "4" }
```

Each provider handles its own format in `normalize_messages`.

---

## Full example

```ruby
require "igniter/core/tool"
require "igniter/ai"
require "igniter/ai"

class SearchWeb < Igniter::Tool
  description "Search the internet for current information"
  param :query,       type: :string,  required: true
  param :max_results, type: :integer, default: 5
  requires_capability :web_access

  def call(query:, max_results: 5)
    WebSearchClient.search(query, limit: max_results)
  end
end

class WriteReport < Igniter::Tool
  description "Write a markdown report to a file"
  param :filename, type: :string, required: true
  param :content,  type: :string, required: true
  requires_capability :filesystem_write

  def call(filename:, content:)
    File.write(filename, content)
    { written: true, path: filename }
  end
end

# Register globally
Igniter::AI::ToolRegistry.register(SearchWeb, WriteReport)

# LLM executor with auto-loop
class ResearchAgent < Igniter::AI::Executor
  provider :anthropic
  model "claude-sonnet-4-6"
  system_prompt "Research assistant. Search, synthesize, write reports."

  tools SearchWeb, WriteReport
  capabilities :web_access, :filesystem_write
  max_tool_iterations 10

  def call(topic:, output_file:)
    complete("Research '#{topic}' and write a report to #{output_file}")
  end
end

# In a Contract pipeline
class ResearchPipeline < Igniter::Contract
  runner :thread_pool, pool_size: 3

  define do
    input :topics       # Array<String>
    input :output_dir

    compose :report1, with: [:topics, :output_dir], contract: Class.new(Igniter::Contract) {
      define do
        input :topics
        input :output_dir
        compute :result, with: [:topics, :output_dir], call: ResearchAgent
        output :result
      end
    }

    output :report1
  end
end
```

---

## Files

| File | Purpose |
|------|---------|
| `lib/igniter/core/tool.rb` | `Igniter::Tool` base class — DSL, schema, capability guard |
| `lib/igniter/ai/tool_registry.rb` | AI registry + capability-filtered discovery |
| `lib/igniter/ai/executor.rb` | Auto tool-use loop in `#complete`, `max_tool_iterations` |
| `lib/igniter/sdk/ai/providers/anthropic.rb` | Tool message normalization (Anthropic format) |
| `lib/igniter/sdk/ai/providers/openai.rb` | Tool message normalization (OpenAI format) |
| `spec/igniter/tool_spec.rb` | Tool unit tests (40 examples) |
| `spec/igniter/tool_registry_spec.rb` | Registry tests (20 examples) |
| `spec/igniter/integrations/llm_tool_loop_spec.rb` | AI tool-loop + guard tests (mock provider, 27 examples) |
| `examples/llm_tools.rb` | Full demo |
