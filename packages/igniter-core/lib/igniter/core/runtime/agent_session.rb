# frozen_string_literal: true

module Igniter
  module Runtime
    class AgentSession
      attr_reader :token, :node_name, :node_path, :agent_name, :message_name,
                  :mode, :waiting_on, :source_node, :trace, :payload, :turn, :phase,
                  :messages, :last_request, :last_reply, :history,
                  :execution_id, :graph

      def initialize(token:, node_name:, node_path: nil, agent_name:, message_name:, mode:, # rubocop:disable Metrics/ParameterLists
                     waiting_on: nil, source_node: nil, trace: nil, payload: {}, turn: 1, phase: nil,
                     messages: nil, last_request: nil, last_reply: nil, history: nil, execution_id: nil, graph: nil)
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
        @turn = Integer(turn || 1)
        @history = Array(history || []).map { |entry| normalize_history_entry(entry) }.freeze
        @messages = normalize_messages(messages)
        @last_request = normalize_message_entry(last_request || find_last_message(:request))
        @last_reply = normalize_message_entry(last_reply || find_last_message(:reply))
        @phase = normalize_phase(phase || default_phase)
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
          turn: value_from(data, :turn) || 1,
          phase: value_from(data, :phase),
          messages: value_from(data, :messages),
          last_request: value_from(data, :last_request),
          last_reply: value_from(data, :last_reply),
          history: value_from(data, :history) || [],
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
          turn: turn,
          phase: phase,
          messages: messages,
          last_request: last_request,
          last_reply: last_reply,
          history: history,
          execution_id: execution_id,
          graph: graph
        }.compact
      end

      def as_json(*)
        to_h
      end

      def continue(payload: {}, trace: nil, token: nil, waiting_on: nil, request: nil)
        next_token = token || self.token
        next_waiting_on = waiting_on || self.waiting_on || node_name
        next_trace = trace || self.trace
        next_turn = turn + 1
        request_message = normalize_message_entry(request || default_request_message(turn: next_turn, payload: payload, source: :continuation))

        self.class.new(
          token: next_token,
          node_name: node_name,
          node_path: node_path,
          agent_name: agent_name,
          message_name: message_name,
          mode: mode,
          waiting_on: next_waiting_on,
          source_node: source_node || node_name,
          trace: next_trace,
          payload: payload,
          turn: next_turn,
          phase: :waiting,
          messages: messages + [request_message],
          last_request: request_message,
          last_reply: last_reply,
          history: history + [
            {
              turn: next_turn,
              event: :continued,
              token: next_token,
              waiting_on: next_waiting_on,
              payload: payload,
              phase: :waiting,
              request: request_message
            }
          ],
          execution_id: execution_id,
          graph: graph
        )
      end

      def complete(value: nil, reply: nil, trace: nil)
        next_turn = turn + 1
        reply_message = normalize_message_entry(reply || default_reply_message(turn: next_turn, value: value))

        self.class.new(
          token: token,
          node_name: node_name,
          node_path: node_path,
          agent_name: agent_name,
          message_name: message_name,
          mode: mode,
          waiting_on: waiting_on,
          source_node: source_node || node_name,
          trace: trace || self.trace,
          payload: payload,
          turn: next_turn,
          phase: :completed,
          messages: messages + [reply_message],
          last_request: last_request,
          last_reply: reply_message,
          history: history + [
            {
              turn: next_turn,
              event: :completed,
              token: token,
              waiting_on: waiting_on,
              phase: :completed,
              reply: reply_message
            }
          ],
          execution_id: execution_id,
          graph: graph
        )
      end

      private

      def normalize_messages(messages)
        base_messages = Array(messages || default_messages)
        base_messages.map { |entry| normalize_message_entry(entry) }.freeze
      end

      def normalize_history_entry(entry)
        case entry
        when Hash
          entry.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        else
          entry
        end
      end

      def normalize_message_entry(entry)
        return nil unless entry
        return entry unless entry.is_a?(Hash)

        entry.each_with_object({}) do |(key, value), memo|
          memo[key.to_sym] = value
        end.freeze
      end

      def normalize_phase(value)
        (value || :waiting).to_sym
      end

      def default_phase
        return :completed if history.last.is_a?(Hash) && history.last[:event] == :completed

        :waiting
      end

      def default_messages
        [default_request_message(turn: turn, payload: payload, source: :contract)]
      end

      def default_request_message(turn:, payload:, source:)
        {
          turn: turn,
          kind: :request,
          name: message_name,
          source: source,
          payload: payload
        }
      end

      def default_reply_message(turn:, value:)
        {
          turn: turn,
          kind: :reply,
          name: message_name,
          source: :agent,
          payload: normalize_reply_payload(value)
        }
      end

      def normalize_reply_payload(value)
        return value if value.is_a?(Hash)

        { value: value }
      end

      def find_last_message(kind)
        messages.reverse.find { |entry| entry[:kind] == kind }
      end

      def self.value_from(data, key)
        return nil unless data

        return data[key] if data.respond_to?(:key?) && data.key?(key)
        return data[key.to_s] if data.respond_to?(:key?) && data.key?(key.to_s)

        nil
      end
    end
  end
end
