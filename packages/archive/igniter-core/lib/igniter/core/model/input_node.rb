# frozen_string_literal: true

module Igniter
  module Model
    class InputNode < Node
      def initialize(id:, name:, path: nil, metadata: {})
        super(id: id, kind: :input, name: name, path: (path || name), metadata: metadata)
      end

      def type
        metadata[:type]
      end

      def required?
        metadata.fetch(:required, !metadata.key?(:default))
      end

      def default?
        metadata.key?(:default)
      end

      def default
        metadata[:default]
      end
    end
  end
end
