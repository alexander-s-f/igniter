# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class OutputsValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          raise ValidationError, "Graph must define at least one output" if @context.outputs.empty?

          @context.outputs.each { |output| validate_output_source!(output) }
        end

        private

        def validate_output_source!(output)
          if output.composition_output?
            validate_nested_output_source!(output)
          else
            return if @context.runtime_nodes_by_name.key?(output.source)

            raise @context.validation_error(output, "Unknown output source '#{output.source}' for output '#{output.name}'")
          end
        end

        def validate_nested_output_source!(output)
          parent_node = @context.runtime_nodes_by_name[output.source_root]
          unless %i[composition branch].include?(parent_node&.kind)
            raise @context.validation_error(
              output,
              "Output '#{output.name}' references unknown nested source '#{output.source}'"
            )
          end

          validate_nested_output_presence!(output, parent_node)
        end

        def validate_nested_output_presence!(output, parent_node)
          child_graphs =
            case parent_node.kind
            when :composition
              [parent_node.contract_class.compiled_graph]
            when :branch
              parent_node.possible_contracts.map(&:compiled_graph)
            else
              []
            end

          return if child_graphs.all? { |graph| graph.outputs_by_name.key?(output.child_output_name) }

          raise @context.validation_error(
            output,
            "Output '#{output.name}' references unknown child output '#{output.child_output_name}' on nested source '#{parent_node.name}'"
          )
        end
      end
    end
  end
end
