# frozen_string_literal: true

module Igniter
  module Compiler
    class Validator
      def self.call(graph)
        new(graph).call
      end

      def initialize(graph)
        @graph = graph
        @runtime_nodes_by_name = {}
      end

      def call
        index_runtime_nodes!
        validate_outputs!
        validate_dependencies!

        self
      end

      def runtime_nodes
        @runtime_nodes ||= @graph.nodes.reject { |node| node.kind == :output }
      end

      def outputs
        @outputs ||= @graph.nodes.select { |node| node.kind == :output }
      end

      def runtime_nodes_by_name
        @runtime_nodes_by_name
      end

      private

      def index_runtime_nodes!
        runtime_nodes.each do |node|
          raise validation_error(node, "Duplicate node name: #{node.name}") if @runtime_nodes_by_name.key?(node.name)

          @runtime_nodes_by_name[node.name] = node
        end
      end

      def validate_outputs!
        raise ValidationError, "Graph must define at least one output" if outputs.empty?

        seen = {}
        outputs.each do |output|
          raise validation_error(output, "Duplicate output name: #{output.name}") if seen.key?(output.name)
          raise validation_error(output, "Unknown output source '#{output.source}' for output '#{output.name}'") unless @runtime_nodes_by_name.key?(output.source)

          seen[output.name] = true
        end
      end

      def validate_dependencies!
        runtime_nodes.each do |node|
          validate_composition_node!(node) if node.kind == :composition

          node.dependencies.each do |dependency_name|
            next if @runtime_nodes_by_name.key?(dependency_name)

            raise validation_error(node, "Unknown dependency '#{dependency_name}' for node '#{node.name}'")
          end
        end
      end

      def validate_composition_node!(node)
        contract_class = node.contract_class

        unless contract_class.is_a?(Class) && contract_class <= Igniter::Contract
          raise validation_error(node, "Composition '#{node.name}' must reference an Igniter::Contract subclass")
        end

        unless contract_class.compiled_graph
          raise validation_error(node, "Composition '#{node.name}' references an uncompiled contract")
        end
      end

      def validation_error(node, message)
        location = node.source_location
        suffix = location ? " (declared at #{location})" : ""
        ValidationError.new("#{message}#{suffix}")
      end
    end
  end
end
