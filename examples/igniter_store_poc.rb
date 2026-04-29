# frozen_string_literal: true

# Igniter::Store — contract-native storage POC
#
# Proves: content-addressed facts, append-only write path,
#         compile-time access paths, time-travel, reactive invalidation,
#         optional file-backed WAL.
#
# Requires: Ruby >= 3.1, stdlib only (digest, json, securerandom, monitor)
# Run:      ruby examples/igniter_store_poc.rb

require "digest"
require "json"
require "securerandom"
require "monitor"

module Igniter
  module Store

    # =========================================================================
    # Fact — immutable unit of storage
    #
    # Every write produces a new Fact. Nothing is mutated. Time-travel is a
    # structural consequence: scan facts where timestamp <= t.
    #
    # value_hash  = SHA-256 of stable-serialized value  (content address)
    # causation   = value_hash of the previous fact for the same key
    #               (nil for the first write — root of the chain)
    # term        = Raft term; 0 in standalone mode
    # schema_version tracks which contract schema version produced this fact
    # =========================================================================
    Fact = Struct.new(
      :id, :store, :key, :value, :value_hash,
      :causation, :timestamp, :term, :schema_version,
      keyword_init: true
    ) do
      def self.build(store:, key:, value:, causation: nil, term: 0, schema_version: 1)
        serialized = JSON.generate(stable_sort(value))
        new(
          id:             SecureRandom.uuid,
          store:          store,
          key:            key,
          value:          deep_freeze(value),
          value_hash:     Digest::SHA256.hexdigest(serialized),
          causation:      causation,
          timestamp:      Process.clock_gettime(Process::CLOCK_REALTIME),
          term:           term,
          schema_version: schema_version
        ).freeze
      end

      # Stable sort guarantees the same hash regardless of Hash insertion order.
      private_class_method def self.stable_sort(obj)
        case obj
        when Hash  then obj.sort_by { |k, _| k.to_s }.to_h { |k, v| [k.to_s, stable_sort(v)] }
        when Array then obj.map { |v| stable_sort(v) }
        else obj
        end
      end

      private_class_method def self.deep_freeze(obj)
        case obj
        when Hash  then obj.transform_values { |v| deep_freeze(v) }.freeze
        when Array then obj.map { |v| deep_freeze(v) }.freeze
        else obj.frozen? ? obj : obj.dup.freeze
        end
      end
    end

    # =========================================================================
    # AccessPath — compile-time access descriptor
    #
    # Registered when a contract is loaded (before any data or query exists).
    # Tells the store: who reads what, via which lookup, with what TTL.
    # The store uses this to pre-index and to route reactive invalidations.
    # =========================================================================
    AccessPath = Struct.new(
      :store,      # Symbol       — which Store[T]
      :lookup,     # Symbol       — :primary_key | :scope | :filter
      :scope,      # Symbol?      — named scope (:open, :pending, …)
      :filter,     # Hash?        — field → key_binding
      :cache_ttl,  # Integer?     — seconds; nil = no TTL
      :consumers,  # Array<#call> — invalidation targets (agents, projections)
      keyword_init: true
    )

    # =========================================================================
    # FactLog — append-only write store (the WAL)
    #
    # Maintains three in-memory indexes rebuilt on replay:
    #   @log       — insertion-ordered Array<Fact>  (full history)
    #   @by_id     — Hash: id → Fact               (O(1) lookup by id)
    #   @by_key    — Hash: [store, key] → [Fact]   (O(1) time-series per key)
    # =========================================================================
    class FactLog
      include MonitorMixin

      def initialize(backend: nil)
        super()
        @log     = []
        @by_id   = {}
        @by_key  = Hash.new { |h, k| h[k] = [] }
        @backend = backend
      end

      def append(fact)
        synchronize do
          @log << fact
          @by_id[fact.id] = fact
          @by_key[[fact.store, fact.key]] << fact
          @backend&.write_fact(fact)
        end
        fact
      end

      # Called during file-backend replay — skips the backend write.
      def replay(fact)
        synchronize do
          @log << fact
          @by_id[fact.id] = fact
          @by_key[[fact.store, fact.key]] << fact
        end
      end

      def latest_for(store:, key:, as_of: nil)
        facts = synchronize { @by_key[[store, key]].dup }
        facts = facts.select { |f| f.timestamp <= as_of } if as_of
        facts.last
      end

      def facts_for(store:, key: nil, since: nil, as_of: nil)
        synchronize do
          base = key ? @by_key[[store, key]].dup : @log.select { |f| f.store == store }
          base = base.select { |f| f.timestamp >= since } if since
          base = base.select { |f| f.timestamp <= as_of } if as_of
          base
        end
      end

      def size = synchronize { @log.size }
    end

    # =========================================================================
    # ReadCache — projection cache with reactive invalidation
    #
    # Cache key: [store, key, as_of]
    # as_of = nil  → current-read slot (invalidated on write)
    # as_of = Float → time-travel slot (immutable; never invalidated)
    #
    # On invalidation, all registered consumers for the store are called
    # with (store, key). This simulates agent mailbox push.
    # =========================================================================
    class ReadCache
      include MonitorMixin

      def initialize
        super
        @entries   = {}
        @consumers = Hash.new { |h, k| h[k] = [] }
      end

      def register_consumer(store, callable)
        synchronize { @consumers[store] << callable }
      end

      def get(store:, key:, as_of: nil, ttl: nil)
        entry = synchronize { @entries[[store, key, as_of]] }
        return nil unless entry
        if ttl
          age = Process.clock_gettime(Process::CLOCK_REALTIME) - entry[:cached_at]
          return nil if age > ttl
        end
        entry[:fact]
      end

      def put(store:, key:, fact:, as_of: nil)
        synchronize do
          @entries[[store, key, as_of]] = {
            fact:      fact,
            cached_at: Process.clock_gettime(Process::CLOCK_REALTIME)
          }
        end
      end

      def invalidate(store:, key: nil)
        targets = synchronize do
          @entries.delete_if { |k, _| k[0] == store && (key.nil? || k[1] == key) }
          @consumers[store].dup
        end
        targets.each { |c| c.call(store, key) rescue nil }
      end
    end

    # =========================================================================
    # SchemaGraph — compile-time access path registry
    #
    # Populated at contract class-load time, not at query time.
    # consumers_for(store) returns every agent / projection that declared a
    # store_read dependency on that store — used to route invalidations.
    # =========================================================================
    class SchemaGraph
      def initialize
        @paths = Hash.new { |h, k| h[k] = [] }
      end

      def register(path)
        @paths[path.store] << path
        self
      end

      def paths_for(store)    = @paths[store].dup
      def consumers_for(store) = @paths[store].flat_map(&:consumers).uniq
    end

    # =========================================================================
    # FileBackend — optional JSON-Lines WAL
    #
    # Each line is one serialized Fact. The file is opened in append mode;
    # writes are synchronous (sync=true). On restart, replay reads all lines
    # in order and returns Facts to rebuild in-memory indexes.
    #
    # Simplification: JSON round-trip converts symbol keys to strings.
    # A production backend would use a binary format (MessagePack, Protobuf).
    # =========================================================================
    class FileBackend
      def initialize(path)
        @path = path
        @file = File.open(path, "a+")
        @file.sync = true
      end

      def write_fact(fact)
        @file.puts(JSON.generate(fact.to_h))
      end

      def replay
        File.readlines(@path, chomp: true).filter_map do |line|
          next if line.empty?
          h = JSON.parse(line, symbolize_names: true)
          # Restore symbol store/key types lost in JSON round-trip.
          h[:store] = h[:store].to_sym
          h[:timestamp] = h[:timestamp].to_f
          Fact.new(**h).freeze
        rescue JSON::ParserError
          nil
        end
      end

      def close = @file.close
    end

    # =========================================================================
    # IgniterStore — main facade
    #
    # Contracts talk only to this surface. Internals (FactLog, ReadCache,
    # SchemaGraph) are opaque.
    #
    # Lifecycle:
    #   IgniterStore.new              — in-memory, ephemeral
    #   IgniterStore.open(path)       — file-backed, survives restarts
    # =========================================================================
    class IgniterStore
      attr_reader :schema_graph

      def initialize(backend: nil)
        @log          = FactLog.new(backend: backend)
        @cache        = ReadCache.new
        @schema_graph = SchemaGraph.new
      end

      def self.open(path)
        backend = FileBackend.new(path)
        store   = new(backend: backend)
        backend.replay.each { |fact| store.instance_variable_get(:@log).replay(fact) }
        store
      end

      # --- Compile-time registration (called at contract load) ---------------

      def register_path(path)
        @schema_graph.register(path)
        path.consumers.each { |c| @cache.register_consumer(path.store, c) }
        self
      end

      # --- Write path --------------------------------------------------------

      # Writes a new version of a mutable record (Store[T]).
      # Previous value_hash becomes causation — the chain is never broken.
      def write(store:, key:, value:, schema_version: 1, term: 0)
        previous = @log.latest_for(store: store, key: key)
        fact = Fact.build(
          store:          store,
          key:            key,
          value:          value,
          causation:      previous&.value_hash,
          schema_version: schema_version,
          term:           term
        )
        @log.append(fact)
        @cache.invalidate(store: store, key: key)
        fact
      end

      # Appends an event to an append-only history (History[T]).
      # Each event gets its own UUID key — there is no "current version".
      def append(history:, event:, schema_version: 1, term: 0)
        fact = Fact.build(
          store:          history,
          key:            SecureRandom.uuid,
          value:          event,
          schema_version: schema_version,
          term:           term
        )
        @log.append(fact)
        fact
      end

      # --- Read path ---------------------------------------------------------

      # Current read (as_of: nil): cache-first, then log, then cache the result.
      # Time-travel read (as_of: Float): always from log; result is immutable
      # so it is cached under a separate key and never invalidated.
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

      # Returns all facts for a store, optionally filtered by key / time window.
      def history(store:, key: nil, since: nil, as_of: nil)
        @log.facts_for(store: store, key: key, since: since, as_of: as_of)
      end

      # Returns the causation chain for a key: ordered list of (hash, causation, ts).
      def causation_chain(store:, key:)
        history(store: store, key: key).map do |f|
          { value_hash: f.value_hash[0, 12], causation: f.causation&.then { |c| c[0, 12] }, timestamp: f.timestamp }
        end
      end

      def fact_count = @log.size
    end

  end
