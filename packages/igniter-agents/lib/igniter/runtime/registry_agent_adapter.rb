# frozen_string_literal: true

require "igniter/core/runtime/agent_adapter"

module Igniter
  module Runtime
    # Default agent-node adapter backed by the local process registry.
    #
    # This keeps core independent from actor runtime details while still giving
    # embedded/app usage a straightforward execution model for agent nodes.
    class RegistryAgentAdapter < AgentAdapter
      def call(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        ref = fetch_ref(node)
        return ref if ref.is_a?(Hash)

        {
          status: :succeeded,
          output: ref.call(node.message_name, inputs, timeout: node.timeout),
          agent_trace: success_trace(node, outcome: :replied)
        }
      rescue Igniter::Agent::TimeoutError => e
        failure(node, e.message, reason: :timeout)
      end

      def cast(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        ref = fetch_ref(node)
        return ref if ref.is_a?(Hash)

        ref.send(node.message_name, inputs)
        { status: :succeeded, output: nil, agent_trace: success_trace(node, outcome: :sent) }
      end

      private

      def fetch_ref(node)
        ref = Igniter::Registry.find(node.agent_name)
        return failure(node, "No registered agent #{node.agent_name.inspect} is available", reason: :not_registered, registered: false, alive: false) unless ref
        return failure(node, "Registered agent #{node.agent_name.inspect} is not alive", reason: :not_alive, registered: true, alive: false) unless ref.alive?

        ref
      end

      def success_trace(node, outcome:)
        {
          adapter: :registry,
          mode: node.mode,
          via: node.agent_name,
          message: node.message_name,
          local: true,
          registered: true,
          alive: true,
          outcome: outcome
        }
      end

      def failure(node, message, reason:, registered: nil, alive: nil)
        {
          status: :failed,
          error: { message: message },
          agent_trace: compact_trace({
            adapter: :registry,
            mode: node.mode,
            via: node.agent_name,
            message: node.message_name,
            local: true,
            registered: registered,
            alive: alive,
            reason: reason
          })
        }
      end

      def compact_trace(trace)
        trace.each_with_object({}) do |(key, value), memo|
          memo[key] = value unless value.nil?
        end
      end
    end

    class << self
      def activate_agent_adapter!
        self.agent_adapter = RegistryAgentAdapter.new
      end

      def deactivate_agent_adapter!
        self.agent_adapter = AgentAdapter.new
      end
    end
  end
end
