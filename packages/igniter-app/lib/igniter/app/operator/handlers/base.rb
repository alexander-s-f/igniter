# frozen_string_literal: true

module Igniter
  class App
    module Operator
      module Handlers
        class Base
          private

          def normalize_operation(operation)
            operation.to_sym
          end

          def normalize_audit(audit)
            audit.to_h.each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end
          end

          def resolve_operator_action(policy, operation, context: nil)
            requested_operation = normalize_operation(operation || policy.default_operation)
            validate_operation!(policy, requested_operation, context: context)
            resolved_operation =
              if policy.allowed_operations.include?(requested_operation)
                requested_operation
              else
                policy.canonical_operation_for(requested_operation)
              end

            {
              requested_operation: requested_operation,
              handled_operation: resolved_operation,
              handled_lifecycle_operation: policy.lifecycle_operation_for(resolved_operation),
              handled_execution_operation: policy.execution_operation_for(resolved_operation)
            }.freeze
          end

          def validate_operation!(policy, applied_operation, context: nil)
            return if policy.allows_operation?(applied_operation)

            allowed = (policy.allowed_operations + policy.lifecycle_operations).uniq
            message =
              if context
                "operation #{applied_operation.inspect} is not allowed for #{context}; allowed operations: #{allowed.join(', ')}"
              else
                "operation #{applied_operation.inspect} is not allowed for operator policy #{policy.name.inspect}; allowed operations: #{allowed.join(', ')}"
              end

            raise ArgumentError, message
          end

          def build_result(id:, policy:, action:, action_resolution:, lane:, queue:, channel:, note:, audit:, status:, report_status: nil, assignee: nil, handler_queue: nil, payload: {})
            HandlerResult.new(
              id: id,
              handled_action: action,
              handled_operation: action_resolution.fetch(:handled_operation),
              handled_lifecycle_operation: action_resolution.fetch(:handled_lifecycle_operation),
              handled_execution_operation: action_resolution.fetch(:handled_execution_operation),
              handled_policy: policy.name,
              handled_lane: lane,
              handled_queue: queue,
              handled_channel: channel,
              handled_handler_queue: handler_queue,
              handled_audit_source: audit[:source],
              handled_actor: audit[:actor],
              handled_origin: audit[:origin],
              handled_actor_channel: audit[:actor_channel],
              handled_assignee: assignee,
              note: note,
              status: status,
              report_status: report_status,
              payload: payload
            ).to_h
          end
        end
      end
    end
  end
end
