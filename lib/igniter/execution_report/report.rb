# frozen_string_literal: true

module Igniter
  module ExecutionReport
    # Structured post-hoc report of what happened during contract execution.
    #
    # Built from the compiled graph's resolution order + execution cache state.
    # Can be generated any time after resolve_all (including after an error).
    #
    # Attributes:
    #   contract_class — the contract class that was executed
    #   entries        — Array<NodeEntry> in resolution order
    class Report
      attr_reader :contract_class, :entries

      def initialize(contract_class:, entries:)
        @contract_class = contract_class
        @entries        = entries.freeze
        freeze
      end

      # True when no nodes failed.
      def success?
        entries.none?(&:failed?)
      end

      # Symbol names of nodes that succeeded.
      def resolved_nodes
        entries.select(&:succeeded?).map(&:name)
      end

      # Symbol names of nodes that failed.
      def failed_nodes
        entries.select(&:failed?).map(&:name)
      end

      # Symbol names of nodes that never ran.
      def pending_nodes
        entries.select(&:pending?).map(&:name)
      end

      # Map of { node_name => error } for failed nodes.
      def errors
        entries.select(&:failed?).each_with_object({}) { |e, h| h[e.name] = e.error }
      end

      # Human-readable execution report.
      def explain
        Formatter.format(self)
      end

      alias to_s explain

      def to_h
        {
          contract: contract_class.name,
          success: success?,
          nodes: entries.map do |e|
            { name: e.name, kind: e.kind, status: e.status, error: e.error&.message }
          end
        }
      end
    end
  end
end
