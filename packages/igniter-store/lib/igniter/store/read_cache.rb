# frozen_string_literal: true

require "monitor"

module Igniter
  module Store
    class ReadCache
      include MonitorMixin

      def initialize
        super()
        @entries = {}
        @consumers = Hash.new { |hash, key| hash[key] = [] }
      end

      def register_consumer(store, callable)
        synchronize { @consumers[store] << callable }
      end

      def get(store:, key:, as_of: nil, ttl: nil)
        entry = synchronize { @entries[[store, key, as_of]] }
        return nil unless entry

        if ttl
          age = Process.clock_gettime(Process::CLOCK_REALTIME) - entry.fetch(:cached_at)
          return nil if age > ttl
        end

        entry.fetch(:fact)
      end

      def put(store:, key:, fact:, as_of: nil)
        synchronize do
          @entries[[store, key, as_of]] = {
            fact: fact,
            cached_at: Process.clock_gettime(Process::CLOCK_REALTIME)
          }
        end
      end

      def invalidate(store:, key: nil)
        targets = synchronize do
          @entries.delete_if do |cache_key, _entry|
            cache_key[0] == store && (key.nil? || cache_key[1] == key)
          end
          @consumers[store].dup
        end

        targets.each { |target| notify(target, store, key) }
      end

      private

      def notify(target, store, key)
        target.call(store, key)
      rescue StandardError
        nil
      end
    end
  end
end
