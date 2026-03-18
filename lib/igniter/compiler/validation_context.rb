# frozen_string_literal: true

module Igniter
  module Compiler
    class ValidationContext
      attr_reader :graph, :runtime_nodes_by_name, :outputs_by_name

      def initialize(graph)
        @graph = graph
        @runtime_nodes_by_name = {}
        @outputs_by_name = {}
      end

      def runtime_nodes
        @runtime_nodes ||= graph.nodes.reject { |node| node.kind == :output }
      end

      def outputs
        @outputs ||= graph.nodes.select { |node| node.kind == :output }
      end

      def build_indexes!
        runtime_nodes.each { |node| @runtime_nodes_by_name[node.name] = node }
        outputs.each { |output| @outputs_by_name[output.name] = output }
      end

      def dependency_resolvable?(dependency_name)
        runtime_nodes_by_name.key?(dependency_name.to_sym) || outputs_by_name.key?(dependency_name.to_sym)
      end

      def validation_error(node, message)
        ValidationError.new(
          message,
          context: {
            graph: graph.name,
            node_id: node.id,
            node_name: node.name,
            node_path: node.path,
            source_location: node.source_location
          }
        )
      end
    end
  end
end
