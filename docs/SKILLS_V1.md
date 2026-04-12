# Igniter Skills — V1

## Overview

`Igniter::AI::Skill` is a composable unit of agent capability — the bridge between
atomic Tools and full autonomous Agents.

| | Tool | Skill | Agent |
|---|---|---|---|
| **Purpose** | Single operation | Multi-step task | Long-running process |
| **LLM inside** | No | Yes (own loop) | Yes (own loop + mailbox) |
| **Discoverable** | ✓ | ✓ | — |
| **Capability guard** | ✓ | ✓ | — |
| **Registered in ToolRegistry** | ✓ | ✓ | — |
| **Used in `tools` DSL** | ✓ | ✓ | — |
| **Duration** | ms | s–min | unbounded |

## Key Insight

From the **parent agent's perspective**, a Skill looks identical to a Tool:
it has a `name`, `description`, parameter schema, and a `call_with_capability_check!`
interface. The parent LLM cannot tell the difference. This enables **hierarchical agents**
where each level delegates to the next.

```
ChatExecutor (parent)
  tools: [TimeTool, WeatherTool, ResearchSkill, WriteCodeSkill]
                                      │
                              ResearchSkill (sub-agent)
                                tools: [SearchWebTool, ReadUrlTool]
                                Runs own LLM + tool loop internally
```

## Defining a Skill

```ruby
class ResearchSkill < Igniter::AI::Skill
  # ── Discovery interface (same as Tool) ──
  description "Research a topic by searching and synthesizing multiple sources"

  param :topic, type: :string, required: true,
                desc: "The subject to research"
  param :depth, type: :string, required: false, default: "brief",
                desc: "brief | detailed"

  requires_capability :network

  # ── Agentic implementation (AI::Executor DSL) ──
  provider :anthropic
  model "claude-sonnet-4-6"
  system_prompt "You are a research assistant. Be concise and accurate."

  tools SearchWebTool, ReadUrlTool    # skill's own sub-tools
  max_tool_iterations 8

  def call(topic:, depth: "brief")
    instruction = depth == "detailed" ? "comprehensive" : "concise 2-3 sentence"
    complete("Research this and return a #{instruction} summary: #{topic}")
  end
end
```

## Hierarchy Example: ChatExecutor with Skills

```ruby
class ChatExecutor < Igniter::AI::Executor
  provider :ollama
  model "llama3.1:8b"
  capabilities :network, :storage     # controls which tools/skills may run

  tools TimeTool,         # instant lookup, no LLM needed
        WeatherTool,      # instant lookup, no LLM needed
        SaveNoteTool,     # atomic storage write
        GetNotesTool,     # atomic storage read
        ResearchSkill,    # → triggers its own LLM loop when called
        RemindMeSkill     # → triggers its own LLM loop when called

  max_tool_iterations 6

  def call(message:, conversation_history:, intent:)
    ctx = build_context(conversation_history, intent)
    complete(message, context: ctx)
    # The auto loop transparently selects the right tool or skill per turn.
    # When ResearchSkill is called, it runs its own sub-loop before returning.
  end
end
```

## Schema Generation

Skills and Tools produce identical schema formats — providers cannot tell them apart.

```ruby
ResearchSkill.tool_name      # => "research_skill"
ResearchSkill.to_schema      # => { name:, description:, parameters: {...} }
ResearchSkill.to_schema(:anthropic)  # => { name:, description:, input_schema: {...} }
ResearchSkill.to_schema(:openai)     # => { type: "function", function: {...} }
```

## ToolRegistry

Skills register the same way as Tools:

```ruby
Igniter::AI::ToolRegistry.register(
  TimeTool, WeatherTool,    # tools
  ResearchSkill,            # skill — registered exactly like a tool
)

Igniter::AI::ToolRegistry.tools_for(capabilities: [:network])
# => [WeatherTool, ResearchSkill]  (TimeTool has no cap requirement → always included)

Igniter::AI::ToolRegistry.schemas(:anthropic, capabilities: [:network, :storage])
```

