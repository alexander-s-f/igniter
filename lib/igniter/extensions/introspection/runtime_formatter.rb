# frozen_string_literal: true

module Igniter
  module Extensions
    module Introspection
      class RuntimeFormatter
        def self.states(execution)
          new(execution).states
        end

        def self.explain_output(execution, output_name)
          new(execution).explain_output(output_name)
        end

        def initialize(execution)
          @execution = execution
        end

        def states
          @execution.cache.to_h.each_with_object({}) do |(node_name, state), memo|
            memo[node_name] = serialize_state(state)
          end
        end

        def explain_output(output_name)
          output = @execution.compiled_graph.fetch_output(output_name)
          source = @execution.compiled_graph.fetch_node(output.source_root)

          explanation = {
            output_id: output.id,
            output: output.name,
            path: output.path,
            source_id: source.id,
            source: source.name,
            source_path: source.path,
            dependencies: dependency_tree(source)
          }

          if output.composition_output?
            explanation[:child_output] = output.child_output_name
            explanation[:child_output_path] = output.source.to_s
          end

          explanation
        end

        private

        def dependency_tree(node)
          state = @execution.cache.fetch(node.name)
          {
            id: node.id,
            name: node.name,
            path: node.path,
            kind: node.kind,
            source_location: node.source_location,
            status: state&.status,
            invalidated_by: invalidation_details(state),
            value: serialize_value(state&.value),
            error: state&.error&.message,
            dependencies: node.dependencies.map do |dependency_name|
              dependency_tree(@execution.compiled_graph.fetch_dependency(dependency_name))
            end
          }
        end

        def serialize_state(state)
          {
            id: state.node.id,
            path: state.node.path,
            kind: state.node.kind,
            source_location: state.node.source_location,
            status: state.status,
            version: state.version,
            invalidated_by: invalidation_details(state),
            value: serialize_value(state.value),
            error: state.error&.message
          }
        end

        def invalidation_details(state)
          return nil unless state&.invalidated_by

          invalidating_node = @execution.compiled_graph.fetch_node(state.invalidated_by)
          {
            node_id: invalidating_node.id,
            node_name: invalidating_node.name,
            node_path: invalidating_node.path
          }
        end

        def serialize_value(value)
          case value
          when Igniter::Runtime::Result
            {
              type: :result,
              graph: value.execution.compiled_graph.name,
              execution_id: value.execution.events.execution_id
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
