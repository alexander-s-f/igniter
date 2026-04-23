# frozen_string_literal: true

module Igniter
  module Cluster
    class RouteRequest
      attr_reader :session_id, :kind, :operation_name, :capabilities,
                  :pinned_peer, :metadata, :profile_fingerprint

      def initialize(session_id:, kind:, operation_name:, capabilities:, pinned_peer:, metadata:, profile_fingerprint:)
        @session_id = session_id.to_s
        @kind = kind.to_sym
        @operation_name = operation_name.to_sym
        @capabilities = Array(capabilities).map(&:to_sym).uniq.sort.freeze
        @pinned_peer = pinned_peer&.to_sym
        @metadata = metadata.dup.freeze
        @profile_fingerprint = profile_fingerprint
        freeze
      end

      def self.from_transport_request(request)
        routing = request.metadata.fetch(:routing, request.metadata.fetch("routing", {}))

        new(
          session_id: request.session_id,
          kind: request.kind,
          operation_name: request.operation_name,
          capabilities: routing.fetch(:all_of, routing.fetch("all_of", [])),
          pinned_peer: routing[:peer] || routing["peer"],
          metadata: request.metadata,
          profile_fingerprint: request.profile_fingerprint
        )
      end

      def to_h
        {
          session_id: session_id,
          kind: kind,
          operation_name: operation_name,
          capabilities: capabilities.dup,
          pinned_peer: pinned_peer,
          metadata: metadata.dup,
          profile_fingerprint: profile_fingerprint
        }
      end
    end
  end
end
