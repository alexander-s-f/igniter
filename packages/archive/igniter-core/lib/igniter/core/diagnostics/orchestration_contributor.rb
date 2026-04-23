# frozen_string_literal: true

module Igniter
  module Diagnostics
    module OrchestrationContributor
      class << self
        def augment(report:, execution:)
          orchestration = execution.orchestration_plan
          return report unless orchestration && orchestration[:total].positive?

          report[:orchestration] = orchestration
          report
        end

        def append_text(report:, lines:)
          orchestration = report[:orchestration]
          return unless orchestration

          lines << "Orchestration: #{orchestration_overview(orchestration)}"
          return if orchestration[:actions].empty?

          lines << "Orchestration Actions: #{orchestration[:actions].map { |action| orchestration_action_text(action) }.join(', ')}"
        end

        def append_markdown_summary(report:, lines:)
          orchestration = report[:orchestration]
          return unless orchestration

          lines << "- Orchestration: #{orchestration_overview(orchestration)}"
        end

        def append_markdown_sections(report:, lines:)
          orchestration = report[:orchestration]
          return unless orchestration

          lines << ""
          lines << "## Orchestration"
          lines << "- Summary: #{orchestration_overview(orchestration)}"
          return if orchestration[:actions].empty?

          lines << "- Actions: #{orchestration[:actions].map { |action| "`#{action[:action]}`(#{action[:node]})" }.join(', ')}"
          orchestration[:actions].each do |action|
            lines << "- `#{action[:node]}` `#{action[:action]}`: #{action[:guidance]} reason=`#{action[:reason]}`"
          end
        end

        private

        def orchestration_overview(orchestration)
          parts = [
            "total=#{orchestration[:total]}",
            "attention_required=#{orchestration[:attention_required]}",
            "resumable=#{orchestration[:resumable]}",
            "interactive_sessions=#{orchestration[:interactive_sessions]}",
            "manual_sessions=#{orchestration[:manual_sessions]}",
            "single_turn_sessions=#{orchestration[:single_turn_sessions]}",
            "deferred_calls=#{orchestration[:deferred_calls]}",
            "actions=#{Array(orchestration[:actions]).size}"
          ]
          if Array(orchestration[:attention_nodes]).any?
            parts << "attention_nodes=#{orchestration[:attention_nodes].join(',')}"
          end
          if orchestration[:by_action] && !orchestration[:by_action].empty?
            parts << "by_action=#{orchestration[:by_action].map { |key, value| "#{key}=#{value}" }.join(',')}"
          end
          parts.join(", ")
        end

        def orchestration_action_text(action)
          "#{action[:node]}(#{action[:action]} reason=#{action[:reason]})"
        end
      end
    end
  end
end
