#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

Igniter::Extensions::Contracts::JournalPack.reset_journal!

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::JournalPack)

compiled = environment.compile do
  input :amount
  output :amount
end

effect_result = environment.apply_effect(
  :journal,
  payload: { amount: 10, event: "quoted" },
  context: { source: :example }
)

execution_result = environment.execute_with(
  :journaled_inline,
  compiled,
  inputs: { amount: 15 }
)

journal = Igniter::Extensions::Contracts::JournalPack.journal

puts "journal_effect_payload=#{effect_result.inspect}"
puts "journal_execution_output=#{execution_result.output(:amount)}"
puts "journal_effect_entries=#{journal[:effects].length}"
puts "journal_execution_entries=#{journal[:executions].length}"
puts "journal_result_entries=#{journal[:results].length}"
