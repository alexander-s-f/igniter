# frozen_string_literal: true

module Igniter
  module Mesh
    # Configuration for the local mesh node: registered peers and local identity.
    class Config
      attr_accessor :peer_name, :local_capabilities, :seeds, :discovery_interval, :auto_announce, :local_url
      attr_reader   :peers, :peer_registry

      def initialize
        @peer_name          = nil
        @local_capabilities = []
        @peers              = []
        @peer_registry      = PeerRegistry.new
        @seeds              = []
        @discovery_interval = 30
        @auto_announce      = true
        @local_url          = nil
      end

      # Register a remote peer by name.
      #
      #   Igniter::Mesh.configure do |c|
      #     c.add_peer "orders-node", url: "http://orders.internal:4567",
      #                               capabilities: [:orders, :inventory]
      #   end
      def add_peer(name, url:, capabilities: [])
        @peers << Peer.new(name: name, url: url, capabilities: capabilities)
        self
      end

      # All static peers that advertise a given capability.
      def peers_with_capability(capability)
        @peers.select { |p| p.capable?(capability) }
      end

      # Find a static peer by its registered name. Returns nil if not found.
      def peer_named(name)
        @peers.find { |p| p.name == name.to_s }
      end
    end
  end
end
