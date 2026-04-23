# frozen_string_literal: true

module Igniter
  module Cluster
    class Environment
      attr_reader :profile

      def initialize(profile:)
        @profile = profile
      end

      def application
        @application ||= Igniter::Application::Environment.new(profile: profile.application_profile)
      end

      def compile(&block)
        application.compile(&block)
      end

      def execute(...)
        application.execute(...)
      end

      def run(...)
        application.run(...)
      end

      def diagnose(result)
        application.diagnose(result)
      end

      def register_peer(name, capabilities:, transport:, metadata: {})
        peer_registry.register(
          Peer.new(name: name, capabilities: capabilities, transport: transport, metadata: metadata)
        )
      end

      def fetch_peer(name)
        peer_registry.fetch(name)
      end

      def peers
        peer_registry.peers
      end

      def compose_invoker(capabilities: [], peer: nil, query: nil, namespace: :cluster_compose, metadata: {},
                          id_generator: nil)
        build_remote_invoker(
          factory: :remote_compose_invoker,
          query: build_capability_query(query: query, capabilities: capabilities, peer: peer),
          namespace: namespace,
          metadata: metadata,
          id_generator: id_generator
        )
      end

      def collection_invoker(
        capabilities: [],
        peer: nil,
        query: nil,
        namespace: :cluster_collection,
        metadata: {},
        id_generator: nil
      )
        build_remote_invoker(
          factory: :remote_collection_invoker,
          query: build_capability_query(query: query, capabilities: capabilities, peer: peer),
          namespace: namespace,
          metadata: metadata,
          id_generator: id_generator
        )
      end

      def dispatch(request)
        route_request = RouteRequest.from_transport_request(request)
        placement = placement_seam.place(request: route_request, peers: peers)
        route = router_seam.route(request: route_request, placement: placement)
        admission = admission_seam.admit(request: route_request, route: route)
        raise AdmissionError, "admission denied for #{request.session_id}: #{admission.code}" unless admission.allowed?

        transport_seam.call(route: route, request: request, placement: placement, admission: admission)
      end

      def remote_transport
        @remote_transport ||= lambda do |request:|
          dispatch(request)
        end
      end

      private

      def build_remote_invoker(factory:, query:, namespace:, metadata:, id_generator:)
        application.public_send(
          factory,
          transport: remote_transport,
          namespace: namespace,
          metadata: metadata.merge(routing: query.to_h),
          id_generator: id_generator
        )
      end

      def build_capability_query(query: nil, capabilities: [], peer: nil)
        return query if query.is_a?(CapabilityQuery)

        CapabilityQuery.new(
          required_capabilities: capabilities,
          preferred_peer: peer
        )
      end

      def transport_seam
        profile.transport_seam
      end

      def router_seam
        profile.router_seam
      end

      def admission_seam
        profile.admission_seam
      end

      def placement_seam
        profile.placement_seam
      end

      def peer_registry
        profile.peer_registry_seam
      end
    end
  end
end
