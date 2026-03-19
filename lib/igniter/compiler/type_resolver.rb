# frozen_string_literal: true

module Igniter
  module Compiler
    class TypeResolver
      def self.call(graph, name)
        new(graph).call(name)
      end

      def initialize(graph)
        @graph = graph
      end

      def call(name)
        if @graph.output?(name)
          resolve_output(@graph.fetch_output(name))
        else
          resolve_node(@graph.fetch_node(name))
        end
      end

      private

      def resolve_output(output)
        return output.type if output.type

        if output.composition_output?
          composition = @graph.fetch_node(output.source_root)
          child_graph = composition.contract_class.compiled_graph
          self.class.call(child_graph, output.child_output_name)
        else
          resolve_node(@graph.fetch_node(output.source))
        end
      end

      def resolve_node(node)
        case node.kind
        when :input
          node.type
        when :compute
          node.type
        when :composition
          :result
        when :branch
          :result
        else
          nil
        end
      end
    end
  end
end
