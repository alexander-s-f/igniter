# frozen_string_literal: true

require "yaml"

module Igniter
  class App
    module Credentials
      class ConfigLoader
        PROVIDER_ENV_KEYS = {
          openai: {
            api_key: "OPENAI_API_KEY",
            base_url: "OPENAI_BASE_URL",
            default_model: "OPENAI_DEFAULT_MODEL"
          },
          anthropic: {
            api_key: "ANTHROPIC_API_KEY",
            base_url: "ANTHROPIC_BASE_URL",
            default_model: "ANTHROPIC_DEFAULT_MODEL"
          },
          deepgram: {
            api_key: "DEEPGRAM_API_KEY",
            base_url: "DEEPGRAM_BASE_URL"
          },
          assemblyai: {
            api_key: "ASSEMBLYAI_API_KEY",
            base_url: "ASSEMBLYAI_BASE_URL"
          }
        }.freeze

        attr_reader :path, :override

        def initialize(path:, override: false)
          @path = path.to_s
          @override = !!override
        end

        def self.load(path, override: false)
          new(path: path, override: override).load
        end

        def self.apply(path, override: false, env: ENV)
          new(path: path, override: override).apply(env: env)
        end

        def self.status(path, applied_keys: [], override: false, env: ENV)
          new(path: path, override: override).status(applied_keys: applied_keys, env: env)
        end

        def load
          return {} unless File.exist?(path)

          YAML.safe_load(File.read(path)) || {}
        end

        def apply(env: ENV)
          data = load
          mappings = extract_mappings(data)

          applied = mappings.each_with_object({}) do |(key, value), memo|
            next if value.nil?
            next if !override && present?(env[key])

            env[key] = value.to_s
            memo[key] = value.to_s
          end

          {
            path: path,
            applied: applied.freeze,
            loaded: File.exist?(path)
          }.freeze
        end

        def status(applied_keys: [], env: ENV)
          data = load
          normalized = symbolize_keys(data)
          normalized_env = normalize_env_map(normalized[:env])
          applied_key_set = Array(applied_keys).map(&:to_s)

          providers = PROVIDER_ENV_KEYS.each_with_object({}) do |(provider, keys), memo|
            provider_values = symbolize_keys(normalized[provider] || {})
            api_env_key = keys.fetch(:api_key)
            configured_in_file = !provider_values[:api_key].to_s.strip.empty? || normalized_env.key?(api_env_key)
            env_present = present?(env[api_env_key])
            source =
              if applied_key_set.include?(api_env_key)
                :local_file
              elsif env_present
                :environment
              elsif configured_in_file
                :file_present_not_loaded
              else
                :missing
              end

            memo[provider] = {
              env_key: api_env_key,
              configured_in_file: configured_in_file,
              env_present: env_present,
              source: source
            }.freeze
          end

          {
            path: path,
            loaded: File.exist?(path),
            override: override,
            applied_keys: applied_key_set.freeze,
            providers: providers.freeze
          }.freeze
        end

        private

        def extract_mappings(data)
          normalized = symbolize_keys(data)
          mappings = {}

          mappings.merge!(normalize_env_map(normalized[:env]))

          PROVIDER_ENV_KEYS.each do |provider, keys|
            provider_values = symbolize_keys(normalized[provider] || {})
            keys.each do |field, env_key|
              value = provider_values[field]
              mappings[env_key] = value unless value.nil?
            end
          end

          mappings.freeze
        end

        def normalize_env_map(value)
          (value || {}).each_with_object({}) do |(key, entry), memo|
            next if entry.nil?

            memo[key.to_s] = entry
          end
        end

        def symbolize_keys(hash)
          (hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def present?(value)
          !value.to_s.strip.empty?
        end
      end
    end
  end
end
