# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class DependenciesValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          @context.runtime_nodes.each do |node|
            validate_composition_node!(node) if node.kind == :composition

            node.dependencies.each do |dependency_name|
              next if @context.dependency_resolvable?(dependency_name)

              raise @context.validation_error(node, "Unknown dependency '#{dependency_name}' for node '#{node.name}'")
            end
          end
        end

        private

        def validate_composition_node!(node)
          contract_class = node.contract_class

          unless contract_class.is_a?(Class) && contract_class <= Igniter::Contract
            raise @context.validation_error(node, "Composition '#{node.name}' must reference an Igniter::Contract subclass")
          end

          unless contract_class.compiled_graph
            raise @context.validation_error(node, "Composition '#{node.name}' references an uncompiled contract")
          end

          validate_composition_input_mapping!(node, contract_class.compiled_graph)
        end

        def validate_composition_input_mapping!(node, child_graph)
          child_input_nodes = child_graph.nodes.select { |child_node| child_node.kind == :input }
          child_input_names = child_input_nodes.map(&:name)

          unknown_inputs = node.input_mapping.keys - child_input_names
          unless unknown_inputs.empty?
            raise @context.validation_error(
              node,
              "Composition '#{node.name}' maps unknown child inputs: #{unknown_inputs.sort.join(', ')}"
            )
          end

          missing_required_inputs = child_input_nodes
            .select(&:required?)
            .reject { |child_input| node.input_mapping.key?(child_input.name) }
            .map(&:name)

          return if missing_required_inputs.empty?

          raise @context.validation_error(
            node,
            "Composition '#{node.name}' is missing mappings for required child inputs: #{missing_required_inputs.sort.join(', ')}"
          )
        end
      end
    end
  end
end
