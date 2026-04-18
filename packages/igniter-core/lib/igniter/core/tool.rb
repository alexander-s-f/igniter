# frozen_string_literal: true

require_relative "errors"
require_relative "runtime/deferred_result"
require_relative "executor"

module Igniter
  # Base class for AI-callable tools.
  #
  # Extends +Igniter::Executor+ with declarative metadata for LLM function-calling
  # (Anthropic, OpenAI) and capability-based access guards.
  # Shares the discovery DSL with +Igniter::AI::Skill+ via +Tool::Discoverable+.
  #
  # == Defining a tool
  #
  #   class SearchWeb < Igniter::Tool
  #     description "Search the internet for current information"
  #
  #     param :query,       type: :string,  required: true,  desc: "The search query"
  #     param :max_results, type: :integer, default: 5,      desc: "Max results to return"
  #
  #     requires_capability :web_access
  #
  #     def call(query:, max_results: 5)
  #       [{ title: "...", url: "...", snippet: "..." }]
  #     end
  #   end
  #
  # == Schema generation
  #
  #   SearchWeb.tool_name             # => "search_web"
  #   SearchWeb.to_schema             # => { name:, description:, parameters: { ... } }
  #   SearchWeb.to_schema(:anthropic) # => { name:, description:, input_schema: { ... } }
  #   SearchWeb.to_schema(:openai)    # => { type: "function", function: { ... } }
  #
  # == Compatibility
  #
  # Tool inherits +Igniter::Executor+ — usable as a compute node in any Contract graph.
  class Tool < Executor
    # Raised when a tool or skill requires a capability the calling agent does not have.
    # Also aliased as +Igniter::AI::Skill::CapabilityError+.
    class CapabilityError < Igniter::Error; end

    require_relative "tool/discoverable"
    include Discoverable

    def self.inherited(subclass)
      super
      # Tool subclasses always start with empty params and capabilities —
      # each concrete tool declares its own. Only the description carries forward.
      subclass.instance_variable_set(:@tool_params, [])
      subclass.instance_variable_set(:@required_capabilities, [].freeze)
      subclass.instance_variable_set(:@tool_description, @tool_description)
    end
  end
end
