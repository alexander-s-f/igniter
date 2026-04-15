# frozen_string_literal: true

require_relative "../../igniter"
require_relative "../core/tool"
require_relative "../ai/config"
require_relative "../ai/context"
require_relative "ai/providers/base"
require_relative "ai/providers/ollama"
require_relative "ai/providers/anthropic"
require_relative "ai/providers/openai"
require_relative "ai/executor"
require_relative "ai/transcription/transcript_result"
require_relative "ai/transcription/providers/base"
require_relative "ai/transcription/providers/openai"
require_relative "ai/transcription/providers/deepgram"
require_relative "ai/transcription/providers/assemblyai"
require_relative "ai/transcription/transcriber"
require_relative "../ai/agents"
require_relative "ai/skill"
require_relative "ai/tool_registry"

module Igniter
  module AI
    class Error < Igniter::Error; end
    class ProviderError < Error; end
    class ConfigurationError < Error; end

    AVAILABLE_PROVIDERS = Config::PROVIDERS

    class << self
      def config
        @config ||= Config.new
      end

      def configure
        yield config
      end

      # Returns a memoized provider instance for the given provider name.
      def provider_instance(name)
        @provider_instances ||= {}
        @provider_instances[name.to_sym] ||= build_provider(name.to_sym)
      end

      # Returns a memoized transcription provider instance.
      def transcription_provider_instance(name)
        @transcription_provider_instances ||= {}
        @transcription_provider_instances[name.to_sym] ||= build_transcription_provider(name.to_sym)
      end

      # Reset cached provider instances (useful after reconfiguration).
      def reset_providers!
        @provider_instances = nil
        @transcription_provider_instances = nil
      end

      private

      def build_provider(name) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        case name
        when :ollama
          cfg = config.ollama
          Providers::Ollama.new(base_url: cfg.base_url, timeout: cfg.timeout)
        when :anthropic
          cfg = config.anthropic
          Providers::Anthropic.new(api_key: cfg.api_key, base_url: cfg.base_url, timeout: cfg.timeout)
        when :openai
          cfg = config.openai
          Providers::OpenAI.new(api_key: cfg.api_key, base_url: cfg.base_url, timeout: cfg.timeout)
        else
          raise ConfigurationError, "Unknown LLM provider: #{name}. Available: #{AVAILABLE_PROVIDERS.inspect}"
        end
      end

      def build_transcription_provider(name) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        case name
        when :openai
          cfg = config.openai
          Transcription::Providers::OpenAI.new(api_key: cfg.api_key, base_url: cfg.base_url, timeout: cfg.timeout)
        when :deepgram
          cfg = config.deepgram
          Transcription::Providers::Deepgram.new(api_key: cfg.api_key, base_url: cfg.base_url, timeout: cfg.timeout)
        when :assemblyai
          cfg = config.assemblyai
          Transcription::Providers::AssemblyAI.new(
            api_key: cfg.api_key,
            base_url: cfg.base_url,
            timeout: cfg.timeout,
            poll_interval: cfg.poll_interval,
            poll_timeout: cfg.poll_timeout
          )
        else
          raise ConfigurationError,
                "Unknown transcription provider: #{name}. Available: #{Config::TRANSCRIPTION_PROVIDERS.inspect}"
        end
      end
    end
  end
end
