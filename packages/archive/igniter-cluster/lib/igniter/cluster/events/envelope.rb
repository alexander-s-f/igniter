# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  module Cluster
    module Events
      Envelope = Struct.new(
        :event_id,
        :topic,
        :type,
        :source,
        :entity_type,
        :entity_id,
        :payload,
        :metadata,
        :timestamp,
        keyword_init: true
      ) do
        def self.build(type:, source:, topic: nil, entity_type: nil, entity_id: nil, payload: {}, metadata: {}, timestamp: nil, event_id: nil)
          new(
            event_id: event_id || SecureRandom.uuid,
            topic: normalize_topic(topic || type),
            type: type.to_s,
            source: source.to_s,
            entity_type: entity_type&.to_s,
            entity_id: entity_id&.to_s,
            payload: stringify_keys(payload),
            metadata: stringify_keys(metadata),
            timestamp: timestamp || Time.now.utc
          )
        end

        def self.from_h(data)
          build(
            event_id: value_from(data, :event_id),
            topic: value_from(data, :topic),
            type: value_from(data, :type),
            source: value_from(data, :source),
            entity_type: value_from(data, :entity_type),
            entity_id: value_from(data, :entity_id),
            payload: value_from(data, :payload) || {},
            metadata: value_from(data, :metadata) || {},
            timestamp: parse_timestamp(value_from(data, :timestamp))
          )
        end

        def self.from_runtime_event(event, source:, topic: "runtime", metadata: {})
          build(
            type: event.type,
            topic: topic,
            source: source,
            entity_type: "execution",
            entity_id: event.execution_id,
            payload: event.as_json,
            metadata: metadata
          )
        end

        def to_h
          {
            event_id: event_id,
            topic: topic,
            type: type,
            source: source,
            entity_type: entity_type,
            entity_id: entity_id,
            payload: payload,
            metadata: metadata,
            timestamp: timestamp
          }
        end

        def as_json(*)
          serialize_value(to_h)
        end

        private

        def self.value_from(data, key)
          data[key] || data[key.to_s]
        end

        def self.normalize_topic(value)
          value.to_s.strip
        end

        def self.parse_timestamp(value)
          case value
          when Time
            value
          when String
            Time.iso8601(value)
          else
            value
          end
        end

        def self.stringify_keys(hash)
          hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_s] = stringify_nested(value)
          end
        end

        def self.stringify_nested(value)
          case value
          when Hash
            stringify_keys(value)
          when Array
            value.map { |item| stringify_nested(item) }
          when Symbol
            value.to_s
          else
            value
          end
        end

        def serialize_value(value)
          case value
          when Time
            value.iso8601
          when Hash
            value.each_with_object({}) { |(key, nested), memo| memo[key] = serialize_value(nested) }
          when Array
            value.map { |item| serialize_value(item) }
          when Symbol
            value.to_s
          else
            value
          end
        end
      end
    end
  end
end
