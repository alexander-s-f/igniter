# frozen_string_literal: true

# Igniter Mesh — Phase 1 (Static) + Phase 2 (Dynamic Discovery)
#
# Extends the remote: DSL with capability-based and pinned routing modes, and
# enables dynamic peer discovery so that the peer topology can be maintained
# without static add_peer declarations.
#
# Usage:
#   require "igniter/extensions/mesh"
#
#   # Phase 1 — static topology (still works):
#   Igniter::Mesh.configure do |c|
#     c.add_peer "orders-node",
#                url: "http://orders.internal:4567",
#                capabilities: [:orders, :inventory]
#   end
#
#   # Phase 2 — dynamic discovery:
#   Igniter::Mesh.configure do |c|
#     c.peer_name          = "api-node"
#     c.local_url          = "http://api.internal:4567"
#     c.local_capabilities = [:api]
#     c.seeds              = %w[http://orders.internal:4567 http://audit.internal:4567]
#     c.discovery_interval = 30
#   end
#   Igniter::Mesh.start_discovery!
#
require "igniter"
require "igniter/server"
require "igniter/mesh"
