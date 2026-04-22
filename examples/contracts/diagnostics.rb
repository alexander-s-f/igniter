#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with

result = environment.run(inputs: { order_total: 100, country: "UA" }) do
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

report = environment.diagnose(result)

puts "contracts_diagnostics_output=#{result.output(:gross_total)}"
puts "contracts_diagnostics_sections=#{report.section_names.join(',')}"
puts "contracts_diagnostics_baseline=#{report.section(:baseline_summary).inspect}"
puts "---"
puts report.to_h.inspect
