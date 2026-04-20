# frozen_string_literal: true

module Igniter
  module Model
    # Represents a graph node that delegates work to a long-lived agent.
    #
    # The node itself is part of the contract graph. Delivery and lookup are
    # delegated to a runtime adapter so core stays independent from any specific
    # actor runtime implementation or registry strategy.
    class AgentNode < Node
      attr_reader :agent_name, :message_name, :input_mapping, :timeout, :mode,
                  :interaction_contract

      def initialize(id:, name:, agent_name:, message_name:, input_mapping:, timeout: 5, mode: :call, reply_mode: nil, finalizer: nil, tool_loop_policy: nil, session_policy: nil, node_url: nil, capability: nil, capability_query: nil, pinned_to: nil, path: nil, metadata: {}) # rubocop:disable Metrics/ParameterLists
        super(
          id: id,
          kind: :agent,
          name: name,
          path: path || name.to_s,
          dependencies: input_mapping.values.map(&:to_sym),
          metadata: metadata
        )
        @agent_name = normalize_agent_name(agent_name)
        @message_name = message_name.to_sym
        @input_mapping = input_mapping.transform_keys(&:to_sym).transform_values(&:to_sym).freeze
        @timeout = Float(timeout)
        @interaction_contract = AgentInteractionContract.new(
          mode: mode,
          reply_mode: reply_mode,
          finalizer: finalizer,
          tool_loop_policy: tool_loop_policy,
          session_policy: session_policy,
          node_url: node_url,
          capability: capability,
          capability_query: capability_query,
          pinned_to: pinned_to
        )
        @mode = @interaction_contract.mode
      end

      def routing_mode
        interaction_contract.routing_mode
      end

      def reply_mode
        interaction_contract.reply_mode
      end

      def finalizer
        interaction_contract.finalizer
      end

      def tool_loop_policy
        interaction_contract.tool_loop_policy
      end

      def session_policy
        interaction_contract.session_policy
      end

      def node_url
        interaction_contract.node_url
      end

      def capability
        interaction_contract.capability
      end

      def capability_query
        interaction_contract.capability_query
      end

      def pinned_to
        interaction_contract.pinned_to
      end

      private

      def normalize_agent_name(agent_name)
        return agent_name.to_sym if agent_name.is_a?(String) || agent_name.is_a?(Symbol)

        agent_name
      end
    end
  end
end
