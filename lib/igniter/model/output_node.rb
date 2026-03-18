# frozen_string_literal: true

module Igniter
  module Model
    class OutputNode < Node
      attr_reader :source

      def initialize(id:, name:, source:, metadata: {})
        super(
          id: id,
          kind: :output,
          name: name,
          path: "output.#{name}",
          dependencies: [source],
          metadata: metadata
        )
        @source = source.to_sym
      end
    end
  end
end
