# frozen_string_literal: true

module Igniter
  class Skill
    # Immutable record of one rated invocation of a Skill.
    FeedbackEntry = Struct.new(
      :input,      # String — the prompt that was sent to the LLM
      :output,     # String — the response that was returned
      :rating,     # Symbol — :good, :bad, or :neutral
      :notes,      # String, nil — optional human comment
      :timestamp,  # Time
      keyword_init: true
    ) do
      def initialize(**)
        super
        freeze
      end
    end

    # Thread-safe in-memory store for feedback entries.
    module FeedbackStore
      class Memory
        MAX_SIZE = 500

        def initialize
          @entries = []
          @mutex   = Mutex.new
        end

        def store(entry)
          @mutex.synchronize do
            @entries << entry
            @entries.shift if @entries.size > MAX_SIZE
          end
          self
        end

        def all
          @mutex.synchronize { @entries.dup }
        end

        def size
          @mutex.synchronize { @entries.size }
        end

        def empty?
          size.zero?
        end

        def by_rating(rating)
          all.select { |e| e.rating == rating.to_sym }
        end

        def clear
          @mutex.synchronize { @entries.clear }
          self
        end
      end
    end

    # Generates an improved system prompt from accumulated feedback.
    #
    # Uses the skill's own LLM provider to propose changes. Returns a plain
    # String — it does NOT mutate any class-level state. The caller decides
    # whether to adopt the refined prompt.
    #
    # == Usage
    #
    #   improved = skill.refine_system_prompt
    #   # Inspect it, then use it:
    #   MySkill.system_prompt improved
    class FeedbackRefiner
      TEMPLATE = <<~PROMPT
        You are improving a system prompt for an AI skill based on user feedback.
        Return ONLY the improved system prompt text, with no explanation or preamble.

        Current system prompt:
        %<current>s

        %<feedback>s
      PROMPT

      def initialize(provider_instance, model)
        @provider = provider_instance
        @model    = model
      end

      # @param current_prompt [String]
      # @param entries        [Array<FeedbackEntry>]
      # @return [String] the refined system prompt
      def refine(current_prompt, entries) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        return current_prompt if entries.empty?

        good = entries.select { |e| e.rating == :good }
                      .filter_map { |e| e.notes && "✓ #{e.notes}" }
                      .join("\n")

        bad = entries.select { |e| e.rating == :bad }
                     .filter_map { |e| e.notes && "✗ #{e.notes}" }
                     .join("\n")

        parts = []
        parts << "Positive feedback (preserve these qualities):\n#{good}" unless good.empty?
        parts << "Negative feedback (address these issues):\n#{bad}"      unless bad.empty?

        return current_prompt if parts.empty?

        prompt = format(TEMPLATE, current: current_prompt, feedback: parts.join("\n\n"))
        @provider.chat(
          messages: [{ role: "user", content: prompt }],
          model: @model
        )[:content]
      end
    end
  end
end
