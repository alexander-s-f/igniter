# frozen_string_literal: true

require_relative "../projection_store"

module Igniter
  module Cluster
    module Events
      class ReadModelProjector
        def initialize(store:, collection:, primary_key: "id", transform:)
          @projection_store = ProjectionStore.new(
            store: store,
            collection: collection,
            primary_key: primary_key
          )
          @transform = transform
        end

        def call(event)
          result = @transform.call(event)
          return nil unless result

          if result.is_a?(Array)
            record, metadata = result
            @projection_store.project(record, metadata: metadata || {})
          else
            @projection_store.project(result)
          end
        end
      end
    end
  end
end
