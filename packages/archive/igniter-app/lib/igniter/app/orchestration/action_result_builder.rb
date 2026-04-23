# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class ActionResultBuilder
        def self.build(item:, requested_operation:, handled_operation:, handled_lifecycle_operation:,
                       handled_execution_operation:, handled_policy:, handled_lane: nil,
                       handled_queue: nil, handled_channel: nil, handled_handler_queue: nil,
                       handled_assignee: nil, note: nil, audit: nil)
          audit_payload = (audit || {}).dup
          latest_history = Array(item[:action_history]).last || {}

          {
            id: item[:id],
            action: item[:action],
            operation: {
              requested: requested_operation&.to_sym,
              handled: handled_operation&.to_sym,
              lifecycle: handled_lifecycle_operation&.to_sym,
              execution: handled_execution_operation&.to_sym
            }.compact.freeze,
            policy: {
              name: handled_policy&.to_sym,
              lane: handled_lane&.to_sym,
              queue: handled_queue,
              channel: handled_channel,
              handler_queue: handled_handler_queue
            }.compact.freeze,
            audit: {
              source: audit_payload[:source]&.to_sym,
              actor: audit_payload[:actor],
              origin: audit_payload[:origin],
              actor_channel: audit_payload[:actor_channel],
              assignee: handled_assignee,
              note: note
            }.compact.freeze,
            workflow: {
              status: item[:status]&.to_sym,
              queue: item[:queue],
              channel: item[:channel],
              assignee: item[:assignee],
              action_history_count: Array(item[:action_history]).size,
              latest_event: latest_history[:event]&.to_sym
            }.compact.freeze,
            runtime: runtime_slice(item)
          }.compact.freeze
        end

        def self.runtime_slice(item)
          runtime = {
            status: item[:orchestration_runtime_status]&.to_sym,
            state: item[:orchestration_runtime_state]&.to_sym,
            state_class: item[:orchestration_runtime_state_class]&.to_sym,
            latest_transition: item[:orchestration_runtime_latest_transition]&.dup,
            latest_event: item[:orchestration_runtime_latest_event]&.dup,
            result: item[:orchestration_runtime_result]&.dup
          }.compact

          runtime.empty? ? nil : runtime.freeze
        end
      end
    end
  end
end
