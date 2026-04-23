# frozen_string_literal: true

require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::McpPack)

tool_names = Igniter::Extensions::Contracts.mcp_tools.map { |tool| tool.fetch(:name) }
session_apply_tool = Igniter::Extensions::Contracts.mcp_tools.find { |tool| tool.fetch(:name) == :creator_session_apply }

wizard = Igniter::Extensions::Contracts.mcp_call(
  :creator_wizard,
  target: environment,
  name: :delivery,
  capabilities: %i[effect executor]
)

session = Igniter::Extensions::Contracts.mcp_creator_session(
  target: environment,
  name: :delivery,
  capabilities: %i[effect executor]
)

completed_session = Igniter::Extensions::Contracts.mcp_call(
  :creator_session_apply,
  target: environment,
  session: session.to_h.fetch(:payload).fetch(:session),
  updates: { scope: :standalone_gem }
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
puts "contracts_mcp_session_apply_args=#{session_apply_tool.fetch(:arguments).map { |argument| argument.fetch(:name) }.join(',')}"
puts "contracts_mcp_wizard_decision=#{wizard.to_h.fetch(:payload).fetch(:pending_decisions).first.fetch(:key)}"
puts "contracts_mcp_session_ready=#{completed_session.to_h.fetch(:payload).fetch(:ready_for_writer)}"
puts "contracts_mcp_debug_output=#{debug.to_h.fetch(:payload).fetch(:execution).fetch(:outputs).fetch(:amount)}"
puts "contracts_mcp_write_files=#{write_payload.fetch(:files_written)}"
