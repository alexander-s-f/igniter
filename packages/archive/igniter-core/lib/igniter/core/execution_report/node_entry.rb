# frozen_string_literal: true

module Igniter
  module ExecutionReport
    # Snapshot of a single node's execution state.
    class NodeEntry
      attr_reader :name, :kind, :status, :value, :error, :effect_type

      def initialize(name:, kind:, status:, value: nil, error: nil, effect_type: nil) # rubocop:disable Metrics/ParameterLists
        @name        = name
        @kind        = kind
        @status      = status
        @value       = value
        @error       = error
        @effect_type = effect_type
        freeze
      end

      def succeeded? = status == :succeeded
      def failed?    = status == :failed
      def pending?   = !succeeded? && !failed?
    end
  end
end
