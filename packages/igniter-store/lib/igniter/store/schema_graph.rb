# frozen_string_literal: true

module Igniter
  module Store
    class SchemaGraph
      def initialize
        @paths = Hash.new { |hash, key| hash[key] = [] }
      end

      def register(path)
        @paths[path.store] << path
        self
      end

      def paths_for(store)
        @paths[store].dup
      end

      def consumers_for(store)
        @paths[store].flat_map { |path| path.consumers.to_a }.uniq
      end

      def path_for(store:, scope:)
        @paths[store].find { |path| path.scope == scope }
      end

      def registered_stores
        @paths.keys
      end

      # Returns a compact snapshot of all registered access paths keyed by store.
      # Each entry describes how the engine routes scope queries for that store:
      # scope name, lookup strategy, active filters, cache TTL, and consumer count.
      # Index descriptors (which fields are co-indexed) remain manifest/facade
      # metadata — they are a schema contract, not an engine routing concern.
      def metadata_snapshot
        @paths.each_with_object({}) do |(store, paths), snapshot|
          snapshot[store] = paths.map do |path|
            {
              store:          path.store,
              scope:          path.scope,
              lookup:         path.lookup,
              filters:        path.filters,
              cache_ttl:      path.cache_ttl,
              consumer_count: path.consumers.to_a.size
            }
          end
        end
      end
    end
  end
end
