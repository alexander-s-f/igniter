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
        ref = Igniter::Registry.find(node.agent_name)
        unless ref
          return failure("No registered agent #{node.agent_name.inspect} is available")
        end

        unless ref.alive?
          return failure("Registered agent #{node.agent_name.inspect} is not alive")
        end

        {
          status: :succeeded,
          output: ref.call(node.message_name, inputs, timeout: node.timeout)
        }
      rescue Igniter::Agent::TimeoutError => e
        failure(e.message)
      end

      private

      def failure(message)
        { status: :failed, error: { message: message } }
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
