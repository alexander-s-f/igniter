#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

Igniter::Extensions::Contracts::JournalPack.reset_journal!

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::JournalPack)

execution_result = environment.run(inputs: { quote_total: 120 }) do
  input :quote_total
  effect :journal_entry, using: :journal, depends_on: [:quote_total] do |quote_total:|
    { quote_total: quote_total, event: "quote_requested" }
  end
  output :journal_entry
end

effect_result = environment.apply_effect(
  :journal,
  payload: { quote_total: 120, event: "quote_requested_direct" },
  context: { source: :contracts_example }
)

diagnostics = environment.diagnose(execution_result)
journal = Igniter::Extensions::Contracts::JournalPack.journal

puts "contracts_effect_payload=#{effect_result.inspect}"
puts "contracts_graph_effect_output=#{execution_result.output(:journal_entry).inspect}"
puts "contracts_effect_entries=#{journal[:effects].length}"
puts "contracts_effect_sections=#{diagnostics.section_names.join(",")}"
