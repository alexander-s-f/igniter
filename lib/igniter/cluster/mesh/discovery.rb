# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Orchestrates the full dynamic-discovery lifecycle:
    #
    #   1. Announce self to all seeds (POST /v1/mesh/peers).
    #   2. Immediately poll all seeds for their known peer list (GET /v1/mesh/peers).
    #   3. Start the background Poller to keep the registry up to date.
    #
    # On #stop:
    #   1. Deannounce self from all seeds (DELETE /v1/mesh/peers/:name), best-effort.
    #   2. Stop the background Poller.
    class Discovery
      def initialize(config)
        @config    = config
        @announcer = Announcer.new(config)
        @poller    = Poller.new(config)
        @repair_loop = RepairLoop.new(config)
      end

      def start
        @announcer.announce_all
        @poller.poll_once
        @poller.start
        @repair_loop.start if @config.auto_self_heal
        self
      end

      def stop
        @announcer.deannounce_all
        @poller.stop
        @repair_loop.stop
        self
      end

      def running?
        @poller.running? || @repair_loop.running?
      end
    end
    end
  end
end
