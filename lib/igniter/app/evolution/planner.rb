# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class Planner
        def initialize(app_class:)
          @app_class = app_class
        end

        def plan(target)
          report = extract_report(target)
          coverage = report.fetch(:app_sdk, {}).fetch(:coverage, {})
          actions = Array(coverage[:plans]).map { |action| normalize_action(action) }

          Plan.new(
            app_class: app_class,
            source: :app_sdk_coverage,
            actions: actions,
            summary: summarize(actions, coverage)
          )
        end

        private

        attr_reader :app_class

        def extract_report(target)
          return target if target.is_a?(Hash)
          return target.to_h if target.class.name == "Igniter::Diagnostics::Report"
          return target.diagnostics.to_h if target.respond_to?(:diagnostics)

          raise ArgumentError,
                "evolution plan target must be a diagnostics hash, diagnostics report, execution, or contract instance"
        end

        def normalize_action(action)
          capability = action.dig(:params, :capability)&.to_sym
          sdk_capabilities = Array(action.dig(:params, :sdk_capabilities)).map(&:to_sym).uniq.sort
          constraints = []
          constraints << :selection_required if action[:action].to_sym == :activate_sdk_capability && sdk_capabilities.size > 1

          {
            id: action_id(action, capability),
            action: action[:action].to_sym,
            scope: action[:scope].to_sym,
            automated: !!action[:automated],
            requires_approval: !!action[:requires_approval],
            params: (action[:params] || {}).merge(
              capability: capability,
              sdk_capabilities: sdk_capabilities
            ).freeze,
            sources: Array(action[:sources]).freeze,
            constraints: constraints.freeze
          }.freeze
        end

        def action_id(action, capability)
          [action[:scope], action[:action], capability].compact.map(&:to_s).join(":")
        end

        def summarize(actions, coverage)
          {
            total: actions.size,
            automated: actions.count { |action| action[:automated] },
            approval_required: actions.count { |action| action[:requires_approval] },
            constrained: actions.count { |action| action[:constraints].any? },
            uncovered_capabilities: Array(coverage[:uncovered_capabilities]).map(&:to_sym).uniq.sort,
            by_action: count_many(actions) { |action| action[:action] }
          }
        end

        def count_many(entries)
          entries.each_with_object(Hash.new(0)) do |entry, memo|
            Array(yield(entry)).each do |key|
              next if key.nil?

              memo[key] += 1
            end
          end
        end
      end
    end
  end
end
