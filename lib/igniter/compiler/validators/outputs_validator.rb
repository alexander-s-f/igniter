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
            validate_composed_output_source!(output)
          else
            return if @context.runtime_nodes_by_name.key?(output.source)

            raise @context.validation_error(output, "Unknown output source '#{output.source}' for output '#{output.name}'")
          end
        end

        def validate_composed_output_source!(output)
          composition_node = @context.runtime_nodes_by_name[output.source_root]
          unless composition_node&.kind == :composition
            raise @context.validation_error(
              output,
              "Output '#{output.name}' references unknown composition source '#{output.source}'"
            )
          end

          child_graph = composition_node.contract_class.compiled_graph
          return if child_graph.outputs_by_name.key?(output.child_output_name)

          raise @context.validation_error(
            output,
            "Output '#{output.name}' references unknown child output '#{output.child_output_name}' on composition '#{composition_node.name}'"
          )
        end
      end
    end
  end
end
