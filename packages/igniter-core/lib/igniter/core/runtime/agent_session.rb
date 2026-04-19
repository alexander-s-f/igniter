# frozen_string_literal: true

module Igniter
  module Runtime
    class AgentSession
      attr_reader :token, :node_name, :node_path, :agent_name, :message_name,
                  :mode, :waiting_on, :source_node, :trace, :payload,
                  :execution_id, :graph

      def initialize(token:, node_name:, node_path: nil, agent_name:, message_name:, mode:, # rubocop:disable Metrics/ParameterLists
                     waiting_on: nil, source_node: nil, trace: nil, payload: {}, execution_id: nil, graph: nil)
        @token = token
        @node_name = node_name&.to_sym
        @node_path = node_path
        @agent_name = agent_name&.to_sym
        @message_name = message_name&.to_sym
        @mode = mode&.to_sym
        @waiting_on = waiting_on&.to_sym
        @source_node = source_node&.to_sym
        @trace = trace
        @payload = (payload || {}).freeze
        @execution_id = execution_id
        @graph = graph
        freeze
      end

      def self.from_h(data)
        new(
          token: value_from(data, :token),
          node_name: value_from(data, :node_name),
          node_path: value_from(data, :node_path),
          agent_name: value_from(data, :agent_name),
          message_name: value_from(data, :message_name),
          mode: value_from(data, :mode),
          waiting_on: value_from(data, :waiting_on),
          source_node: value_from(data, :source_node),
          trace: value_from(data, :trace),
          payload: value_from(data, :payload) || {},
          execution_id: value_from(data, :execution_id),
          graph: value_from(data, :graph)
        )
      end

      def to_h
        {
          token: token,
          node_name: node_name,
          node_path: node_path,
          agent_name: agent_name,
          message_name: message_name,
          mode: mode,
          waiting_on: waiting_on,
          source_node: source_node,
          trace: trace,
          payload: payload,
          execution_id: execution_id,
          graph: graph
        }.compact
      end

      def as_json(*)
        to_h
      end

      private

      def self.value_from(data, key)
        return nil unless data

        return data[key] if data.respond_to?(:key?) && data.key?(key)
        return data[key.to_s] if data.respond_to?(:key?) && data.key?(key.to_s)

        nil
      end
    end
  end
end
