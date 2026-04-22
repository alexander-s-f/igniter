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
                  :pack_manifests,
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
        @pack_manifests = []
        @effects = effects
        @executors = executors
        @finalized = false
      end

      def install(pack)
        raise FrozenKernelError, "kernel already finalized" if finalized?

        register_pack_manifest(pack)
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

      def register_pack_manifest(pack)
        return unless pack.respond_to?(:manifest)

        pack_manifests << pack.manifest
      end

      def validate_completeness!
        manifest_contracts = pack_manifests.flat_map(&:node_contracts)
        undeclared_contracts = nodes.to_h.values.reject { |node| manifest_contracts.any? { |contract| contract.kind == node.kind } }
                                    .map do |node|
          PackManifest.node(
            node.kind,
            requires_dsl: node.requires_dsl?,
            requires_runtime: node.requires_runtime?
          )
        end
        contracts = manifest_contracts + undeclared_contracts

        missing_node_definitions = manifest_contracts.map(&:kind).reject { |kind| nodes.registered?(kind) }
        missing_dsl = contracts.select(&:requires_dsl).map(&:kind).reject { |kind| dsl_keywords.registered?(kind) }
        missing_runtime = contracts.select(&:requires_runtime).map(&:kind).reject { |kind| runtime_handlers.registered?(kind) }
        return if missing_node_definitions.empty? && missing_dsl.empty? && missing_runtime.empty?

        parts = []
        parts << "missing node definitions for: #{missing_node_definitions.map(&:to_s).join(', ')}" unless missing_node_definitions.empty?
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
