# frozen_string_literal: true

require "securerandom"
require "time"
require "igniter/data"

module Companion
  module Dashboard
    module ViewSubmissionStore
      COLLECTION = "companion_view_submissions"

      module_function

      def create(view_id:, action_id:, schema_version:, raw_payload:, normalized_payload:, status: "received")
        record = {
          "id" => SecureRandom.hex(8),
          "view_id" => view_id.to_s,
          "action_id" => action_id.to_s,
          "schema_version" => schema_version.to_i,
          "raw_payload" => stringify_values(raw_payload),
          "normalized_payload" => stringify_values(normalized_payload),
          "status" => status,
          "created_at" => Time.now.utc.iso8601,
          "processed_at" => nil,
          "processing_result" => nil,
          "error" => nil
        }

        Igniter::Data.default_store.put(collection: COLLECTION, key: record.fetch("id"), value: record)
      end

      def get(id)
        Igniter::Data.default_store.get(collection: COLLECTION, key: id.to_s)
      end

      def update(id, attrs)
        record = get(id)
        return nil unless record

        updated = record.merge(stringify_values(attrs))
        Igniter::Data.default_store.put(collection: COLLECTION, key: id.to_s, value: updated)
      end

      def for_view(view_id)
        Igniter::Data.default_store.all(collection: COLLECTION).values
          .select { |record| record["view_id"] == view_id.to_s }
          .sort_by { |record| record["created_at"].to_s }
      end

      def reset!
        Igniter::Data.default_store.clear(collection: COLLECTION)
      end

      def stringify_values(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, entry), memo|
            memo[key.to_s] = stringify_values(entry)
          end
        when Array
          value.map { |entry| stringify_values(entry) }
        else
          value
        end
      end
    end
  end
end
