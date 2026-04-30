# frozen_string_literal: true

require "securerandom"

module Igniter
  module Store
    class IgniterStore
      attr_reader :schema_graph

      def initialize(backend: nil)
        @backend = backend
        @log = FactLog.new(backend: backend)
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
        path.consumers.to_a.each { |consumer| @cache.register_consumer(path.store, consumer) }
        self
      end

      def write(store:, key:, value:, schema_version: 1, term: 0)
        previous = @log.latest_for(store: store, key: key)
        fact = Fact.build(
          store: store,
          key: key,
          value: value,
          causation: previous&.value_hash,
          schema_version: schema_version,
          term: term
        )
        @log.append(fact)
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

      def history(store:, key: nil, since: nil, as_of: nil)
        @log.facts_for(store: store, key: key, since: since, as_of: as_of)
      end

      def causation_chain(store:, key:)
        history(store: store, key: key).map do |fact|
          {
            value_hash: fact.value_hash[0, 12],
            causation: fact.causation&.then { |value| value[0, 12] },
            timestamp: fact.timestamp
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
