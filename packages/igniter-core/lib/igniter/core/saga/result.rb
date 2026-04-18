# frozen_string_literal: true

module Igniter
  module Saga
    # Immutable result of a saga execution (resolve_saga call).
    #
    # Attributes:
    #   contract      — the contract instance that was executed
    #   error         — Igniter::Error that caused failure (nil on success)
    #   failed_node   — Symbol name of the first node that failed (nil on success)
    #   compensations — Array<CompensationRecord> for all attempted compensations
    class Result
      attr_reader :contract, :error, :failed_node, :compensations

      def initialize(success:, contract:, error: nil, failed_node: nil, compensations: [])
        @success       = success
        @contract      = contract
        @error         = error
        @failed_node   = failed_node
        @compensations = compensations.freeze
        freeze
      end

      def success? = @success
      def failed?  = !@success

      # Human-readable saga report.
      def explain
        Formatter.format(self)
      end

      alias to_s explain

      # Structured (serialisable) representation.
      def to_h
        {
          success: success?,
          failed_node: failed_node,
          error: error&.message,
          compensations: compensations.map do |rec|
            { node: rec.node_name, success: rec.success?, error: rec.error&.message }
          end
        }
      end
    end
  end
end
