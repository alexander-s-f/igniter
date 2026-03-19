# frozen_string_literal: true

module Igniter
  module Model
    class CollectionNode < Node
      attr_reader :source_dependency, :contract_class, :key_name, :mode

      def initialize(id:, name:, source_dependency:, contract_class:, key_name:, mode:, path: nil, metadata: {})
        super(
          id: id,
          kind: :collection,
          name: name,
          path: (path || name),
          dependencies: [source_dependency],
          metadata: metadata
        )

        @source_dependency = source_dependency.to_sym
        @contract_class = contract_class
        @key_name = key_name.to_sym
        @mode = mode.to_sym
      end
    end
  end
end
