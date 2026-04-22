# frozen_string_literal: true

module Igniter
  module Contracts
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
        kernel.validators.register(:project_sources, method(:validate_project_sources))
        kernel.runtime_handlers.register(:project, method(:handle_project))
        kernel
      end

      def validate_project_sources(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        available = operations.reject { |operation| operation.fetch(:kind) == :output }.map { |operation| operation.fetch(:name) }
        missing = operations.select { |operation| operation.fetch(:kind) == :project }
                            .map { |operation| operation.dig(:attributes, :from).to_sym }
                            .reject { |name| available.include?(name) }
                            .uniq
        return if missing.empty?

        raise ValidationError, "project sources are not defined: #{missing.map(&:to_s).join(', ')}"
      end

      def handle_project(operation:, state:, **)
        from = operation.dig(:attributes, :from).to_sym
        key = operation.dig(:attributes, :key).to_sym
        source = state.fetch(from)

        if source.respond_to?(:key?) && source.key?(key)
          source.fetch(key)
        elsif source.respond_to?(:key?) && source.key?(key.to_s)
          source.fetch(key.to_s)
        else
          raise KeyError, "project key #{key} not present in #{from}"
        end
      end
    end
  end
end
