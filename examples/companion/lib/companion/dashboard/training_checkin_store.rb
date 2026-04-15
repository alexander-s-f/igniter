# frozen_string_literal: true

require "securerandom"
require "time"
require "igniter/sdk/data"

module Companion
  module Dashboard
    module TrainingCheckinStore
      COLLECTION = "companion_training_checkins"

      module_function

      def create(view_id:, submission_id:, checkin:)
        record = {
          "id" => SecureRandom.hex(8),
          "view_id" => view_id.to_s,
          "submission_id" => submission_id.to_s,
          "checkin" => stringify_keys(checkin),
          "created_at" => Time.now.utc.iso8601
        }

        Igniter::Data.default_store.put(collection: COLLECTION, key: record.fetch("id"), value: record)
      end

      def all
        Igniter::Data.default_store.all(collection: COLLECTION).values.sort_by { |record| record["created_at"].to_s }
      end

      def reset!
        Igniter::Data.default_store.clear(collection: COLLECTION)
      end

      def stringify_keys(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, entry), memo|
            memo[key.to_s] = stringify_keys(entry)
          end
        when Array
          value.map { |entry| stringify_keys(entry) }
        else
          value
        end
      end
    end
  end
end
