# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    class ProjectionStore
      def initialize(store:, collection:, primary_key: "id", timestamp_field: "projection_updated_at", clock: nil)
        @store = store
        @collection = collection.to_s
        @primary_key = primary_key.to_s
        @timestamp_field = timestamp_field.to_s
        @clock = clock || -> { Time.now.utc.iso8601 }
      end

      def project(record = nil, key: nil, metadata: {}, **attributes)
        entry = stringify_keys(record || attributes).merge(stringify_keys(metadata))
        projection_key = key_for(entry, explicit_key: key)
        entry[@primary_key] = projection_key
        entry[@timestamp_field] = @clock.call
        active_store.put(collection: @collection, key: projection_key, value: entry)
      end

      def get(key)
        active_store.get(collection: @collection, key: key.to_s)
      end

      def all
        active_store.all(collection: @collection).values
      end

      def delete(key)
        active_store.delete(collection: @collection, key: key.to_s)
      end

      def clear
        active_store.clear(collection: @collection)
      end

      private

      def active_store
        @store.respond_to?(:call) ? @store.call : @store
      end

      def key_for(entry, explicit_key:)
        return explicit_key.to_s unless explicit_key.nil?

        key = entry[@primary_key]
        raise ArgumentError, "projection record is missing primary key #{@primary_key.inspect}" if key.to_s.empty?

        key.to_s
      end

      def stringify_keys(hash)
        hash.each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = value
        end
      end
    end
  end
end
