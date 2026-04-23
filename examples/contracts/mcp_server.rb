# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-mcp-adapter/lib", __dir__))

require "igniter-mcp-adapter"

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::McpPack)

tool = Igniter::MCP::Adapter::Server.tool(:creator_session_apply)

response = Igniter::MCP::Adapter::Server.call(
  :creator_session_start,
  target: environment,
  arguments: {
    name: "delivery",
    capabilities: %w[effect executor]
  }
)

puts "contracts_mcp_server_required=#{tool.fetch(:inputSchema).fetch(:required).join(",")}"
puts "contracts_mcp_server_tool=#{tool.fetch(:name)}"
puts "contracts_mcp_server_error=#{response.fetch(:isError)}"
puts "contracts_mcp_server_decision=#{response.fetch(:structuredContent).fetch(:pending_decisions).first.fetch(:key)}"
