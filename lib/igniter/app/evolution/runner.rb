# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class Runner
        def initialize(app_class:)
          @app_class = app_class
        end

        def run(plan, approve: false, selections: {})
          applied = []
          blocked = []

          plan.actions.each do |action|
            blocking_reason = blocking_reason_for(action, approve: approve, selections: selections)
            if blocking_reason
              blocked << {
                id: action[:id],
                action: action[:action],
                status: :blocked,
                reason: blocking_reason,
                params: action[:params]
              }
              next
            end

            applied << execute(action, selections: selections)
          end

          refresh_runtime_context! if applied.any?

          Result.new(app_class: app_class, applied: applied, blocked: blocked)
        end

        private

        attr_reader :app_class

        def blocking_reason_for(action, approve:, selections:)
          return :approval_required if action[:requires_approval] && !approve

          case action[:action]
          when :activate_sdk_capability
            candidates = Array(action.dig(:params, :sdk_capabilities)).map(&:to_sym).uniq.sort
            chosen = selected_sdk_capabilities_for(action, selections)
            return :selection_required if chosen.empty? && candidates.size > 1
            return :invalid_selection unless (chosen - candidates).empty?
          else
            return :unsupported_action
          end

          nil
        end

        def execute(action, selections:)
          case action[:action]
          when :activate_sdk_capability
            execute_sdk_activation(action, selections: selections)
          else
            raise ArgumentError, "Unsupported app evolution action #{action[:action].inspect}"
          end
        end

        def execute_sdk_activation(action, selections:)
          chosen = selected_sdk_capabilities_for(action, selections)
          chosen = Array(action.dig(:params, :sdk_capabilities)).map(&:to_sym).uniq.sort if chosen.empty?
          app_class.use(*chosen)

          {
            id: action[:id],
            action: action[:action],
            status: :applied,
            scope: action[:scope],
            capability: action.dig(:params, :capability),
            applied_sdk_capabilities: chosen,
            params: action[:params]
          }
        end

        def selected_sdk_capabilities_for(action, selections)
          capability = action.dig(:params, :capability)
          selected = selections[capability] || selections[capability.to_s]
          Array(selected).map(&:to_sym).uniq.sort
        end

        def refresh_runtime_context!
          current = Igniter::App::RuntimeContext.current
          return unless current
          return unless current[:app_class].equal?(app_class)

          Igniter::App::RuntimeContext.current = current.merge(
            sdk_capabilities: app_class.sdk_capabilities.map(&:to_sym).uniq.sort
          ).freeze
        end
      end
    end
  end
end
