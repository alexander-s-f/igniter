# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class UniquenessValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          validate_unique_ids!
          validate_unique_names!
          validate_unique_paths!
        end

        private

        def validate_unique_ids!
          seen = {}
          @context.graph.nodes.each do |node|
            raise @context.validation_error(node, "Duplicate node id: #{node.id}") if seen.key?(node.id)

            seen[node.id] = true
          end
        end

        def validate_unique_names!
          seen_runtime = {}
          @context.runtime_nodes.each do |node|
            raise @context.validation_error(node, "Duplicate node name: #{node.name}") if seen_runtime.key?(node.name)

            seen_runtime[node.name] = true
          end

          seen_outputs = {}
          @context.outputs.each do |output|
            raise @context.validation_error(output, "Duplicate output name: #{output.name}") if seen_outputs.key?(output.name)

            seen_outputs[output.name] = true
          end
        end

        def validate_unique_paths!
          seen = {}

          (@context.runtime_nodes + @context.outputs).each do |node|
            raise @context.validation_error(node, "Duplicate node path: #{node.path}") if seen.key?(node.path)

            seen[node.path] = true
          end
        end
      end
    end
  end
end
