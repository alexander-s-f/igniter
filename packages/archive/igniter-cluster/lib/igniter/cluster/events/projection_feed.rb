# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Events
      class ProjectionFeed
        include HookSupport

        def initialize(name:, log:, projector:, store:, checkpoint_collection: "igniter_cluster_projection_feed_checkpoints",
                       before_process: [], after_process: [], around_process: [])
          @name = name.to_s
          @log = log
          @projector = projector
          @store = store
          @checkpoint_collection = checkpoint_collection.to_s
          @before_process = before_process.dup
          @after_process = after_process.dup
          @around_process = around_process.dup
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
          context = { feed: self, event: event, name: @name }
          run_before_hooks(@before_process, context)
          result = run_around_hooks(@around_process, context) { project_and_checkpoint(event) }
          run_after_hooks(@after_process, context.merge(result: result))
          result
        end

        def checkpoint
          checkpoint_data&.dup
        end

        def before_process(callable = nil, &block)
          @before_process << (callable || block)
          self
        end

        def after_process(callable = nil, &block)
          @after_process << (callable || block)
          self
        end

        def around_process(callable = nil, &block)
          @around_process << (callable || block)
          self
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

        def project_and_checkpoint(event)
          @projector.call(event)
          write_checkpoint(event)
          event
        end
      end
    end
  end
end
