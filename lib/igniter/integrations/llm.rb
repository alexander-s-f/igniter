# frozen_string_literal: true

require "igniter"
require_relative "llm/config"
require_relative "llm/context"
require_relative "llm/providers/base"
require_relative "llm/providers/ollama"
require_relative "llm/executor"

module Igniter
  module LLM
    class Error < Igniter::Error; end
    class ProviderError < Error; end
    class ConfigurationError < Error; end

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

      private

      def build_provider(name)
        case name
        when :ollama
          cfg = config.ollama
          Providers::Ollama.new(base_url: cfg.base_url, timeout: cfg.timeout)
        else
          raise ConfigurationError, "Unknown LLM provider: #{name}. " \
                                    "Available: [:ollama]"
        end
      end
    end
  end
end
