# frozen_string_literal: true

require "igniter/sdk/data"
require "time"
require_relative "runtime_profile"

module Companion
  module Shared
    module AssistantEvaluationStore
      COLLECTION = "companion_assistant_evaluations"

      class << self
        def add(request_id:, action:, requester: nil, scenario_key: nil, scenario_label: nil, runtime_model: nil,
                status: nil, source: nil, metadata: {})
          entry = {
            "id" => "assistant-eval-#{Time.now.utc.strftime("%Y%m%d%H%M%S%6N")}",
            "request_id" => request_id.to_s,
            "action" => action.to_s,
            "requester" => requester.to_s.strip,
            "scenario_key" => scenario_key&.to_s,
            "scenario_label" => scenario_label,
            "runtime_model" => runtime_model,
            "status" => status&.to_s,
            "source" => source.to_s.strip,
            "metadata" => metadata || {},
            "created_at" => Time.now.utc.iso8601
          }.compact

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

        def recent(limit = 8)
          all.first(limit)
        end

        def count
          all.size
        end

        def reset!
          store.clear(collection: COLLECTION)
        end

        private

        def store
          path = Companion::Shared::RuntimeProfile.assistant_evaluation_store_path
          return @store if defined?(@store_path) && @store_path == path && @store

          @store_path = path
          @store = Igniter::Data::Stores::File.new(path: path)
        end
      end
    end
  end
end
