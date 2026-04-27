# frozen_string_literal: true

require "tmpdir"

require "igniter-ai"

require_relative "services/store_backends"

module Companion
  class Configuration
    attr_reader :credentials, :store_backend, :store_path, :llm_model

    def initialize
      @credentials = []
      @store_backend = :sqlite
      @store_path = File.join(Dir.tmpdir, "igniter_companion.sqlite3")
      @llm_model = ENV.fetch("OPENAI_MODEL", "gpt-5.2")
    end

    def credential(name, env:, required: false, description: nil)
      @credentials << {
        name: name,
        env: env,
        required: required,
        description: description
      }
      self
    end

    def store(backend, path: nil)
      @store_backend = backend.to_sym
      @store_path = path.to_s unless path.nil?
      self
    end

    def credential_store
      Igniter::Application::CredentialStore.new(
        definitions: credentials.map do |entry|
          Igniter::Application::CredentialDefinition.new(**entry)
        end
      )
    end

    def store_adapter
      case store_backend
      when :memory
        Services::StoreBackends::Memory.new
      when :sqlite
        Services::StoreBackends::Sqlite.new(path: store_path)
      else
        raise ArgumentError, "unknown companion store backend #{store_backend.inspect}"
      end
    end

    def llm(model: nil)
      @llm_model = model.to_s unless model.nil?
      self
    end

    def llm_provider
      key = credential_store.fetch(:openai_api_key, default: nil)
      return nil if key.nil?

      Igniter::AI.client(
        provider: Igniter::AI::Providers::OpenAIResponses.new(api_key: key, model: llm_model)
      )
    end
  end

  def self.configure
    config = Configuration.new
    yield config if block_given?
    config
  end

  def self.default_configuration(store_path: nil)
    configure do |config|
      config.credential :openai_api_key,
                        env: "OPENAI_API_KEY",
                        required: false,
                        description: "OpenAI API key for live mode"
      config.store :sqlite, path: store_path || File.join(Dir.tmpdir, "igniter_companion.sqlite3")
      config.llm model: ENV.fetch("OPENAI_MODEL", "gpt-5.2")
    end
  end
end
