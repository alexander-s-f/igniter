# frozen_string_literal: true

require_relative "mesh/errors"
require_relative "mesh/peer"
require_relative "mesh/peer_registry"
require_relative "mesh/config"
require_relative "mesh/router"
require_relative "mesh/announcer"
require_relative "mesh/poller"
require_relative "mesh/discovery"

module Igniter
  # Mesh routing for remote: nodes.
  #
  # Phase 1 — Static Mesh:
  #   Declare peer topology via add_peer. capability: and pinned_to: routing
  #   modes select alive peers at resolution time.
  #
  # Phase 2 — Dynamic Discovery:
  #   Configure seed URLs and call start_discovery!. The local node announces
  #   itself to seeds and polls them for the current peer list in the background.
  #
  # Usage:
  #
  #   require "igniter/extensions/mesh"
  #
  #   Igniter::Mesh.configure do |c|
  #     c.peer_name          = "api-node"
  #     c.local_url          = "http://api.internal:4567"
  #     c.local_capabilities = [:api]
  #     c.seeds              = %w[http://orders.internal:4567 http://audit.internal:4567]
  #     c.discovery_interval = 30   # seconds (default)
  #
  #     # Static peers still work alongside dynamic discovery:
  #     c.add_peer "legacy-node",
  #                url: "http://legacy.internal:4567",
  #                capabilities: [:billing]
  #   end
  #
  #   Igniter::Mesh.start_discovery!   # announce + poll + background thread
  #   # …
  #   Igniter::Mesh.stop_discovery!    # deannounce + stop thread (on shutdown)
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

      # Start dynamic discovery: announce self to seeds, do an immediate poll,
      # then begin background polling at config.discovery_interval.
      def start_discovery!
        discovery.start
        self
      end

      # Stop dynamic discovery: deannounce self from seeds, stop background thread.
      def stop_discovery!
        @discovery&.stop
        @discovery = nil
        self
      end

      def discovery
        @discovery ||= Discovery.new(config)
      end

      # Reset all singletons (config, router, discovery). Useful in tests.
      def reset!
        stop_discovery!
        @config = nil
        @router = nil
      end
    end
  end
end
