# frozen_string_literal: true

require "tsort"

module Igniter
  module Compiler
    class GraphCompiler
      include TSort

      def self.call(graph)
        new(graph).call
      end

      def initialize(graph)
        @graph = graph
      end

      def call
        validator = Validator.call(@graph)
        @nodes_by_name = validator.runtime_nodes_by_name
        @outputs_by_name = validator.outputs.each_with_object({}) { |output, memo| memo[output.name] = output }

        CompiledGraph.new(
          name: @graph.name,
          nodes: validator.runtime_nodes,
          outputs: validator.outputs,
          resolution_order: tsort,
          dependents: build_dependents
        )
      end

      private

      def runtime_nodes
        @runtime_nodes ||= @graph.nodes.reject { |node| node.kind == :output }
      end

      def build_dependents
        runtime_nodes.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |node, memo|
          node.dependencies.each do |dependency_name|
            memo[dependency_source_name(dependency_name)] << node.name
          end
        end
      end

      def tsort_each_node(&block)
        runtime_nodes.each(&block)
      end

      def tsort_each_child(node, &block)
        node.dependencies.each do |dependency_name|
          block.call(@nodes_by_name.fetch(dependency_source_name(dependency_name)))
        end
      end

      def dependency_source_name(dependency_name)
        output = @outputs_by_name[dependency_name.to_sym]
        return output.source_root if output

        dependency_name
      end

      def tsort
        super
      rescue TSort::Cyclic => e
        raise CycleError, e.message
      end
    end
  end
end
