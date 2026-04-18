# frozen_string_literal: true

module Igniter
  module Model
    class Graph
      attr_reader :name, :nodes, :metadata

      def initialize(name:, nodes:, metadata: {})
        @name = name
        @nodes = nodes.freeze
        @metadata = metadata.freeze
      end
    end
  end
end
