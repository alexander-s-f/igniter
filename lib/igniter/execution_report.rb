# frozen_string_literal: true

require_relative "errors"
require_relative "execution_report/node_entry"
require_relative "execution_report/formatter"
require_relative "execution_report/report"
require_relative "execution_report/builder"

module Igniter
  # Post-hoc execution report — answers "what ran, what succeeded, what failed?"
  #
  # Reconstructs a structured timeline from the compiled graph's resolution
  # order and the execution cache.  Works regardless of whether the contract
  # succeeded or raised an error.
  #
  # Usage:
  #
  #   require "igniter/extensions/execution_report"
  #
  #   contract = MyContract.new(inputs)
  #   contract.resolve_all rescue nil   # run regardless of outcome
  #
  #   report = contract.execution_report
  #   report.success?         # => false
  #   report.failed_nodes     # => [:charge_card]
  #   report.pending_nodes    # => [:send_confirmation]
  #   puts report.explain     # formatted table
  #
  module ExecutionReport
    class ExecutionReportError < Igniter::Error; end
  end
end
