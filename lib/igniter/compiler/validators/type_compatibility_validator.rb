# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class TypeCompatibilityValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
          @resolver = TypeResolver.new(context)
        end

        def call
          validate_executor_dependency_types!
          validate_composition_input_types!
        end

        private

        def validate_executor_dependency_types!
          @context.runtime_nodes.each do |node|
            next unless node.kind == :compute
            next unless node.callable.is_a?(Class) && node.callable <= Igniter::Executor

            node.callable.executor_inputs.each do |dependency_name, config|
              next unless node.dependencies.include?(dependency_name)

              validate_edge_type!(
                node: node,
                dependency_name: dependency_name,
                target_type: config[:type],
                label: "executor input '#{dependency_name}'"
              )
            end
          end
        end

        def validate_composition_input_types!
          @context.runtime_nodes.each do |node|
            next unless node.kind == :composition

            child_inputs = node.contract_class.compiled_graph.nodes.select { |child_node| child_node.kind == :input }
            child_inputs.each do |child_input|
              dependency_name = node.input_mapping[child_input.name]
              next unless dependency_name

              validate_edge_type!(
                node: node,
                dependency_name: dependency_name,
                target_type: child_input.type,
                label: "composition input '#{child_input.name}'"
              )
            end
          end
        end

        def validate_edge_type!(node:, dependency_name:, target_type:, label:)
          return unless target_type

          unless TypeSystem.supported?(target_type)
            raise @context.validation_error(node, "Unsupported target type '#{target_type}' for #{label}")
          end

          source_type = @resolver.call(dependency_name)
          return if source_type.nil?

          unless TypeSystem.supported?(source_type)
            raise @context.validation_error(node, "Unsupported source type '#{source_type}' for dependency '#{dependency_name}'")
          end

          return if TypeSystem.compatible?(source_type, target_type)

          raise @context.validation_error(
            node,
            "Type mismatch for #{label}: dependency '#{dependency_name}' is #{source_type}, expected #{target_type}"
          )
        end
      end
    end
  end
end
