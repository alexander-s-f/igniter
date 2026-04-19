# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class Planner
        def initialize(app_class:)
          @app_class = app_class
        end

        def plan(target)
          orchestration = extract_orchestration(target)
          actions = Array(orchestration[:actions]).map { |action| normalize_action(action) }

          Plan.new(
            app_class: app_class,
            source: :agent_orchestration,
            actions: actions,
            summary: summarize(actions, orchestration)
          )
        end

        private

        attr_reader :app_class

        def extract_orchestration(target)
          return target[:orchestration] if target.is_a?(Hash) && target.key?(:orchestration)
          return target if target.is_a?(Hash) && target.key?(:actions) && target.key?(:attention_required)
          return target.to_h[:orchestration] if target.class.name == "Igniter::Diagnostics::Report"
          return target.orchestration_plan if target.respond_to?(:orchestration_plan)
          return target.execution.orchestration_plan if target.respond_to?(:execution)
          return target.diagnostics.to_h[:orchestration] if target.respond_to?(:diagnostics)

          raise ArgumentError,
                "orchestration plan target must be an orchestration hash, diagnostics report, execution, or contract instance"
        end

        def normalize_action(action)
          {
            id: action[:id].to_s,
            action: action[:action].to_sym,
            node: action[:node].to_sym,
            interaction: action[:interaction].to_sym,
            reason: action[:reason].to_sym,
            guidance: action[:guidance].to_s,
            attention_required: !!action[:attention_required],
            resumable: !!action[:resumable]
          }.freeze
        end

        def summarize(actions, orchestration)
          {
            total: actions.size,
            attention_required: actions.count { |action| action[:attention_required] },
            manual_completion: actions.count { |action| action[:action] == :require_manual_completion },
            deferred_replies: actions.count { |action| action[:action] == :await_deferred_reply },
            interactive_sessions: actions.count { |action| action[:action] == :open_interactive_session },
            single_turn_sessions: actions.count { |action| action[:action] == :await_single_turn_completion },
            attention_nodes: Array(orchestration[:attention_nodes]).map(&:to_sym),
            by_action: actions.each_with_object(Hash.new(0)) do |action, memo|
              memo[action[:action]] += 1
            end
          }
        end
      end
    end
  end
end
