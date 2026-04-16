# frozen_string_literal: true

module Igniter
  class App
    # Cluster-specific host settings owned by the application layer.
    class ClusterAppHostConfig
      Peer = Struct.new(:name, :url, :capabilities, :tags, :metadata, keyword_init: true)

      attr_accessor :peer_name, :local_capabilities, :local_tags, :local_metadata, :seeds,
                    :discovery_interval, :auto_announce, :local_url, :gossip_fanout, :start_discovery

      attr_reader :peers

      def initialize
        @peer_name          = nil
        @local_capabilities = []
        @local_tags         = []
        @local_metadata     = {}
        @seeds              = []
        @discovery_interval = 30
        @auto_announce      = true
        @local_url          = nil
        @gossip_fanout      = 3
        @start_discovery    = false
        @peers              = []
      end

      def add_peer(name, url:, capabilities: [], tags: [], metadata: {})
        @peers << Peer.new(
          name: name.to_s,
          url: url,
          capabilities: Array(capabilities).map(&:to_sym),
          tags: Array(tags).map(&:to_sym),
          metadata: Hash(metadata)
        )
        self
      end

      def to_h
        {
          peer_name: peer_name,
          local_capabilities: Array(local_capabilities).map(&:to_sym),
          local_tags: Array(local_tags).map(&:to_sym),
          local_metadata: Hash(local_metadata),
          seeds: Array(seeds),
          discovery_interval: discovery_interval,
          auto_announce: auto_announce,
          local_url: local_url,
          gossip_fanout: gossip_fanout,
          start_discovery: start_discovery,
          peers: peers.map do |peer|
            {
              name: peer.name,
              url: peer.url,
              capabilities: peer.capabilities,
              tags: peer.tags,
              metadata: peer.metadata
            }
          end
        }
      end
    end
  end
end
