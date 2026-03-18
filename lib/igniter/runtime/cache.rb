# frozen_string_literal: true

module Igniter
  module Runtime
    class Cache
      def initialize
        @states = {}
      end

      def fetch(node_name)
        @states[node_name.to_sym]
      end

      def write(state)
        current = fetch(state.node.name)
        version = state.version || next_version(current)
        @states[state.node.name] = NodeState.new(
          node: state.node,
          status: state.status,
          value: state.value,
          error: state.error,
          version: version,
          resolved_at: state.resolved_at,
          invalidated_by: state.invalidated_by
        )
      end

      def stale!(node, invalidated_by:)
        current = fetch(node.name)
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
      end

      def values
        @states.values
      end

      def to_h
        @states.dup
      end

      private

      def next_version(current)
        current ? current.version + 1 : 1
      end
    end
  end
end
