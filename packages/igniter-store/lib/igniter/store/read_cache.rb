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
        @scope_consumers = Hash.new { |hash, key| hash[key] = [] }
      end

      def register_consumer(store, callable)
        synchronize { @consumers[store] << callable }
      end

      def register_scope_consumer(store, scope, callable)
        synchronize { @scope_consumers[[store, scope]] << callable }
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

      def get_scope(store:, scope:, as_of: nil, ttl: nil)
        entry = synchronize { @entries[[:scope, store, scope, as_of]] }
        return nil unless entry

        if ttl
          age = Process.clock_gettime(Process::CLOCK_REALTIME) - entry.fetch(:cached_at)
          return nil if age > ttl
        end

        entry.fetch(:facts)
      end

      def put_scope(store:, scope:, facts:, as_of: nil)
        synchronize do
          @entries[[:scope, store, scope, as_of]] = {
            facts: facts,
            cached_at: Process.clock_gettime(Process::CLOCK_REALTIME)
          }
        end
      end

      # +scope_changes+ is a Hash of { scope_name => :changed | :unchanged | :unknown }
      # produced by IgniterStore#update_scope_indices.  Scope consumers are only
      # notified for scopes that are :changed or :unknown (conservative).  Scopes
      # marked :unchanged are skipped — their membership did not change and firing
      # their consumers would be a false-positive thundering herd.
      def invalidate(store:, key: nil, scope_changes: {})
        point_targets, scope_notifications = synchronize do
          affected_scopes = []
          @entries.delete_if do |cache_key, _entry|
            if cache_key[0] == :scope && cache_key[1] == store
              affected_scopes << cache_key[2]
              true
            else
              cache_key[0] == store && (key.nil? || cache_key[1] == key)
            end
          end

          # Scope-aware: suppress notifications for scopes whose membership is
          # confirmed unchanged.  All other scopes (changed or unknown) still fire.
          notify_scopes = affected_scopes.uniq.reject do |scope|
            scope_changes[scope] == :unchanged
          end

          scope_notifs = notify_scopes.map do |scope|
            [scope, @scope_consumers[[store, scope]].dup]
          end

          [@consumers[store].dup, scope_notifs]
        end

        point_targets.each { |t| notify(t, store, key) }
        scope_notifications.each do |scope, targets|
          targets.each { |t| notify_scope(t, store, scope) }
        end
      end

      private

      def notify(target, store, key)
        target.call(store, key)
      rescue StandardError
        nil
      end

      def notify_scope(target, store, scope)
        target.call(store, scope)
      rescue StandardError
        nil
      end
    end
  end
end
