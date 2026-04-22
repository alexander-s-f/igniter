# frozen_string_literal: true

module Igniter
  module Extensions
    module Contracts
      module AggregatePack
        NODE_KINDS = %i[count sum avg].freeze

        class << self
          def manifest
            Igniter::Contracts::PackManifest.new(
              name: :extensions_aggregate,
              node_contracts: NODE_KINDS.map { |kind| Igniter::Contracts::PackManifest.node(kind) },
              registry_contracts: [Igniter::Contracts::PackManifest.validator(:aggregate_sources)]
            )
          end

          def install_into(kernel)
            install_nodes(kernel)
            install_dsl_keywords(kernel)
            install_validators(kernel)
            install_runtime_handlers(kernel)
            kernel
          end

          def install_nodes(kernel)
            NODE_KINDS.each do |kind|
              kernel.nodes.register(kind, Igniter::Contracts::NodeType.new(kind: kind, metadata: { category: :aggregate }))
            end
          end

          def install_dsl_keywords(kernel)
            kernel.dsl_keywords.register(:count, count_keyword)
            kernel.dsl_keywords.register(:sum, sum_keyword)
            kernel.dsl_keywords.register(:avg, avg_keyword)
          end

          def install_validators(kernel)
            kernel.validators.register(:aggregate_sources, method(:validate_aggregate_sources))
          end

          def install_runtime_handlers(kernel)
            kernel.runtime_handlers.register(:count, method(:handle_count))
            kernel.runtime_handlers.register(:sum, method(:handle_sum))
            kernel.runtime_handlers.register(:avg, method(:handle_avg))
          end

          def count_keyword
            Igniter::Contracts::DslKeyword.new(:count) do |name, from:, matching: nil, builder:|
              builder.add_operation(
                kind: :count,
                name: name,
                from: from.to_sym,
                matching: matching
              )
            end
          end

          def sum_keyword
            Igniter::Contracts::DslKeyword.new(:sum) do |name, from:, using: nil, builder:|
              builder.add_operation(
                kind: :sum,
                name: name,
                from: from.to_sym,
                using: using
              )
            end
          end

          def avg_keyword
            Igniter::Contracts::DslKeyword.new(:avg) do |name, from:, using: nil, builder:|
              builder.add_operation(
                kind: :avg,
                name: name,
                from: from.to_sym,
                using: using
              )
            end
          end

          def validate_aggregate_sources(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
            available = operations.reject(&:output?).map(&:name)
            missing = operations.select { |operation| NODE_KINDS.include?(operation.kind) }
                              .map { |operation| operation.attributes.fetch(:from).to_sym }
                              .reject { |name| available.include?(name) }
                              .uniq
            return [] if missing.empty?

            [Igniter::Contracts::ValidationFinding.new(
              code: :missing_aggregate_sources,
              message: "aggregate sources are not defined: #{missing.map(&:to_s).join(', ')}",
              subjects: missing
            )]
          end

          def handle_count(operation:, state:, **)
            items = enumerable_source(operation, state)
            predicate = operation.attributes[:matching]

            return items.count unless predicate

            items.count { |item| predicate.call(item) }
          end

          def handle_sum(operation:, state:, **)
            values = projected_values(operation, state)
            values.reduce(0) { |total, value| total + value }
          end

          def handle_avg(operation:, state:, **)
            values = projected_values(operation, state)
            return nil if values.empty?

            values.sum.to_f / values.length
          end

          def enumerable_source(operation, state)
            source_name = operation.attributes.fetch(:from).to_sym
            source = state.fetch(source_name)
            return source.to_a if source.respond_to?(:to_a)

            raise TypeError, "#{operation.kind} source #{source_name} is not enumerable"
          end

          def projected_values(operation, state)
            projection = operation.attributes[:using]

            enumerable_source(operation, state).map do |item|
              extract_value(item, projection)
            end
          end

          def extract_value(item, projection)
            return item if projection.nil?
            return projection.call(item) if projection.respond_to?(:call)

            key = projection.to_sym
            return item.fetch(key) if item.respond_to?(:key?) && item.key?(key)
            return item.fetch(key.to_s) if item.respond_to?(:key?) && item.key?(key.to_s)

            item.public_send(key)
          end
        end
      end
    end
  end
end
