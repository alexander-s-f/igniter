# frozen_string_literal: true

module Igniter
  module Contracts
    module HookSpecs
      module_function

      REGISTRY_SPECS = {
        dsl_keywords: HookSpec.new(
          registry: :dsl_keywords,
          method_name: :call,
          required_keywords: %i[builder]
        ),
        normalizers: HookSpec.new(
          registry: :normalizers,
          method_name: :call,
          required_keywords: %i[operations profile]
        ),
        validators: HookSpec.new(
          registry: :validators,
          method_name: :call,
          required_keywords: %i[operations profile]
        ),
        runtime_handlers: HookSpec.new(
          registry: :runtime_handlers,
          method_name: :call,
          required_keywords: %i[operation state outputs inputs profile]
        ),
        diagnostics_contributors: HookSpec.new(
          registry: :diagnostics_contributors,
          method_name: :augment,
          required_keywords: %i[report result profile]
        )
      }.freeze

      def fetch(registry_name)
        REGISTRY_SPECS.fetch(registry_name.to_sym)
      end

      def registry_names
        REGISTRY_SPECS.keys
      end
    end
  end
end
