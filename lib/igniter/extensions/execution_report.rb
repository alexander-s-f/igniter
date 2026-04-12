# frozen_string_literal: true

require_relative "../../igniter"
require_relative "../core/execution_report"

module Igniter
  module Extensions
    # Adds execution_report method to all Igniter contracts.
    #
    # Applied globally via:
    #   Igniter::Contract.include(Igniter::Extensions::ExecutionReport)
    #
    module ExecutionReport
      # Build a structured execution report from the current execution state.
      #
      # Can be called after resolve_all succeeds OR after it raises — in both
      # cases the cache contains partial or full execution state.
      #
      # @return [Igniter::ExecutionReport::Report]
      def execution_report
        Igniter::ExecutionReport::Builder.build(self)
      end
    end
  end
end

Igniter::Contract.include(Igniter::Extensions::ExecutionReport)
