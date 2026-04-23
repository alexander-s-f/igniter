# frozen_string_literal: true

module Igniter
  class App
    module Operator
      class Dispatcher
        def call(app_class:, record:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
          kind = operator_kind_for(record)
          raise ArgumentError, "operator item #{record[:id].inspect} is not actionable" unless kind

          handler = HandlerRegistry.fetch(kind)
          kwargs = {
            app_class: app_class,
            record: record,
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

        private

        def operator_kind_for(record)
          kind = record[:record_kind] || record.dig(:lifecycle, :record_kind)
          return kind.to_sym if kind

          nil
        end
      end
    end
  end
end
