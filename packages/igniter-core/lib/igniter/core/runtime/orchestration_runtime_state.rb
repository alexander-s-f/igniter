# frozen_string_literal: true

module Igniter
  module Runtime
    class OrchestrationRuntimeState
      attr_reader :runtime_status, :state, :state_class, :session_lifecycle_state,
                  :source_status, :transitions, :latest_transition

      class << self
        def build(node_entry:, state:, session:, timeline:)
          new(node_entry: node_entry, state: state, session: session, timeline: timeline)
        end
      end

      def initialize(node_entry:, state:, session:, timeline:)
        @session_lifecycle_state = session&.lifecycle_state
        @runtime_status = derive_runtime_status(node_entry: node_entry, state: state, session: session)
        @state = derive_state(node_entry: node_entry, state: state, session: session)
        @state_class = classify_state(@state)
        @source_status = (node_entry[:status] || state&.status)&.to_sym
        @transitions = build_transitions(Array(timeline), session: session).freeze
        @latest_transition = (@transitions.last || inferred_transition).freeze
        freeze
      end

      def terminal?
        latest_transition[:terminal]
      end

      def to_h
        {
          runtime_status: runtime_status,
          state: state,
          state_class: state_class,
          session_lifecycle_state: session_lifecycle_state,
          source_status: source_status,
          terminal: terminal?,
          transitions: transitions,
          latest_transition: latest_transition
        }.freeze
      end

      private

      def derive_runtime_status(node_entry:, state:, session:)
        return :pending_session if session
        return :completed if state&.succeeded?
        return :failed if state&.failed?
        return :running if state&.running?
        return :pending if state&.pending?
        return :ready if node_entry[:ready]
        return :blocked if node_entry[:blocked]

        (node_entry[:status] || state&.status || :unknown).to_sym
      end

      def derive_state(node_entry:, state:, session:)
        return session_state(session) if session
        return :completed if state&.succeeded?
        return :failed if state&.failed?
        return :running if state&.running?
        return :pending_resolution if state&.pending?
        return :ready if node_entry[:ready]
        return :blocked if node_entry[:blocked]

        normalize_state_name(node_entry[:status] || state&.status || :unknown)
      end

      def session_state(session)
        case session&.lifecycle_state
        when :waiting
          :awaiting_reply
        when :streaming
          :streaming
        when :completed
          :completed
        else
          :pending_session
        end
      end

      def classify_state(state_name)
        case state_name
        when :completed, :failed
          :terminal
        when :awaiting_reply, :streaming, :pending_session
          :session
        when :running
          :active
        when :pending, :pending_resolution
          :pending
        when :ready
          :ready
        when :blocked
          :blocked
        else
          :unknown
        end
      end

      def build_transitions(timeline, session:)
        timeline.filter_map do |entry|
          transition = transition_for_event(entry, session: session)
          transition&.freeze
        end
      end

      def transition_for_event(entry, session:)
        payload = entry[:payload] || {}
        transition_state =
          case entry[:event]&.to_sym
          when :node_started
            :running
          when :node_pending
            pending_state_from_payload(payload, session: session)
          when :agent_session_continued
            session_state_from_payload(payload)
          when :agent_session_completed, :node_resumed, :node_succeeded, :node_skipped,
               :node_content_cache_hit, :node_ttl_cache_hit, :node_coalesced, :node_backdated
            :completed
          when :node_failed
            :failed
          else
            nil
          end
        return nil unless transition_state

        {
          event: entry[:event]&.to_sym,
          status: entry[:status]&.to_sym,
          state: transition_state,
          state_class: classify_state(transition_state),
          terminal: %i[completed failed].include?(transition_state),
          timestamp: entry[:timestamp],
          turn: payload[:turn],
          phase: payload[:phase]&.to_sym,
          waiting_on: (payload[:waiting_on] || payload.dig(:agent_session, :waiting_on))&.to_sym,
          source_status: entry[:status]&.to_sym
        }.compact
      end

      def pending_state_from_payload(payload, session:)
        session_state_from_payload(payload) || session_state(session) || :pending_resolution
      end

      def session_state_from_payload(payload)
        raw_session =
          payload[:agent_session] ||
          payload["agent_session"] ||
          payload.dig(:payload, :agent_session) ||
          payload.dig("payload", "agent_session")
        return nil unless raw_session

        session = Runtime::AgentSession.from_h(raw_session)
        session_state(session)
      rescue StandardError
        nil
      end

      def inferred_transition
        {
          event: :state_inferred,
          status: source_status,
          state: state,
          state_class: state_class,
          terminal: %i[completed failed].include?(state),
          source_status: source_status
        }.compact
      end

      def normalize_state_name(value)
        value.to_sym
      end
    end
  end
end
