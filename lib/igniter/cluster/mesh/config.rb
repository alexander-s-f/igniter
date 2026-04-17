# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Configuration for the local mesh node: registered peers and local identity.
    class Config
      attr_accessor :peer_name, :local_capabilities, :local_tags, :local_metadata,
                    :seeds, :discovery_interval, :auto_announce, :local_url, :gossip_fanout,
                    :identity, :trust_store
      attr_reader   :peers, :peer_registry

      def initialize
        @peer_name          = nil
        @local_capabilities = []
        @local_tags         = []
        @local_metadata     = {}
        @peers              = []
        @peer_registry      = PeerRegistry.new
        @seeds              = []
        @discovery_interval = 30
        @auto_announce      = true
        @local_url          = nil
        @gossip_fanout      = 3
        @identity           = nil
        @trust_store        = Igniter::Cluster::Trust::TrustStore.new
      end

      def ensure_identity!
        @identity ||= Igniter::Cluster::Identity::NodeIdentity.generate(node_id: @peer_name || "anonymous-node")
      end

      # Register a remote peer by name.
      #
      #   Igniter::Cluster::Mesh.configure do |c|
      #     c.add_peer "orders-node", url: "http://orders.internal:4567",
      #                               capabilities: [:orders, :inventory]
      #   end
      def add_peer(name, url:, capabilities: [], tags: [], metadata: {})
        @peers << Peer.new(name: name, url: url, capabilities: capabilities, tags: tags, metadata: metadata)
        self
      end

      # All static peers that advertise a given capability.
      def peers_with_capability(capability)
        @peers.select { |p| p.capable?(capability) }
      end

      # All static peers matching a capability query.
      def peers_matching_query(query)
        @peers.select { |p| p.matches_query?(query) }
      end

      # Find a static peer by its registered name. Returns nil if not found.
      def peer_named(name)
        @peers.find { |p| p.name == name.to_s }
      end
    end
    end
  end
end
