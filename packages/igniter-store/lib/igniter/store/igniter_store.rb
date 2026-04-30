# frozen_string_literal: true

require "securerandom"

module Igniter
  module Store
    class IgniterStore
      attr_reader :schema_graph

      def initialize(backend: nil)
        @backend = backend
        # Native FactLog takes no backend arg — write_fact is called directly by IgniterStore.
        # Pure-Ruby FactLog also accepts `backend:` for backward compat (ignored when nil).
        @log = FactLog.new
        @cache = ReadCache.new
        @schema_graph = SchemaGraph.new
      end

      def self.open(path)
        backend = FileBackend.new(path)
        store = new(backend: backend)
        backend.replay.each { |fact| store.__send__(:replay, fact) }
        store
      end

      def register_path(path)
        @schema_graph.register(path)
        path.consumers.to_a.each do |consumer|
          if path.scope
            @cache.register_scope_consumer(path.store, path.scope, consumer)
          else
            @cache.register_consumer(path.store, consumer)
          end
        end
        self
      end

      def write(store:, key:, value:, schema_version: 1, term: 0)
        previous = @log.latest_for(store: store, key: key)
        fact = Fact.build(
          store: store,
          key: key,
          value: value,
          causation: previous&.id,
          schema_version: schema_version,
          term: term
        )
        @log.append(fact)
        @backend&.write_fact(fact)
        @cache.invalidate(store: store, key: key)
        fact
      end

      def append(history:, event:, schema_version: 1, term: 0)
        fact = Fact.build(
          store: history,
          key: SecureRandom.uuid,
          value: event,
          schema_version: schema_version,
          term: term
        )
        @log.append(fact)
        @backend&.write_fact(fact)
        fact
      end

      def read(store:, key:, as_of: nil, ttl: nil)
        cached = @cache.get(store: store, key: key, as_of: as_of, ttl: ttl)
        return cached.value if cached

        fact = @log.latest_for(store: store, key: key, as_of: as_of)
        return nil unless fact

        @cache.put(store: store, key: key, fact: fact, as_of: as_of)
        fact.value
      end

      def time_travel(store:, key:, at:)
        read(store: store, key: key, as_of: at)
      end

      def query(store:, scope:, as_of: nil, ttl: nil)
        path = @schema_graph.path_for(store: store, scope: scope)
        raise ArgumentError, "No registered path for store=#{store.inspect} scope=#{scope.inspect}" unless path

        effective_ttl = ttl || path.cache_ttl
        cached = @cache.get_scope(store: store, scope: scope, as_of: as_of, ttl: effective_ttl)
        return cached if cached

        filters = path.filters || {}
        facts = @log.query_scope(store: store, filters: filters, as_of: as_of)
        @cache.put_scope(store: store, scope: scope, facts: facts, as_of: as_of)
        facts
      end

      def history(store:, key: nil, since: nil, as_of: nil)
        @log.facts_for(store: store, key: key, since: since, as_of: as_of)
      end

      def causation_chain(store:, key:)
        history(store: store, key: key).map do |fact|
          {
            id:         fact.id,
            value_hash: fact.value_hash[0, 12],
            causation:  fact.causation,
            timestamp:  fact.timestamp
          }
        end
      end

      def fact_count
        @log.size
      end

      def close
        @backend&.close
      end

      protected

      def replay(fact)
        @log.replay(fact)
      end
    end
  end
end
