# frozen_string_literal: true

module Igniter
  class App
    module Operator
      module Handlers
        class OrchestrationHandler < Base
          def call(app_class:, record:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
            item = record[:inbox_item] || app_class.orchestration_inbox.find(record.fetch(:id))
            return nil unless item

            handler = app_class.orchestration_handler(item)
            kwargs = {
              app_class: app_class,
              item: item,
              operation: operation,
              target: target,
              value: value,
              assignee: assignee,
              queue: queue,
              channel: channel,
              note: note,
              audit: audit
            }
            kwargs.delete(:audit) unless app_class.send(:callable_accepts_keyword?, handler, :audit)

            handler.call(**kwargs)
          end
        end
      end
    end
  end
end
