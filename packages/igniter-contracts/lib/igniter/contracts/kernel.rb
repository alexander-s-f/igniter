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
        freeze_registries!
        @finalized = true
        Profile.build_from(self)
      end

      def finalized?
        @finalized
      end

      private

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
