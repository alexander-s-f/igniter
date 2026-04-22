# frozen_string_literal: true

module Igniter
  module Contracts
    module BaselinePack
      module_function

      BASELINE_NODE_KINDS = {
        input: :baseline_input_node,
        compute: :baseline_compute_node,
        composition: :baseline_composition_node,
        branch: :baseline_branch_node,
        collection: :baseline_collection_node,
        output: :baseline_output_node
      }.freeze

      BASELINE_DSL_KEYWORDS = {
        input: :baseline_input_keyword,
        compute: :baseline_compute_keyword,
        composition: :baseline_composition_keyword,
        branch: :baseline_branch_keyword,
        collection: :baseline_collection_keyword,
        output: :baseline_output_keyword
      }.freeze

      BASELINE_VALIDATORS = {
        uniqueness: :baseline_uniqueness_validator,
        outputs: :baseline_outputs_validator,
        dependencies: :baseline_dependencies_validator,
        callables: :baseline_callable_validator,
        types: :baseline_type_validator
      }.freeze

      BASELINE_RUNTIME_HANDLERS = {
        input: :baseline_input_runtime_handler,
        compute: :baseline_compute_runtime_handler,
        composition: :baseline_composition_runtime_handler,
        branch: :baseline_branch_runtime_handler,
        collection: :baseline_collection_runtime_handler,
        output: :baseline_output_runtime_handler
      }.freeze

      BASELINE_DIAGNOSTICS = {
        baseline_summary: :baseline_summary_diagnostics
      }.freeze

      def install_into(kernel)
        install_nodes(kernel)
        install_dsl_keywords(kernel)
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

      def install_validators(kernel)
        BASELINE_VALIDATORS.each do |key, value|
          kernel.validators.register(key, value)
        end
      end

      def install_runtime_handlers(kernel)
        BASELINE_RUNTIME_HANDLERS.each do |key, value|
          kernel.runtime_handlers.register(key, value)
        end
      end

      def install_diagnostics(kernel)
        BASELINE_DIAGNOSTICS.each do |key, value|
          kernel.diagnostics_contributors.register(key, value)
        end
      end
    end
  end
end
