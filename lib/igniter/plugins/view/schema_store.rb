# frozen_string_literal: true

require "igniter/sdk/data"

module Igniter
  module Plugins
    module View
      class SchemaStore
        DEFAULT_COLLECTION = "igniter_view_schemas"

        def initialize(store: Igniter::Data.default_store, collection: DEFAULT_COLLECTION)
          @store = store
          @collection = collection.to_s
        end

        def put(payload)
          schema = payload.is_a?(Schema) ? payload : Schema.load(payload)
          @store.put(collection: @collection, key: schema.id, value: schema.to_h)
          schema
        end

        def patch(id, patch:, increment_version: true)
          current = fetch(id)
          merged = SchemaPatcher.apply(current.to_h, patch)
          merged["id"] ||= current.id
          merged["kind"] ||= current.kind
          merged["version"] = current.version.to_i + 1 if increment_version
          put(merged)
        end

        def get(id)
          payload = @store.get(collection: @collection, key: id.to_s)
          payload ? Schema.load(payload) : nil
        end

        def fetch(id)
          get(id) || raise(KeyError, "view schema not found: #{id}")
        end

        def delete(id)
          payload = @store.delete(collection: @collection, key: id.to_s)
          payload ? Schema.load(payload) : nil
        end

        def all
          @store.all(collection: @collection).transform_values { |payload| Schema.load(payload) }
        end

        def reset!
          @store.clear(collection: @collection)
        end
      end
    end
  end
end
