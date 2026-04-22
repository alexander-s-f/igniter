#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with

report = environment.compilation_report do
  input :order_total
  input :country

  compute :subtotal, depends_on: [:order_total] do |order_total:|
    order_total.round(2)
  end

  compute :vat_rate, depends_on: [:country] do |country:|
    country == "UA" ? 0.2 : 0.0
  end

  compute :grand_total, depends_on: %i[subtotal vat_rate] do |subtotal:, vat_rate:|
    (subtotal * (1 + vat_rate)).round(2)
  end

  output :grand_total
end

compiled = report.to_compiled_graph
result = environment.execute(compiled, inputs: { order_total: 100, country: "UA" })
diagnostics = environment.diagnose(result)

puts "=== Compilation Report ==="
puts "contracts_introspection_ok=#{report.ok?}"
puts "contracts_introspection_operations=#{report.operations.map(&:name).join(',')}"

puts "\n=== Compiled Graph ==="
puts "contracts_introspection_graph=#{compiled.to_h.inspect}"

puts "\n=== Execution Result ==="
puts "contracts_introspection_output=#{result.output(:grand_total)}"
puts "contracts_introspection_result=#{result.to_h.inspect}"

puts "\n=== Diagnostics Report ==="
puts "contracts_introspection_sections=#{diagnostics.section_names.join(',')}"
puts diagnostics.to_h.inspect
