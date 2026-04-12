# frozen_string_literal: true

module Igniter
  module Model
    class Node
      attr_reader :id, :kind, :name, :path, :dependencies, :metadata

      def initialize(id:, kind:, name:, path:, dependencies: [], metadata: {})
        @id = id
        @kind = kind
        @name = name.to_sym
        @path = path.to_s
        @dependencies = dependencies.map(&:to_sym).freeze
        @metadata = metadata.freeze
      end

      def source_location
        metadata[:source_location]
      end
    end
  end
end
