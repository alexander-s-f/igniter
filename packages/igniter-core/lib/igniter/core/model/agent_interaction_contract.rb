# frozen_string_literal: true

module Igniter
  module Model
    class AgentInteractionContract
      SYMBOL_LIST_KEYS = RemoteNode::SYMBOL_LIST_KEYS
      SYMBOL_SCALAR_KEYS = RemoteNode::SYMBOL_SCALAR_KEYS

      MODES = %i[call cast].freeze
      REPLY_MODES = %i[single deferred stream none].freeze
      TOOL_LOOP_POLICIES = %i[ignore resolved complete].freeze
      SESSION_POLICIES = %i[interactive single_turn manual].freeze
      ROUTING_MODES = %i[local static capability pinned].freeze

      attr_reader :mode, :reply_mode, :finalizer, :tool_loop_policy, :session_policy,
                  :node_url, :capability, :capability_query, :pinned_to

      def initialize(mode: :call, reply_mode: nil, finalizer: nil, tool_loop_policy: nil, session_policy: nil,
                     node_url: nil, capability: nil, capability_query: nil, pinned_to: nil)
        @mode = normalize_mode(mode)
        @reply_mode = normalize_reply_mode(reply_mode || default_reply_mode(@mode))
        @finalizer = normalize_finalizer(finalizer || default_finalizer(@reply_mode))
        @tool_loop_policy = normalize_tool_loop_policy(tool_loop_policy || default_tool_loop_policy(@reply_mode))
        @session_policy = normalize_session_policy(session_policy || default_session_policy(@reply_mode))
        @node_url = node_url&.to_s
        @capability = capability&.to_sym
        @capability_query = normalize_query(capability_query)
        @pinned_to = pinned_to&.to_s
        freeze
      end

      def routing_mode
        return :pinned if pinned?
        return :capability if capability_routed?
        return :static if static?

        :local
      end

      def call?
        mode == :call
      end

      def cast?
        mode == :cast
      end

      def streaming?
        reply_mode == :stream
      end

      def static?
        !node_url.nil? && !node_url.empty?
      end

      def capability_routed?
        !capability.nil? || !capability_query.nil?
      end

      def pinned?
        !pinned_to.nil? && !pinned_to.empty?
      end

      def to_h
        payload = {
          mode: mode,
          routing_mode: routing_mode,
          reply: reply_mode,
          finalizer: serialized_finalizer,
          tool_loop_policy: tool_loop_policy,
          session_policy: session_policy
        }
        payload[:node] = node_url if routing_mode == :static
        payload[:capability] = capability if capability
        payload[:query] = capability_query if capability_query
        payload[:pinned_to] = pinned_to if pinned_to
        payload.freeze
      end

      private

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

      def serialized_finalizer
        return nil if finalizer.nil?
        return finalizer if finalizer.is_a?(Symbol)

        :proc
      end
    end
  end
end
