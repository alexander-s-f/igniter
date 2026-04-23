#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-core/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter"
require "igniter/extensions/execution_report"
require "igniter/extensions/contracts"

class LegacyExecutionReportPricing < Igniter::Contract
  define do
    input :order_total
    input :country

    compute :vat_rate, depends_on: [:country] do |country:|
      country == "UA" ? 0.2 : 0.0
    end

    compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end

    output :gross_total
  end
end

legacy_contract = LegacyExecutionReportPricing.new(order_total: 100, country: "UA")
legacy_contract.resolve_all
legacy_report = legacy_contract.execution_report

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::ExecutionReportPack
)

contracts_result = environment.run(inputs: { order_total: 100, country: "UA" }) do
  input :order_total
  input :country

  compute :vat_rate, depends_on: [:country] do |country:|
    country == "UA" ? 0.2 : 0.0
  end

  compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
    order_total * (1 + vat_rate)
  end

  output :gross_total
end

contracts_report = environment.diagnose(contracts_result)

puts "legacy_execution_report_output=#{legacy_contract.result.gross_total}"
puts "legacy_execution_report_entries=#{legacy_report.entries.length}"
puts "contracts_execution_report_output=#{contracts_result.output(:gross_total)}"
puts "contracts_execution_report_sections=#{contracts_report.section_names.join(',')}"
puts "execution_report_pack_installed=#{environment.profile.pack_names.include?(:extensions_execution_report)}"
puts "execution_report_migration_match=#{legacy_contract.result.gross_total == contracts_result.output(:gross_total)}"
