# frozen_string_literal: true

module Igniter
  module ExecutionReport
    # Formats an ExecutionReport::Report as human-readable text.
    #
    # Example:
    #
    #   Contract: OrderWorkflow
    #   Success:  NO
    #
    #     [ok]     input      :order_id
    #     [ok]     input      :amount
    #     [ok]     compute    :reserve_stock
    #     [fail]   compute    :charge_card
    #                error: Insufficient funds
    #     [pend]   compute    :send_confirmation
    #
    module Formatter
      class << self
        def format(report)
          lines = []
          lines << "Contract: #{report.contract_class.name}"
          lines << "Success:  #{report.success? ? "YES" : "NO"}"
          lines << ""

          report.entries.each do |entry|
            append_entry(entry, lines)
          end

          lines.join("\n")
        end

        private

        def append_entry(entry, lines)
          tag = case entry.status
                when :succeeded then "[ok]  "
                when :failed    then "[fail]"
                else                 "[pend]"
                end
          kind_label = entry.effect_type ? "effect:#{entry.effect_type}" : entry.kind.to_s
          kind_str = kind_label.ljust(10)
          lines << "  #{tag}  #{kind_str}  :#{entry.name}"
          lines << "               error: #{entry.error.message}" if entry.failed? && entry.error
        end
      end
    end
  end
end
