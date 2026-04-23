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

      def register_peer(name, capabilities:, transport:, metadata: {}, roles: [], labels: {}, region: nil, zone: nil,
                        health: nil, health_status: :healthy, health_checks: {})
        peer_registry.register(
          Peer.new(
            name: name,
            capabilities: capabilities,
            transport: transport,
            metadata: metadata,
            roles: roles,
            labels: labels,
            region: region,
            zone: zone,
            capability_catalog: profile.capability_catalog,
            health: health,
            health_status: health_status,
            health_checks: health_checks
          )
        )
      end

      def fetch_peer(name)
        peer_registry.fetch(name)
      end

      def peers
        peer_registry.peers
      end

      def plan_rebalance(capabilities: [], traits: [], labels: {}, peer: nil, region: nil, zone: nil, query: nil,
                         policy: nil, metadata: {})
        effective_query = build_capability_query(
          query: query,
          capabilities: capabilities,
          traits: traits,
          labels: labels,
          peer: peer,
          region: region,
          zone: zone
        )
        effective_policy = policy || profile.topology_policy
        effective_policy.plan(peers: peers, query: effective_query, metadata: metadata)
      end

      def plan_ownership(target:, capabilities: [], traits: [], labels: {}, peer: nil, region: nil, zone: nil,
                         query: nil, policy: nil, metadata: {})
        effective_query = build_capability_query(
          query: query,
          capabilities: capabilities,
          traits: traits,
          labels: labels,
          peer: peer,
          region: region,
          zone: zone
        )
        effective_policy = policy || profile.ownership_policy
        effective_policy.plan(
          peers: peers,
          query: effective_query,
          target: target,
          topology_policy: profile.topology_policy,
          metadata: metadata
        )
      end

      def plan_lease(target:, capabilities: [], traits: [], labels: {}, peer: nil, region: nil, zone: nil,
                     query: nil, ownership_plan: nil, ownership_policy: nil, policy: nil, metadata: {})
        effective_ownership_plan = ownership_plan || plan_ownership(
          target: target,
          capabilities: capabilities,
          traits: traits,
          labels: labels,
          peer: peer,
          region: region,
          zone: zone,
          query: query,
          policy: ownership_policy
        )
        effective_policy = policy || profile.lease_policy
        effective_policy.plan(
          target: target,
          ownership_plan: effective_ownership_plan,
          metadata: metadata
        )
      end

      def plan_failover(target:, capabilities: [], traits: [], labels: {}, peer: nil, region: nil, zone: nil,
                        query: nil, ownership_policy: nil, topology_policy: nil, policy: nil, metadata: {})
        effective_query = build_capability_query(
          query: query,
          capabilities: capabilities,
          traits: traits,
          labels: labels,
          peer: peer,
          region: region,
          zone: zone
        )
        effective_policy = policy || profile.health_policy
        effective_policy.plan(
          peers: peers,
          query: effective_query,
          target: target,
          ownership_policy: ownership_policy || profile.ownership_policy,
          topology_policy: topology_policy || profile.topology_policy,
          metadata: metadata
        )
      end

      def compose_invoker(capabilities: [], traits: [], labels: {}, peer: nil, region: nil, zone: nil, query: nil,
                          namespace: :cluster_compose, metadata: {}, id_generator: nil)
        build_remote_invoker(
          factory: :remote_compose_invoker,
          query: build_capability_query(
            query: query,
            capabilities: capabilities,
            traits: traits,
            labels: labels,
            peer: peer,
            region: region,
            zone: zone
          ),
          namespace: namespace,
          metadata: metadata,
          id_generator: id_generator
        )
      end

      def collection_invoker(
        capabilities: [],
        traits: [],
        labels: {},
        peer: nil,
        region: nil,
        zone: nil,
        query: nil,
        namespace: :cluster_collection,
        metadata: {},
        id_generator: nil
      )
        build_remote_invoker(
          factory: :remote_collection_invoker,
          query: build_capability_query(
            query: query,
            capabilities: capabilities,
            traits: traits,
            labels: labels,
            peer: peer,
            region: region,
            zone: zone
          ),
          namespace: namespace,
          metadata: metadata,
          id_generator: id_generator
        )
      end

      def dispatch(request)
        route_request = RouteRequest.from_transport_request(request, capability_catalog: profile.capability_catalog)
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

      def build_capability_query(query: nil, capabilities: [], traits: [], labels: {}, peer: nil, region: nil,
                                 zone: nil)
        return query if query.is_a?(CapabilityQuery)

        CapabilityQuery.new(
          required_capabilities: capabilities,
          required_traits: traits,
          required_labels: labels,
          preferred_peer: peer,
          preferred_region: region,
          preferred_zone: zone,
          capability_catalog: profile.capability_catalog
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
