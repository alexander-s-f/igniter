# frozen_string_literal: true

require "securerandom"
require "set"

module Igniter
  module Store
    # Thin wrapper returned from read paths when a schema coercion is registered.
    # Delegates identity fields to the underlying fact; exposes the coerced value.
    CoercedFact = Struct.new(:fact, :value) do
      def key            = fact.key
      def id             = fact.id
      def timestamp      = fact.timestamp
      def schema_version = fact.schema_version
      def causation      = fact.causation
      def value_hash     = fact.value_hash
      def store          = fact.store
    end

    class IgniterStore
      attr_reader :schema_graph

      def initialize(backend: nil, lru_cap: ReadCache::DEFAULT_LRU_CAP)
        @backend      = backend
        @log          = FactLog.new
        @cache        = ReadCache.new(lru_cap: lru_cap)
        @schema_graph = SchemaGraph.new
        # Materialized scope index: { [store, scope] => Set<key> }
        # Populated lazily on first query; maintained on every write thereafter.
        # Time-travel queries (as_of: non-nil) bypass the index.
        @scope_index  = {}
        @scope_mutex  = Mutex.new
        # Partition index: { [store, partition_key] => { partition_value => [fact, ...] } }
        # Populated lazily on first history_partition call; maintained on every append thereafter.
        # as_of/since filtering is applied at read time over the pre-grouped slice.
        @partition_index = {}
        @partition_mutex = Mutex.new
        # Schema coercion hooks: { store_name => callable(value, schema_version) }
        # Applied on every read path; raw facts remain immutable in the log and cache.
        @coercions = {}
      end

      def self.open(path, lru_cap: ReadCache::DEFAULT_LRU_CAP)
        backend = FileBackend.new(path)
        store = new(backend: backend, lru_cap: lru_cap)
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

      # Register a schema migration hook for +store_name+.
      # The block receives (value, schema_version) and must return the migrated value.
      # Applied on every read (point reads, scope queries, history); raw facts are
      # never mutated — coercion is a read-path transform only.
      def register_coercion(store_name, &block)
        @coercions[store_name] = block
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
        scope_changes = update_scope_indices(store, key, value)
        @cache.invalidate(store: store, key: key, scope_changes: scope_changes)
        fact
      end

      def append(history:, event:, schema_version: 1, term: 0, partition_key: nil)
        fact = Fact.build(
          store: history,
          key: SecureRandom.uuid,
          value: event,
          schema_version: schema_version,
          term: term
        )
        @log.append(fact)
        @backend&.write_fact(fact)
        if partition_key && (pv = event[partition_key])
          idx_key = [history, partition_key]
          @partition_mutex.synchronize do
            if @partition_index.key?(idx_key)
              (@partition_index[idx_key][pv] ||= []) << fact
            end
          end
        end
        fact
      end

      def read(store:, key:, as_of: nil, ttl: nil)
        cached = @cache.get(store: store, key: key, as_of: as_of, ttl: ttl)
        return coerce_value(store, cached) if cached

        fact = @log.latest_for(store: store, key: key, as_of: as_of)
        return nil unless fact

        @cache.put(store: store, key: key, fact: fact, as_of: as_of)
        coerce_value(store, fact)
      end

      def time_travel(store:, key:, at:)
        read(store: store, key: key, as_of: at)
      end

      def query(store:, scope:, as_of: nil, ttl: nil)
        path = @schema_graph.path_for(store: store, scope: scope)
        raise ArgumentError, "No registered path for store=#{store.inspect} scope=#{scope.inspect}" unless path

        effective_ttl = ttl || path.cache_ttl
        cached = @cache.get_scope(store: store, scope: scope, as_of: as_of, ttl: effective_ttl)
        return apply_coercions(store, cached) if cached

        filters = path.filters || {}
        facts = if as_of
          # Time-travel: bypass scope index — the index reflects current state only.
          @log.query_scope(store: store, filters: filters, as_of: as_of)
        else
          scope_key = [store, scope]
          idx = @scope_mutex.synchronize { @scope_index[scope_key] }
          if idx
            # Index is warm: O(matched_keys) read instead of O(all_keys) scan.
            idx.filter_map { |k| @log.latest_for(store: store, key: k) }
          else
            # First query for this scope: full scan + build index.
            all_facts = @log.query_scope(store: store, filters: filters, as_of: nil)
            @scope_mutex.synchronize do
              @scope_index[scope_key] ||= Set.new(all_facts.map(&:key))
            end
            all_facts
          end
        end

        @cache.put_scope(store: store, scope: scope, facts: facts, as_of: as_of)
        apply_coercions(store, facts)
      end

      def history(store:, key: nil, since: nil, as_of: nil)
        apply_coercions(store, @log.facts_for(store: store, key: key, since: since, as_of: as_of))
      end

      # Partition-filtered history query backed by a materialized index.
      # First call for a (store, partition_key) pair performs a full scan and
      # builds the index; subsequent calls are O(partition slice).
      # as_of/since filtering is applied over the cached slice at read time.
      def history_partition(store:, partition_key:, partition_value:, since: nil, as_of: nil)
        idx_key = [store, partition_key]
        @partition_mutex.synchronize do
          unless @partition_index.key?(idx_key)
            all_facts = @log.facts_for(store: store)
            groups    = Hash.new { |h, k| h[k] = [] }
            all_facts.each do |f|
              pv = f.value[partition_key]
              groups[pv] << f if pv
            end
            @partition_index[idx_key] = groups
          end

          slice = (@partition_index[idx_key][partition_value] || []).dup
          slice = slice.select { |f| f.timestamp >= since } if since
          slice = slice.select { |f| f.timestamp <= as_of } if as_of
          apply_coercions(store, slice)
        end
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

      private

      # Updates the materialized scope index for all scopes registered on +store+.
      # Returns a Hash of { scope_name => :changed | :unchanged | :unknown } so that
      # ReadCache can suppress consumer notifications for scopes whose membership
      # did not change.
      #
      # :unknown means the index was not yet initialised (no query has run for that
      # scope). ReadCache treats :unknown conservatively — it still notifies.
      def update_scope_indices(store, key, new_value)
        changes = {}
        # Multiple paths may share the same [store, scope] key (e.g. when on_scope
        # adds a consumer path alongside the register path).  Process each scope
        # exactly once — the shared Set must not be evaluated twice per write.
        seen_scopes = Set.new
        @schema_graph.paths_for(store).each do |path|
          next unless path.scope
          next unless seen_scopes.add?(path.scope)

          scope_key = [store, path.scope]
          filters   = path.filters || {}
          now_in    = matches_filters?(new_value, filters)

          @scope_mutex.synchronize do
            idx = @scope_index[scope_key]
            if idx.nil?
              changes[path.scope] = :unknown
            else
              was_in = idx.include?(key)
              if now_in && !was_in
                idx.add(key)
                changes[path.scope] = :changed
              elsif !now_in && was_in
                idx.delete(key)
                changes[path.scope] = :changed
              else
                changes[path.scope] = :unchanged
              end
            end
          end
        end
        changes
      end

      def matches_filters?(value, filters)
        return false unless value.is_a?(Hash)
        filters.all? { |k, v| value[k] == v }
      end

      # Returns the coerced value for a single fact point-read.
      def coerce_value(store, fact)
        coercion = @coercions[store]
        return fact.value unless coercion

        coercion.call(fact.value, fact.schema_version)
      end

      # Wraps each fact in a CoercedFact when a coercion is registered for +store+.
      # Returns the original array unchanged when no coercion is registered (preserves
      # object identity for TTL cache equality checks).
      def apply_coercions(store, facts)
        coercion = @coercions[store]
        return facts unless coercion

        facts.map do |f|
          original = f.value
          coerced  = coercion.call(original, f.schema_version)
          coerced.equal?(original) ? f : CoercedFact.new(f, coerced)
        end
      end
    end
  end
end
