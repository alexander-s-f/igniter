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
