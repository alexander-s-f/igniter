# frozen_string_literal: true

module Igniter
  module Model
    # Represents a graph node that delegates work to a long-lived agent.
    #
    # The node itself is part of the contract graph. Delivery and lookup are
    # delegated to a runtime adapter so core stays independent from any specific
    # actor runtime implementation or registry strategy.
    class AgentNode < Node
      SYMBOL_LIST_KEYS = RemoteNode::SYMBOL_LIST_KEYS
      SYMBOL_SCALAR_KEYS = RemoteNode::SYMBOL_SCALAR_KEYS

      attr_reader :agent_name, :message_name, :input_mapping, :timeout, :mode,
                  :reply_mode, :finalizer, :tool_loop_policy, :session_policy,
                  :node_url, :capability, :capability_query, :pinned_to

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
        @mode = normalize_mode(mode)
        @reply_mode = normalize_reply_mode(reply_mode || default_reply_mode(@mode))
        @finalizer = normalize_finalizer(finalizer || default_finalizer(@reply_mode))
        @tool_loop_policy = normalize_tool_loop_policy(tool_loop_policy || default_tool_loop_policy(@reply_mode))
        @session_policy = normalize_session_policy(session_policy || default_session_policy(@reply_mode))
        @node_url = node_url&.to_s
        @capability = capability&.to_sym
        @capability_query = normalize_query(capability_query)
        @pinned_to = pinned_to&.to_s
      end

      def routing_mode
        return :pinned if @pinned_to
        return :capability if @capability || @capability_query
        return :static if @node_url && !@node_url.empty?

        :local
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

      def normalize_reply_mode(reply_mode)
        return reply_mode.to_sym if reply_mode.is_a?(String) || reply_mode.is_a?(Symbol)

        reply_mode
      end

      def default_reply_mode(mode)
        mode == :cast ? :none : :deferred
      end

      def normalize_finalizer(finalizer)
        return finalizer.to_sym if finalizer.is_a?(String) || finalizer.is_a?(Symbol)

        finalizer
      end

      def default_finalizer(reply_mode)
        reply_mode == :stream ? :join : nil
      end

      def normalize_tool_loop_policy(tool_loop_policy)
        return tool_loop_policy.to_sym if tool_loop_policy.is_a?(String) || tool_loop_policy.is_a?(Symbol)

        tool_loop_policy
      end

      def default_tool_loop_policy(reply_mode)
        reply_mode == :stream ? :complete : nil
      end

      def normalize_session_policy(session_policy)
        return session_policy.to_sym if session_policy.is_a?(String) || session_policy.is_a?(Symbol)

        session_policy
      end

      def default_session_policy(reply_mode)
        reply_mode == :stream ? :interactive : nil
      end

      def normalize_query(query)
        case query
        when nil
          nil
        when Symbol, String
          { all_of: [query.to_sym] }.freeze
        when Array
          { all_of: query.map(&:to_sym).freeze }.freeze
        when Hash
          normalize_query_hash(query).freeze
        else
          query
        end
      end

      def normalize_query_hash(hash)
        hash.each_with_object({}) do |(key, value), memo|
          normalized_key = key.to_sym
          memo[normalized_key] = normalize_query_value(normalized_key, value)
        end
      end

      def normalize_query_value(key, value)
        if SYMBOL_LIST_KEYS.include?(key)
          Array(value).map { |item| item.is_a?(String) || item.is_a?(Symbol) ? item.to_sym : item }.freeze
        elsif SYMBOL_SCALAR_KEYS.include?(key) && (value.is_a?(String) || value.is_a?(Symbol))
          value.to_sym
        elsif value.is_a?(Hash)
          normalize_query_hash(value).freeze
        elsif value.is_a?(Array)
          value.map { |item| item.is_a?(Hash) ? normalize_query_hash(item).freeze : item }.freeze
        else
          value
        end
      end
    end
  end
end
