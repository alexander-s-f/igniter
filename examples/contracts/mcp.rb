# frozen_string_literal: true

require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::McpPack)

tool_names = Igniter::Extensions::Contracts.mcp_tools.map { |tool| tool.fetch(:name) }

wizard = Igniter::Extensions::Contracts.mcp_call(
  :creator_wizard,
  target: environment,
  name: :delivery,
  capabilities: %i[effect executor]
)

debug = Igniter::Extensions::Contracts.mcp_call(
  :debug_report,
  target: environment,
  inputs: { amount: 12 }
) do
  input :amount
  output :amount
end

write_payload = nil
Dir.mktmpdir("igniter_mcp_example") do |dir|
  write_payload = Igniter::Extensions::Contracts.mcp_call(
    :creator_write,
    name: :slug,
    profile: :feature_node,
    scope: :app_local,
    root: dir
  ).to_h.fetch(:payload)
end

puts "contracts_mcp_tools=#{tool_names.join(',')}"
puts "contracts_mcp_wizard_decision=#{wizard.to_h.fetch(:payload).fetch(:pending_decisions).first.fetch(:key)}"
puts "contracts_mcp_debug_output=#{debug.to_h.fetch(:payload).fetch(:execution).fetch(:outputs).fetch(:amount)}"
puts "contracts_mcp_write_files=#{write_payload.fetch(:files_written)}"
