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
          metadata = attach_governance(metadata)

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

        def attach_governance(metadata)
          return metadata unless defined?(Igniter::Cluster::Mesh)

          mesh_config = Igniter::Cluster::Mesh.config
          return metadata unless mesh_config.peer_name == @config.peer_name

          checkpoint = mesh_config.governance_checkpoint(limit: 10)
          metadata.merge(
            mesh_governance: {
              node_id: checkpoint.node_id,
              peer_name: checkpoint.peer_name,
              fingerprint: checkpoint.fingerprint,
              checkpointed_at: checkpoint.checkpointed_at,
              crest_digest: checkpoint.crest_digest,
              checkpoint: checkpoint.to_h,
              trust: Igniter::Cluster::Trust::Verifier.assess_governance_checkpoint(
                checkpoint,
                trust_store: mesh_config.trust_store
              ).to_h
            }
          )
        rescue StandardError
          metadata
        end
      end
    end
  end
end
