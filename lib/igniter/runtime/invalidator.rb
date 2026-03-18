# frozen_string_literal: true

module Igniter
  module Runtime
    class Invalidator
      def initialize(execution)
        @execution = execution
      end

      def invalidate_from(node_name)
        queue = @execution.compiled_graph.dependents.fetch(node_name.to_sym, []).dup
        seen = {}

        until queue.empty?
          dependent_name = queue.shift
          next if seen[dependent_name]

          seen[dependent_name] = true
          dependent_node = @execution.compiled_graph.fetch_node(dependent_name)
          stale_state = @execution.cache.stale!(dependent_node, invalidated_by: node_name.to_sym)

          if stale_state
            @execution.events.emit(
              :node_invalidated,
              node: dependent_node,
              status: :stale,
              payload: { cause: node_name.to_sym }
            )
            emit_output_invalidations_for(dependent_node.name, node_name)
          end

          queue.concat(@execution.compiled_graph.dependents.fetch(dependent_name, []))
        end
      end

      private

      def emit_output_invalidations_for(source_name, cause_name)
        @execution.compiled_graph.outputs.each do |output_node|
          next unless output_node.source == source_name.to_sym

          @execution.events.emit(
            :node_invalidated,
            node: output_node,
            status: :stale,
            payload: { cause: cause_name.to_sym }
          )
        end
      end
    end
  end
end
