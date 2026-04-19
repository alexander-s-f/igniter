# frozen_string_literal: true

module Igniter
  module Runtime
    # Base transport seam for agent nodes.
    #
    # Core runtime delegates agent-node delivery to this adapter instead of
    # directly depending on the actor runtime package.
    class AgentAdapter
      def call(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "agent :#{node.name} requires a configured agent adapter. " \
              "Require 'igniter/agent', pass `runner :inline, agent_adapter: ...`, " \
              "or set `Igniter::Runtime.agent_adapter`."
      end

      def cast(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "agent :#{node.name} requires a configured agent adapter. " \
              "Require 'igniter/agent', pass `runner :inline, agent_adapter: ...`, " \
              "or set `Igniter::Runtime.agent_adapter`."
      end
    end

    class << self
      attr_writer :agent_adapter

      def agent_adapter
        @agent_adapter ||= AgentAdapter.new
      end
    end
  end
end
