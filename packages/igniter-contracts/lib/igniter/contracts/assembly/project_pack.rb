# frozen_string_literal: true

module Igniter
  module Contracts
    module Assembly
      module ProjectPack
        module_function

        def manifest
          PackManifest.new(
            name: :project,
            registry_contracts: [PackManifest.dsl_keyword(:project)]
          )
        end

        def install_into(kernel)
          kernel.dsl_keywords.register(:project, DslKeyword.new(:project) do |name, from:, key:, builder:|
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
                else
                  raise KeyError, "project key #{key_name} not present in #{source_name}"
                end
              end
            )
          end)
          kernel
        end
      end
    end
  end
end
