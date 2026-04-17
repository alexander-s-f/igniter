# frozen_string_literal: true

require_relative "app_host"
require_relative "../cluster"

module Igniter
  class App
    # Cluster-backed host adapter for Igniter::App.
    #
    # It reuses the server host for HTTP serving, while layering in cluster
    # transport activation plus mesh/bootstrap configuration on the application side.
    class ClusterAppHost < AppHost
      def build_config(host_config)
        config = super
        apply_cluster_settings!(config, host_config.host_settings_for(:cluster_app))
        config
      end

      def activate_transport!
        Igniter::Cluster.activate_remote_adapter!
      end

      def start(config:)
        start_discovery_if_needed!
        super
      end

      def rack_app(config:)
        start_discovery_if_needed!
        super
      end

      private

      def apply_cluster_settings!(server_config, cluster_settings)
        @cluster_settings = cluster_settings
        return if cluster_settings.nil? || cluster_settings.empty?

        local_capabilities = Array(cluster_settings[:local_capabilities]).map(&:to_sym)
        local_tags = Array(cluster_settings[:local_tags]).map(&:to_sym)
        local_metadata = Hash(cluster_settings[:local_metadata] || {})
        trust_store = cluster_settings[:trust_store] || Igniter::Cluster::Trust::TrustStore.new
        server_config.peer_name = cluster_settings[:peer_name]
        server_config.peer_capabilities = local_capabilities
        server_config.peer_tags = local_tags
        server_config.peer_metadata = local_metadata
        server_config.peer_identity = cluster_settings[:identity]
        server_config.peer_trust_store = trust_store

        Igniter::Cluster::Mesh.reset!
        Igniter::Cluster::Mesh.configure do |c|
          c.peer_name = cluster_settings[:peer_name]
          c.local_capabilities = local_capabilities
          c.local_tags = local_tags
          c.local_metadata = local_metadata
          c.seeds = Array(cluster_settings[:seeds])
          c.discovery_interval = cluster_settings[:discovery_interval]
          c.auto_announce = cluster_settings[:auto_announce]
          c.local_url = cluster_settings[:local_url]
          c.gossip_fanout = cluster_settings[:gossip_fanout]
          c.identity = cluster_settings[:identity]
          c.trust_store = trust_store
          c.auto_self_heal = cluster_settings[:auto_self_heal]
          c.self_heal_interval = cluster_settings[:self_heal_interval] if cluster_settings.key?(:self_heal_interval)
          c.self_heal_limit = cluster_settings[:self_heal_limit] if cluster_settings.key?(:self_heal_limit)
          c.self_heal_report_provider = cluster_settings[:self_heal_report_provider] if cluster_settings.key?(:self_heal_report_provider)

          Array(cluster_settings[:peers]).each do |peer|
            c.add_peer(
              peer[:name],
              url: peer[:url],
              capabilities: peer[:capabilities],
              tags: peer[:tags],
              metadata: peer[:metadata]
            )
          end
        end
      end

      def start_discovery_if_needed!
        return unless @cluster_settings
        return unless @cluster_settings[:start_discovery]

        Igniter::Cluster::Mesh.start_discovery!
      end
    end
  end
end
