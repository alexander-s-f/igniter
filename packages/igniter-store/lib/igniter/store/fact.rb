# frozen_string_literal: true

require "digest"
require "json"
require "securerandom"

module Igniter
  module Store
    unless defined?(NATIVE) && NATIVE
      # Pure-Ruby Fact Struct — skipped when the Rust native extension is loaded.
      # The native extension provides its own Fact class with :build and reader methods.
      Fact = Struct.new(
        :id,
        :store,
        :key,
        :value,
        :value_hash,
        :causation,
        :timestamp,
        :term,
        :schema_version,
        keyword_init: true
      ) do
        def self.build(store:, key:, value:, causation: nil, term: 0, schema_version: 1)
          serialized = JSON.generate(stable_sort(value))
          new(
            id: SecureRandom.uuid,
            store: store,
            key: key,
            value: deep_freeze(value),
            value_hash: Digest::SHA256.hexdigest(serialized),
            causation: causation,
            timestamp: Process.clock_gettime(Process::CLOCK_REALTIME),
            term: term,
            schema_version: schema_version
          ).freeze
        end

        private_class_method def self.stable_sort(value)
          case value
          when Hash
            value.sort_by { |key, _entry| key.to_s }.to_h do |key, entry|
              [key.to_s, stable_sort(entry)]
            end
          when Array
            value.map { |entry| stable_sort(entry) }
          else
            value
          end
        end

        private_class_method def self.deep_freeze(value)
          case value
          when Hash
            value.transform_values { |entry| deep_freeze(entry) }.freeze
          when Array
            value.map { |entry| deep_freeze(entry) }.freeze
          else
            value.frozen? ? value : value.dup.freeze
          end
        end
      end
    end

    # Reopen Fact (Ruby Struct or native class) and add from_h + normalizations.
    class Fact
      if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE
        # Native extension stores `store` as a Rust String; normalize to Symbol
        # to match the Ruby Struct fallback behaviour.
        alias_method :_native_store_str, :store
        def store = _native_store_str.to_sym
      end

      # Reconstruct a Fact from a wire-deserialized hash.
      #
      # In Ruby mode: uses Fact.new to preserve all original fields including id
      # and timestamp.
      #
      # In native mode: Fact.new is unavailable (no Ruby allocator), so we call
      # Fact.build which recomputes id and timestamp. causation and value_hash are
      # preserved because they are content-addressed (SHA256 of stable-sorted value).
      # Time-travel fidelity over the network requires a future _native_reconstruct
      # Rust method — tracked as a known Phase 2 gap.
      def self.from_h(h)
        h = h.transform_keys(&:to_sym)
        h[:store]     = h.fetch(:store).to_sym
        h[:timestamp] = h.fetch(:timestamp).to_f
        if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE
          build(
            store: h[:store], key: h[:key], value: h[:value],
            causation: h[:causation], term: h.fetch(:term, 0),
            schema_version: h.fetch(:schema_version, 1)
          )
        else
          new(**h).freeze
        end
      end
    end
  end
end
