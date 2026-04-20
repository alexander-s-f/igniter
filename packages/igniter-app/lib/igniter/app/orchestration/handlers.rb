# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      module Handlers
        class Base < Igniter::App::Operator::Handlers::Base
          def call(app_class:, item:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
            policy = app_class.orchestration_policy(item)
            action_resolution = resolve_operator_action(
              policy,
              operation || default_operation(item, policy),
              context: "orchestration item #{item[:id].inspect}"
            )
            applied_audit = { source: :orchestration_handler }.merge(normalize_audit(audit)).merge(
              requested_operation: action_resolution[:requested_operation],
              lifecycle_operation: action_resolution[:handled_lifecycle_operation],
              execution_operation: action_resolution[:handled_execution_operation],
              handler: self.class.name
            )

            updated_item = case action_resolution[:handled_operation]
            when :handoff
              app_class.handoff_orchestration_item(
                item[:id],
                assignee: assignee,
                queue: queue,
                channel: channel,
                note: note,
                audit: applied_audit
              )
            else
              case action_resolution[:handled_lifecycle_operation]
            when :acknowledge
              app_class.acknowledge_orchestration_item(item[:id], note: note, audit: applied_audit)
            when :resolve
              app_class.resolve_orchestration_item(item[:id], target: target, value: value, note: note, audit: applied_audit)
            when :dismiss
              app_class.dismiss_orchestration_item(item[:id], note: note, audit: applied_audit)
            else
              raise ArgumentError, "unsupported orchestration operation #{action_resolution[:handled_lifecycle_operation].inspect}"
              end
            end

            return nil unless updated_item

            build_result(
              id: item[:id],
              policy: policy,
              action: item[:action],
              action_resolution: action_resolution,
              lane: item.dig(:lane, :name),
              queue: updated_item[:queue],
              channel: updated_item[:channel],
              handler_queue: item[:queue],
              assignee: updated_item[:assignee],
              note: note,
              audit: applied_audit,
              status: updated_item[:status],
              payload: updated_item.reject do |key, _|
                %i[
                  id handled_action handled_operation handled_lifecycle_operation
                  handled_execution_operation handled_policy handled_lane handled_queue
                  handled_channel handled_handler_queue handled_audit_source handled_actor
                  handled_origin handled_actor_channel handled_assignee note status
                  report_status
                ].include?(key)
              end
            )
          end

          private

          def normalize_operation(operation)
            operation.to_sym
          end

          def default_operation(_item, policy)
            policy.default_operation
          end
        end

        class InteractiveSessionHandler < Base; end

        class CompletionHandler < Base; end
      end
    end
  end
end
