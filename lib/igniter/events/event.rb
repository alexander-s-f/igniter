# frozen_string_literal: true

require "time"

module Igniter
  module Events
    Event = Struct.new(
      :event_id,
      :type,
      :execution_id,
      :node_id,
      :node_name,
      :path,
      :status,
      :payload,
      :timestamp,
      keyword_init: true
    ) do
      def self.from_h(data)
        new(
          event_id: value_from(data, :event_id),
          type: value_from(data, :type).to_sym,
          execution_id: value_from(data, :execution_id),
          node_id: value_from(data, :node_id),
          node_name: value_from(data, :node_name)&.to_sym,
          path: value_from(data, :path),
          status: value_from(data, :status)&.to_sym,
          payload: value_from(data, :payload) || {},
          timestamp: parse_timestamp(value_from(data, :timestamp))
        )
      end

      def to_h
        {
          event_id: event_id,
          type: type,
          execution_id: execution_id,
          node_id: node_id,
          node_name: node_name,
          path: path,
          status: status,
          payload: payload,
          timestamp: timestamp
        }
      end

      def as_json(*)
        to_h.transform_values { |value| serialize_value(value) }
      end

      private

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

      def self.value_from(data, key)
        data[key] || data[key.to_s]
      end

      def serialize_value(value)
        case value
        when Time
          value.iso8601
        when Hash
          value.each_with_object({}) { |(key, nested_value), memo| memo[key] = serialize_value(nested_value) }
        when Array
          value.map { |item| serialize_value(item) }
        else
          value
        end
      end
    end
  end
end
