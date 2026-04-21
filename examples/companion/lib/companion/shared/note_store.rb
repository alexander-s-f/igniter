# frozen_string_literal: true

require "igniter/sdk/data"
require "time"

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
          @store ||= Igniter::Data::Stores::File.new(path: File.expand_path("../../../var/notes.json", __dir__))
        end
      end
    end
  end
end
