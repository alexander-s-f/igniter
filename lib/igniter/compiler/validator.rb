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
        validate_unique_ids!
        index_runtime_nodes!
        validate_outputs!
        validate_unique_paths!
        validate_dependencies!
        validate_callable_signatures!

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

      def validate_unique_ids!
        seen = {}

        @graph.nodes.each do |node|
          if seen.key?(node.id)
            raise validation_error(node, "Duplicate node id: #{node.id}")
          end

          seen[node.id] = true
        end
      end

      def validate_unique_paths!
        seen = {}

        runtime_nodes.each do |node|
          if seen.key?(node.path)
            raise validation_error(node, "Duplicate node path: #{node.path}")
          end

          seen[node.path] = true
        end

        outputs.each do |output|
          if seen.key?(output.path)
            raise validation_error(output, "Duplicate node path: #{output.path}")
          end

          seen[output.path] = true
        end
      end

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

        validate_composition_input_mapping!(node, contract_class.compiled_graph)
      end

      def validate_composition_input_mapping!(node, child_graph)
        child_input_nodes = child_graph.nodes.select { |child_node| child_node.kind == :input }
        child_input_names = child_input_nodes.map(&:name)

        unknown_inputs = node.input_mapping.keys - child_input_names
        unless unknown_inputs.empty?
          raise validation_error(
            node,
            "Composition '#{node.name}' maps unknown child inputs: #{unknown_inputs.sort.join(', ')}"
          )
        end

        missing_required_inputs = child_input_nodes
          .select(&:required?)
          .reject { |child_input| node.input_mapping.key?(child_input.name) }
          .map(&:name)

        return if missing_required_inputs.empty?

        raise validation_error(
          node,
          "Composition '#{node.name}' is missing mappings for required child inputs: #{missing_required_inputs.sort.join(', ')}"
        )
      end

      def validate_callable_signatures!
        runtime_nodes.each do |node|
          next unless node.kind == :compute
          next unless node.callable.is_a?(Proc)

          validate_proc_signature!(node)
        end
      end

      def validate_proc_signature!(node)
        parameters = node.callable.parameters
        positional_kinds = %i[req opt rest]
        positional = parameters.select { |kind, _name| positional_kinds.include?(kind) }

        unless positional.empty?
          raise validation_error(
            node,
            "Compute '#{node.name}' proc must use keyword arguments for dependencies, got positional parameters"
          )
        end

        accepts_any_keywords = parameters.any? { |kind, _name| kind == :keyrest }
        accepted_keywords = parameters
          .select { |kind, _name| %i[key keyreq].include?(kind) }
          .map(&:last)
        required_keywords = parameters
          .select { |kind, _name| kind == :keyreq }
          .map(&:last)

        missing_dependencies = required_keywords - node.dependencies
        unless missing_dependencies.empty?
          raise validation_error(
            node,
            "Compute '#{node.name}' requires undeclared dependencies: #{missing_dependencies.sort.join(', ')}"
          )
        end

        return if accepts_any_keywords

        unknown_dependencies = node.dependencies - accepted_keywords
        return if unknown_dependencies.empty?

        raise validation_error(
          node,
          "Compute '#{node.name}' declares unsupported dependencies for its proc: #{unknown_dependencies.sort.join(', ')}"
        )
      end

      def validation_error(node, message)
        ValidationError.new(
          message,
          context: {
            graph: @graph.name,
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
