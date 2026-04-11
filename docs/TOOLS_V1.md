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
require "igniter/tool"

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

## `Igniter::ToolRegistry` — discovery and schema export

```ruby
require "igniter/tool_registry"

# Global registration (typically in an initializer)
Igniter::ToolRegistry.register(Calculator, DatabaseLookup, SendEmail)

# Discovery
Igniter::ToolRegistry.all                               # => [Calculator, DatabaseLookup, SendEmail]
Igniter::ToolRegistry.find("calculator")                # => Calculator

# Capability filtering — only tools the agent is authorized to call
Igniter::ToolRegistry.tools_for(capabilities: [:database_read])
# => [Calculator, DatabaseLookup]   (SendEmail needs :email_send)

# Schema export
Igniter::ToolRegistry.schemas                           # intermediate, all tools
Igniter::ToolRegistry.schemas(:anthropic)               # Anthropic format, all
Igniter::ToolRegistry.schemas(:openai, capabilities: [:database_read])  # filtered
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
inherited by `LLM::Executor`:

```ruby
class SupportAgent < Igniter::LLM::Executor
  capabilities :database_read, :email_send   # what this agent may do
  tools DatabaseLookup, SendEmail
  ...
end
```

---

## LLM::Executor — automatic tool-use loop

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
class ProductAssistant < Igniter::LLM::Executor
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
| Loop exceeds `max_tool_iterations` | `Igniter::LLM::ToolLoopError` raised |

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
require "igniter/tool"
require "igniter/tool_registry"
require "igniter/integrations/llm"

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
Igniter::ToolRegistry.register(SearchWeb, WriteReport)

# LLM executor with auto-loop
class ResearchAgent < Igniter::LLM::Executor
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
| `lib/igniter/tool.rb` | `Igniter::Tool` base class — DSL, schema, capability guard |
| `lib/igniter/tool_registry.rb` | Global registry + capability-filtered discovery |
| `lib/igniter/integrations/llm/executor.rb` | Auto tool-use loop in `#complete`, `max_tool_iterations` |
| `lib/igniter/integrations/llm/providers/anthropic.rb` | Tool message normalization (Anthropic format) |
| `lib/igniter/integrations/llm/providers/openai.rb` | Tool message normalization (OpenAI format) |
| `spec/igniter/tool_spec.rb` | Tool unit tests (40 examples) |
| `spec/igniter/tool_registry_spec.rb` | Registry tests (20 examples) |
| `spec/igniter/integrations/llm_tool_loop_spec.rb` | Loop + guards tests (mock provider, 27 examples) |
| `examples/llm_tools.rb` | Full demo |
