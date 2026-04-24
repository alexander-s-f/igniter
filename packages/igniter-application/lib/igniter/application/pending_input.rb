# frozen_string_literal: true

module Igniter
  module Application
    class PendingInput
      attr_reader :name, :input_type, :required, :target, :schema, :metadata

      def initialize(name:, input_type: :text, required: true, target: nil, schema: {}, metadata: {})
        @name = name.to_sym
        @input_type = input_type.to_sym
        @required = required == true
        @target = target&.to_sym
        @schema = schema.dup.freeze
        @metadata = metadata.dup.freeze
        freeze
      end

      def self.from(value)
        return value if value.is_a?(self)

        new(**value)
      end

      def required?
        required
      end

      def to_h
        {
          name: name,
          input_type: input_type,
          required: required?,
          target: target,
          schema: schema.dup,
          metadata: metadata.dup
        }
      end
    end
  end
end
