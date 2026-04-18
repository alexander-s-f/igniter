# frozen_string_literal: true

module Igniter
  module Cluster
    module Trust
      class TrustAssessment
        attr_reader :status, :node_id, :peer_name, :reason, :fingerprint, :expected_fingerprint

        def initialize(status:, node_id:, peer_name:, reason: nil, fingerprint: nil, expected_fingerprint: nil)
          @status = status.to_sym
          @node_id = node_id.to_s
          @peer_name = peer_name.to_s
          @reason = (reason || status).to_sym
          @fingerprint = fingerprint
          @expected_fingerprint = expected_fingerprint
          freeze
        end

        def trusted?
          status == :trusted
        end

        def to_h
          {
            status: status,
            trusted: trusted?,
            node_id: node_id,
            peer_name: peer_name,
            reason: reason,
            fingerprint: fingerprint,
            expected_fingerprint: expected_fingerprint
          }
        end
      end
    end
  end
end
