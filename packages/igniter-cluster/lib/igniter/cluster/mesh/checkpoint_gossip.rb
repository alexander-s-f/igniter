# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Mesh
      # Shared helper: accepts a governance checkpoint embedded in a peer's
      # metadata (received during Poller seed-fetch or GossipRound peer-exchange)
      # and persists it locally when it is newer than the current local checkpoint.
      #
      # Called after every peer registration in both Poller and GossipRound.
      # No-op when config.checkpoint_store is nil.
      #
      # Security: the remote checkpoint's RSA/ECDSA signature is verified before
      # the checkpoint is accepted. Tampered or unsigned payloads are silently
      # dropped.
      #
      # Governance trail: records :checkpoint_replicated when a newer checkpoint
      # is saved, allowing operators to audit the replication history.
      module CheckpointGossip
        module_function

        # @param peer_metadata [Hash]  symbol-keyed metadata from PeerIdentityEnvelope
        # @param config        [Mesh::Config]
        # @param source        [Symbol]  :poller or :gossip (for trail attribution)
        def sync(peer_metadata, config:, source: :discovery)
          store = config.checkpoint_store
          return unless store

          checkpoint_hash = peer_metadata.dig(:mesh_governance, :checkpoint)
          return unless checkpoint_hash.is_a?(Hash)

          remote_cp = Igniter::Cluster::Governance::Checkpoint.from_h(checkpoint_hash)
          return unless remote_cp&.verify_signature

          local_cp = store.load
          if local_cp
            remote_time = Time.parse(remote_cp.checkpointed_at)
            local_time  = Time.parse(local_cp.checkpointed_at)
            return if local_time >= remote_time
          end

          store.save(remote_cp)
          config.governance_trail&.record(
            :checkpoint_replicated,
            source:  source,
            payload: {
              from_peer:       peer_metadata.dig(:mesh_governance, :peer_name),
              crest_digest:    remote_cp.crest_digest,
              checkpointed_at: remote_cp.checkpointed_at
            }
          )
        rescue StandardError
          nil
        end
      end
    end
  end
end
