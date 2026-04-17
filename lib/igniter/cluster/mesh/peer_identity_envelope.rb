# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Bridges signed manifests into peer metadata so discovery and gossip can
      # relay identity/trust without introducing a dedicated replication layer yet.
      module PeerIdentityEnvelope
        module_function

        def build(source:, trust_store:, relayed_by: nil)
          normalized = PeerMetadata.normalize(source || {})
          manifest = extract_manifest(normalized)
          attestation = extract_attestation(normalized, manifest)

          if manifest
            assessment = Igniter::Cluster::Trust::Verifier.assess(manifest, trust_store: trust_store)
            base_metadata = base_metadata_for(normalized, manifest)
            metadata = relayed_by ? PeerMetadata.relay(base_metadata, relayed_by: relayed_by) : base_metadata
            metadata = attach_identity(metadata, manifest, assessment)
            metadata = attach_attestation(metadata, attestation, trust_store) if attestation

            return {
              name: manifest.peer_name,
              url: manifest.url,
              capabilities: manifest.capabilities,
              tags: manifest.tags,
              metadata: metadata
            }
          end

          metadata = Hash(normalized[:metadata] || {})
          metadata = PeerMetadata.relay(metadata, relayed_by: relayed_by) if relayed_by
          metadata = attach_attestation(metadata, attestation, trust_store) if attestation

          {
            name: attestation&.peer_name || normalized[:name],
            url: attestation&.url || normalized[:url],
            capabilities: attestation ? attestation.capabilities : Array(normalized[:capabilities]).map(&:to_sym),
            tags: attestation ? attestation.tags : Array(normalized[:tags]).map(&:to_sym),
            metadata: metadata
          }
        end

        def attach_identity(metadata, manifest, assessment)
          base = PeerMetadata.normalize(metadata)
          base.merge(
            mesh_identity: {
              node_id: manifest.node_id,
              peer_name: manifest.peer_name,
              algorithm: manifest.algorithm,
              fingerprint: manifest.fingerprint,
              public_key: manifest.public_key,
              signed_at: manifest.signed_at,
              contracts: manifest.contracts,
              manifest: manifest.to_h
            },
            mesh_trust: assessment.to_h
          )
        end

        def attach_attestation(metadata, attestation, trust_store)
          assessment = Igniter::Cluster::Trust::Verifier.assess_attestation(attestation, trust_store: trust_store)
          base = PeerMetadata.normalize(metadata)
          base.merge(
            mesh_capabilities: {
              node_id: attestation.node_id,
              peer_name: attestation.peer_name,
              fingerprint: attestation.fingerprint,
              observed_at: attestation.observed_at,
              capabilities: attestation.capabilities,
              tags: attestation.tags,
              attestation: attestation.to_h,
              trust: assessment.to_h
            }
          )
        end

        def extract_manifest(source)
          manifest_hash = if source[:manifest].is_a?(Hash)
                            source[:manifest]
                          elsif source[:node_id] || source[:public_key] || source[:signature]
                            source
                          else
                            source.dig(:metadata, :mesh_identity, :manifest)
                          end

          return nil unless manifest_hash.is_a?(Hash)

          Igniter::Cluster::Identity::Manifest.from_h(manifest_hash)
        end

        def extract_attestation(source, manifest = nil)
          attestation_hash = if source[:capability_attestation].is_a?(Hash)
                               source[:capability_attestation]
                             elsif source.dig(:metadata, :mesh_capabilities, :attestation).is_a?(Hash)
                               source.dig(:metadata, :mesh_capabilities, :attestation)
                             else
                               manifest&.capability_attestation&.to_h
                             end

          return nil unless attestation_hash.is_a?(Hash)

          Igniter::Cluster::Identity::CapabilityAttestation.from_h(attestation_hash)
        end

        def base_metadata_for(source, manifest)
          metadata = Hash(source[:metadata] || {})
          metadata.empty? ? manifest.metadata : metadata
        end
      end
    end
  end
end
