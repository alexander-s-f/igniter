# frozen_string_literal: true

require_relative "envelope"

module Igniter
  module Cluster
    module Events
      class Log
        def initialize(store:, collection: "igniter_cluster_events")
          @store = store
          @collection = collection.to_s
          @subscribers = []
        end

        def publish(type: nil, source:, topic: nil, entity_type: nil, entity_id: nil, payload: {}, metadata: {}, envelope: nil)
          event = envelope || Envelope.build(
            type: type,
            source: source,
            topic: topic,
            entity_type: entity_type,
            entity_id: entity_id,
            payload: payload,
            metadata: metadata
          )

          active_store.put(collection: @collection, key: key_for(event), value: event.as_json)
          @subscribers.each { |subscriber| subscriber.call(event) }
          event
        end

        def publish_runtime_event(event, source:, topic: "runtime", metadata: {})
          publish(
            source: source,
            envelope: Envelope.from_runtime_event(event, source: source, topic: topic, metadata: metadata)
          )
        end

        def all(topic: nil)
          events = active_store.all(collection: @collection).values.map { |entry| Envelope.from_h(entry) }
          events = events.select { |event| event.topic == topic.to_s } if topic
          events.sort_by { |event| [event.timestamp.to_f, event.event_id] }
        end

        def since(timestamp: nil, event_id: nil, topic: nil)
          all(topic: topic).select do |event|
            newer_than_timestamp = timestamp.nil? || event.timestamp > timestamp
            same_timestamp_but_newer_id = !timestamp.nil? && event.timestamp == timestamp && event.event_id > event_id.to_s
            newer_than_timestamp || same_timestamp_but_newer_id
          end
        end

        def subscribe(subscriber = nil, &block)
          @subscribers << (subscriber || block)
        end

        private

        def active_store
          @store.respond_to?(:call) ? @store.call : @store
        end

        def key_for(event)
          "#{format_timestamp(event.timestamp)}-#{event.event_id}"
        end

        def format_timestamp(timestamp)
          seconds = timestamp.to_i
          micros = timestamp.usec
          format("%010d%06d", seconds, micros)
        end
      end
    end
  end
end
