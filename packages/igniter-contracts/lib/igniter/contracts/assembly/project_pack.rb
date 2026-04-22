# frozen_string_literal: true

module Igniter
  module Contracts
    module Assembly
      module ProjectPack
        module_function

        def manifest
          PackManifest.new(
            name: :project,
            node_contracts: [PackManifest.node(:project)],
            registry_contracts: [PackManifest.validator(:project_sources)]
          )
        end

        def install_into(kernel)
          kernel.nodes.register(:project, NodeType.new(kind: :project, metadata: { category: :data }))
          kernel.dsl_keywords.register(:project, DslKeyword.new(:project) do |name, from:, key:, builder:|
            builder.add_operation(kind: :project, name: name, from: from.to_sym, key: key.to_sym)
          end)
          kernel.validators.register(:project_sources, Execution::ProjectValidators.method(:validate_project_sources))
          kernel.runtime_handlers.register(:project, Execution::ProjectRuntime.method(:handle_project))
          kernel
        end
      end
    end
  end
end
