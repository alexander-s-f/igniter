# frozen_string_literal: true

module Igniter
  module Contracts
    class Kernel
      attr_reader :nodes,
                  :dsl_keywords,
                  :validators,
                  :normalizers,
                  :runtime_handlers,
                  :diagnostics_contributors,
                  :effects,
                  :executors

      def initialize(
        nodes: Registry.new(name: :nodes),
        dsl_keywords: Registry.new(name: :dsl_keywords),
        validators: OrderedRegistry.new(name: :validators),
        normalizers: OrderedRegistry.new(name: :normalizers),
        runtime_handlers: Registry.new(name: :runtime_handlers),
        diagnostics_contributors: OrderedRegistry.new(name: :diagnostics_contributors),
        effects: Registry.new(name: :effects),
        executors: Registry.new(name: :executors)
      )
        @nodes = nodes
        @dsl_keywords = dsl_keywords
        @validators = validators
        @normalizers = normalizers
        @runtime_handlers = runtime_handlers
        @diagnostics_contributors = diagnostics_contributors
        @effects = effects
        @executors = executors
        @finalized = false
      end

      def install(pack)
        raise FrozenKernelError, "kernel already finalized" if finalized?

        pack.install_into(self)
        self
      end

      def finalize
        validate_completeness!
        freeze_registries!
        @finalized = true
        Profile.build_from(self)
      end

      def finalized?
        @finalized
      end

      private

      def validate_completeness!
        missing_dsl = nodes.to_h.values.select(&:requires_dsl?).map(&:kind).reject { |kind| dsl_keywords.registered?(kind) }
        missing_runtime = nodes.to_h.values.select(&:requires_runtime?).map(&:kind).reject { |kind| runtime_handlers.registered?(kind) }
        return if missing_dsl.empty? && missing_runtime.empty?

        parts = []
        parts << "missing DSL keywords for: #{missing_dsl.map(&:to_s).join(', ')}" unless missing_dsl.empty?
        parts << "missing runtime handlers for: #{missing_runtime.map(&:to_s).join(', ')}" unless missing_runtime.empty?

        raise IncompletePackError, parts.join("; ")
      end

      def freeze_registries!
        [
          nodes,
          dsl_keywords,
          validators,
          normalizers,
          runtime_handlers,
          diagnostics_contributors,
          effects,
          executors
        ].each(&:freeze!)
      end
    end
  end
end
