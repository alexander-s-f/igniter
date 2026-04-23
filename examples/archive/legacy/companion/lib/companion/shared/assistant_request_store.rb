# frozen_string_literal: true

require "igniter/sdk/data"
require "time"
require_relative "runtime_profile"

module Companion
  module Shared
    module AssistantRequestStore
      COLLECTION = "companion_assistant_requests"

      class << self
        def add(requester:, request:, graph:, execution_id:, followup_ids:, status: "open", completed_at: nil,
                completed_briefing: nil, runtime_mode: nil, runtime_provider: nil, runtime_model: nil,
                runtime_profile_key: nil, runtime_profile_label: nil, scenario_key: nil, scenario_label: nil,
                scenario_context: nil, artifacts: nil, prompt_package: nil, delivery: nil)
          entry = {
            "id" => "assistant-request-#{Time.now.utc.strftime("%Y%m%d%H%M%S%6N")}",
            "requester" => requester.to_s.strip,
            "request" => request.to_s.strip,
            "graph" => graph.to_s,
            "execution_id" => execution_id.to_s,
            "followup_ids" => Array(followup_ids).map(&:to_s),
            "submitted_at" => Time.now.utc.iso8601,
            "status" => status.to_s,
            "completed_at" => completed_at,
            "completed_briefing" => completed_briefing,
            "runtime_mode" => runtime_mode&.to_s,
            "runtime_provider" => runtime_provider&.to_s,
            "runtime_model" => runtime_model,
            "runtime_profile_key" => runtime_profile_key&.to_s,
            "runtime_profile_label" => runtime_profile_label,
            "scenario_key" => scenario_key&.to_s,
            "scenario_label" => scenario_label,
            "scenario_context" => scenario_context,
            "artifacts" => artifacts,
            "prompt_package" => prompt_package,
            "delivery" => delivery
          }.compact

          save(entry)
        end

        def save(entry)
          store.put(collection: COLLECTION, key: entry.fetch("id"), value: entry)
          entry
        end

        def all
          store
            .all(collection: COLLECTION)
            .values
            .sort_by { |entry| entry.fetch("submitted_at", "") }
            .reverse
        end

        def fetch(id)
          value = store.get(collection: COLLECTION, key: id.to_s)
          raise KeyError, "Unknown assistant request #{id.inspect}" unless value

          value
        end

        def count
          all.size
        end

        def reset!
          store.clear(collection: COLLECTION)
        end

        private

        def store
          path = Companion::Shared::RuntimeProfile.assistant_request_store_path
          return @store if defined?(@store_path) && @store_path == path && @store

          @store_path = path
          @store = Igniter::Data::Stores::File.new(path: path)
        end
      end
    end
  end
end
