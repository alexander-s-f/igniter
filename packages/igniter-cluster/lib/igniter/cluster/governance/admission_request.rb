# frozen_string_literal: true

require "digest"
require "securerandom"
require "time"

module Igniter
  module Cluster
    module Governance
      # A formal peer admission request submitted to the cluster.
      #
      # Immutable — created by the requesting peer (or operator) and submitted
      # to AdmissionWorkflow for policy evaluation.
      AdmissionRequest = Data.define(
        :request_id,
        :peer_name,
        :node_id,
        :public_key,
        :url,
        :capabilities,
        :justification,
        :requested_at
      ) do
        def self.build(peer_name:, node_id:, public_key:, url: nil, capabilities: [], justification: nil, requested_at: Time.now.utc.iso8601)
          new(
            request_id:    SecureRandom.uuid,
            peer_name:     peer_name.to_s,
            node_id:       node_id.to_s,
            public_key:    public_key.to_s,
            url:           url.to_s,
            capabilities:  Array(capabilities).map(&:to_sym).freeze,
            justification: justification&.to_s,
            requested_at:  requested_at.to_s
          )
        end

        # 12-hex fingerprint derived from the public key (matches TrustStore fingerprint convention).
        def fingerprint
          Digest::SHA256.hexdigest(public_key)[0, 24]
        end

        def routable?
          !url.to_s.empty?
        end

        def to_h
          {
            request_id:   request_id,
            peer_name:    peer_name,
            node_id:      node_id,
            public_key:   public_key,
            url:          url,
            capabilities: capabilities,
            justification: justification,
            requested_at: requested_at,
            fingerprint:  fingerprint
          }
        end
      end
    end
  end
end
