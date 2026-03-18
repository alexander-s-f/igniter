# frozen_string_literal: true

module Igniter
  module Model
    class CompositionNode < Node
      attr_reader :contract_class, :input_mapping

      def initialize(id:, name:, contract_class:, input_mapping:, metadata: {})
        super(
          id: id,
          kind: :composition,
          name: name,
          path: name,
          dependencies: input_mapping.values,
          metadata: metadata
        )
        @contract_class = contract_class
        @input_mapping = input_mapping.transform_keys(&:to_sym).transform_values(&:to_sym).freeze
      end
    end
  end
end
