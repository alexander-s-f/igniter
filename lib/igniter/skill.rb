# frozen_string_literal: true

require_relative "tool"
require_relative "integrations/llm/executor"

module Igniter
  # Base class for AI-callable skills — composable units of agent capability.
  #
  # A +Skill+ is both discoverable (LLM can call it like a Tool) and agentic
  # (it runs its own LLM reasoning loop with its own set of tools).
  # Use Skills when a single tool call is not enough: the task requires planning,
  # multi-step tool use, or internal LLM reasoning.
  #
  # == Tool vs Skill
  #
  # +Tool+  — atomic operation, single call, stateless, fast.
  # +Skill+ — multi-step process, own LLM loop, own tools, may take seconds.
  #
  # From the parent agent's perspective both look identical: they share the same
  # discovery interface (+description+, +param+, +to_schema+, +requires_capability+)
  # and are registered in +ToolRegistry+ the same way.
  #
  # == Defining a skill
  #
  #   class ResearchSkill < Igniter::Skill
  #     description "Research a topic by searching and synthesizing multiple sources"
  #
  #     param :topic, type: :string, required: true,
  #                   desc: "Subject to research"
  #
  #     requires_capability :network
  #
  #     provider :anthropic
  #     model "claude-sonnet-4-6"
  #     tools SearchWebTool, ReadUrlTool   # skill's own sub-tools
  #     max_tool_iterations 8
  #
  #     def call(topic:)
  #       complete("Research this thoroughly: #{topic}")
  #       # ↑ runs sub-tool loop internally; returns plain-text summary
  #     end
  #   end
  #
  # == Hierarchical agents
  #
  #   class ChatExecutor < Igniter::LLM::Executor
  #     tools TimeTool, WeatherTool,
  #           ResearchSkill,   # ← parent sees this as a Tool
  #           WriteCodeSkill   # ← parent sees this as a Tool
  #   end
  #
  # == Schema + registry
  #
  #   ResearchSkill.tool_name          # => "research_skill"
  #   ResearchSkill.to_schema          # => { name:, description:, parameters: { ... } }
  #   Igniter::ToolRegistry.register(ResearchSkill)
  class Skill < LLM::Executor
    # CapabilityError is the same class as Tool::CapabilityError.
    # Defined here as an alias for convenience and symmetry.
    CapabilityError = Tool::CapabilityError

    include Tool::Discoverable

    # Propagate BOTH the LLM executor config (via super → LLM::Executor.inherited)
    # AND the Discoverable metadata to every subclass.
    def self.inherited(subclass)
      super
      copy_discoverable_state_to(subclass)
    end
  end
end
