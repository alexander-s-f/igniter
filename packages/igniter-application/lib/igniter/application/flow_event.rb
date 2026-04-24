# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  module Application
    class FlowEvent
      attr_reader :id, :session_id, :type, :source, :target, :payload, :timestamp, :metadata

      def initialize(type:, session_id:, source: :system, target: nil, payload: {}, id: nil,
                     timestamp: Time.now.utc, metadata: {})
        @id = (id || SecureRandom.uuid).to_s
        @session_id = session_id.to_s
        @type = type.to_sym
        @source = source.to_sym
        @target = target&.to_sym
        @payload = payload.dup.freeze
        @timestamp = timestamp.is_a?(String) ? Time.parse(timestamp).utc : timestamp.utc
        @metadata = metadata.dup.freeze
        freeze
      end

      def self.from(value, session_id:)
        return value if value.is_a?(self)

        new(**value.merge(session_id: value.fetch(:session_id, session_id)))
      end

      def to_h
        {
          id: id,
          session_id: session_id,
          type: type,
          source: source,
          target: target,
          payload: payload.dup,
          timestamp: timestamp.iso8601,
          metadata: metadata.dup
        }
      end
    end
  end
end
