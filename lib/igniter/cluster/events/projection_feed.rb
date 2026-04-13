# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Events
      class ProjectionFeed
        def initialize(name:, log:, projector:, store:, checkpoint_collection: "igniter_cluster_projection_feed_checkpoints")
          @name = name.to_s
          @log = log
          @projector = projector
          @store = store
          @checkpoint_collection = checkpoint_collection.to_s
        end

        def start!
          @log.subscribe { |event| process(event) }
          self
        end

        def replay!(topic: nil)
          checkpoint = checkpoint_data
          events = @log.since(
            timestamp: checkpoint && Time.iso8601(checkpoint.fetch("timestamp")),
            event_id: checkpoint && checkpoint.fetch("event_id"),
            topic: topic
          )
          events.each { |event| process(event) }
          events
        end

        def process(event)
          @projector.call(event)
          write_checkpoint(event)
          event
        end

        def checkpoint
          checkpoint_data&.dup
        end

        private

        def active_store
          @store.respond_to?(:call) ? @store.call : @store
        end

        def checkpoint_data
          active_store.get(collection: @checkpoint_collection, key: @name)
        end

        def write_checkpoint(event)
          active_store.put(
            collection: @checkpoint_collection,
            key: @name,
            value: {
              "name" => @name,
              "event_id" => event.event_id,
              "timestamp" => event.timestamp.iso8601,
              "topic" => event.topic,
              "updated_at" => Time.now.utc.iso8601
            }
          )
        end
      end
    end
  end
end
