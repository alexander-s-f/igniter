# frozen_string_literal: true

# Igniter Mesh — Phase 1: Static Mesh
#
# Extends the remote: DSL with capability-based and pinned routing modes so
# that contracts can route calls across a declared peer topology without
# hard-coding URLs in every node definition.
#
# Usage:
#   require "igniter/extensions/mesh"
#
#   Igniter::Mesh.configure do |c|
#     c.peer_name          = "api-node"
#     c.local_capabilities = [:api]
#     c.add_peer "orders-node",
#                url: "http://orders.internal:4567",
#                capabilities: [:orders, :inventory]
#     c.add_peer "audit-node",
#                url: "http://audit.internal:4567",
#                capabilities: [:audit]
#   end
#
require "igniter"
require "igniter/server"
require "igniter/mesh"