## Capability Guard

Same `call_with_capability_check!` interface as Tool. `CapabilityError` is the same class:

```ruby
Igniter::AI::Skill::CapabilityError == Igniter::Tool::CapabilityError  # => true

skill = ResearchSkill.new
skill.call_with_capability_check!(allowed_capabilities: [], topic: "AI")
# => raises Igniter::Tool::CapabilityError: "research_skill" requires [:network]
```

## Inheritance

A Skill inherits BOTH the Discoverable DSL AND the AI::Executor config:

```ruby
class BaseResearcher < Igniter::AI::Skill
  provider :anthropic
  model "claude-sonnet-4-6"
  requires_capability :network
end

class DeepResearchSkill < BaseResearcher
  description "Exhaustive multi-source research with citations"
  param :topic, type: :string, required: true, desc: "Topic"
  max_tool_iterations 20
  # inherits provider, model, requires_capability from BaseResearcher
end
```

## Tool::Discoverable

Both `Tool` and `Skill` include `Igniter::Tool::Discoverable`, which provides:

| Method | Description |
|--------|-------------|
| `.description(text)` | Set LLM-facing description |
| `.param(name, type:, ...)` | Declare a parameter |
| `.requires_capability(*caps)` | Declare required capabilities |
| `.tool_name` | Auto-derived snake_case name |
| `.to_schema(provider)` | Generate LLM tool schema |
| `.tool_params` | Array of declared params |
| `.required_capabilities` | Array of required caps |
| `#call_with_capability_check!(...)` | Guard + invoke `#call` |

## When to Use Tool vs Skill vs Agent

**Use a Tool when:**
- Operation is atomic and deterministic
- No LLM reasoning needed internally
- Response comes back in milliseconds
- Examples: `TimeTool`, `SaveNoteTool`, `WebhookTool`

**Use a Skill when:**
- Task requires multi-step reasoning or tool orchestration
- Output benefits from LLM synthesis (not just data retrieval)
- Task runs in seconds (not unbounded)
- Parent agent should treat it as a single callable unit
- Examples: `ResearchSkill`, `RemindMeSkill`, `WriteCodeSkill`, `TranslateDocumentSkill`

**Use an Agent when:**
- Long-running process with its own lifecycle (mailbox, supervisor)
- Needs to handle events asynchronously
- Maintains complex persistent state
- Examples: monitoring agent, background indexer, event-driven workflow

## Companion Example

The Companion voice assistant uses both tools and skills:

```
ChatExecutor
├── TimeTool        [tool]  → "what time is it?"
├── WeatherTool     [tool]  → "weather in Moscow?"
├── SaveNoteTool    [tool]  → persist a note
├── GetNotesTool    [tool]  → recall a note
├── ResearchSkill   [skill] → "explain how Raft consensus works"
└── RemindMeSkill   [skill] → "remind me to call Alice tomorrow at 3pm"
```

Skills in Companion:
- `ResearchSkill` — keyword search + LLM synthesis (uses `SaveNoteTool` to persist findings)
- `RemindMeSkill` — NL parsing + structured save (uses `TimeTool` + `SaveNoteTool`)
  When Consensus cluster is active, notes survive node failures automatically.

## Key Files

| File | Description |
|------|-------------|
| `lib/igniter/ai/skill.rb` | Skill base class |
| `lib/igniter/core/tool/discoverable.rb` | Shared DSL (Tool + Skill) |
| `lib/igniter/core/tool.rb` | Tool base class |
| `lib/igniter/ai/tool_registry.rb` | Registry for Tool + Skill |
| `spec/igniter/skill_spec.rb` | 30+ examples |
| `examples/companion/skills/research_skill.rb` | ResearchSkill demo |
| `examples/companion/skills/remind_me_skill.rb` | RemindMeSkill demo |
| `docs/TOOLS_V1.md` | Tool system docs |
