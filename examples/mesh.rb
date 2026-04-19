# frozen_string_literal: true

# ─────────────────────────────────────────────────────────────────────────────
# Igniter Mesh — Phase 1: Static Mesh
#
# This example demonstrates how to configure a static peer topology and use
# the two new routing modes for remote: nodes:
#
#   capability: :sym   — auto-select an alive peer that advertises the capability;
#                        if none are alive the node is deferred (:pending), and
#                        resolution retries when inputs are updated.
#
#   pinned_to: "name"  — must call this exact peer; if it is down the node
#                        fails with IncidentError signalling admin intervention.
#
# In production you would require "igniter/cluster" and configure real
# peer URLs.  Here we stub the HTTP layer so the example runs without any
# actual servers.
# ─────────────────────────────────────────────────────────────────────────────

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/cluster"
require "json"

# ── 1. Configure the mesh ────────────────────────────────────────────────────

Igniter::Cluster::Mesh.configure do |c|
  c.peer_name          = "api-node"
  c.local_capabilities = [:api]

  # Declare the remote peers this node knows about.
  c.add_peer "orders-node",
             url: "http://orders.internal:4567",
             capabilities: %i[orders inventory]

  c.add_peer "audit-node",
             url: "http://audit.internal:4567",
             capabilities: %i[audit]
end

puts "Mesh configured with #{Igniter::Cluster::Mesh.config.peers.size} peers:"
Igniter::Cluster::Mesh.config.peers.each do |p|
  puts "  #{p.name} (#{p.url}) — capabilities: #{p.capabilities.join(", ")}"
end
puts

# ── 2. Server configuration (what a peer advertises) ────────────────────────

Igniter::Server.configure do |c|
  c.peer_name         = "orders-node"
  c.peer_capabilities = %i[orders inventory]
  c.register "ProcessOrder", Class.new(Igniter::Contract) do
    input :order_id
    define do
      compute :result, depends_on: :order_id do |order_id:|
        { id: order_id, status: "processed" }
      end
    end
    output :result, from: :result
  end
end

puts "Server peer_name:    #{Igniter::Server.config.peer_name}"
puts "Server capabilities: #{Igniter::Server.config.peer_capabilities.join(", ")}"
puts

# ── 3. Contract using capability: routing ───────────────────────────────────

class OrderPipeline < Igniter::Contract
  define do
    input :order_id
    # Route to any alive peer advertising :orders capability.
    # If no peer is alive → node defers (:pending) until one comes up.
    remote :order_result,
           contract: "ProcessOrder",
           capability: :orders,
           inputs: { order_id: :order_id }
    output :order_result
  end
end

# ── 4. Contract using pinned_to: routing ────────────────────────────────────

class AuditPipeline < Igniter::Contract
  define do
    input :event
    # Always call the "audit-node" — if it is down, raise IncidentError.
    # This is for critical side-effects that must not be load-balanced.
    remote :audit_log,
           contract: "WriteAudit",
           pinned_to: "audit-node",
           inputs: { event: :event }
    output :audit_log
  end
end

puts "OrderPipeline compiled:  #{OrderPipeline.compiled_graph.name}"
puts "AuditPipeline compiled:  #{AuditPipeline.compiled_graph.name}"
puts

# ── 5. Stub HTTP layer and demonstrate capability routing ────────────────────

# Simulate orders-node being alive.
def stub_alive(_url, health_response: { "status" => "ok" })
  client = Object.new

  client.define_singleton_method(:health) { health_response }
  client.define_singleton_method(:execute) do |_contract, inputs:|
    { status: :succeeded, outputs: { result: { id: inputs[:order_id], status: "processed" } } }
  end

  # We cannot easily monkey-patch in a plain script, so we demonstrate
  # the behaviour via inline contracts instead.
  client
end

puts "=== Scenario A: capability routing — orders-node alive ==="

Igniter::Cluster::Mesh.reset!
Igniter::Cluster::Mesh.configure do |c|
  c.add_peer "orders-node",
             url: "http://orders.internal:4567",
             capabilities: [:orders]
