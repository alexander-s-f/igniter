# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class RuntimeOverviewBuilder
        def self.latest_event_for(record)
          latest_event = Array(record[:combined_timeline]).last || Array(record[:timeline]).last
          latest_event&.dup&.freeze
        end

        def self.result_snapshot(record)
          latest_event = latest_event_for(record)

          {
            id: record[:id],
            node: record[:node],
            action: record[:action],
            runtime_status: record[:runtime_status],
            runtime_state: record[:runtime_state],
            runtime_state_class: record[:runtime_state_class],
            inbox_status: record[:inbox_status],
            session_lifecycle_state: record[:session_lifecycle_state],
            interaction_contract: record[:interaction_contract],
            waiting_on: record[:waiting_on],
            terminal: !!record[:terminal],
            latest_runtime_transition: record[:latest_runtime_transition],
            latest_event: latest_event
          }.compact.freeze
        end

        def initialize(execution:, inbox_items:)
          @execution = execution
          @inbox_items = Array(inbox_items).map(&:dup).freeze
          freeze
        end

        def overview
          base_overview = execution.orchestration_overview
          inbox_by_id = @inbox_items.each_with_object({}) { |item, memo| memo[item[:id].to_s] = item }
          combined_events = []

          records = Array(base_overview[:records]).map do |record|
            inbox_item = inbox_by_id[record[:id].to_s]
            combined_timeline = merge_timelines(
              node_name: record[:node],
              runtime_timeline: record[:timeline],
              inbox_history: inbox_item&.dig(:action_history)
            )
            event_query = RuntimeEventQuery.new(combined_timeline)
            combined_events.concat(combined_timeline)

            record.merge(
              inbox_item_id: inbox_item&.dig(:item_id),
              inbox_status: inbox_item&.dig(:status),
              inbox_queue: inbox_item&.dig(:queue),
              inbox_channel: inbox_item&.dig(:channel),
              inbox_assignee: inbox_item&.dig(:assignee),
              inbox_action_history: Array(inbox_item&.dig(:action_history)).map(&:dup).freeze,
              combined_timeline: combined_timeline,
              event_summary: event_query.summary,
              latest_event: event_query.summary[:latest_event]
            ).freeze
          end.freeze

          {
            summary: build_summary(base_overview[:summary], records, combined_events),
            results: build_results(records),
            records: records,
            timeline: base_overview[:timeline],
            combined_timeline: combined_events.sort_by { |event| event[:timestamp].to_s }.freeze,
            event_query: RuntimeEventQuery.new(combined_events),
            transition_query: execution.orchestration_transition_query
          }.freeze
        end

        def fallback_record_for(item)
          node_name = item[:node].to_sym
          session = execution.agent_sessions.find do |entry|
            entry.node_name == node_name &&
              entry.graph.to_s == item[:graph].to_s &&
              entry.execution_id.to_s == item[:execution_id].to_s
          end
          state = execution.cache.fetch(node_name)
          runtime_timeline = serialize_runtime_timeline(node_name)
          combined_timeline = merge_timelines(
            node_name: node_name,
            runtime_timeline: runtime_timeline,
            inbox_history: item[:action_history]
          )
          event_query = RuntimeEventQuery.new(combined_timeline)
          runtime_state = Runtime::OrchestrationRuntimeState.build(
            node_entry: { status: state&.status },
            state: state,
            session: session,
            timeline: runtime_timeline
          )

          {
            id: item[:id],
            node: node_name,
            action: item[:action],
            interaction: item[:interaction],
            reason: item[:reason],
            guidance: item[:guidance],
            attention_required: !!item[:attention_required],
            resumable: !!item[:resumable],
            status: state&.status || item[:status],
            runtime_status: runtime_state.runtime_status,
            runtime_state: runtime_state.state,
            runtime_state_class: runtime_state.state_class,
            runtime_terminal: runtime_state.terminal?,
            latest_runtime_transition: runtime_state.latest_transition,
            runtime_transitions: runtime_state.transitions,
            waiting_on: session&.waiting_on || item[:waiting_on],
            reply_mode: session&.reply_mode || item[:reply_mode],
            finalizer: session&.finalizer || item[:finalizer],
            session_policy: session&.session_policy || item[:session_policy],
            tool_loop_policy: session&.tool_loop_policy || item[:tool_loop_policy],
            routing_mode: session&.routing_mode || item[:routing_mode],
            interaction_contract: session&.interaction_contract&.to_h || item[:interaction_contract],
            session_lifecycle_state: session&.lifecycle_state,
            phase: session&.phase || item[:phase],
            ownership: session&.ownership,
            owner_url: session&.owner_url,
            delivery_route: session&.delivery_route,
            token: session&.token || item[:token],
            turn: session&.turn || item[:turn],
            interactive: session ? session.interactive? : false,
            terminal: runtime_state.terminal?,
            continuable: session ? session.continuable? : false,
            routed: session ? session.routed? : false,
            session: session&.to_h,
            timeline: runtime_timeline,
            inbox_item_id: item[:item_id],
            inbox_status: item[:status],
            inbox_queue: item[:queue],
            inbox_channel: item[:channel],
            inbox_assignee: item[:assignee],
            inbox_action_history: Array(item[:action_history]).map(&:dup).freeze,
            combined_timeline: combined_timeline,
            event_summary: event_query.summary,
            latest_event: event_query.summary[:latest_event]
          }.freeze
        end

        private

        attr_reader :execution

        def build_summary(base_summary, records, combined_events)
          base_summary.merge(
            with_inbox_items: records.count { |record| !record[:inbox_item_id].nil? },
            by_inbox_status: records.each_with_object(Hash.new(0)) do |record, memo|
              memo[record[:inbox_status]] += 1 if record[:inbox_status]
            end.freeze,
            by_combined_event_type: combined_events.each_with_object(Hash.new(0)) do |event, memo|
              memo[event[:event]] += 1 if event[:event]
            end.freeze,
            recent_combined_events: combined_events.sort_by { |event| event[:timestamp].to_s }.last(10).freeze
          ).freeze
        end

        def build_results(records)
          latest_records = records.filter_map do |record|
            latest_event = self.class.latest_event_for(record)
            next unless latest_event

            {
              id: record[:id],
              node: record[:node],
              action: record[:action],
              runtime_status: record[:runtime_status],
              runtime_state: record[:runtime_state],
              runtime_state_class: record[:runtime_state_class],
              inbox_status: record[:inbox_status],
              session_lifecycle_state: record[:session_lifecycle_state],
              latest_event: latest_event[:event],
              latest_event_class: latest_event[:event_class],
              latest_timestamp: latest_event[:timestamp],
              latest_source: latest_event[:source],
              latest_actor: latest_event[:actor],
              latest_origin: latest_event[:origin],
              latest_lifecycle_operation: latest_event[:lifecycle_operation],
              latest_execution_operation: latest_event[:execution_operation],
              waiting_on: record[:waiting_on]
            }.compact.freeze
          end

          {
            terminal_records: records.count do |record|
              %i[completed failed].include?(record[:runtime_status]&.to_sym) ||
                %i[resolved dismissed].include?(record[:inbox_status]&.to_sym)
            end,
            completed_runtime_records: records.count { |record| record[:runtime_status]&.to_sym == :completed },
            failed_runtime_records: records.count { |record| record[:runtime_status]&.to_sym == :failed },
            latest_records: latest_records.sort_by { |entry| entry[:latest_timestamp].to_s }.last(5).freeze
          }.freeze
        end

        def merge_timelines(node_name:, runtime_timeline:, inbox_history:)
          runtime_entries = Array(runtime_timeline).map do |entry|
            build_runtime_event(entry, source: :runtime, node_name: node_name)
          end
          inbox_entries = Array(inbox_history).map do |entry|
            build_runtime_event(
              {
                event: entry[:event],
                status: entry[:status],
                timestamp: entry[:at],
                actor: entry[:actor],
                origin: entry[:origin],
                actor_channel: entry[:actor_channel],
                note: entry[:note],
                requested_operation: entry[:requested_operation],
                lifecycle_operation: entry[:lifecycle_operation],
                execution_operation: entry[:execution_operation],
                payload: entry.dup
              },
              source: :inbox,
              node_name: node_name
            )
          end

          (runtime_entries + inbox_entries).sort_by { |entry| entry[:timestamp].to_s }.freeze
        end

        def serialize_runtime_timeline(node_name)
          execution.events.events.filter_map do |event|
            next unless event.node_name == node_name.to_sym

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
          end.freeze
        end

        def build_runtime_event(entry, source:, node_name:)
          payload = (entry[:payload] || {}).dup
          event_status = entry[:status]&.to_sym

          {
            source: source.to_sym,
            event_class: source.to_sym == :runtime ? :runtime : :operator,
            event: entry[:event]&.to_sym,
            node: (entry[:node] || node_name)&.to_sym,
            status: event_status,
            timestamp: entry[:timestamp],
            terminal: orchestration_event_terminal_status?(event_status),
            token: entry[:token] || payload[:token],
            turn: entry[:turn] || payload[:turn],
            phase: entry[:phase] || payload[:phase],
            waiting_on: entry[:waiting_on] || payload[:waiting_on],
            actor: entry[:actor] || payload[:actor],
            origin: entry[:origin] || payload[:origin],
            actor_channel: entry[:actor_channel] || payload[:actor_channel],
            requested_operation: (entry[:requested_operation] || payload[:requested_operation])&.to_sym,
            lifecycle_operation: (entry[:lifecycle_operation] || payload[:lifecycle_operation])&.to_sym,
            execution_operation: (entry[:execution_operation] || payload[:execution_operation])&.to_sym,
            note: entry[:note] || payload[:note],
            event_id: entry[:event_id],
            payload: payload.freeze
          }.compact.freeze
        end

        def orchestration_event_terminal_status?(status)
          %i[completed failed resolved dismissed].include?(status&.to_sym)
        end
      end
    end
  end
end
