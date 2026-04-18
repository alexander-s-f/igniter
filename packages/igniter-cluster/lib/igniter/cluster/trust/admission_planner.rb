# frozen_string_literal: true

module Igniter
  module Cluster
    module Trust
      class AdmissionPlanner
        def initialize(config:)
          @config = config
        end

        def plan(peer_name, label: nil)
          peer = find_peer(peer_name)
          return empty_plan(:unknown_peer, peer_name: peer_name) unless peer

          identity = Hash(peer.metadata[:mesh_identity] || {})
          node_id = identity[:node_id].to_s
          public_key = identity[:public_key].to_s
          fingerprint = identity[:fingerprint]

          return empty_plan(:missing_identity, peer_name: peer_name) if node_id.empty? || public_key.empty?

          existing = @config.trust_store.entry_for(node_id)
          if existing
            expected = Igniter::Cluster::Trust::Verifier.fingerprint_for(existing.public_key)
            if expected == fingerprint
              return empty_plan(:already_trusted, peer_name: peer_name, node_id: node_id, fingerprint: fingerprint)
            end

            return empty_plan(
              :key_mismatch,
              peer_name: peer_name,
              node_id: node_id,
              fingerprint: fingerprint,
              expected_fingerprint: expected
            )
          end

          AdmissionPlan.new(
            actions: [
              {
                id: "admit-#{peer.name}",
                action: :admit_trusted_peer,
                scope: :mesh_trust_store,
                automated: false,
                requires_approval: true,
                params: {
                  peer_name: peer.name,
                  node_id: node_id,
                  public_key: public_key,
                  fingerprint: fingerprint,
                  label: (label || "admitted-peer").to_s
                }
              }
            ],
            summary: {
              status: :pending_approval,
              peer_name: peer.name,
              node_id: node_id,
              fingerprint: fingerprint
            }
          )
        end

        private

        def find_peer(peer_name)
          @config.peer_registry.peer_named(peer_name) || @config.peer_named(peer_name)
        end

        def empty_plan(status, payload = {})
          AdmissionPlan.new(actions: [], summary: payload.merge(status: status))
        end
      end
    end
  end
end
