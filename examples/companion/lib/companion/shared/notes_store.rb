# frozen_string_literal: true

require "igniter/sdk/data"

module Companion
  module NotesStore
    COLLECTION = "companion_notes"

    class << self
      def configure_cluster(cluster)
        @cluster = cluster
      end

      def save(key, value)
        if @cluster
          @cluster.write(type: :set_note, key: key.to_s, value: value.to_s)
        else
          store.put(collection: COLLECTION, key: key, value: value.to_s)
        end
      end

      def get(key)
        if @cluster
          (@cluster.state_machine_snapshot[:notes] || {})[key.to_s]
        else
          store.get(collection: COLLECTION, key: key)
        end
      end

      def all
        if @cluster
          @cluster.state_machine_snapshot[:notes] || {}
        else
          store.all(collection: COLLECTION)
        end
      end

      def cluster? = !@cluster.nil?

      def reset!
        @cluster = nil
        store.clear(collection: COLLECTION)
      end

      private

      def store
        Igniter::Data.default_store
      end
    end
  end
end
