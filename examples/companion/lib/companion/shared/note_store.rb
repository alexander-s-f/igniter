# frozen_string_literal: true

require "igniter/sdk/data"
require "time"
require_relative "runtime_profile"

module Companion
  module Shared
    module NoteStore
      COLLECTION = "companion_notes"

      class << self
        def add(text, source: "operator")
          entry = {
            "id" => "companion-#{Time.now.utc.strftime("%Y%m%d%H%M%S%6N")}",
            "text" => text.to_s.strip,
            "source" => source.to_s,
            "created_at" => Time.now.utc.iso8601
          }

          store.put(collection: COLLECTION, key: entry.fetch("id"), value: entry)
          entry
        end

        def all
          store
            .all(collection: COLLECTION)
            .values
            .sort_by { |entry| entry.fetch("created_at", "") }
            .reverse
        end

        def count
          all.size
        end

        def reset!
          store.clear(collection: COLLECTION)
        end

        private

        def store
          path = Companion::Shared::RuntimeProfile.note_store_path
          return @store if defined?(@store_path) && @store_path == path && @store

          @store_path = path
          @store = Companion::Shared::RuntimeProfile.note_store
        end
      end
    end
  end
end
