# frozen_string_literal: true

module Igniter
  module Cluster
    class RouteRequest
      attr_reader :session_id, :kind, :operation_name, :capabilities,
                  :pinned_peer, :metadata, :profile_fingerprint

      def initialize(attributes)
        @session_id = attributes.fetch(:session_id).to_s
        @kind = attributes.fetch(:kind).to_sym
        @operation_name = attributes.fetch(:operation_name).to_sym
        assign_routing!(attributes.fetch(:routing))
        @metadata = attributes.fetch(:metadata).dup.freeze
        @profile_fingerprint = attributes.fetch(:profile_fingerprint)
        freeze
      end

      def self.from_transport_request(request)
        new(attributes_from_transport_request(request))
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

      class << self
        private

        def routing_metadata(request)
          request.metadata.fetch(:routing, request.metadata.fetch("routing", {}))
        end

        def routing_capabilities(request)
          metadata = routing_metadata(request)
          metadata.fetch(:all_of, metadata.fetch("all_of", []))
        end

        def routing_peer(request)
          metadata = routing_metadata(request)
          metadata[:peer] || metadata["peer"]
        end

        def attributes_from_transport_request(request)
          {
            session_id: request.session_id,
            kind: request.kind,
            operation_name: request.operation_name,
            routing: routing_attributes(request),
            metadata: request.metadata,
            profile_fingerprint: request.profile_fingerprint
          }
        end

        def routing_attributes(request)
          {
            capabilities: routing_capabilities(request),
            pinned_peer: routing_peer(request)
          }
        end
      end

      private

      def assign_routing!(routing)
        @capabilities = Array(routing.fetch(:capabilities, [])).map(&:to_sym).uniq.sort.freeze
        @pinned_peer = routing[:pinned_peer]&.to_sym
      end
    end
  end
end
