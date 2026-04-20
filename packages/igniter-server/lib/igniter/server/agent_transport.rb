# frozen_string_literal: true

module Igniter
  module Server
    # HTTP transport for remotely routed agent nodes.
    class AgentTransport < Igniter::Runtime::AgentTransport
      def session_lifecycle?
        true
      end

      def call(route:, node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        client = Client.new(route.url, timeout: node.timeout)
        response = client.call_agent(
          via: node.agent_name,
          message: node.message_name,
          inputs: inputs,
          timeout: node.timeout,
          reply_mode: node.reply_mode
        )

        normalize_response(response)
      rescue Client::ConnectionError => error
        raise ResolutionError, "Cannot reach #{route.url}: #{error.message}"
      end

      def cast(route:, node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        client = Client.new(route.url, timeout: node.timeout)
        response = client.cast_agent(
          via: node.agent_name,
          message: node.message_name,
          inputs: inputs,
          timeout: node.timeout
        )

        normalize_response(response)
      rescue Client::ConnectionError => error
        raise ResolutionError, "Cannot reach #{route.url}: #{error.message}"
      end

      def continue_session(route:, session:, payload:, execution: nil, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil) # rubocop:disable Metrics/ParameterLists, Lint/UnusedMethodArgument
        client = Client.new(route.url, timeout: 5)
        response = client.continue_agent_session(
          token: session.token,
          session: session.to_h,
          payload: payload,
          trace: trace,
          next_token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )

        normalize_response(response)
      rescue Client::ConnectionError => error
        raise ResolutionError, "Cannot reach #{route.url}: #{error.message}"
      end

      def resume_session(route:, session:, execution: nil, value: nil) # rubocop:disable Lint/UnusedMethodArgument
        return nil if value.nil?

        client = Client.new(route.url, timeout: 5)
        response = client.resume_agent_session(
          token: session.token,
          session: session.to_h,
          value: value
        )

        normalize_response(response)
      rescue Client::ConnectionError => error
        raise ResolutionError, "Cannot reach #{route.url}: #{error.message}"
      end

      private

      def normalize_response(response)
        normalized = response.dup
        deferred = response[:deferred_result]
        return normalized unless deferred.is_a?(Hash) && !deferred.empty?

        normalized[:deferred_result] = Igniter::Runtime::DeferredResult.build(
          token: value_from(deferred, :token),
          payload: value_from(deferred, :payload) || {},
          source_node: value_from(deferred, :source_node),
          waiting_on: value_from(deferred, :waiting_on)
        )
        normalized
      end

      def value_from(hash, key)
        hash[key] || hash[key.to_s]
      end
    end
  end
end
