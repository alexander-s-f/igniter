# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      # Returns a JSON manifest describing this peer: its name, advertised
      # capabilities, registered contracts, and its base URL.
      # Used by Igniter::Cluster::Mesh::Router health-probing and peer discovery.
      class ManifestHandler < Base
        def initialize(registry, store, config: nil)
          super(registry, store)
          @config = config
        end

        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          return json_ok({}) unless @config

          identity = @config.ensure_peer_identity!
          metadata = if defined?(Igniter::Cluster::Mesh::PeerMetadata)
                       Igniter::Cluster::Mesh::PeerMetadata.authoritative(
                         @config.peer_metadata || {},
                         origin: @config.peer_name
                       )
                     else
                       @config.peer_metadata || {}
                     end

          manifest = Igniter::Cluster::Identity::Manifest.build(
            identity: identity,
            peer_name: @config.peer_name,
            url: node_url,
            capabilities: @config.peer_capabilities || [],
            tags: @config.peer_tags || [],
            metadata: metadata,
            contracts: @registry.names
          )

          json_ok(manifest.to_h)
        end

        def node_url
          return nil unless @config

          "http://#{@config.host}:#{@config.port}"
        end
      end
    end
  end
end
