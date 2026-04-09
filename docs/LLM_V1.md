# LLM Integration v1

Igniter's LLM integration (`require "igniter/integrations/llm"`) makes language models
first-class compute nodes inside a graph. A multi-step LLM pipeline — classify, assess,
draft a response — is just a normal Igniter contract with chained `compute` nodes backed
by LLM executors. Caching, invalidation, auditing, and diagnostics all work the same way.

## Quick Start

```ruby
require "igniter/integrations/llm"

Igniter::LLM.configure do |c|
  c.default_provider = :anthropic
  c.anthropic.api_key = ENV["ANTHROPIC_API_KEY"]
end

class SummarizeExecutor < Igniter::LLM::Executor
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
    compute :summary, depends_on: :text, with: SummarizeExecutor
    output :summary
  end
end

ArticleContract.new(text: "Long article...").result.summary
```

---

## `Igniter::LLM::Executor`

Subclass `Igniter::LLM::Executor` and override `#call(**inputs)`. Inside `call`, use the
protected helper methods to interact with the provider.

### Class-level configuration

```ruby
class MyExecutor < Igniter::LLM::Executor
  provider     :anthropic          # :ollama | :anthropic | :openai
  model        "claude-haiku-4-5-20251001"
  system_prompt "You are a helpful assistant."
  temperature  0.2                 # optional; provider default if omitted

  # Declare tools for structured output / function calling
  tools({
    name: "set_result",
    description: "Record the computed result",
    input_schema: {
      type: "object",
      properties: { value: { type: "number" } },
      required: ["value"]
    }
  })
end
```

Configuration is inherited by subclasses:

```ruby
class BaseExecutor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
end

class ClassifyExecutor < BaseExecutor
  system_prompt "Classify into: bug, feature, question."
  # Inherits provider and model from BaseExecutor
end
```

### Instance helpers

| Method | Description |
|--------|-------------|
| `complete(prompt, context: nil)` | Single-turn completion. Returns the assistant's text content. |
| `chat(context:)` | Multi-turn chat from a `Context` or messages array. Returns content. |
| `complete_with_tools(prompt, context: nil)` | Tool-use call. Returns a `DeferredResult` if the LLM requests a tool call, otherwise returns the text content. |
| `last_usage` | Token usage from the last call (`{ prompt_tokens:, completion_tokens: }`). |
| `last_context` | Updated `Context` after the last `complete` call (includes the new turn). |

---

## `Igniter::LLM::Context`

Immutable conversation history that accumulates turns across calls.

```ruby
ctx = Igniter::LLM::Context.empty(system: "You are a code reviewer.")
ctx = ctx.append_user("Review this method: def foo; end")
ctx = ctx.append_assistant("The method is empty. Consider adding a docstring.")
ctx = ctx.append_user("How would you improve it?")

# Pass as context: to maintain continuity across executor calls
response = chat(context: ctx)
```

`Context` is immutable — each `append_*` call returns a new instance.

---

## Providers

### Ollama (local)

No API key needed. Requires a running Ollama instance.

```ruby
Igniter::LLM.configure do |c|
  c.default_provider = :ollama
  c.ollama.base_url      = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
  c.ollama.default_model = "llama3.2"
end
```

```bash
# Install: https://ollama.com
ollama pull llama3.2
```

### Anthropic

```ruby
Igniter::LLM.configure do |c|
  c.default_provider = :anthropic
  c.anthropic.api_key       = ENV["ANTHROPIC_API_KEY"]
  c.anthropic.default_model = "claude-haiku-4-5-20251001"
end
```

Anthropic-specific notes:
- `system_prompt` is sent as a top-level `"system"` field (not in the messages array)
- Tool definitions use `input_schema` (Anthropic format)
- Supported models: any `claude-*` model identifier

### OpenAI (and compatible)

```ruby
Igniter::LLM.configure do |c|
  c.default_provider = :openai
  c.openai.api_key       = ENV["OPENAI_API_KEY"]
  c.openai.default_model = "gpt-4o-mini"

  # For OpenAI-compatible APIs (Groq, Mistral, Azure, etc.)
  c.openai.base_url = "https://api.groq.com/openai"
  c.openai.api_key  = ENV["GROQ_API_KEY"]
end
```

