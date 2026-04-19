# frozen_string_literal: true

module Igniter
  module Model
    # Represents a graph node that delegates work to a long-lived agent.
    #
    # The node itself is part of the contract graph. Delivery and lookup are
    # delegated to a runtime adapter so core stays independent from any specific
    # actor runtime implementation or registry strategy.
    class AgentNode < Node
      attr_reader :agent_name, :message_name, :input_mapping, :timeout, :mode

      def initialize(id:, name:, agent_name:, message_name:, input_mapping:, timeout: 5, mode: :call, path: nil, metadata: {}) # rubocop:disable Metrics/ParameterLists
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
        @mode = normalize_mode(mode)
      end

      private

      def normalize_agent_name(agent_name)
        return agent_name.to_sym if agent_name.is_a?(String) || agent_name.is_a?(Symbol)

        agent_name
      end

      def normalize_mode(mode)
        return mode.to_sym if mode.is_a?(String) || mode.is_a?(Symbol)

        mode
      end
    end
  end
end
