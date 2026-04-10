# frozen_string_literal: true

module Igniter
  module Model
    class CollectionNode < Node
      attr_reader :source_dependency, :contract_class, :key_name, :mode, :window, :context_dependencies, :input_mapper

      def initialize(id:, name:, source_dependency:, contract_class:, key_name:, mode:, window: nil, context_dependencies: [], input_mapper: nil, path: nil, metadata: {})
        super(
          id: id,
          kind: :collection,
          name: name,
          path: (path || name),
          dependencies: [source_dependency, *context_dependencies],
          metadata: metadata
        )

        @source_dependency = source_dependency.to_sym
        @contract_class = contract_class
        @key_name = key_name.to_sym
        @mode = mode.to_sym
        @window = window
        @context_dependencies = Array(context_dependencies).map(&:to_sym)
        @input_mapper = input_mapper
      end

      def input_mapper?
        !input_mapper.nil?
      end
    end
  end
end
