# frozen_string_literal: true

# Igniter Mesh — Phase 2: Dynamic Discovery
#
# Demonstrates how peers self-register at startup and how the local node
# discovers topology without a static add_peer list.
#
# This example uses in-process stubs so no real HTTP servers are needed.

require_relative "../lib/igniter/extensions/mesh"

# ─── Shared contract ──────────────────────────────────────────────────────────
class ProcessOrder < Igniter::Contract
  define do
    input :order_id
    compute :status, depends_on: :order_id do |order_id:|
      order_id > 0 ? "accepted" : "rejected"
    end
    output :status
  end
end

# ─── Stub HTTP layer ──────────────────────────────────────────────────────────
# In production each peer is a separate igniter-server process. Here we stub
# the HTTP client so the example runs inline.

module ClientStubs
  PEERS = {
    "http://orders-node-1:4567" => {
      peer_name:    "orders-node-1",
      capabilities: %i[orders inventory],
      contracts:    ["ProcessOrder"],
      alive:        true
    },
    "http://orders-node-2:4567" => {
      peer_name:    "orders-node-2",
      capabilities: %i[orders],
      contracts:    ["ProcessOrder"],
      alive:        true
    },
    "http://audit-node:4567" => {
      peer_name:    "audit-node",
      capabilities: %i[audit],
      contracts:    ["WriteAudit"],
      alive:        false  # <-- offline
    },
    "http://seed:4567" => {
      peer_name:    "seed",
      capabilities: [],
      contracts:    [],
      alive:        true,
      # What the seed returns for GET /v1/mesh/peers:
      known_peers: [
        { name: "orders-node-1", url: "http://orders-node-1:4567", capabilities: ["orders", "inventory"] },
        { name: "orders-node-2", url: "http://orders-node-2:4567", capabilities: ["orders"] },
        { name: "audit-node",    url: "http://audit-node:4567",    capabilities: ["audit"] }
      ]
    }
  }.freeze

  def self.install!
    Igniter::Server::Client.class_eval do
      alias_method :real_health,        :health
      alias_method :real_manifest,      :manifest
      alias_method :real_list_peers,    :list_peers
      alias_method :real_register_peer, :register_peer

      def health
        info = ClientStubs::PEERS[@base_url]
        raise Igniter::Server::Client::ConnectionError, "offline" unless info && info[:alive]

        { "status" => "ok" }
      end

      def manifest
        info = ClientStubs::PEERS[@base_url] || {}
        { peer_name: info[:peer_name], capabilities: info[:capabilities] || [],
          contracts: info[:contracts] || [], url: @base_url }
      end

      def list_peers
        info = ClientStubs::PEERS[@base_url] || {}
        (info[:known_peers] || []).map do |p|
          { name: p[:name], url: p[:url], capabilities: Array(p[:capabilities]).map(&:to_sym) }
        end
      end

      def register_peer(name:, url:, capabilities: [])
        puts "  [seed] registered peer: #{name} @ #{url} caps=#{capabilities}"
        { "registered" => true }
      end
    end
  end

  def self.uninstall!
    Igniter::Server::Client.class_eval do
      alias_method :health,        :real_health
      alias_method :manifest,      :real_manifest
      alias_method :list_peers,    :real_list_peers
      alias_method :register_peer, :real_register_peer
    end
  end
end

ClientStubs.install!

# ─── Stub execute path ────────────────────────────────────────────────────────
Igniter::Server::Client.class_eval do
  alias_method :real_execute, :execute
  def execute(contract_name, inputs: {})
    order_id = inputs[:order_id] || inputs["order_id"] || 0
    contract = ProcessOrder.new(order_id: order_id)
    contract.resolve_all
    { status: :succeeded, execution_id: "stub-#{order_id}",
      outputs: { status: contract.result.status }, waiting_for: [], error: nil }
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 1 — Dynamic topology discovery at startup
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 1: Dynamic discovery from seed"
puts "=" * 60

