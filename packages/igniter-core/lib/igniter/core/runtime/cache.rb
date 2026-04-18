# frozen_string_literal: true

module Igniter
  module Runtime
    class Cache
      def initialize
        @states = {}
        @mutex = Mutex.new
        @condition = ConditionVariable.new
      end

      def fetch(node_name)
        @mutex.synchronize { @states[node_name.to_sym] }
      end

      def write(state) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @mutex.synchronize do
          current = @states[state.node.name]
          version = state.version || (current&.running? ? current.version : next_version(current))
          value_version = compute_value_version(state, current)
          @states[state.node.name] = NodeState.new(
            node: state.node,
            status: state.status,
            value: state.value,
            error: state.error,
            version: version,
            value_version: value_version,
            resolved_at: state.resolved_at,
            invalidated_by: state.invalidated_by,
            dep_snapshot: state.dep_snapshot
          )
          @condition.broadcast
        end
      end

      def begin_resolution(node) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @mutex.synchronize do
          loop do
            current = @states[node.name]
            return [:cached, current] if current && !current.stale? && !current.running?

            unless current&.running?
              @states[node.name] = NodeState.new(
                node: node,
                status: :running,
                value: current&.value,
                error: current&.error,
                version: next_version(current),
                value_version: current&.value_version,
                resolved_at: current&.resolved_at || Time.now.utc,
                invalidated_by: nil,
                dep_snapshot: current&.dep_snapshot
              )
              return [:started, @states[node.name]]
            end

            @condition.wait(@mutex)
          end
        end
      end

      def stale!(node, invalidated_by:) # rubocop:disable Metrics/MethodLength
        @mutex.synchronize do
          current = @states[node.name]
          return unless current

          @states[node.name] = NodeState.new(
            node: node,
            status: :stale,
            value: current.value,
            error: current.error,
            version: current.version + 1,
            value_version: current.value_version,
            resolved_at: current.resolved_at,
            invalidated_by: invalidated_by,
            dep_snapshot: current.dep_snapshot
          )
          @condition.broadcast
        end
      end

      def values
        @mutex.synchronize { @states.values }
      end

      def to_h
        @mutex.synchronize { @states.dup }
      end

      def restore!(states)
        @mutex.synchronize do
          @states = states.transform_keys(&:to_sym)
          @condition.broadcast
        end
      end

      private

      def next_version(current)
        current ? current.version + 1 : 1
      end

      # value_version only increments when the actual value changes.
      # When state.value_version is set explicitly (backdating from resolver), use it.
      # For :succeeded states, compare the new value against the old value:
      #   - same value → preserve value_version
      #   - different (or first time) → increment
      # For all other statuses (failed, pending, etc.) → no value_version.
      def compute_value_version(state, current)
        return state.value_version if state.value_version

        return nil unless state.status == :succeeded

        base_vv = current&.value_version || 0
        # When current is :running, current.value holds the pre-stale value for comparison.
        old_value = current&.value

        if base_vv.positive? && old_value == state.value
          base_vv
        else
          base_vv + 1
        end
      end
    end
  end
end
