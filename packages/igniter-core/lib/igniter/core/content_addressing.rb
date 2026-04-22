# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/content_addressing")
require "digest"

module Igniter
  # Content-addressed computation cache for pure executors.
  #
  # When an executor is declared `pure`, its output is fully determined by:
  #   1. The executor's content fingerprint (class name or explicit version string)
  #   2. The serialized dependency values
  #
  # The content key is SHA-256(fingerprint + serialized_deps), truncated to 24 hex chars.
  # This key is used as a universal cache key — valid across executions, processes, and nodes.
  #
  # == Usage
  #
  #   require "igniter/extensions/content_addressing"
  #
  #   class TaxCalculator < Igniter::Executor
  #     pure                           # enables content-addressed caching
  #     fingerprint "tax_calc_v1"      # optional explicit version (invalidates cache on bump)
  #
  #     def call(country:, amount:)
  #       TAX_RATES[country] * amount  # deterministic — same inputs, same output
  #     end
  #   end
  #
  # On first call with a given (country, amount) pair, the result is computed and cached.
  # Subsequent calls (even in different executions) return the cached value instantly.
  #
  # == Shared cache (distributed nodes)
  #
  # Replace the default in-process cache with a Redis-backed one:
  #
  #   Igniter::ContentAddressing.cache = MyRedisContentCache.new(redis: Redis.new)
  #   # Must implement: #fetch(key) → value | nil, #store(key, value)
  module ContentAddressing
    # Immutable content key derived from executor fingerprint + serialized dep values.
    class ContentKey
      attr_reader :hex

      def initialize(hex)
        @hex = hex.freeze
        freeze
      end

      def to_s    = "ca:#{@hex}"
      def inspect = "#<ContentKey #{self}>"
      def ==(other) = other.is_a?(ContentKey) && other.hex == hex

      class << self
        # Compute a ContentKey from an executor class and its resolved dependency values.
        def compute(executor_class, dep_values)
          fp   = executor_class.content_fingerprint
          deps = stable_serialize(dep_values)
          hex  = Digest::SHA256.hexdigest("#{fp}\x00#{deps}")[0..23]
          new(hex)
        end

        private

        # Serialize a value to a stable, order-independent string.
        # Used as part of the content key — must produce identical output for equal values.
        def stable_serialize(val) # rubocop:disable Metrics/CyclomaticComplexity
          case val
          when Hash
            pairs = val.sort_by { |k, _| k.to_s }.map { |k, v| "#{k}:#{stable_serialize(v)}" }
            "{#{pairs.join(",")}}"
          when Array  then "[#{val.map { |v| stable_serialize(v) }.join(",")}]"
          when String then val.inspect
          when Symbol then ":#{val}"
          when Numeric, NilClass, TrueClass, FalseClass then val.inspect
          else val.hash.to_s
          end
        end
      end
    end

    # Thread-safe in-process content cache.
    # Replace with a distributed implementation to share results across nodes.
    class Cache
      def initialize
        @store  = {}
        @mu     = Mutex.new
        @hits   = 0
        @misses = 0
      end

      # Retrieve a cached value. Returns nil on miss.
      def fetch(key)
        @mu.synchronize do
          val = @store[key.hex]
          if val.nil?
            @misses += 1
            nil
          else
            @hits += 1
            val
          end
        end
      end

      # Store a value under the given content key.
      def store(key, value)
        @mu.synchronize { @store[key.hex] = value }
      end

      def size = @mu.synchronize { @store.size }

      def clear
        @mu.synchronize do
          @store.clear
          @hits = 0
          @misses = 0
        end
      end

      def stats
        @mu.synchronize { { size: @store.size, hits: @hits, misses: @misses } }
      end
    end

    class << self
      # Global content cache. Default: thread-safe in-process Hash.
      # Can be replaced with any object responding to #fetch(key) and #store(key, value).
      attr_writer :cache

      def cache
        @cache ||= Cache.new
      end
    end
  end
end
