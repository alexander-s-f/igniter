# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Background thread that periodically fetches the peer list from every seed
    # and populates the local PeerRegistry with newly discovered peers.
    #
    # - Errors from individual seeds are swallowed (seed may be temporarily down).
    # - Does not remove peers from the registry on failure — the health cache in
    #   Router handles routing around dead peers without purging known topology.
    # - Thread is non-daemon: call #stop explicitly on shutdown (Discovery does this).
    class Poller
      def initialize(config)
        @config  = config
        @running = false
        @thread  = nil
        @mutex   = Mutex.new
      end

      # Start the background polling thread. Idempotent.
      def start
        @mutex.synchronize do
          return if @running

          @running = true
          @thread  = Thread.new { run_loop }
          @thread.abort_on_exception = false
        end
      end

      # Stop the background thread. Idempotent.
      def stop
        @mutex.synchronize do
          @running = false
          @thread&.kill
          @thread = nil
        end
      end

      def running?
        @mutex.synchronize { @running }
      end

      # Fetch peers from all seeds, then run a gossip round with random registry
      # peers (Phase 3). Synchronous — used at startup and inside the background loop.
      def poll_once
        @config.seeds.each { |url| fetch_peers_from(url) }
        GossipRound.new(@config).run if @config.gossip_fanout.positive?
      end

      private

      def run_loop
        loop do
          sleep(@config.discovery_interval)
          break unless @running

          poll_once
        end
      end

      def fetch_peers_from(seed_url)
        peers = Igniter::Server::Client.new(seed_url, timeout: 5).list_peers
        peers.each do |pd|
          attributes = PeerIdentityEnvelope.build(
            source: pd,
            trust_store: @config.trust_store,
            relayed_by: seed_url
          )
          next if attributes[:name].nil? || attributes[:url].nil?
          next if attributes[:name] == @config.peer_name

          @config.peer_registry.register(
            Peer.new(
              name: attributes[:name],
              url: attributes[:url],
              capabilities: attributes[:capabilities] || [],
              tags: attributes[:tags] || [],
              metadata: attributes[:metadata] || {}
            )
          )

          CheckpointGossip.sync(attributes[:metadata] || {}, config: @config, source: :poller)
        end
      rescue Igniter::Server::Client::ConnectionError
        nil
      end
    end
    end
  end
end
