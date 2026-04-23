# frozen_string_literal: true

module Igniter
  module Extensions
    module Contracts
      module LookupPack
        module_function

        NO_FALLBACK = Object.new.freeze

        def manifest
          Igniter::Contracts::PackManifest.new(
            name: :extensions_lookup,
            registry_contracts: [Igniter::Contracts::PackManifest.dsl_keyword(:lookup)]
          )
        end

        def install_into(kernel)
          kernel.dsl_keywords.register(:lookup, lookup_keyword)
          kernel
        end

        def lookup_keyword
          Igniter::Contracts::DslKeyword.new(:lookup) do |name, from:, key:, fallback: NO_FALLBACK, builder:|
            source_name = from.to_sym
            key_name = key.to_sym

            builder.add_operation(
              kind: :compute,
              name: name,
              depends_on: [source_name],
              callable: lambda do |**values|
                source = values.fetch(source_name)

                if source.respond_to?(:key?) && source.key?(key_name)
                  source.fetch(key_name)
                elsif source.respond_to?(:key?) && source.key?(key_name.to_s)
                  source.fetch(key_name.to_s)
                elsif !fallback.equal?(NO_FALLBACK)
                  fallback
                else
                  raise KeyError, "lookup key #{key_name} not present in #{source_name}"
                end
              end
            )
          end
        end
      end
    end
  end
end
