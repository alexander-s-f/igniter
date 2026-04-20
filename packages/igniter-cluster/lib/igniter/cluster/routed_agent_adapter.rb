# frozen_string_literal: true

module Igniter
  module Cluster
    # Cluster-aware routed adapter for agent nodes.
    class RoutedAgentAdapter < Igniter::Runtime::ProxyAgentAdapter
      def initialize(local_adapter: Igniter::Runtime::RegistryAgentAdapter.new,
                     route_resolver: AgentRouteResolver.new,
                     transport: Igniter::Runtime::AgentTransport.new)
        super(local_adapter: local_adapter, route_resolver: route_resolver, transport: transport)
      end

      def call(node:, inputs:, execution: nil)
        super
      rescue Igniter::Cluster::Mesh::DeferredCapabilityError => error
        pending(node, error)
      rescue Igniter::Cluster::Mesh::IncidentError => error
        failure(node, error)
      end

      def cast(node:, inputs:, execution: nil)
        super
      rescue Igniter::Cluster::Mesh::DeferredCapabilityError => error
        pending(node, error)
      rescue Igniter::Cluster::Mesh::IncidentError => error
        failure(node, error)
      end

      private

      def pending(node, error)
        payload = error.deferred_result.payload
        payload = payload.merge(routing_trace: error.explanation) if error.explanation

        {
          status: :pending,
          message: error.message,
          deferred_result: error.deferred_result,
          payload: payload,
          agent_trace: compact_trace(
            adapter: :cluster_routed,
            via: node.agent_name,
            message: node.message_name,
            routing_mode: :capability,
            capability: error.capability,
            capability_query: error.query,
            local: false,
            remote: true,
            outcome: :pending,
            reason: :routing_deferred
          )
        }
      end

      def failure(node, error)
        {
          status: :failed,
          error: { message: error.message },
          agent_trace: compact_trace(
            adapter: :cluster_routed,
            via: node.agent_name,
            message: node.message_name,
            routing_mode: :pinned,
            pinned_to: error.peer_name,
            local: false,
            remote: true,
            reason: :routing_incident
          )
        }
      end

      def compact_trace(**trace)
        trace.each_with_object({}) do |(key, value), memo|
          memo[key] = value unless value.nil?
        end
      end
    end
  end
end
