# frozen_string_literal: true

module Igniter
  module Model
    class BranchNode < Node
      attr_reader :selector_dependency, :cases, :default_contract, :input_mapping, :context_dependencies, :input_mapper

      def initialize(id:, name:, selector_dependency:, cases:, default_contract:, input_mapping:, context_dependencies: [], input_mapper: nil, path: nil, metadata: {})
        dependencies = ([selector_dependency] + input_mapping.values + context_dependencies).uniq

        super(
          id: id,
          kind: :branch,
          name: name,
          path: (path || name),
          dependencies: dependencies,
          metadata: metadata
        )

        @selector_dependency = selector_dependency.to_sym
        @cases = cases.map { |entry| normalize_case(entry) }.freeze
        @default_contract = default_contract
        @input_mapping = input_mapping.transform_keys(&:to_sym).transform_values(&:to_sym).freeze
        @context_dependencies = Array(context_dependencies).map(&:to_sym).freeze
        @input_mapper = input_mapper
      end

      def possible_contracts
        (cases.map { |entry| entry[:contract] } + [default_contract]).uniq
      end

      def input_mapper?
        !input_mapper.nil?
      end

      private

      def normalize_case(entry)
        {
          match: entry.fetch(:match),
          contract: entry.fetch(:contract)
        }
      end
    end
  end
end
