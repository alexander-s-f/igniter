# frozen_string_literal: true

module Igniter
  module Memory
    # Evaluates recent episodes and produces a ReflectionRecord.
    #
    # ReflectionCycle can operate in two modes:
    #
    # * **Rule-based** (default) — analyses failure rates using simple heuristics,
    #   requiring no LLM. Always available.
    # * **LLM-assisted** — delegates to an LLM executor for a richer summary and
    #   an optional system-prompt patch. Enabled by passing an +llm:+ object.
    #
    # @example Rule-based reflection
    #   cycle = Igniter::Memory::ReflectionCycle.new(store: store)
    #   rec   = cycle.reflect(agent_id: "MyAgent:1")
    #   # => ReflectionRecord (summary describes failure breakdown)
    #
    # @example With failure threshold check
    #   cycle.should_reflect?(agent_id: "MyAgent:1")
    #   # => true when recent failures >= DEFAULT_FAILURE_THRESHOLD
    class ReflectionCycle
      DEFAULT_FAILURE_THRESHOLD = 5
      DEFAULT_WINDOW            = 50

      # @param store             [Store]    backing episode store
      # @param failure_threshold [Integer]  minimum failures to trigger reflection
      # @param window            [Integer]  how many recent episodes to inspect
      # @param llm               [#call, nil] optional LLM executor for smart reflection
      def initialize(store:, failure_threshold: DEFAULT_FAILURE_THRESHOLD,
                     window: DEFAULT_WINDOW, llm: nil)
        @store             = store
        @failure_threshold = failure_threshold
        @window            = window
        @llm               = llm
      end

      # Check whether a reflection cycle should be triggered.
      #
      # Returns true when the number of recent "failure" outcomes meets or
      # exceeds the configured +failure_threshold+.
      #
      # @param agent_id [String]
      # @return [Boolean]
      def should_reflect?(agent_id:)
        recent   = @store.episodes(agent_id: agent_id, last: @window)
        failures = recent.count { |e| e.outcome == "failure" }
        failures >= @failure_threshold
      end

      # Run a reflection cycle and persist the result.
      #
      # Analyses the most recent +window+ episodes and produces a
      # ReflectionRecord with a summary (and optional system-prompt patch when
      # an LLM is configured).
      #
      # @param agent_id              [String]
      # @param current_system_prompt [String, nil] passed to the LLM if available
      # @return [ReflectionRecord]
      def reflect(agent_id:, current_system_prompt: nil) # rubocop:disable Metrics/MethodLength
        recent = @store.episodes(agent_id: agent_id, last: @window)
        summary, patch = if @llm
                           smart_reflect(recent, current_system_prompt)
                         else
                           rule_based_reflect(recent)
                         end

        @store.record_reflection(
          agent_id: agent_id,
          summary: summary,
          system_patch: patch
        )
      end

      private

      def rule_based_reflect(episodes) # rubocop:disable Metrics/CyclomaticComplexity
        failures      = episodes.select { |e| e.outcome == "failure" }
        failure_types = failures.group_by(&:type).transform_values(&:count)
        top           = failure_types.max_by { |_, v| v }

        summary = "#{failures.size}/#{episodes.size} failures. " \
                  "Top failure type: #{top&.first || "none"} (#{top&.last || 0}\xc3\x97)"
        [summary, nil]
      end

      def smart_reflect(episodes, current_system_prompt)
        result = @llm.call(
          episodes: episodes.map { |e| { type: e.type, content: e.content, outcome: e.outcome } },
          current_system_prompt: current_system_prompt
        )
        [result[:summary], result[:system_patch]]
      end
    end
  end
end
