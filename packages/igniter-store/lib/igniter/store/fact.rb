# frozen_string_literal: true

# Pure-Ruby fallback — skipped when the Rust native extension is loaded.
return if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE

require "digest"
require "json"
require "securerandom"

module Igniter
  module Store
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
end