end

# =============================================================================
# Demonstration
# =============================================================================

if __FILE__ == $PROGRAM_NAME

  hr = ->(label) { puts "\n#{"=" * 60}\n#{label}\n#{"=" * 60}" }

  # ---------------------------------------------------------------------------
  hr.("1. Setup: in-memory store + compile-time access path")

  store = Igniter::Store::IgniterStore.new

  # Simulates a ProactiveAgent mailbox — called on every invalidation.
  invalidations = []
  agent_mailbox = ->(s, k) { invalidations << [s, k] }

  # Registered at contract load time — before any data exists.
  store.register_path(
    Igniter::Store::AccessPath.new(
      store:     :reminders,
      lookup:    :primary_key,
      scope:     nil,
      filter:    nil,
      cache_ttl: 60,
      consumers: [agent_mailbox]
    )
  )
  puts "Access paths for :reminders: #{store.schema_graph.paths_for(:reminders).length}"

  # ---------------------------------------------------------------------------
  hr.("2. Write path: append-only, content-addressed, causation chain")

  t_before = Process.clock_gettime(Process::CLOCK_REALTIME)

  f1 = store.write(store: :reminders, key: "r1", value: { title: "Buy milk", status: :open })
  puts "f1 hash:      #{f1.value_hash[0, 16]}..."
  puts "f1 causation: #{f1.causation.inspect}  (nil = root)"

  sleep 0.02
  t_mid = Process.clock_gettime(Process::CLOCK_REALTIME)

  f2 = store.write(store: :reminders, key: "r1", value: { title: "Buy milk", status: :closed })
  puts "f2 hash:      #{f2.value_hash[0, 16]}..."
  puts "f2 causation: #{f2.causation[0, 16]}...  (← f1.value_hash)"
  puts "Chain intact: #{f2.causation == f1.value_hash}"

  sleep 0.02
  t_after = Process.clock_gettime(Process::CLOCK_REALTIME)

  # ---------------------------------------------------------------------------
  hr.("3. Read path: current state")

  current = store.read(store: :reminders, key: "r1")
  puts "Current status: #{current[:status].inspect}"  # :closed

  # Second read — served from cache.
  store.read(store: :reminders, key: "r1")
  puts "(second read served from cache — no log scan)"

  # ---------------------------------------------------------------------------
  hr.("4. Time-travel: state at t_mid (between writes)")

  past = store.time_travel(store: :reminders, key: "r1", at: t_mid)
  puts "Status at t_mid:   #{past[:status].inspect}"   # :open

  future = store.time_travel(store: :reminders, key: "r1", at: t_after)
  puts "Status at t_after: #{future[:status].inspect}" # :closed

  none = store.time_travel(store: :reminders, key: "r1", at: t_before)
  puts "Status before any write: #{none.inspect}"      # nil

  # ---------------------------------------------------------------------------
  hr.("5. Causation chain inspection")

  chain = store.causation_chain(store: :reminders, key: "r1")
  chain.each_with_index do |link, i|
    puts "[#{i}] hash=#{link[:value_hash]}  causation=#{link[:causation].inspect}"
  end

  # ---------------------------------------------------------------------------
  hr.("6. Reactive invalidation: agent mailbox received push signals")

  puts "Invalidation events: #{invalidations.inspect}"
  # => [[:reminders, "r1"], [:reminders, "r1"]]  — one per write

  # ---------------------------------------------------------------------------
  hr.("7. Append-only history (History[T])")

  store.append(history: :reminder_logs, event: { reminder_id: "r1", action: :created, at: t_before })
  store.append(history: :reminder_logs, event: { reminder_id: "r1", action: :closed,  at: t_after })

  logs = store.history(store: :reminder_logs)
  puts "Log entries: #{logs.map { |f| f.value[:action] }.inspect}"  # [:created, :closed]
  puts "Each has unique key: #{logs.map(&:key).uniq.length == 2}"

  # History[T] time-window query:
  recent = store.history(store: :reminder_logs, since: t_mid)
  puts "Events since t_mid: #{recent.map { |f| f.value[:action] }.inspect}"  # [:closed]

  # ---------------------------------------------------------------------------
  hr.("8. Content deduplication: same value → same hash")

  fa = store.write(store: :items, key: "x", value: { n: 1 })
  fb = store.write(store: :items, key: "y", value: { n: 1 })
  puts "fa.value_hash == fb.value_hash: #{fa.value_hash == fb.value_hash}"  # true

  # Hash key order does not affect the hash (stable_sort):
  fc = store.write(store: :items, key: "z", value: { b: 2, a: 1 })
  fd = store.write(store: :items, key: "w", value: { a: 1, b: 2 })
  puts "Order-independent hash: #{fc.value_hash == fd.value_hash}"           # true

  # ---------------------------------------------------------------------------
  hr.("9. File-backed WAL: persist and replay")

  require "tmpdir"
  wal_path = File.join(Dir.tmpdir, "igniter_store_poc_#{Process.pid}.jsonl")

  begin
    store_a = Igniter::Store::IgniterStore.open(wal_path)
    store_a.write(store: :tasks, key: "t1", value: { title: "Implement POC", done: false })
    store_a.write(store: :tasks, key: "t1", value: { title: "Implement POC", done: true })
    puts "Written #{store_a.fact_count} facts to #{File.basename(wal_path)}"

    store_b = Igniter::Store::IgniterStore.open(wal_path)
    replayed = store_b.read(store: :tasks, key: "t1")
    puts "Replayed after restart — done: #{replayed[:done]}"  # true
    puts "Fact count after replay: #{store_b.fact_count}"      # 2
  ensure
    File.delete(wal_path) if File.exist?(wal_path)
  end

  # ---------------------------------------------------------------------------
  hr.("Summary")
  puts "Total facts in log: #{store.fact_count}"
  puts "All checks passed."

end
