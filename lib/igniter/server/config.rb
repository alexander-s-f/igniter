# frozen_string_literal: true

module Igniter
  module Server
    class Config
      attr_accessor :host, :port, :store, :logger,
                    :metrics_collector, :log_format, :drain_timeout,
                    :peer_name, :peer_capabilities, :peer_tags, :peer_metadata, :peer_identity, :peer_trust_store, :custom_routes,
                    :before_request_hooks, :after_request_hooks, :around_request_hooks
      attr_reader   :registry

      def initialize
        @host              = "0.0.0.0"
        @port              = 4567
        @store             = Igniter::Runtime::Stores::MemoryStore.new
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
        @peer_trust_store  = Igniter::Cluster::Trust::TrustStore.new
        @custom_routes     = []
        @before_request_hooks = []
        @after_request_hooks = []
        @around_request_hooks = []
      end

      def ensure_peer_identity!
        @peer_identity ||= Igniter::Cluster::Identity::NodeIdentity.generate(node_id: @peer_name || "anonymous-node")
      end

      def register(name, contract_class)
        @registry.register(name, contract_class)
        self
      end

      def contracts=(hash)
        hash.each { |name, klass| register(name.to_s, klass) }
      end
    end
  end
end
