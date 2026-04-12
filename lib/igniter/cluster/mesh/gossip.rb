# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Executes a single peer-to-peer gossip round.
    #
    # Picks up to config.gossip_fanout random peers from the local PeerRegistry
    # (excluding self), fetches their GET /v1/mesh/peers lists, and registers
    # any newly discovered peers. This decentralises topology exchange: once seeds
    # bootstrap the registry, peers continue spreading topology information among
    # themselves even if seeds become unavailable.
    #
    # Errors from individual peers are swallowed — a dead peer must not abort
    # the round for the remaining candidates.
    class GossipRound
      def initialize(config)
        @config = config
      end

      def run
        pick_candidates.each { |peer| exchange_with(peer) }
      end

      private

      def pick_candidates
        @config.peer_registry.all
               .reject { |p| p.url == @config.local_url }
               .sample(@config.gossip_fanout)
      end

      def exchange_with(peer) # rubocop:disable Metrics/AbcSize
        peers = Igniter::Server::Client.new(peer.url, timeout: 5).list_peers
        peers.each do |pd|
          next if pd[:name].nil? || pd[:url].nil?
          next if pd[:name] == @config.peer_name

          @config.peer_registry.register(
            Peer.new(name: pd[:name], url: pd[:url], capabilities: pd[:capabilities] || [])
          )
        end
      rescue Igniter::Server::Client::ConnectionError
        nil
      end
    end
    end
  end
end
