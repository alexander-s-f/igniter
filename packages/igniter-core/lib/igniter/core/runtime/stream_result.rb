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
          chunks: chunks,
          chunk_count: chunks.size
        )
      end
    end
  end
end
