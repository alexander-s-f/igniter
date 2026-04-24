# frozen_string_literal: true

module Igniter
  module Application
    class PendingAction
      attr_reader :name, :action_type, :target, :payload_schema, :metadata

      def initialize(name:, action_type: :command, target: nil, payload_schema: {}, metadata: {})
        @name = name.to_sym
        @action_type = action_type.to_sym
        @target = target&.to_s
        @payload_schema = payload_schema.dup.freeze
        @metadata = metadata.dup.freeze
        freeze
      end

      def self.from(value)
        return value if value.is_a?(self)

        new(**value)
      end

      def to_h
        {
          name: name,
          action_type: action_type,
          target: target,
          payload_schema: payload_schema.dup,
          metadata: metadata.dup
        }
      end
    end
  end
end
