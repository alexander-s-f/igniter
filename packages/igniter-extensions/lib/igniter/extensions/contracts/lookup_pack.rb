# frozen_string_literal: true

module Igniter
  module Extensions
    module Contracts
      module LookupPack
        module_function

        NO_FALLBACK = Object.new.freeze

        LOOKUP_VALIDATORS = Module.new do
          module_function

          def validate_lookup_sources(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
            available = operations.reject(&:output?).map(&:name)
            missing = operations.select { |operation| operation.kind == :lookup }
                              .map { |operation| operation.attributes.fetch(:from).to_sym }
                              .reject { |name| available.include?(name) }
                              .uniq
            return [] if missing.empty?

            [Igniter::Contracts::ValidationFinding.new(
              code: :missing_lookup_sources,
              message: "lookup sources are not defined: #{missing.map(&:to_s).join(', ')}",
              subjects: missing
            )]
          end
        end

        LOOKUP_RUNTIME = Module.new do
          module_function

          def handle_lookup(operation:, state:, **)
            source_name = operation.attributes.fetch(:from).to_sym
            key = operation.attributes.fetch(:key).to_sym
            source = state.fetch(source_name)

            return source.fetch(key) if source.respond_to?(:key?) && source.key?(key)
            return source.fetch(key.to_s) if source.respond_to?(:key?) && source.key?(key.to_s)
            return operation.attributes.fetch(:fallback) if operation.attribute?(:fallback)

            raise KeyError, "lookup key #{key} not present in #{source_name}"
          end
        end

        def manifest
          Igniter::Contracts::PackManifest.new(
            name: :extensions_lookup,
            node_contracts: [Igniter::Contracts::PackManifest.node(:lookup)],
            registry_contracts: [Igniter::Contracts::PackManifest.validator(:lookup_sources)]
          )
        end

        def install_into(kernel)
          kernel.nodes.register(:lookup, Igniter::Contracts::NodeType.new(kind: :lookup, metadata: { category: :data }))
          kernel.dsl_keywords.register(:lookup, lookup_keyword)
          kernel.validators.register(:lookup_sources, LOOKUP_VALIDATORS.method(:validate_lookup_sources))
          kernel.runtime_handlers.register(:lookup, LOOKUP_RUNTIME.method(:handle_lookup))
          kernel
        end

        def lookup_keyword
          Igniter::Contracts::DslKeyword.new(:lookup) do |name, from:, key:, fallback: NO_FALLBACK, builder:|
            attributes = {
              from: from.to_sym,
              key: key.to_sym
            }
            attributes[:fallback] = fallback unless fallback.equal?(NO_FALLBACK)

            builder.add_operation(kind: :lookup, name: name, **attributes)
          end
        end
      end
    end
  end
end
