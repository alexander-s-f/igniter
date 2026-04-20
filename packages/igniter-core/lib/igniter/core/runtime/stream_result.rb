# frozen_string_literal: true

module Igniter
  module Runtime
    class StreamResult < DeferredResult
      def self.build(token: nil, payload: {}, source_node: nil, waiting_on: nil)
        new(
          token: token || SecureRandom.uuid,
          payload: payload,
          source_node: source_node,
          waiting_on: waiting_on
        )
      end

      def session
        data = agent_session_data
        return nil unless data

        Runtime::AgentSession.from_h(data)
      end

      def phase
        session&.phase || :streaming
      end

      def chunks
        session&.chunks || []
      end

      def events
        session&.events || []
      end

      def last_event
        events.last
      end

      def status_events
        events.select { |event| event[:type] == :status }
      end

      def statuses
        status_events.filter_map { |event| event[:status] }
      end

      def tool_calls
        events.select { |event| event[:type] == :tool_call }
      end

      def tool_results
        events.select { |event| event[:type] == :tool_result }
      end

      def artifacts
        events.select { |event| event[:type] == :artifact }
      end

      def final_event
        events.reverse.find { |event| event[:type] == :final }
      end

      def tool_interactions
        session&.tool_interactions || []
      end

      def pending_tool_interactions
        session&.pending_tool_interactions || []
      end

      def completed_tool_interactions
        session&.completed_tool_interactions || []
      end

      def orphan_tool_interactions
        session&.orphan_tool_interactions || []
      end

      def all_tool_calls_resolved?
        session ? session.all_tool_calls_resolved? : true
      end

      def tool_loop_consistent?
        session ? session.tool_loop_consistent? : true
      end

      def tool_loop_complete?
        session ? session.tool_loop_complete? : true
      end

      def tool_loop_status
        session&.tool_loop_status || :idle
      end

      def tool_loop_summary
        session&.tool_loop_summary || {
          status: :idle,
          total: 0,
          pending: 0,
          completed: 0,
          orphaned: 0,
          resolved: true,
          consistent: true,
          complete: true,
          open_keys: [],
          orphan_keys: []
        }
      end

      def tool_runtime
        session&.tool_runtime || {
          status: :idle,
          policy: nil,
          finalizer: nil,
          waiting_on: waiting_on,
          interaction_count: 0,
          pending_count: 0,
          completed_count: 0,
          orphaned_count: 0,
          resolved: true,
          consistent: true,
          complete: true,
          open_keys: [],
          orphan_keys: [],
          open_tools: [],
          completed_tools: [],
          orphan_tools: []
        }.freeze
      end

      def last_chunk
        chunks.last
      end

      def complete?
        phase == :completed
      end

      def streaming?
        !complete?
      end

      def to_h
        super.merge(
          type: :stream,
          phase: phase,
          events: events,
          event_count: events.size,
          status_count: status_events.size,
          tool_call_count: tool_calls.size,
          tool_result_count: tool_results.size,
          tool_interaction_count: tool_interactions.size,
          pending_tool_interaction_count: pending_tool_interactions.size,
          completed_tool_interaction_count: completed_tool_interactions.size,
          orphan_tool_interaction_count: orphan_tool_interactions.size,
          tool_loop_status: tool_loop_status,
          tool_loop_complete: tool_loop_complete?,
          tool_loop_summary: tool_loop_summary,
          tool_runtime: tool_runtime,
          artifact_count: artifacts.size,
          chunks: chunks,
          chunk_count: chunks.size
        )
      end
    end
  end
end
