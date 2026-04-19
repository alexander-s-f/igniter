# frozen_string_literal: true

module Igniter
  module Runtime
    class AgentSession
      STREAM_EVENT_TYPES = %i[chunk status tool_call tool_result artifact final].freeze

      class << self
        def stream_event(type, **attributes)
          { type: type.to_sym }.merge(compact_event_attributes(attributes))
        end

        def chunk_event(chunk: nil, text: nil, value: nil, **attributes)
          stream_event(:chunk, chunk: chunk, text: text, value: value, **attributes)
        end

        def status_event(status:, **attributes)
          stream_event(:status, status: status, **attributes)
        end

        def tool_call_event(name: nil, tool: nil, arguments: nil, call_id: nil, **attributes)
          stream_event(:tool_call, name: name, tool: tool, arguments: arguments, call_id: call_id, **attributes)
        end

        def tool_result_event(name: nil, tool: nil, result: nil, value: nil, error: nil, call_id: nil, **attributes)
          stream_event(
            :tool_result,
            name: name,
            tool: tool,
            result: result,
            value: value,
            error: error,
            call_id: call_id,
            **attributes
          )
        end

        def artifact_event(artifact: nil, name: nil, uri: nil, **attributes)
          stream_event(:artifact, artifact: artifact, name: name, uri: uri, **attributes)
        end

        def final_event(value: nil, result: nil, output: nil, **attributes)
          stream_event(:final, value: value, result: result, output: output, **attributes)
        end

        private

        def compact_event_attributes(attributes)
          attributes.each_with_object({}) do |(key, value), memo|
            memo[key] = value unless value.nil?
          end
        end
      end

      attr_reader :token, :node_name, :node_path, :agent_name, :message_name,
                  :mode, :reply_mode, :waiting_on, :source_node, :trace, :payload, :turn, :phase,
                  :messages, :last_request, :last_reply, :history,
                  :execution_id, :graph

      def initialize(token:, node_name:, node_path: nil, agent_name:, message_name:, mode:, # rubocop:disable Metrics/ParameterLists
                     reply_mode: nil, waiting_on: nil, source_node: nil, trace: nil, payload: {}, turn: 1, phase: nil,
                     messages: nil, last_request: nil, last_reply: nil, history: nil, execution_id: nil, graph: nil)
        @token = token
        @node_name = node_name&.to_sym
        @node_path = node_path
        @agent_name = agent_name&.to_sym
        @message_name = message_name&.to_sym
        @mode = mode&.to_sym
        @reply_mode = reply_mode&.to_sym
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
          reply_mode: value_from(data, :reply_mode),
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
          reply_mode: reply_mode,
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

      def continue(payload: {}, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil)
        next_token = token || self.token
        next_waiting_on = waiting_on || self.waiting_on || node_name
        next_trace = trace || self.trace
        next_turn = turn + 1
        request_message = build_request_message(turn: next_turn, payload: payload, request: request)
        reply_message = normalize_message_entry(reply)
        next_messages = messages.dup
        next_messages << request_message if request_message
        next_messages << reply_message if reply_message

        self.class.new(
          token: next_token,
          node_name: node_name,
          node_path: node_path,
          agent_name: agent_name,
          message_name: message_name,
          mode: mode,
          reply_mode: reply_mode,
          waiting_on: next_waiting_on,
          source_node: source_node || node_name,
          trace: next_trace,
          payload: payload,
          turn: next_turn,
          phase: normalize_phase(phase || default_continue_phase(reply_message)),
          messages: next_messages,
          last_request: request_message || last_request,
          last_reply: reply_message || last_reply,
          history: history + [
            {
              turn: next_turn,
              event: :continued,
              token: next_token,
              waiting_on: next_waiting_on,
              payload: payload,
              phase: normalize_phase(phase || default_continue_phase(reply_message)),
              request: request_message,
              reply: reply_message
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
          reply_mode: reply_mode,
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

      def chunks
        events.filter_map { |event| chunk_from_event(event) }
      end

      def events
        messages.flat_map do |message|
          next [] unless message[:kind] == :reply

          stream_events_for_message(message)
        end
      end

      def last_event
        events.last
      end

      def tool_interactions
        interactions = {}
        sequence_by_tool = Hash.new(0)
        open_keys_by_tool = Hash.new { |hash, key| hash[key] = [] }

        events.each_with_index do |event, index|
          next unless %i[tool_call tool_result].include?(event[:type])

          tool_name = tool_name_for_event(event)
          key = if event[:call_id]
                  "call_id:#{event[:call_id]}"
                elsif event[:type] == :tool_call
                  sequence_by_tool[tool_name] += 1
                  generated = "tool:#{tool_name}:#{sequence_by_tool[tool_name]}"
                  open_keys_by_tool[tool_name] << generated
                  generated
                else
                  open_keys_by_tool[tool_name].last || "orphan_result:#{tool_name}:#{index + 1}"
                end

          interaction = interactions[key] ||= {
            key: key,
            call_id: event[:call_id],
            tool_name: tool_name,
            call: nil,
            results: []
          }

          if event[:type] == :tool_call
            interaction[:call] ||= event
            interaction[:call_id] ||= event[:call_id]
            interaction[:tool_name] ||= tool_name
          else
            interaction[:results] << event
            interaction[:tool_name] ||= tool_name
          end
        end

        interactions.values.map do |interaction|
          results = interaction[:results].freeze
          call = interaction[:call]
          status =
            if call && !results.empty?
              :completed
            elsif call
              :pending
            else
              :orphan_result
            end

          {
            key: interaction[:key],
            call_id: interaction[:call_id],
            tool_name: interaction[:tool_name],
            call: call,
            results: results,
            status: status,
            complete: status == :completed
          }.freeze
        end.freeze
      end

      def pending_tool_interactions
        tool_interactions.select { |interaction| interaction[:status] == :pending }
      end

      def completed_tool_interactions
        tool_interactions.select { |interaction| interaction[:status] == :completed }
      end

      def orphan_tool_interactions
        tool_interactions.select { |interaction| interaction[:status] == :orphan_result }
      end

      def all_tool_calls_resolved?
        pending_tool_interactions.empty?
      end

      def tool_loop_consistent?
        orphan_tool_interactions.empty?
      end

      def tool_loop_complete?
        all_tool_calls_resolved? && tool_loop_consistent?
      end

      def tool_loop_status
        return :idle if tool_interactions.empty?
        return :orphaned unless tool_loop_consistent?
        return :open unless all_tool_calls_resolved?

        :complete
      end

      def tool_loop_summary
        {
          status: tool_loop_status,
          total: tool_interactions.size,
          pending: pending_tool_interactions.size,
          completed: completed_tool_interactions.size,
          orphaned: orphan_tool_interactions.size,
          resolved: all_tool_calls_resolved?,
          consistent: tool_loop_consistent?,
          complete: tool_loop_complete?,
          open_keys: pending_tool_interactions.map { |interaction| interaction[:key] },
          orphan_keys: orphan_tool_interactions.map { |interaction| interaction[:key] }
        }.freeze
      end

      def ready_to_finalize_stream?
        %i[idle complete].include?(tool_loop_status)
      end

      def ensure_ready_to_finalize_stream!
        return true if ready_to_finalize_stream?

        raise ResolutionError,
              "Streaming agent session '#{node_name}' cannot auto-finalize while tool loop is #{tool_loop_status.inspect}"
      end

      def validate_stream_reply!(reply)
        return if reply.nil?

        reply_message = normalize_message_entry(reply)
        payload = reply_message[:payload]
        unless payload.is_a?(Hash)
          raise ResolutionError, "Streaming agent session '#{node_name}' reply payload must be a Hash"
        end

        if !payload.key?(:events) && !payload.key?(:event) && !payload.key?(:chunk)
          raise ResolutionError, "Streaming agent session '#{node_name}' replies must use payload[:event], payload[:events], or payload[:chunk]"
        end

        stream_events_for_message(reply_message)
      end

      def finalized_value(finalizer:, contract: nil, execution: nil)
        case finalizer
        when nil, :join
          chunks.map(&:to_s).join
        when :array
          chunks.dup
        when :last
          chunks.last
        when :events
          events.dup
        when Proc
          finalizer.call(
            chunks: chunks,
            events: events,
            messages: messages,
            session: self,
            contract: contract,
            execution: execution
          )
        when Symbol, String
          raise ResolutionError, "Stream finalizer #{finalizer.inspect} requires a contract instance" unless contract

          contract.public_send(
            finalizer.to_sym,
            chunks: chunks,
            events: events,
            messages: messages,
            session: self,
            execution: execution
          )
        else
          raise ResolutionError, "Unsupported stream finalizer #{finalizer.inspect}"
        end
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
        return :streaming if reply_mode == :stream

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
          reply_mode: reply_mode,
          payload: payload
        }
      end

      def default_reply_message(turn:, value:)
        {
          turn: turn,
          kind: :reply,
          name: message_name,
          source: :agent,
          reply_mode: reply_mode,
          payload: normalize_reply_payload(value)
        }
      end

      def build_request_message(turn:, payload:, request:)
        return normalize_message_entry(request) if request
        return nil if payload.nil? || payload.empty?

        default_request_message(turn: turn, payload: payload, source: :continuation)
      end

      def default_continue_phase(reply_message)
        return :streaming if reply_mode == :stream
        return :responding if reply_message

        :waiting
      end

      def normalize_reply_payload(value)
        if reply_mode == :stream
          return { event: self.class.final_event(value: value) }
        end

        return value if value.is_a?(Hash)

        { value: value }
      end

      def find_last_message(kind)
        messages.reverse.find { |entry| entry[:kind] == kind }
      end

      def stream_events_for_message(message)
        payload = message[:payload]
        return [] unless payload.is_a?(Hash)

        if payload.key?(:events)
          Array(payload[:events]).filter_map do |entry|
            normalize_stream_event(entry, message: message)
          end
        elsif payload.key?(:event)
          [normalize_stream_event(payload[:event], message: message, extra: hash_without(payload, :event))].compact
        elsif payload.key?(:chunk)
          [normalize_stream_event(payload, message: message, default_type: :chunk)].compact
        else
          []
        end
      end

      def normalize_stream_event(entry, message:, extra: nil, default_type: nil)
        case entry
        when Hash
          normalized = normalize_message_entry(entry)
          type = normalized[:type] || normalized[:event] || default_type
          return nil unless type

          event = {
            turn: message[:turn],
            source: message[:source],
            message_name: message[:name],
            type: type.to_sym
          }.merge(hash_without(normalized, :type, :event)).merge(extra || {})
          validate_stream_event!(event)
          event.freeze
        when Symbol, String
          event = {
            turn: message[:turn],
            source: message[:source],
            message_name: message[:name],
            type: entry.to_sym
          }.merge(extra || {})
          validate_stream_event!(event)
          event.freeze
        else
          nil
        end
      end

      def validate_stream_event!(event)
        type = event[:type]&.to_sym
        unless STREAM_EVENT_TYPES.include?(type)
          raise ResolutionError, "Unsupported stream event type #{type.inspect} for agent session '#{node_name}'"
        end

        case type
        when :chunk
          return if event.key?(:chunk) || event.key?(:text) || event.key?(:value)

          raise ResolutionError, "Stream :chunk events for agent session '#{node_name}' require :chunk, :text, or :value"
        when :status
          return if event.key?(:status)

          raise ResolutionError, "Stream :status events for agent session '#{node_name}' require :status"
        when :tool_call
          return if event.key?(:name) || event.key?(:tool)

          raise ResolutionError, "Stream :tool_call events for agent session '#{node_name}' require :name or :tool"
        when :tool_result
          return if event.key?(:name) || event.key?(:tool) || event.key?(:result) || event.key?(:value)

          raise ResolutionError, "Stream :tool_result events for agent session '#{node_name}' require tool identity or result payload"
        when :artifact
          return if event.key?(:artifact) || event.key?(:name) || event.key?(:uri)

          raise ResolutionError, "Stream :artifact events for agent session '#{node_name}' require :artifact, :name, or :uri"
        when :final
          return if event.key?(:value) || event.key?(:result) || event.key?(:output)

          raise ResolutionError, "Stream :final events for agent session '#{node_name}' require :value, :result, or :output"
        end
      end

      def hash_without(hash, *keys)
        rejected = keys.map(&:to_sym)
        hash.each_with_object({}) do |(key, value), memo|
          memo[key] = value unless rejected.include?(key.to_sym)
        end
      end

      def chunk_from_event(event)
        return nil unless event[:type] == :chunk

        return event[:chunk] if event.key?(:chunk)
        return event[:text] if event.key?(:text)
        return event[:value] if event.key?(:value)

        nil
      end

      def tool_name_for_event(event)
        (event[:tool] || event[:name] || :unknown_tool).to_sym
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
