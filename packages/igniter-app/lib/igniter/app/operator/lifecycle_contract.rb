# frozen_string_literal: true

module Igniter
  class App
    module Operator
      class LifecycleContract
        TERMINAL_STATUSES = %i[resolved dismissed joined failed torn_down].freeze

        attr_reader :record_kind, :status, :combined_state, :default_operation,
                    :allowed_operations, :runtime_completion, :attention_required,
                    :resumable, :actionable, :terminal, :history_count

        def initialize(record_kind:, status:, combined_state:, default_operation: nil,
                       allowed_operations: [], runtime_completion: nil,
                       attention_required:, resumable:, actionable:, terminal: nil,
                       history_count: 0)
          @record_kind = record_kind.to_sym
          @status = status&.to_sym
          @combined_state = combined_state&.to_sym
          @default_operation = default_operation&.to_sym
          @allowed_operations = Array(allowed_operations).map(&:to_sym).freeze
          @runtime_completion = runtime_completion&.to_sym
          @attention_required = !!attention_required
          @resumable = !!resumable
          @actionable = !!actionable
          @terminal = terminal.nil? ? infer_terminal : !!terminal
          @history_count = Integer(history_count || 0)
          freeze
        end

        def to_h
          {
            record_kind: record_kind,
            status: status,
            combined_state: combined_state,
            default_operation: default_operation,
            allowed_operations: allowed_operations,
            runtime_completion: runtime_completion,
            attention_required: attention_required,
            resumable: resumable,
            actionable: actionable,
            terminal: terminal,
            history_count: history_count
          }.freeze
        end

        private

        def infer_terminal
          TERMINAL_STATUSES.include?(status)
        end
      end
    end
  end
end
