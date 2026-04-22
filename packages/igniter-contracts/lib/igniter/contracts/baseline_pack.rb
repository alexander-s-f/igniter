# frozen_string_literal: true

module Igniter
  module Contracts
    module BaselinePack
      module_function

      BASELINE_NODE_KINDS = {
        input: NodeType.new(kind: :input, metadata: { category: :data }),
        compute: NodeType.new(kind: :compute, metadata: { category: :data }),
        composition: NodeType.new(kind: :composition, metadata: { category: :structural }),
        branch: NodeType.new(kind: :branch, metadata: { category: :control_flow }),
        collection: NodeType.new(kind: :collection, metadata: { category: :control_flow }),
        output: NodeType.new(kind: :output, metadata: { category: :terminal })
      }.freeze

      BASELINE_DSL_KEYWORDS = {
        input: DslKeyword.new(:input, lambda { |name, builder:, **attributes|
          builder.add_operation(kind: :input, name: name, **attributes)
        }),
        compute: DslKeyword.new(:compute, lambda { |name, builder:, **attributes, &block|
          builder.add_operation(kind: :compute, name: name, **attributes.merge(callable: block))
        }),
        composition: DslKeyword.new(:composition, lambda { |name, builder:, **attributes|
          builder.add_operation(kind: :composition, name: name, **attributes)
        }),
        branch: DslKeyword.new(:branch, lambda { |name, builder:, **attributes|
          builder.add_operation(kind: :branch, name: name, **attributes)
        }),
        collection: DslKeyword.new(:collection, lambda { |name, builder:, **attributes|
          builder.add_operation(kind: :collection, name: name, **attributes)
        }),
        output: DslKeyword.new(:output, lambda { |name, builder:, **attributes|
          builder.add_operation(kind: :output, name: name, **attributes)
        })
      }.freeze

      BASELINE_DIAGNOSTICS = {
        baseline_summary: Module.new do
          module_function

          def augment(report:, result:, profile:) # rubocop:disable Lint/UnusedMethodArgument
            report.add_section(:baseline_summary, {
              outputs: result.outputs.keys.sort,
              state: result.state.keys.sort
            })
          end
        end
      }.freeze

      def install_into(kernel)
        install_nodes(kernel)
        install_dsl_keywords(kernel)
        install_normalizers(kernel)
        install_validators(kernel)
        install_runtime_handlers(kernel)
        install_diagnostics(kernel)
        kernel
      end

      def install_nodes(kernel)
        BASELINE_NODE_KINDS.each do |key, value|
          kernel.nodes.register(key, value)
        end
      end

      def install_dsl_keywords(kernel)
        BASELINE_DSL_KEYWORDS.each do |key, value|
          kernel.dsl_keywords.register(key, value)
        end
      end

      def install_normalizers(kernel)
        kernel.normalizers.register(:normalize_operation_attributes, BaselineNormalizers.method(:normalize_operation_attributes))
      end

      def install_validators(kernel)
        kernel.validators.register(:uniqueness, BaselineValidators.method(:validate_uniqueness))
        kernel.validators.register(:outputs, BaselineValidators.method(:validate_outputs))
        kernel.validators.register(:dependencies, BaselineValidators.method(:validate_dependencies))
        kernel.validators.register(:callables, BaselineValidators.method(:validate_callables))
        kernel.validators.register(:types, BaselineValidators.method(:validate_types))
        kernel.validators.register(:supported_baseline_runtime, BaselineValidators.method(:validate_supported_baseline_runtime))
      end

      def install_runtime_handlers(kernel)
        kernel.runtime_handlers.register(:input, BaselineRuntime.method(:handle_input))
        kernel.runtime_handlers.register(:compute, BaselineRuntime.method(:handle_compute))
        kernel.runtime_handlers.register(:output, BaselineRuntime.method(:handle_output))
        kernel.runtime_handlers.register(:composition, BaselineRuntime.unsupported(:composition))
        kernel.runtime_handlers.register(:branch, BaselineRuntime.unsupported(:branch))
        kernel.runtime_handlers.register(:collection, BaselineRuntime.unsupported(:collection))
      end

      def install_diagnostics(kernel)
        BASELINE_DIAGNOSTICS.each do |key, value|
          kernel.diagnostics_contributors.register(key, value)
        end
      end
    end
  end
end
