# frozen_string_literal: true

module Igniter
  module Saga
    # Formats a SagaResult as a human-readable text block.
    #
    # Example:
    #
    #   Contract: OrderWorkflow
    #   Status:   FAILED
    #   Error:    Insufficient funds
    #   At node:  :charge_card
    #
    #   COMPENSATIONS (1):
    #     [ok]    :reserve_stock
    #
    module Formatter
      class << self
        def format(result)
          lines = []
          lines << "Contract: #{result.contract.class.name}"
          lines << "Status:   #{result.success? ? "SUCCESS" : "FAILED"}"

          if result.failed?
            lines << "Error:    #{result.error&.message}"
            lines << "At node:  :#{result.failed_node}" if result.failed_node
          end

          append_compensations(result, lines)
          lines.join("\n")
        end

        private

        def append_compensations(result, lines)
          return if result.compensations.empty?

          lines << ""
          lines << "COMPENSATIONS (#{result.compensations.size}):"
          result.compensations.each do |rec|
            tag = rec.success? ? "[ok]   " : "[fail] "
            lines << "  #{tag} :#{rec.node_name}"
            lines << "    error: #{rec.error.message}" if rec.failed?
          end
        end
      end
    end
  end
end
