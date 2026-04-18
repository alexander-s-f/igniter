# frozen_string_literal: true

module Igniter
  module Extensions
    module Auditing
      class Timeline
        attr_reader :execution

        def initialize(execution)
          @execution = execution
          @events = []
        end

        def call(event)
          @events << event
        end

        def events
          @events.dup
        end

        def restore!(events)
          @events = Array(events).map { |event| event.is_a?(Igniter::Events::Event) ? event : Igniter::Events::Event.from_h(event) }
        end

        def snapshot
          {
            execution_id: execution.events.execution_id,
            graph: execution.compiled_graph.name,
            event_count: @events.size,
            events: @events.map { |event| serialize_event(event) },
            states: serialize_states,
            children: child_snapshots
          }
        end

        private

        def serialize_event(event)
          {
            event_id: event.event_id,
            type: event.type,
            execution_id: event.execution_id,
            node_id: event.node_id,
            node_name: event.node_name,
            path: event.path,
            status: event.status,
            payload: serialize_payload(event.payload),
            timestamp: event.timestamp
          }
        end

        def serialize_states
          execution.cache.to_h.each_with_object({}) do |(node_name, state), memo|
            memo[node_name] = {
              path: state.node.path,
              kind: state.node.kind,
              status: state.status,
              version: state.version,
              invalidated_by: state.invalidated_by,
              resolved_at: state.resolved_at,
              value: serialize_value(state.value),
              error: state.error&.message
            }
          end
        end

        def child_snapshots
          execution.cache.values.filter_map do |state|
            next unless state.value.is_a?(Igniter::Runtime::Result)

            {
              node_name: state.node.name,
              path: state.node.path,
              snapshot: state.value.execution.audit.snapshot
            }
          end
        end

        def serialize_payload(payload)
          payload.each_with_object({}) do |(key, value), memo|
            memo[key] = serialize_value(value)
          end
        end

        def serialize_value(value)
          case value
          when Igniter::Runtime::Result
            {
              type: :result,
              execution_id: value.execution.events.execution_id,
              graph: value.execution.compiled_graph.name
            }
          when Array
            value.map { |item| serialize_value(item) }
          else
            value
          end
        end
      end
    end
  end
end
