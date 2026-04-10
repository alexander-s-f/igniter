# frozen_string_literal: true

require_relative "mesh/errors"
require_relative "mesh/peer"
require_relative "mesh/config"
require_relative "mesh/router"

module Igniter
  # Static mesh: capability-based and pinned routing for remote: nodes.
  #
  # Usage:
  #
  #   require "igniter/mesh"
  #
  #   Igniter::Mesh.configure do |c|
  #     c.peer_name          = "api-node"
  #     c.local_capabilities = [:api]
  #     c.add_peer "orders-node",
  #                url: "http://orders.internal:4567",
  #                capabilities: [:orders, :inventory]
  #   end
  #
  # In a contract:
  #
  #   remote :order_result,
  #          contract: "ProcessOrder",
  #          capability: :orders,       # auto-select alive peer
  #          inputs: { order_id: :id }
  #
  #   remote :audit_log,
  #          contract: "WriteAudit",
  #          pinned_to: "audit-node",   # must use this exact peer
  #          inputs: { event: :event }
  module Mesh
    class << self
      def config
        @config ||= Config.new
      end

      def configure
        yield config
        self
      end

      def router
        @router ||= Router.new(config)
      end

      # Reset config and router singleton (useful in tests).
      def reset!
        @config = nil
        @router = nil
      end
    end
  end
end