end

# Patch Client for demo purposes
orders_client = Object.new
orders_client.define_singleton_method(:health) { { "status" => "ok" } }
orders_client.define_singleton_method(:execute) do |_contract, inputs:|
  { status: :succeeded, outputs: { result: { id: inputs[:order_id], status: "processed" } } }
end

original_new = Igniter::Server::Client.method(:new)
Igniter::Server::Client.define_singleton_method(:new) do |url, **opts|
  url == "http://orders.internal:4567" ? orders_client : original_new.call(url, **opts)
end

contract = OrderPipeline.new(order_id: 42)
begin
  contract.resolve_all
  puts "  order_result: #{contract.result.order_result.inspect}"
rescue Igniter::Error => e
  puts "  Error: #{e.message}"
ensure
  Igniter::Server::Client.define_singleton_method(:new, &original_new)
  Igniter::Cluster::Mesh.reset!
end

puts

puts "=== Scenario B: capability routing — no alive peers (deferred) ==="

Igniter::Cluster::Mesh.reset!
Igniter::Cluster::Mesh.configure do |c|
  c.add_peer "orders-node",
             url: "http://orders.internal:4567",
             capabilities: [:orders]
end

dead_client = Object.new
dead_client.define_singleton_method(:health) do
  raise Igniter::Server::Client::ConnectionError, "Connection refused"
end

Igniter::Server::Client.define_singleton_method(:new) do |url, **opts|
  url == "http://orders.internal:4567" ? dead_client : original_new.call(url, **opts)
end

contract = OrderPipeline.new(order_id: 42)
begin
  contract.resolve_all
rescue Igniter::Error
  nil
end

order_state = contract.execution.cache.fetch(:order_result)
puts "  order_result status: #{order_state&.status.inspect}   (expected :pending)"

Igniter::Server::Client.define_singleton_method(:new, &original_new)
Igniter::Cluster::Mesh.reset!
puts

puts "=== Scenario C: pinned_to routing — audit-node down (incident) ==="

Igniter::Cluster::Mesh.reset!
Igniter::Cluster::Mesh.configure do |c|
  c.add_peer "audit-node",
             url: "http://audit.internal:4567",
             capabilities: [:audit]
end

Igniter::Server::Client.define_singleton_method(:new) do |url, **opts|
  url == "http://audit.internal:4567" ? dead_client : original_new.call(url, **opts)
end

audit_contract = AuditPipeline.new(event: "order.created")
begin
  audit_contract.resolve_all
rescue Igniter::Error
  nil
end

audit_state = audit_contract.execution.cache.fetch(:audit_log)
puts "  audit_log status: #{audit_state&.status.inspect}   (expected :failed)"
puts "  error class:      #{audit_state&.error&.class}"
puts "  error message:    #{audit_state&.error&.message}"

Igniter::Server::Client.define_singleton_method(:new, &original_new)
Igniter::Cluster::Mesh.reset!
puts

# ── 6. GET /v1/manifest demo ─────────────────────────────────────────────────

puts "=== Server manifest endpoint ==="

Igniter::Server.configure do |c|
  c.peer_name         = "orders-node"
  c.peer_capabilities = %i[orders inventory]
end

registry = Igniter::Server::Registry.new
registry.register("ProcessOrder", Class.new(Igniter::Contract))

handler = Igniter::Server::Handlers::ManifestHandler.new(
  registry,
  Igniter::Runtime::Stores::MemoryStore.new,
  config: Igniter::Server.config
)

result = handler.call(params: {}, body: {})
manifest = JSON.parse(result[:body])
puts "  peer_name:    #{manifest["peer_name"]}"
puts "  capabilities: #{manifest["capabilities"].join(", ")}"
puts "  contracts:    #{manifest["contracts"].join(", ")}"
puts "  url:          #{manifest["url"]}"
puts

Igniter::Server.reset!

puts "Done."
