# frozen_string_literal: true

require_relative "events/hook_support"
require_relative "events/envelope"
require_relative "events/log"
require_relative "events/projection_feed"
require_relative "events/read_model_projector"

module Igniter
  module Cluster
    module Events
      class << self
        attr_reader :store

        def configure
          yield self
        end

        def store=(store)
          @store = store
          @log = nil
        end

        def log_collection=(collection)
          @log_collection = collection.to_s
          @log = nil
        end

        def checkpoint_collection=(collection)
          @checkpoint_collection = collection.to_s
        end

        def log
          @log ||= build_log
        end

        def build_log(collection: nil)
          Log.new(
            store: ensure_store!,
            collection: collection || @log_collection || "igniter_cluster_events",
            before_publish: before_publish_hooks.dup,
            after_publish: after_publish_hooks.dup,
            around_publish: around_publish_hooks.dup
          )
        end

        def build_projection_feed(name:, projector:, log: self.log, store: nil, checkpoint_collection: nil)
          ProjectionFeed.new(
            name: name,
            log: log,
            projector: projector,
            store: store || ensure_store!,
            checkpoint_collection: checkpoint_collection || @checkpoint_collection || "igniter_cluster_projection_feed_checkpoints",
            before_process: before_process_hooks.dup,
            after_process: after_process_hooks.dup,
            around_process: around_process_hooks.dup
          )
        end

        def before_publish(callable = nil, &block)
          before_publish_hooks << (callable || block)
        end

        def after_publish(callable = nil, &block)
          after_publish_hooks << (callable || block)
        end

        def around_publish(callable = nil, &block)
          around_publish_hooks << (callable || block)
        end

        def before_process(callable = nil, &block)
          before_process_hooks << (callable || block)
        end

        def after_process(callable = nil, &block)
          after_process_hooks << (callable || block)
        end

        def around_process(callable = nil, &block)
          around_process_hooks << (callable || block)
        end

        def reset!
          @store = nil
          @log = nil
          @log_collection = nil
          @checkpoint_collection = nil
          @before_publish_hooks = []
          @after_publish_hooks = []
          @around_publish_hooks = []
          @before_process_hooks = []
          @after_process_hooks = []
          @around_process_hooks = []
        end

        private

        def ensure_store!
          return @store unless @store.nil?

          raise ArgumentError, "Igniter::Cluster::Events.store is not configured"
        end

        def before_publish_hooks
          @before_publish_hooks ||= []
        end

        def after_publish_hooks
          @after_publish_hooks ||= []
        end

        def around_publish_hooks
          @around_publish_hooks ||= []
        end

        def before_process_hooks
          @before_process_hooks ||= []
        end

        def after_process_hooks
          @after_process_hooks ||= []
        end

        def around_process_hooks
          @around_process_hooks ||= []
        end
      end
    end
  end
end
