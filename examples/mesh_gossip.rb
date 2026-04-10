# frozen_string_literal: true

# Igniter Mesh — Phase 3: Gossip Protocol
#
# Demonstrates how peer topology spreads through gossip even when seeds
# are unavailable. Three nodes form a mesh: A knows B, C only knows A.
# After one gossip round C discovers B — without ever contacting a seed.
#
# This example uses in-process stubs so no real HTTP servers are needed.

require_relative "../lib/igniter/extensions/mesh"

# ─── Shared contract ──────────────────────────────────────────────────────────
class CheckInventory < Igniter::Contract
  define do
    input :sku
    compute :available, depends_on: :sku do |sku:|
      sku.start_with?("VALID") ? true : false
    end
    output :available
  end
end

# ─── Node registries (in-memory representation of three separate processes) ───
#
# node_a: knows B (via seed bootstrap)
# node_b: fresh node with inventory capability
# node_c: knows A (via seed bootstrap), does NOT know B yet
#
# After node_c gossips with node_a → it will learn about node_b.

NODE_A = {
  name: "node-a", url: "http://node-a:4567",
  capabilities: %w[orders],
  peers: [
    { name: "node-b", url: "http://node-b:4567", capabilities: ["inventory"] }
  ]
}.freeze

NODE_B = {
  name: "node-b", url: "http://node-b:4567",
  capabilities: %w[inventory],
  peers: []
}.freeze

NODE_C = {
  name: "node-c", url: "http://node-c:4567",
  capabilities: %w[api],
  peers: [
    { name: "node-a", url: "http://node-a:4567", capabilities: ["orders"] }
  ]
}.freeze

# ─── Stub HTTP layer ──────────────────────────────────────────────────────────
# Stubs GET /v1/mesh/peers (list_peers) for each node URL.
# No health checks or execute stubs needed for this scenario.

PEER_DB = {
  NODE_A[:url] => NODE_A,
  NODE_B[:url] => NODE_B,
  NODE_C[:url] => NODE_C
}.freeze

Igniter::Server::Client.class_eval do
  alias_method :real_list_peers_gossip, :list_peers

  def list_peers
    info = PEER_DB[@base_url] || {}
    (info[:peers] || []).map do |p|
      { name: p[:name], url: p[:url], capabilities: Array(p[:capabilities]).map(&:to_sym) }
    end
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 1 — Baseline: C's registry before gossip
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 1: C's registry before gossip"
puts "=" * 60

Igniter::Mesh.configure do |c|
  c.peer_name          = NODE_C[:name]
  c.local_url          = NODE_C[:url]
  c.local_capabilities = NODE_C[:capabilities].map(&:to_sym)
  c.gossip_fanout      = 3
  c.discovery_interval = 60
  c.seeds              = []   # no seeds — gossip only
end

# C initially knows A (as if bootstrapped from a seed earlier)
Igniter::Mesh.config.peer_registry.register(
  Igniter::Mesh::Peer.new(name: NODE_A[:name], url: NODE_A[:url], capabilities: NODE_A[:capabilities].map(&:to_sym))
)

puts "\nC's registry before gossip:"
Igniter::Mesh.config.peer_registry.all.each do |p|
  puts "  - #{p.name} @ #{p.url} caps=#{p.capabilities}"
end

knows_b_before = !Igniter::Mesh.config.peer_registry.peer_named("node-b").nil?
puts "  C knows node-b? #{knows_b_before}"
puts

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 2 — Gossip round: C contacts A, learns about B
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 2: C runs one gossip round → discovers B via A"
puts "=" * 60

Igniter::Mesh::GossipRound.new(Igniter::Mesh.config).run

puts "\nC's registry after gossip:"
Igniter::Mesh.config.peer_registry.all.each do |p|
  puts "  - #{p.name} @ #{p.url} caps=#{p.capabilities}"
end

knows_b_after = !Igniter::Mesh.config.peer_registry.peer_named("node-b").nil?
puts "\n  C knows node-b? #{knows_b_after}"
puts "  Convergence achieved without seed: #{knows_b_after}"
puts

# ─────────────────────────────────────────────────────────────────────────────
# Scenario 3 — gossip_fanout = 0 disables gossip
# ─────────────────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Scenario 3: gossip_fanout = 0 disables the gossip round"
puts "=" * 60

Igniter::Mesh.reset!

Igniter::Mesh.configure do |c|
  c.peer_name          = NODE_C[:name]
  c.local_url          = NODE_C[:url]
  c.gossip_fanout      = 0   # disabled
  c.discovery_interval = 60
  c.seeds              = []
end

# Seed registry with A
Igniter::Mesh.config.peer_registry.register(
  Igniter::Mesh::Peer.new(name: NODE_A[:name], url: NODE_A[:url], capabilities: NODE_A[:capabilities].map(&:to_sym))
)

before_size = Igniter::Mesh.config.peer_registry.size
Igniter::Mesh::Poller.new(Igniter::Mesh.config).poll_once  # no seeds → no seed fetch; gossip disabled
after_size  = Igniter::Mesh.config.peer_registry.size

puts "  gossip_fanout = 0 → registry size unchanged: #{before_size} → #{after_size}"
puts

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────
Igniter::Mesh.reset!

Igniter::Server::Client.class_eval do
  alias_method :list_peers, :real_list_peers_gossip
end

puts "Done."
