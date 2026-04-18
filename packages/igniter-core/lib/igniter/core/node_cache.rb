# frozen_string_literal: true

require "digest"

module Igniter
  # Cross-execution TTL cache and request coalescing for compute nodes.
  #
  # Activated per-node via the `cache_ttl:` and `coalesce:` options on `compute`:
  #
  #   compute :available_slots, with: [...], call: CheckAvailability,
  #           cache_ttl: 60,     # seconds — reuse result across executions
  #           coalesce: true     # deduplicate concurrent in-flight requests
  #
  # == Setup
  #
  #   require "igniter/core/node_cache"
  #   Igniter::NodeCache.cache = Igniter::NodeCache::Memory.new
  #   Igniter::NodeCache.coalescing_lock = Igniter::NodeCache::CoalescingLock.new
  #
  # Or via the configure block:
  #
  #   Igniter.configure do |c|
  #     c.node_cache = Igniter::NodeCache::Memory.new
  #     c.node_coalescing = true   # auto-creates a CoalescingLock
  #   end
  #
  # == AR fingerprinting (Gap 3)
  #
  # Cache keys are built from a stable fingerprint of dep values.
  # For ActiveRecord objects, include Igniter::Fingerprint (or use the Railtie):
  #
  #   class Trade < ApplicationRecord
  #     include Igniter::Fingerprint
  #     # default: "Trade:42:1712345678"
  #   end
  module NodeCache
    class << self
      # Global TTL cache backend. nil = disabled (default).
      # Must respond to: #fetch(key) → value | nil
      #                  #store(key, value, ttl:)
      attr_accessor :cache

      # Global coalescing lock. nil = disabled (default).
      attr_accessor :coalescing_lock
    end

    # ─── Cache key ────────────────────────────────────────────────────────────

    # Immutable key uniquely identifying a node result for a given set of dep values.
    # Format: "ttl:{contract_name}:{node_name}:{dep_fingerprint_hex}"
    class CacheKey
      attr_reader :hex

      def initialize(contract_name, node_name, dep_hex)
        @hex = "ttl:#{contract_name}:#{node_name}:#{dep_hex}".freeze
        freeze
      end

      def to_s    = @hex
      def inspect = "#<NodeCache::CacheKey #{@hex}>"
      def ==(other) = other.is_a?(CacheKey) && other.hex == @hex
    end

    # ─── Memory backend ───────────────────────────────────────────────────────

    # Thread-safe in-process TTL store. Entries expire after their TTL.
    # Replace with a Redis-backed implementation for multi-process sharing.
    class Memory
      Entry = Struct.new(:value, :expires_at) do
        def expired? = Time.now.utc > expires_at
      end

      def initialize
        @store  = {}
        @mu     = Mutex.new
        @hits   = 0
        @misses = 0
      end

      # Returns the cached value, or nil on miss / expiry.
      def fetch(key)
        @mu.synchronize do
          entry = @store[key.hex]
          if entry.nil? || entry.expired?
            @store.delete(key.hex) if entry
            @misses += 1
            nil
          else
            @hits += 1
            entry.value
          end
        end
      end

      # Stores value with a TTL in seconds.
      def store(key, value, ttl:)
        @mu.synchronize do
          @store[key.hex] = Entry.new(value, Time.now.utc + ttl)
        end
        value
      end

      # Remove all expired entries. Call periodically to reclaim memory.
      def prune!
        @mu.synchronize do
          now = Time.now.utc
          @store.delete_if { |_, e| e.expires_at < now }
        end
      end

      def size  = @mu.synchronize { @store.size }
      def clear = @mu.synchronize { @store.clear; @hits = 0; @misses = 0 }
      def stats = @mu.synchronize { { size: @store.size, hits: @hits, misses: @misses } }
    end

    # ─── Coalescing lock ──────────────────────────────────────────────────────

    # In-flight deduplication for concurrent requests with identical dep fingerprints.
    #
    # When two executions race to compute the same `coalesce: true` node:
    #   • The first caller becomes the leader — computes and stores the result.
    #   • Subsequent callers become followers — wait for the leader, then reuse its result.
    #
    # This eliminates duplicate work for concurrent auction-style requests
    # (e.g. 3 vendors arriving within ~50ms for the same lead).
    #
    # Scope: single Ruby process. For Puma multi-worker, extend with a Redis-based
    # implementation using SETNX advisory locks + Pub/Sub.
    class CoalescingLock
      WAIT_TIMEOUT = 30 # seconds before a follower gives up and computes independently

      InFlight = Struct.new(:mutex, :cond, :done, :value, :error, keyword_init: true)

      def initialize
        @mu      = Mutex.new
        @flights = {}
      end

      # Attempt to acquire a computation slot for `hex`.
      #
      # Returns [:leader, flight]   — caller is first; must compute then call finish!
      # Returns [:follower, flight] — another caller is already computing; call wait(flight)
      def acquire(hex)
        @mu.synchronize do
          if @flights.key?(hex)
            [:follower, @flights[hex]]
          else
            flight = InFlight.new(
              mutex: Mutex.new,
              cond:  ConditionVariable.new,
              done:  false,
              value: nil,
              error: nil
            )
            @flights[hex] = flight
            [:leader, flight]
          end
        end
      end

      # Called by the leader when computation finishes (success or failure).
      # Unblocks all waiting followers.
      def finish!(hex, value: nil, error: nil)
        flight = @mu.synchronize { @flights.delete(hex) }
        return unless flight

        flight.mutex.synchronize do
          flight.value = value
          flight.error = error
          flight.done  = true
          flight.cond.broadcast
        end
      end

      # Called by a follower after receiving the flight object from acquire.
      # Blocks until the leader calls finish!, then returns [value, error].
      # Times out after WAIT_TIMEOUT seconds and returns [nil, nil] (follower recomputes).
      def wait(flight)
        flight.mutex.synchronize do
          deadline = Time.now + WAIT_TIMEOUT
          until flight.done
            remaining = deadline - Time.now
            break if remaining <= 0

            flight.cond.wait(flight.mutex, remaining)
          end
          [flight.value, flight.error]
        end
      end

      def in_flight_count = @mu.synchronize { @flights.size }
    end

    # ─── Fingerprinter ────────────────────────────────────────────────────────

    # Produces a stable hex fingerprint for a set of dependency values.
    # Used as part of the NodeCache::CacheKey.
    #
    # Supports the Igniter::Fingerprint protocol:
    #   objects responding to #igniter_fingerprint return a stable string
    #   (e.g. "Trade:42:1712345678").
    #
    # Fallback for unknown objects: "#ClassName@object_id" — stable within
    # a single process but NOT across restarts. Sufficient for the in-process
    # Memory backend; Redis-backed deployments should ensure all dep objects
    # implement igniter_fingerprint.
    module Fingerprinter
      def self.call(dep_values)
        Digest::SHA256.hexdigest(serialize(dep_values))[0..23]
      end

      def self.serialize(val) # rubocop:disable Metrics/CyclomaticComplexity
        case val
        when Hash
          pairs = val.sort_by { |k, _| k.to_s }.map { |k, v| "#{k}:#{serialize(v)}" }
          "{#{pairs.join(",")}}"
        when Array  then "[#{val.map { |v| serialize(v) }.join(",")}]"
        when String then val.inspect
        when Symbol then ":#{val}"
        when Numeric, NilClass, TrueClass, FalseClass then val.inspect
        else
          if val.respond_to?(:igniter_fingerprint)
            "fp:#{val.igniter_fingerprint}"
          else
            "obj:#{val.class.name}@#{val.object_id}"
          end
        end
      end
    end
  end
end
