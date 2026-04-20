# frozen_string_literal: true

module Igniter
  module Server
    class Config
      attr_accessor :host, :port, :store, :logger,
                    :metrics_collector, :log_format, :drain_timeout,
                    :peer_name, :peer_capabilities, :peer_tags, :peer_metadata, :peer_identity, :peer_trust_store, :custom_routes,
                    :before_request_hooks, :after_request_hooks, :around_request_hooks, :after_start_hooks,
                    :agent_session_store
      attr_reader   :registry

      def initialize
        @host              = "0.0.0.0"
        @port              = 4567
        @store             = Igniter::Runtime::Stores::MemoryStore.new
        @agent_session_store = Igniter::Server::AgentSessionStore.new
        @registry          = Registry.new
        @logger            = nil
        @metrics_collector = nil
        @log_format        = :text
        @drain_timeout     = 30
        @peer_name         = nil
        @peer_capabilities = []
        @peer_tags         = []
        @peer_metadata     = {}
        @peer_identity     = nil
        @peer_trust_store  = nil
        @custom_routes     = []
        @before_request_hooks = []
        @after_request_hooks = []
        @around_request_hooks = []
        @after_start_hooks = []
      end

      def ensure_peer_identity!
        load_cluster_support!
        @peer_identity ||= Igniter::Cluster::Identity::NodeIdentity.generate(node_id: @peer_name || "anonymous-node")
      end

      def peer_trust_store
        @peer_trust_store ||= begin
          load_cluster_support!
          Igniter::Cluster::Trust::TrustStore.new
        end
      end

      def register(name, contract_class)
        @registry.register(name, contract_class)
        self
      end

      def contracts=(hash)
        hash.each { |name, klass| register(name.to_s, klass) }
      end

      private

      def load_cluster_support!
        return if defined?(Igniter::Cluster::Identity::NodeIdentity) &&
          defined?(Igniter::Cluster::Trust::TrustStore)

        require "igniter/cluster"
      rescue LoadError => e
        raise LoadError,
              "Igniter::Server cluster identity support requires `igniter/cluster` (#{e.message})"
      end
    end
  end
end
