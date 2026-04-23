# frozen_string_literal: true

require_relative "agent_adapter"
require_relative "agent_route_resolver"
require_relative "agent_transport"

module Igniter
  module Runtime
    # Delegates local agent delivery to one adapter and remote delivery to a
    # transport chosen through a route resolver.
    class ProxyAgentAdapter < AgentAdapter
      def initialize(local_adapter:, route_resolver: AgentRouteResolver.new, transport: AgentTransport.new)
        @local_adapter = local_adapter
        @route_resolver = route_resolver
        @transport = transport
      end

      def call(node:, inputs:, execution: nil)
        route = @route_resolver.resolve(node: node, execution: execution)
        response =
          if route.local?
            @local_adapter.call(node: node, inputs: inputs, execution: execution)
          else
            @transport.call(route: route, node: node, inputs: inputs, execution: execution)
          end

        merge_route_trace(response, route)
      end

      def cast(node:, inputs:, execution: nil)
        route = @route_resolver.resolve(node: node, execution: execution)
        response =
          if route.local?
            @local_adapter.cast(node: node, inputs: inputs, execution: execution)
          else
            @transport.cast(route: route, node: node, inputs: inputs, execution: execution)
          end

        merge_route_trace(response, route)
      end

      def continue_session(session:, payload:, execution: nil, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil) # rubocop:disable Metrics/ParameterLists
        return nil unless transport_session_lifecycle?

        route = route_for_session(session)
        return nil unless route

        response = @transport.continue_session(
          route: route,
          session: session,
          payload: payload,
          execution: execution,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )

        merge_route_trace(response, route)
      end

      def resume_session(session:, execution: nil, value: nil)
        return nil unless transport_session_lifecycle?

        route = route_for_session(session)
        return nil unless route

        response = @transport.resume_session(
          route: route,
          session: session,
          execution: execution,
          value: value
        )

        merge_route_trace(response, route)
      end

      private

      def route_for_session(session)
        return nil unless session.respond_to?(:remote_owned?) && session.remote_owned?

        route = session.delivery_route || {}
        routing_mode = route[:routing_mode] || :static
        return nil if routing_mode == :local

        AgentRoute.new(
          routing_mode: routing_mode,
          via: session.agent_name,
          message: session.message_name,
          url: route[:url] || session.owner_url,
          capability: route[:capability],
          query: route[:query],
          pinned_to: route[:pinned_to]
        )
      end

      def transport_session_lifecycle?
        @transport.session_lifecycle?
      rescue StandardError
        false
      end

      def merge_route_trace(response, route)
        return response unless response.is_a?(Hash)

        route_trace = {
          routing_mode: route.routing_mode,
          route_url: route.url,
          capability: route.capability,
          capability_query: route.query,
          pinned_to: route.pinned_to,
          remote: route.remote?
        }.reject { |_key, value| value.nil? }

        existing_trace = response[:agent_trace] || response["agent_trace"] || {}

        response.merge(agent_trace: route_trace.merge(existing_trace))
      end
    end
  end
end
