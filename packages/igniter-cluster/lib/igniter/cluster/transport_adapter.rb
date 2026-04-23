# frozen_string_literal: true

module Igniter
  module Cluster
    class TransportAdapter
      def call(route:, request:, placement:, admission:)
        response = route.peer.transport.call(request: request)
        ensure_transport_response!(route, response)

        Igniter::Application::TransportResponse.new(
          result: response.result,
          metadata: response.metadata.merge(cluster: cluster_metadata(placement, route, admission))
        )
      end

      private

      def ensure_transport_response!(route, response)
        return if response.is_a?(Igniter::Application::TransportResponse)

        raise Error,
              "cluster transport for #{route.peer.name} must return " \
              "Igniter::Application::TransportResponse"
      end

      def cluster_metadata(placement, route, admission)
        {
          placement: placement.to_h,
          route: route.to_h,
          admission: admission.to_h
        }
      end
    end
  end
end
