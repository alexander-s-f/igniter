# frozen_string_literal: true

module Igniter
  class App
    module Operator
      module Handlers
        class IgniteHandler < Base
          def call(app_class:, record:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
            payload = record[:ignition_target] || {}
            policy = Igniter::App::Operator::Policy.from_h(record.fetch(:policy))
            action_resolution = resolve_operator_action(
              policy,
              operation,
              context: "ignition item #{record.fetch(:id).inspect}"
            )
            audit_payload = app_class.send(:normalize_ignite_operator_audit, audit)

            app_class.send(:stack_context_for!).ignition_trail.record(
              :"ignition_operator_#{action_resolution[:handled_operation]}",
              source: audit_payload[:source],
              payload: {
                target_id: payload[:target_id],
                requested_operation: action_resolution[:requested_operation],
                operation: action_resolution[:handled_operation],
                lifecycle_operation: action_resolution[:handled_lifecycle_operation],
                execution_operation: action_resolution[:handled_execution_operation],
                note: note,
                actor: audit_payload[:actor],
                origin: audit_payload[:origin],
                actor_channel: audit_payload[:actor_channel]
              }.compact
            )

            updated_report = execute_operation(
              app_class,
              payload,
              action_resolution.fetch(:handled_execution_operation),
              action_resolution.fetch(:handled_operation),
              note: note
            )

            build_result(
              id: record.fetch(:id),
              policy: policy,
              action: record[:action],
              action_resolution: action_resolution,
              lane: record.dig(:lane, :name),
              queue: record[:queue],
              channel: record[:channel],
              note: note,
              audit: audit_payload,
              status: app_class.operator_query(filters: { id: record.fetch(:id) }).first&.dig(:status) || payload[:status],
              report_status: updated_report&.status
            )
          end

          private

          def execute_operation(app_class, payload, execution_operation, handled_operation, note: nil)
            stack = app_class.send(:stack_context_for!)

            case execution_operation
            when :dismiss
              stack.latest_ignition_report
            when :approve, :retry_bootstrap
              stack.ignite(**app_class.send(:ignite_operator_options, payload, operation: handled_operation))
            when :detach
              report = stack.latest_ignition_report
              raise ArgumentError, "no persisted ignition report is available for detach" unless report

              stack.detach_ignite_target(
                report: report,
                target_id: payload.fetch(:target_id),
                mesh: app_class.send(:default_ignite_mesh),
                metadata: { reason: note }.compact
              )
            when :teardown
              report = stack.latest_ignition_report
              raise ArgumentError, "no persisted ignition report is available for teardown" unless report

              stack.teardown_ignite_target(
                report: report,
                target_id: payload.fetch(:target_id),
                mesh: app_class.send(:default_ignite_mesh),
                metadata: { reason: note }.compact
              )
            when :reignite
              stack.reignite_target(
                target_id: payload.fetch(:target_id),
                **app_class.send(:ignite_operator_options, payload, operation: handled_operation)
              )
            when :reconcile_join
              report = stack.latest_ignition_report
              raise ArgumentError, "no persisted ignition report is available for reconcile" unless report

              mesh = app_class.send(:default_ignite_mesh)
              raise ArgumentError, "reconcile_join requires an active mesh" unless mesh

              stack.reconcile_ignite(report: report, mesh: mesh)
            else
              raise ArgumentError, "unsupported ignition operation #{execution_operation.inspect}"
            end
          end
        end
      end
    end
  end
end
