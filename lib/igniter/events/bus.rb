# frozen_string_literal: true

require "securerandom"

module Igniter
  module Events
    class Bus
      attr_reader :execution_id, :events

      def initialize(execution_id: SecureRandom.uuid)
        @execution_id = execution_id
        @events = []
        @subscribers = []
      end

      def emit(type, node: nil, status: nil, payload: {})
        event = Event.new(
          event_id: SecureRandom.uuid,
          type: type,
          execution_id: execution_id,
          node_id: node&.id,
          node_name: node&.name,
          path: node&.path,
          status: status,
          payload: payload,
          timestamp: Time.now.utc
        )

        @events << event
        @subscribers.each { |subscriber| subscriber.call(event) }
        event
      end

      def subscribe(subscriber = nil, &block)
        @subscribers << (subscriber || block)
      end
    end
  end
end
