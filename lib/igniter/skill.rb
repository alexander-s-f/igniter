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
  # == Structured output
  #
  #   class AnalysisSkill < Igniter::Skill
  #     output_schema do
  #       field :summary,    String
  #       field :confidence, Float
  #     end
  #
  #     def call(document:)
  #       complete("Analyse: #{document}")
  #       # Returns StructuredResult, not a plain String
  #     end
  #   end
  #
  # == Feedback loop
  #
  #   class MySkill < Igniter::Skill
  #     feedback_enabled true
  #     feedback_store   :memory
  #
  #     def call(prompt:) = complete(prompt)
  #   end
  #
  #   result = MySkill.call(prompt: "...")
  #   MySkill.new.feedback(result, rating: :good, notes: "Very helpful")
  #   improved = MySkill.new.refine_system_prompt
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

    class << self
      # Propagate BOTH the LLM executor config (via super → LLM::Executor.inherited)
      # AND the Discoverable metadata to every subclass.
      # Note: @feedback_store is intentionally NOT copied — each class owns its store.
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@output_schema, @output_schema)
        subclass.instance_variable_set(:@feedback_enabled, @feedback_enabled)
        copy_discoverable_state_to(subclass)
      end

      # Declare a typed JSON output schema for this skill.
      #
      # When a block is given, creates an +OutputSchema+ and stores it.
      # Calling +complete+ inside +call+ will then inject a JSON instruction
      # into the prompt and return a +StructuredResult+ instead of a String.
      #
      # Without a block, falls back to the inherited +Executor#output_schema+
      # metadata getter/setter for backward compatibility.
      #
      # @example
      #   output_schema do
      #     field :summary,    String
      #     field :confidence, Float
      #     field :sources,    Array
      #   end
      def output_schema(value = nil, &block)
        if block
          @output_schema = Skill::OutputSchema.new(&block)
        elsif value
          super(value)             # Executor metadata setter (backward compat)
        else
          @output_schema || super  # new DSL ivar or executor_metadata fallback
        end
      end

      # Enable or query feedback collection for this skill.
      # When enabled, +#feedback+ stores entries in the configured store.
      #
      # @param val [Boolean, nil] pass true/false to set; nil to get
      def feedback_enabled(val = nil)
        val.nil? ? (@feedback_enabled || false) : (@feedback_enabled = val)
      end

      # Set or get the feedback store for this skill.
      #
      # Pass +:memory+ to create a new in-memory store (one per class).
      # Pass any object responding to +#store+, +#all+, and +#clear+ to use a custom store.
      #
      # Note: the store is NOT inherited by subclasses — each class has its own.
      #
      # @param val [:memory, #store, nil]
      def feedback_store(val = nil)
        return @feedback_store if val.nil?

        @feedback_store = val == :memory ? Skill::FeedbackStore::Memory.new : val
      end
    end

    protected

    # Override LLM::Executor#complete to inject a JSON instruction when an
    # +OutputSchema+ is declared, and parse the response into a +StructuredResult+.
    def complete(prompt, context: nil)
      schema = self.class.output_schema

      adjusted = if schema.is_a?(Skill::OutputSchema)
                   "#{prompt}\n\nRespond ONLY with valid JSON matching this schema: #{schema.to_json_description}"
                 else
                   prompt
                 end

      result = super(adjusted, context: context)
      schema.is_a?(Skill::OutputSchema) ? schema.parse(result) : result
    end

    public

    # Record feedback for a previous output.
    #
    # Matches +output+ against +call_history+ to capture the input context.
    # No-op when +feedback_enabled+ is false or no store is configured.
    #
    # @param output [String, StructuredResult] the response to rate
    # @param rating [:good, :bad, :neutral]
    # @param notes  [String, nil]
    # @return [self]
    def feedback(output, rating:, notes: nil) # rubocop:disable Metrics/MethodLength
      return self unless self.class.feedback_enabled

      store = self.class.feedback_store
      return self unless store

      output_str = output.to_s
      matched    = (call_history || []).reverse.find { |h| h[:output] == output_str }

      store.store(FeedbackEntry.new(
                    input: matched&.dig(:input),
                    output: output_str,
                    rating: rating.to_sym,
                    notes: notes,
                    timestamp: Time.now
                  ))
      self
    end

    # Generate an improved system prompt based on accumulated feedback.
    #
    # Uses the skill's own LLM provider + model. Returns a new String — does NOT
    # mutate class-level state. The caller decides whether to adopt the result.
    #
    # @return [String] the refined system prompt
    # @raise [Igniter::Error] if no feedback_store is configured
    def refine_system_prompt
      store = self.class.feedback_store
      raise Igniter::Error, "No feedback_store configured on #{self.class.name}" unless store

      FeedbackRefiner.new(provider_instance, current_model).refine(
        self.class.system_prompt.to_s,
        store.all
      )
    end
  end
end

# Load sub-files that reopen Skill after it is fully defined above.
require_relative "skill/output_schema"
require_relative "skill/feedback"
