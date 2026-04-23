# frozen_string_literal: true

module Igniter
  class App
    module Operator
      class HandlerResult
        attr_reader :id, :handled_action, :handled_operation, :handled_lifecycle_operation,
                    :handled_execution_operation, :handled_policy, :handled_lane,
                    :handled_queue, :handled_channel, :handled_handler_queue,
                    :handled_audit_source, :handled_actor, :handled_origin,
                    :handled_actor_channel, :handled_assignee, :note, :status,
                    :report_status, :payload

        def initialize(id:, handled_action: nil, handled_operation:, handled_lifecycle_operation:,
                       handled_execution_operation:, handled_policy:, handled_lane: nil,
                       handled_queue: nil, handled_channel: nil, handled_handler_queue: nil,
                       handled_audit_source: nil, handled_actor: nil, handled_origin: nil,
                       handled_actor_channel: nil, handled_assignee: nil, note: nil,
                       status: nil, report_status: nil, payload: {})
          @id = id
          @handled_action = handled_action
          @handled_operation = handled_operation.to_sym
          @handled_lifecycle_operation = handled_lifecycle_operation.to_sym
          @handled_execution_operation = handled_execution_operation.to_sym
          @handled_policy = handled_policy.to_sym
          @handled_lane = handled_lane&.to_sym
          @handled_queue = handled_queue
          @handled_channel = handled_channel
          @handled_handler_queue = handled_handler_queue
          @handled_audit_source = handled_audit_source&.to_sym
          @handled_actor = handled_actor
          @handled_origin = handled_origin
          @handled_actor_channel = handled_actor_channel
          @handled_assignee = handled_assignee
          @note = note
          @status = status&.to_sym
          @report_status = report_status&.to_sym
          @payload = payload.dup.freeze
          freeze
        end

        def to_h
          {
            id: id,
            handled_action: handled_action,
            handled_operation: handled_operation,
            handled_lifecycle_operation: handled_lifecycle_operation,
            handled_execution_operation: handled_execution_operation,
            handled_policy: handled_policy,
            handled_lane: handled_lane,
            handled_queue: handled_queue,
            handled_channel: handled_channel,
            handled_handler_queue: handled_handler_queue,
            handled_audit_source: handled_audit_source,
            handled_actor: handled_actor,
            handled_origin: handled_origin,
            handled_actor_channel: handled_actor_channel,
            handled_assignee: handled_assignee,
            note: note,
            status: status,
            report_status: report_status
          }.merge(payload).compact.freeze
        end
      end
    end
  end
end
