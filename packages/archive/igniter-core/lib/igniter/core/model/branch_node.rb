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

      def match_case(selector_value)
        cases.find { |entry| case_matches?(entry, selector_value) }
      end

      def case_payload(entry)
        return entry[:value] if entry[:matcher] == :eq

        entry[:value].inspect
      end

      def input_mapper?
        !input_mapper.nil?
      end

      private

      def normalize_case(entry)
        matcher = (entry[:matcher] || :eq).to_sym
        value = entry.key?(:value) ? entry[:value] : entry[:match]

        {
          matcher: matcher,
          value: normalize_case_value(matcher, value),
          contract: entry.fetch(:contract)
        }
      end

      def normalize_case_value(matcher, value)
        case matcher
        when :in
          Array(value).freeze
        else
          value
        end
      end

      def case_matches?(entry, selector_value)
        case entry[:matcher]
        when :eq
          entry[:value] == selector_value
        when :in
          entry[:value].include?(selector_value)
        when :matches
          entry[:value].match?(selector_value.to_s)
        else
          false
        end
      end
    end
  end
end
