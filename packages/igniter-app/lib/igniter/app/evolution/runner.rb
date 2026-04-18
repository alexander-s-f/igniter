# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class Runner
        def initialize(app_class:)
          @app_class = app_class
        end

        def run(plan, approval: nil, approve: false, selections: {})
          decision = ApprovalDecision.normalize(approval.nil? ? approve : approval, selections: selections)
          applied = []
          blocked = []

          plan.actions.each do |action|
            blocking_reason = blocking_reason_for(action, decision: decision)
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

            applied << execute(action, decision: decision)
          end

          refresh_runtime_context! if applied.any?

          Result.new(app_class: app_class, applied: applied, blocked: blocked)
        end

        private

        attr_reader :app_class

        def blocking_reason_for(action, decision:)
          if action[:requires_approval]
            return :approval_denied if decision&.deny_action?(action[:id])
            return :approval_required unless decision&.approve_action?(action[:id])
          end

          case action[:action]
          when :activate_sdk_capability
            candidates = Array(action.dig(:params, :sdk_capabilities)).map(&:to_sym).uniq.sort
            chosen = selected_sdk_capabilities_for(action, decision)
            return :selection_required if chosen.empty? && candidates.size > 1
            return :invalid_selection unless (chosen - candidates).empty?
          else
            return :unsupported_action
          end

          nil
        end

        def execute(action, decision:)
          case action[:action]
          when :activate_sdk_capability
            execute_sdk_activation(action, decision: decision)
          else
            raise ArgumentError, "Unsupported app evolution action #{action[:action].inspect}"
          end
        end

        def execute_sdk_activation(action, decision:)
          chosen = selected_sdk_capabilities_for(action, decision)
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

        def selected_sdk_capabilities_for(action, decision)
          capability = action.dig(:params, :capability)
          Array(decision&.selection_for(capability)).map(&:to_sym).uniq.sort
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
