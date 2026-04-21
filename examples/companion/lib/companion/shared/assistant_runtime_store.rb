# frozen_string_literal: true

require "igniter/sdk/data"
require "igniter/ai"
require_relative "runtime_profile"

module Companion
  module Shared
    module AssistantRuntimeStore
      COLLECTION = "companion_assistant_runtime"
      KEY = "default"
      DEFAULT_CONFIG = {
        "mode" => "manual",
        "provider" => "ollama",
        "model" => "qwen2.5-coder:latest",
        "base_url" => "http://127.0.0.1:11434",
        "timeout_seconds" => 20,
        "delivery_strategy" => "prefer_openai",
        "openai_model" => Igniter::AI::Config.new.openai.default_model,
        "anthropic_model" => Igniter::AI::Config.new.anthropic.default_model
      }.freeze

      class << self
        def fetch
          DEFAULT_CONFIG.merge(store.get(collection: COLLECTION, key: KEY) || {})
        end

        def save(config)
          value = DEFAULT_CONFIG.merge(stringify_keys(config))
          store.put(collection: COLLECTION, key: KEY, value: value)
          value
        end

        def reset!
          store.clear(collection: COLLECTION)
        end

        private

        def stringify_keys(hash)
          hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_s] = value
          end
        end

        def store
          path = Companion::Shared::RuntimeProfile.assistant_runtime_store_path
          return @store if defined?(@store_path) && @store_path == path && @store

          @store_path = path
          @store = Igniter::Data::Stores::File.new(path: path)
        end
      end
    end
  end
end
