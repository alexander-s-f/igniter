#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

Igniter::Extensions::Contracts::JournalPack.reset_journal!

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::JournalPack)

compiled = environment.compile do
  input :quote_total
  output :quote_total
end

effect_result = environment.apply_effect(
  :journal,
  payload: { quote_total: 120, event: "quote_requested" },
  context: { source: :contracts_example }
)

execution_result = environment.execute_with(
  :journaled_inline,
  compiled,
  inputs: { quote_total: 120 }
)

diagnostics = environment.diagnose(execution_result)
journal = Igniter::Extensions::Contracts::JournalPack.journal

puts "contracts_effect_payload=#{effect_result.inspect}"
puts "contracts_executor_output=#{execution_result.output(:quote_total)}"
puts "contracts_effect_entries=#{journal[:effects].length}"
puts "contracts_execution_entries=#{journal[:executions].length}"
puts "contracts_result_entries=#{journal[:results].length}"
puts "contracts_effect_sections=#{diagnostics.section_names.join(',')}"
