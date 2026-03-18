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

      def write(state)
        @mutex.synchronize do
          current = @states[state.node.name]
          version = state.version || (current&.running? ? current.version : next_version(current))
          @states[state.node.name] = NodeState.new(
            node: state.node,
            status: state.status,
            value: state.value,
            error: state.error,
            version: version,
            resolved_at: state.resolved_at,
            invalidated_by: state.invalidated_by
          )
          @condition.broadcast
        end
      end

      def begin_resolution(node)
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
                resolved_at: current&.resolved_at || Time.now.utc,
                invalidated_by: nil
              )
              return [:started, @states[node.name]]
            end

            @condition.wait(@mutex)
          end
        end
      end

      def stale!(node, invalidated_by:)
        @mutex.synchronize do
          current = @states[node.name]
          return unless current

          @states[node.name] = NodeState.new(
            node: node,
            status: :stale,
            value: current.value,
            error: current.error,
            version: current.version + 1,
            resolved_at: current.resolved_at,
            invalidated_by: invalidated_by
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

      private

      def next_version(current)
        current ? current.version + 1 : 1
      end
    end
  end
end
