# frozen_string_literal: true

module Igniter
  module Runtime
    class OrchestrationOverview
      attr_reader :execution, :plan

      def initialize(execution:, plan:)
        @execution = execution
        @plan = plan.freeze
      end

      def records
        @records ||= begin
          action_index = actions.each_with_object({}) { |action, memo| memo[action[:node].to_sym] = action }

          actions.map do |action|
            node_name = action[:node].to_sym
            session = sessions_by_node[node_name]
            node_entry = node_entries[node_name] || {}
            state = execution.cache.fetch(node_name)
            timeline = timeline_for(node_name)
            orchestration = node_entry[:orchestration] || {}
            runtime_state = Runtime::OrchestrationRuntimeState.build(
              node_entry: node_entry,
              state: state,
              session: session,
              timeline: timeline
            )

            {
              id: action[:id],
              node: node_name,
              action: action[:action],
              interaction: action[:interaction],
              reason: action[:reason],
              guidance: action[:guidance],
              attention_required: !!action[:attention_required],
              resumable: !!action[:resumable],
              status: node_entry[:status] || state&.status,
              runtime_status: runtime_state.runtime_status,
              runtime_state: runtime_state.state,
              runtime_state_class: runtime_state.state_class,
              runtime_terminal: runtime_state.terminal?,
              latest_runtime_transition: runtime_state.latest_transition,
              runtime_transitions: runtime_state.transitions,
              waiting_on: session&.waiting_on || Array(node_entry[:waiting_on]).first,
              reply_mode: node_entry[:reply_mode],
              session_policy: node_entry[:session_policy],
              tool_loop_policy: node_entry[:tool_loop_policy],
              finalizer: session&.finalizer || node_entry[:finalizer],
              routing_mode: session&.routing_mode || node_entry[:routing_mode],
              interaction_contract: session&.interaction_contract&.to_h || node_entry[:interaction_contract],
              session_lifecycle_state: session&.lifecycle_state,
              phase: session&.phase,
              ownership: session&.ownership,
              owner_url: session&.owner_url,
              delivery_route: session&.delivery_route,
              token: session&.token,
              turn: session&.turn,
              interactive: session ? session.interactive? : false,
              terminal: runtime_state.terminal?,
              continuable: session ? session.continuable? : false,
              routed: session ? session.routed? : false,
              tool_runtime: session&.tool_runtime,
              allows_continuation: !!orchestration[:allows_continuation],
              requires_explicit_completion: !!orchestration[:requires_explicit_completion],
              auto_finalization: orchestration[:auto_finalization],
              session: session&.to_h,
              timeline: timeline
            }.freeze
          end.freeze
        end
      end

      def timeline
        @timeline ||= actions.flat_map { |action| timeline_for(action[:node]) }.sort_by { |entry| entry[:timestamp].to_s }.freeze
      end

      def transitions
        @transitions ||= records.flat_map do |record|
          Array(record[:runtime_transitions]).map do |transition|
            {
              id: record[:id],
              node: record[:node],
              action: record[:action],
              interaction: record[:interaction],
              reason: record[:reason],
              runtime_status: record[:runtime_status],
              runtime_state: record[:runtime_state],
              runtime_state_class: record[:runtime_state_class]
            }.merge(transition).freeze
          end
        end.sort_by { |entry| entry[:timestamp].to_s }.freeze
      end

      def transition_query
        @transition_query ||= Runtime::OrchestrationTransitionQuery.new(transitions)
      end

      def transition_summary
        transition_query.summary
      end

      def summary
        @summary ||= begin
          waiting_on = Hash.new(0)
          records.each do |record|
            waiting_value = record[:waiting_on]
            waiting_on[waiting_value] += 1 if waiting_value
          end

          {
            total: records.size,
            attention_required: records.count { |record| record[:attention_required] },
            resumable: records.count { |record| record[:resumable] },
            with_session: records.count { |record| !record[:session].nil? },
            interactive_sessions: records.count { |record| record[:interaction] == :interactive_session },
            manual_sessions: records.count { |record| record[:interaction] == :manual_session },
            single_turn_sessions: records.count { |record| record[:interaction] == :single_turn_session },
            deferred_calls: records.count { |record| record[:interaction] == :deferred_call },
            by_action: facet(records, :action),
            by_interaction: facet(records, :interaction),
            by_runtime_status: facet(records, :runtime_status),
            by_runtime_state: facet(records, :runtime_state),
            by_runtime_state_class: facet(records, :runtime_state_class),
            by_status: facet(records, :status),
            by_session_lifecycle_state: facet(records, :session_lifecycle_state),
            by_ownership: facet(records, :ownership),
            by_phase: facet(records, :phase),
            by_reply_mode: facet(records, :reply_mode),
            by_tool_runtime_status: facet(records, :tool_loop_status),
            by_waiting_on: waiting_on.freeze,
            terminal_runtime_records: records.count { |record| record[:runtime_terminal] },
            by_event_type: facet(timeline, :event),
            recent_events: timeline.last(5).freeze
          }.freeze
        end
      end

      def to_h
        {
          summary: summary,
          records: records,
          timeline: timeline,
          transitions: transition_query.to_h
        }.freeze
      end

      private

      def actions
        Array(plan.dig(:orchestration, :actions)).freeze
      end

      def node_entries
        @node_entries ||= begin
          plan.fetch(:nodes, {}).each_with_object({}) do |(node_name, entry), memo|
            memo[node_name.to_sym] = entry
          end.freeze
        end
      end

      def sessions_by_node
        @sessions_by_node ||= execution.agent_sessions.each_with_object({}) do |session, memo|
          memo[session.node_name.to_sym] = session
        end.freeze
      end

      def timeline_for(node_name)
        relevant_events
          .select { |event| event.node_name == node_name.to_sym }
          .map { |event| serialize_event(event) }
          .freeze
      end

      def relevant_events
        @relevant_events ||= execution.events.events.select do |event|
          next false unless event.node_name

          actions.any? { |action| action[:node].to_sym == event.node_name.to_sym }
        end.freeze
      end

      def serialize_event(event)
        payload = event.payload || {}

        {
          event_id: event.event_id,
          event: event.type,
          node: event.node_name,
          status: event.status,
          timestamp: event.timestamp,
          token: payload[:token],
          turn: payload[:turn],
          phase: payload[:phase],
          waiting_on: payload[:waiting_on],
          payload: payload
        }.compact.freeze
      end

      def facet(entries, key)
        entries.each_with_object(Hash.new(0)) do |entry, memo|
          value = entry[key]
          next if value.nil?

          memo[value] += 1
        end.freeze
      end
    end
  end
end
