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
          source = @execution.compiled_graph.fetch_node(output.source)

          {
            output: output.name,
            path: output.path,
            source: source.name,
            dependencies: dependency_tree(source)
          }
        end

        private

        def dependency_tree(node)
          state = @execution.cache.fetch(node.name)
          {
            name: node.name,
            path: node.path,
            kind: node.kind,
            status: state&.status,
            value: serialize_value(state&.value),
            error: state&.error&.message,
            dependencies: node.dependencies.map do |dependency_name|
              dependency_tree(@execution.compiled_graph.fetch_node(dependency_name))
            end
          }
        end

        def serialize_state(state)
          {
            path: state.node.path,
            kind: state.node.kind,
            status: state.status,
            version: state.version,
            invalidated_by: state.invalidated_by,
            value: serialize_value(state.value),
            error: state.error&.message
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
