# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Configuration for the local mesh node: registered peers and local identity.
    class Config
      attr_accessor :peer_name, :local_capabilities, :local_tags, :local_metadata,
                    :local_state, :local_locality,
                    :seeds, :discovery_interval, :auto_announce, :local_url, :gossip_fanout,
                    :identity, :trust_store, :governance_trail, :auto_self_heal,
                    :self_heal_interval, :self_heal_limit, :self_heal_report_provider,
                    :ownership_registry, :checkpoint_store,
                    :knowledge_shard
      attr_reader   :peers, :peer_registry

      def initialize
        @peer_name          = nil
        @local_capabilities = []
        @local_tags         = []
        @local_metadata     = {}
        @local_state        = {}
        @local_locality     = {}
        @peers              = []
        @peer_registry      = PeerRegistry.new
        @seeds              = []
        @discovery_interval = 30
        @auto_announce      = true
        @local_url          = nil
        @gossip_fanout      = 3
        @identity           = nil
        @trust_store        = Igniter::Cluster::Trust::TrustStore.new
        @governance_trail   = Igniter::Cluster::Governance::Trail.new
        @auto_self_heal     = false
        @self_heal_interval = 15
        @self_heal_limit    = nil
        @self_heal_report_provider = nil
        @ownership_registry = nil
        @checkpoint_store   = nil
        @knowledge_shard    = nil
        @last_routing_report = nil
      end

      def ensure_identity!
        @identity ||= Igniter::Cluster::Identity::NodeIdentity.generate(node_id: @peer_name || "anonymous-node")
      end

      def governance_log(path, archive: nil, retain_events: nil, retention_policy: nil)
        @governance_trail = Igniter::Cluster::Governance::Trail.new(
          store: Igniter::Cluster::Governance::Stores::FileStore.new(
            path: path,
            max_events: retain_events,
            archive_path: archive,
            retention_policy: retention_policy
          )
        )
        self
      end

      def reload_governance_trail!
        return @governance_trail unless @governance_trail&.store

        @governance_trail = Igniter::Cluster::Governance::Trail.new(store: @governance_trail.store)
      end

      def governance_checkpoint(limit: 10, checkpointed_at: Time.now.utc.iso8601)
        identity = ensure_identity!
        Igniter::Cluster::Governance::Checkpoint.build(
          identity: identity,
          peer_name: @peer_name || identity.node_id,
          trail: @governance_trail,
          limit: limit,
          checkpointed_at: checkpointed_at
        )
      end

      def record_routing_report!(target)
        @last_routing_report = normalize_routing_report(target)
      end

      def current_routing_report
        provided = @self_heal_report_provider&.call
        report = normalize_routing_report(provided)
        return report if report

        @last_routing_report
      rescue StandardError
        @last_routing_report
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

      private

      def normalize_routing_report(target)
        return nil if target.nil?

        report =
          if target.respond_to?(:diagnostics)
            target.diagnostics.to_h
          elsif target.is_a?(Hash)
            target
          elsif target.respond_to?(:to_h)
            target.to_h
          end

        return nil unless report.is_a?(Hash)
        return nil unless report.dig(:routing, :plans).is_a?(Array)

        report
      rescue StandardError
        nil
      end
    end
    end
  end
end
