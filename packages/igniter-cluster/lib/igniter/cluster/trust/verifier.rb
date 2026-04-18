# frozen_string_literal: true

require "openssl"

module Igniter
  module Cluster
    module Trust
      module Verifier
        module_function

        def assess(manifest, trust_store:)
          candidate = manifest.is_a?(Igniter::Cluster::Identity::Manifest) ? manifest : Igniter::Cluster::Identity::Manifest.from_h(manifest)

          return assessment(:missing_identity, candidate) if candidate.node_id.empty? || candidate.public_key.empty?
          return assessment(:missing_signature, candidate) if candidate.signature.empty?
          return assessment(:invalid_signature, candidate) unless candidate.verify_signature

          entry = trust_store&.entry_for(candidate.node_id)
          return assessment(:unknown, candidate) unless entry

          expected = fingerprint_for(entry.public_key)
          actual = candidate.fingerprint
          return assessment(:key_mismatch, candidate, expected_fingerprint: expected) unless expected == actual

          assessment(:trusted, candidate, expected_fingerprint: expected)
        end

        def assess_attestation(attestation, trust_store:)
          candidate = attestation.is_a?(Igniter::Cluster::Identity::CapabilityAttestation) ? attestation : Igniter::Cluster::Identity::CapabilityAttestation.from_h(attestation)

          return assessment(:missing_identity, candidate) if candidate.node_id.empty? || candidate.public_key.empty?
          return assessment(:missing_signature, candidate) if candidate.signature.empty?
          return assessment(:invalid_signature, candidate) unless candidate.verify_signature

          entry = trust_store&.entry_for(candidate.node_id)
          return assessment(:unknown, candidate) unless entry

          expected = fingerprint_for(entry.public_key)
          actual = candidate.fingerprint
          return assessment(:key_mismatch, candidate, expected_fingerprint: expected) unless expected == actual

          assessment(:trusted, candidate, expected_fingerprint: expected)
        end

        def assess_governance_checkpoint(checkpoint, trust_store:)
          candidate = checkpoint.is_a?(Igniter::Cluster::Governance::Checkpoint) ? checkpoint : Igniter::Cluster::Governance::Checkpoint.from_h(checkpoint)

          return assessment(:missing_identity, candidate) if candidate.node_id.empty? || candidate.public_key.empty?
          return assessment(:missing_signature, candidate) if candidate.signature.empty?
          return assessment(:invalid_signature, candidate) unless candidate.verify_signature

          entry = trust_store&.entry_for(candidate.node_id)
          return assessment(:unknown, candidate) unless entry

          expected = fingerprint_for(entry.public_key)
          actual = candidate.fingerprint
          return assessment(:key_mismatch, candidate, expected_fingerprint: expected) unless expected == actual

          assessment(:trusted, candidate, expected_fingerprint: expected)
        end

        def fingerprint_for(public_key)
          OpenSSL::Digest::SHA256.hexdigest(OpenSSL::PKey.read(public_key.to_s).to_der)[0, 24]
        rescue OpenSSL::PKey::PKeyError
          nil
        end

        def assessment(status, manifest, expected_fingerprint: nil)
          TrustAssessment.new(
            status: status,
            node_id: manifest.node_id,
            peer_name: manifest.peer_name,
            fingerprint: manifest.fingerprint,
            expected_fingerprint: expected_fingerprint
          )
        end
      end
    end
  end
end
