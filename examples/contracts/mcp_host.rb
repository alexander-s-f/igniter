# frozen_string_literal: true

require "json"
require "stringio"

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-mcp-adapter/lib", __dir__))

require "igniter-mcp-adapter"

host = Igniter::MCP::Adapter::Host.new

initialize_response = host.handle_message(
  jsonrpc: "2.0",
  id: 1,
  method: "initialize"
)

tools_response = host.handle_message(
  jsonrpc: "2.0",
  id: 2,
  method: "tools/list"
)

call_response = host.handle_message(
  jsonrpc: "2.0",
  id: 3,
  method: "tools/call",
  params: {
    name: "creator_session_start",
    arguments: {
      name: "delivery",
      capabilities: %w[effect executor]
    }
  }
)

invalid_response = host.handle_message(
  jsonrpc: "2.0",
  id: 4,
  method: "tools/call",
  params: {
    name: "creator_session_apply",
    arguments: {
      session: {}
    }
  }
)

puts "contracts_mcp_host_protocol=#{initialize_response.fetch(:result).fetch(:protocolVersion)}"
puts "contracts_mcp_host_tools=#{tools_response.fetch(:result).fetch(:tools).length.positive?}"
puts "contracts_mcp_host_decision=#{call_response.fetch(:result).fetch(:structuredContent).fetch(:pending_decisions).first.fetch(:key)}"
puts "contracts_mcp_host_error=#{call_response.key?(:error)}"
puts "contracts_mcp_host_invalid_code=#{invalid_response.fetch(:error).fetch(:code)}"
