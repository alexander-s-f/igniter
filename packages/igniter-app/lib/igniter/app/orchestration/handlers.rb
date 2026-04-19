# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      module Handlers
        class Base
          def call(app_class:, item:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
            policy = app_class.orchestration_policy(item)
            requested_operation = normalize_operation(operation || default_operation(item, policy))
            validate_operation!(policy, requested_operation, item)
            lifecycle_operation = policy.lifecycle_operation_for(requested_operation)
            applied_audit = { source: :orchestration_handler }.merge(normalize_audit(audit)).merge(
              requested_operation: requested_operation,
              lifecycle_operation: lifecycle_operation,
              handler: self.class.name
            )

            updated_item = case requested_operation
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
              case lifecycle_operation
            when :acknowledge
              app_class.acknowledge_orchestration_item(item[:id], note: note, audit: applied_audit)
            when :resolve
              app_class.resolve_orchestration_item(item[:id], target: target, value: value, note: note, audit: applied_audit)
            when :dismiss
              app_class.dismiss_orchestration_item(item[:id], note: note, audit: applied_audit)
            else
              raise ArgumentError, "unsupported orchestration operation #{lifecycle_operation.inspect}"
              end
            end

            return nil unless updated_item

            updated_item.merge(
              handled_action: item[:action],
              handled_operation: requested_operation,
              handled_lifecycle_operation: lifecycle_operation,
              handled_policy: policy.name,
              handled_lane: item.dig(:lane, :name),
              handled_handler_queue: item[:queue],
              handled_audit_source: applied_audit[:source],
              handled_assignee: updated_item[:assignee],
              handled_queue: updated_item[:queue],
              handled_channel: updated_item[:channel]
            )
          end

          private

          def normalize_operation(operation)
            operation.to_sym
          end

          def default_operation(_item, policy)
            policy.default_operation
          end

          def validate_operation!(policy, applied_operation, item)
            return if policy.allows_operation?(applied_operation)

            raise ArgumentError,
                  "operation #{applied_operation.inspect} is not allowed for orchestration item #{item[:id].inspect}; allowed operations: #{(policy.allowed_operations + policy.lifecycle_operations).join(', ')}"
          end

          def normalize_audit(audit)
            audit.to_h.each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end
          end
        end

        class InteractiveSessionHandler < Base; end

        class CompletionHandler < Base; end
      end
    end
  end
end
