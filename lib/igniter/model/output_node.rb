# frozen_string_literal: true

module Igniter
  module Model
    class OutputNode < Node
      attr_reader :source

      def initialize(id:, name:, source:, metadata: {})
        normalized_source = source.to_s

        super(
          id: id,
          kind: :output,
          name: name,
          path: "output.#{name}",
          dependencies: [normalized_source.split(".").first],
          metadata: metadata
        )
        @source = normalized_source.include?(".") ? normalized_source : normalized_source.to_sym
      end

      def source_root
        source.to_s.split(".").first.to_sym
      end

      def composition_output?
        source.to_s.include?(".")
      end

      def type
        metadata[:type]
      end

      def child_output_name
        return unless composition_output?

        source.to_s.split(".", 2).last.to_sym
      end
    end
  end
end
