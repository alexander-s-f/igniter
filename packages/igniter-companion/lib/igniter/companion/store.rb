# frozen_string_literal: true

require "igniter/store"

module Igniter
  module Companion
    # Application-level store that wraps Igniter::Store::IgniterStore.
    #
    # Provides typed read/write/scope/append/replay via Record and History schema classes.
    # Acts as the "user side" pressure on igniter-store primitives.
    #
    # Usage:
    #   store = Igniter::Companion::Store.new               # in-memory
    #   store = Igniter::Companion::Store.new(backend: :file, path: "/tmp/data.wal")
    #
    #   store.register(Reminder)
    #   store.write(Reminder, key: "r1", title: "Buy milk", status: :open)
    #   store.read(Reminder, key: "r1")
    #   store.scope(Reminder, :open)
    #   store.append(TrackerLog, tracker_id: "t1", value: 8.5)
    #   store.replay(TrackerLog)
    class Store
      def initialize(backend: :memory, path: nil)
        @inner = case backend
        when :memory then Igniter::Store::IgniterStore.new
        when :file   then Igniter::Store::IgniterStore.open(path)
        else raise ArgumentError, "Unknown backend: #{backend.inspect}. Use :memory or :file"
        end
      end

      # Register a Record schema — sets up AccessPaths for all declared scopes.
      # Must be called before any scope queries on this schema class.
      def register(schema_class)
        return self unless schema_class.respond_to?(:_scopes)

        schema_class._scopes.each do |scope_name, opts|
          @inner.register_path(
            Igniter::Store::AccessPath.new(
              store:     schema_class.store_name,
              lookup:    :primary_key,
              scope:     scope_name,
              filters:   opts[:filters],
              cache_ttl: opts[:cache_ttl],
              consumers: []
            )
          )
        end
        self
      end

      # Subscribe a callable to scope-level changes.
      # The callable receives (store_name, scope_name) when facts in the store change.
      def on_scope(schema_class, scope_name, &block)
        scope_opts = schema_class._scopes[scope_name] || {}
        @inner.register_path(
          Igniter::Store::AccessPath.new(
            store:     schema_class.store_name,
            lookup:    :primary_key,
            scope:     scope_name,
            filters:   scope_opts[:filters],
            cache_ttl: scope_opts[:cache_ttl],
            consumers: [block]
          )
        )
        self
      end

      # Write (upsert) a record. Returns a WriteReceipt wrapping the typed record.
      # Receipt delegates unknown methods to the record, so callers can use it
      # as if it were the record directly (e.g. receipt.title).
      def write(schema_class, key:, **fields)
        fact = @inner.write(store: schema_class.store_name, key: key, value: fields)
        record = schema_class.new(key: key, **fields)
        WriteReceipt.new(
          mutation_intent: :record_write,
          fact_id:         fact.id,
          value_hash:      fact.value_hash,
          causation:       fact.causation,
          key:             key,
          record:          record
        )
      end

      # Read the latest value for a key. Returns nil if not found.
      def read(schema_class, key:, as_of: nil)
        value = @inner.read(store: schema_class.store_name, key: key, as_of: as_of)
        return nil unless value

        schema_class.new(key: key, **value)
      end

      # Query all records matching a registered scope.
      def scope(schema_class, scope_name, as_of: nil)
        facts = @inner.query(store: schema_class.store_name, scope: scope_name, as_of: as_of)
        facts.map { |f| schema_class.from_fact(f) }
      end

      # Append an event to a History stream. Returns an AppendReceipt.
      # Receipt delegates unknown methods to the event (e.g. receipt.value).
      def append(history_class, **fields)
        pk    = history_class._partition_key
        fact  = @inner.append(history: history_class.store_name, event: fields, partition_key: pk)
        event = history_class.new(fact_id: fact.id, timestamp: fact.timestamp, **fields)
        AppendReceipt.new(
          mutation_intent: :history_append,
          fact_id:         fact.id,
          value_hash:      fact.value_hash,
          timestamp:       fact.timestamp,
          event:           event
        )
      end

      # Replay events from a History stream.
      # `partition:` filters by the declared partition_key value (e.g. tracker_id: "sleep").
      # `since:` / `as_of:` are timestamp boundaries.
      def replay(history_class, since: nil, as_of: nil, partition: nil)
        pk    = history_class._partition_key
        facts = if partition && pk
          @inner.history_partition(
            store:           history_class.store_name,
            partition_key:   pk,
            partition_value: partition,
            since:           since,
            as_of:           as_of
          )
        else
          @inner.history(store: history_class.store_name, since: since, as_of: as_of)
        end

        facts.map { |f| history_class.from_fact(f) }
      end

      # Causation chain for a Record key — useful for debugging mutations.
      def causation_chain(schema_class, key:)
        @inner.causation_chain(store: schema_class.store_name, key: key)
      end

      def close
        @inner.close
      end
    end
  end
end
