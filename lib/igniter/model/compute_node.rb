# frozen_string_literal: true

module Igniter
  module Model
    class ComputeNode < Node
      attr_reader :callable

      def initialize(id:, name:, dependencies:, callable:, metadata: {})
        super(
          id: id,
          kind: :compute,
          name: name,
          path: name,
          dependencies: dependencies,
          metadata: metadata
        )
        @callable = callable
      end
    end
  end
end