Igniter::Mesh.configure do |c|
  c.peer_name          = "api-node"
  c.local_url          = "http://api-node:4567"
  c.local_capabilities = %i[api]
  c.seeds              = %w[http://seed:4567]
  c.discovery_interval = 60
end

puts "\nBefore start_discovery!:"
puts "  Dynamic peers: #{Igniter::Mesh.config.peer_registry.size}"

Igniter::Mesh.start_discovery!

puts "\nAfter start_discovery!:"
puts "  Dynamic peers: #{Igniter::Mesh.config.peer_registry.size}"
Igniter::Mesh.config.peer_registry.all.each do |p|
  puts "  - #{p.name} @ #{p.url} caps=#{p.capabilities}"
end
puts

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 2 — Capability routing over discovered peers
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 2: Capability routing to discovered peers"
puts "=" * 60

class OrderPipeline < Igniter::Contract
  define do
    input :order_id

    remote :order_result,
           contract:   "ProcessOrder",
           capability: :orders,
           inputs:     { order_id: :order_id }

    output :order_result
  end
end

results = [101, 102, 103].map do |id|
  contract = OrderPipeline.new(order_id: id)
  contract.resolve_all
  status = contract.result.order_result[:status]
  puts "  order_id=#{id} → status=#{status}"
  status
end

puts "\nAll orders accepted: #{results.all? { |r| r == "accepted" }}"
puts

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 3 — New peer joins mid-run (simulated via direct registration)
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 3: New peer joins the mesh mid-run"
puts "=" * 60

# Simulate a new billing-node announcing itself via POST /v1/mesh/peers
# In production this is done by the new peer calling start_discovery!
new_peer = Igniter::Mesh::Peer.new(
  name:         "billing-node",
  url:          "http://billing-node:4567",
  capabilities: %i[billing]
)
Igniter::Mesh.config.peer_registry.register(new_peer)

puts "  Registered billing-node into local registry"
puts "  Peers with :billing capability: #{Igniter::Mesh.config.peer_registry.peers_with_capability(:billing).map(&:name)}"
puts

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 4 — Deferred when discovered peer is offline
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 4: Capability routing → :pending when peer offline"
puts "=" * 60

class AuditPipeline < Igniter::Contract
  define do
    input :event

    remote :audit_log,
           contract:   "WriteAudit",
           capability: :audit,
           inputs:     { event: :event }

    output :audit_log
  end
end

contract = AuditPipeline.new(event: "order_placed")
begin
  contract.resolve_all
rescue Igniter::Error
  nil
end

cache = contract.execution.cache
audit_state = cache.values.find { |s| s.node.name == :audit_log }
puts "  audit_log node status: #{audit_state&.status || :unknown}"
puts "  (audit-node is offline → capability routing defers → :pending)"
puts

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 5 — Static + dynamic peers merged
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 5: Static add_peer + dynamic discovery merged"
puts "=" * 60

Igniter::Mesh.stop_discovery!
Igniter::Mesh.reset!

Igniter::Mesh.configure do |c|
  c.peer_name = "api-node"
  c.local_url = "http://api-node:4567"
  c.seeds     = %w[http://seed:4567]
  c.discovery_interval = 60
  # Static peer declared manually:
  c.add_peer "legacy-node", url: "http://legacy:4567", capabilities: %i[billing]
end

Igniter::Mesh.start_discovery!

static_names  = Igniter::Mesh.config.peers.map(&:name)
dynamic_names = Igniter::Mesh.config.peer_registry.all.map(&:name)

puts "  Static peers:  #{static_names}"
puts "  Dynamic peers: #{dynamic_names}"
puts "  Combined (via router):"
all_orders = Igniter::Mesh.router.instance_eval { all_capable_peers(:orders) }.map(&:name)
puts "    :orders capable peers: #{all_orders}"

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────
Igniter::Mesh.stop_discovery!
Igniter::Mesh.reset!
ClientStubs.uninstall!

puts "\nDone."
