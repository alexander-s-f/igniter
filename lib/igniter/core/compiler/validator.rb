# frozen_string_literal: true

module Igniter
  module Compiler
    class Validator
      def self.call(graph)
        new(graph).call
      end

      def initialize(graph)
        @graph = graph
      end

      def call
        ValidationPipeline.call(ValidationContext.new(@graph))
      end
    end
  end
end