---

## Multi-Step LLM Pipeline

Chain multiple LLM executors as sequential compute nodes. Each node receives the
output of the previous as an input:

```ruby
class ClassifyExecutor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Classify feedback into: bug_report, feature_request, question."

  def call(feedback:)
    complete("Classify: #{feedback}")
  end
end

class PriorityExecutor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Assess priority: low, medium, or high."

  def call(feedback:, category:)
    ctx = Igniter::LLM::Context
      .empty(system: self.class.system_prompt)
      .append_user("Feedback: #{feedback}")
      .append_user("Category: #{category}")
    chat(context: ctx)
  end
end

class FeedbackContract < Igniter::Contract
  define do
    input :feedback

    compute :category, depends_on: :feedback,             with: ClassifyExecutor
    compute :priority, depends_on: %i[feedback category], with: PriorityExecutor

    output :category
    output :priority
  end
end
```

---

## Tool Use

Declare tools at the class level with `tools`. Call `complete_with_tools` inside `#call`
to trigger tool-use mode. If the LLM returns tool calls, the node is deferred (pending),
and must be resumed with the tool result via `Contract.resume_from_store`.

```ruby
EXTRACT_TOOL = {
  name: "extract_entities",
  description: "Extract named entities from text",
  input_schema: {
    type: "object",
    properties: {
      entities: {
        type: "array",
        items: { type: "string" },
        description: "List of entity names found in the text"
      }
    },
    required: ["entities"]
  }
}.freeze

class EntityExtractor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Extract named entities. Always use the extract_entities tool."

  tools EXTRACT_TOOL

  def call(text:)
    # Returns DeferredResult if the LLM requests a tool call
    complete_with_tools("Extract entities from: #{text}")
  end
end

class ExtractionContract < Igniter::Contract
  run_with runner: :store

  define do
    input :text
    compute :entities, depends_on: :text, with: EntityExtractor
    output :entities
  end
end

# Configure a store for async execution
Igniter.configure { |c| c.execution_store = Igniter::Runtime::Stores::MemoryStore.new }

contract     = ExtractionContract.new(text: "Apple and Google announced a partnership.")
deferred     = contract.result.entities  # triggers tool call
execution_id = contract.execution.events.execution_id

# In a real app: parse tool_calls from deferred.payload[:tool_calls],
# run actual extraction logic, then resume with the result
tool_result = ["Apple", "Google"]

resumed = ExtractionContract.resume_from_store(
  execution_id, token: deferred.token, value: tool_result
)
resumed.result.entities  # => ["Apple", "Google"]
```

---

## LLM Executor with Igniter Composition

LLM executors compose naturally with non-LLM nodes:

```ruby
class DocumentPipeline < Igniter::Contract
  define do
    input :document_text
    input :language, default: "en"

    # Non-LLM preprocessing
    compute :cleaned_text, depends_on: :document_text do |document_text:|
      document_text.strip.gsub(/\s+/, " ")
    end

    # LLM summarization
    compute :summary, depends_on: %i[cleaned_text language], with: SummarizeExecutor

    # Non-LLM post-processing
    compute :word_count, depends_on: :summary do |summary:|
      summary.split.size
    end

    output :summary
    output :word_count
  end
end
```

---

## Token Usage and Auditing

Each `Igniter::LLM::Executor` instance tracks token usage after each call:

```ruby
class TrackingExecutor < Igniter::LLM::Executor
  def call(text:)
    result = complete("Process: #{text}")
    # last_usage is available after complete/chat
    { result: result, tokens: last_usage }
  end
end
```

Standard Igniter auditing and diagnostics work unchanged for LLM nodes:

```ruby
contract = MyLLMContract.new(...)
contract.resolve_all

contract.diagnostics_text   # includes LLM node timing
contract.audit_snapshot     # includes all node events
```

---

## ENV Variables

| Variable | Provider | Purpose |
|----------|----------|---------|
| `ANTHROPIC_API_KEY` | Anthropic | API key (used automatically if not configured via `configure`) |
| `OPENAI_API_KEY` | OpenAI | API key (used automatically if not configured via `configure`) |
| `OLLAMA_URL` | Ollama | Override base URL (default: `http://localhost:11434`) |
