# frozen_string_literal: true

module Igniter
  module LLM
    class Config
      class OllamaConfig
        attr_accessor :base_url, :default_model, :timeout

        def initialize
          @base_url = "http://localhost:11434"
          @default_model = "llama3.2"
          @timeout = 120
        end
      end

      class AnthropicConfig
        attr_accessor :api_key, :base_url, :default_model, :timeout

        def initialize
          @api_key = ENV["ANTHROPIC_API_KEY"]
          @base_url = "https://api.anthropic.com"
          @default_model = "claude-sonnet-4-6"
          @timeout = 120
        end
      end

      class OpenAIConfig
        attr_accessor :api_key, :base_url, :default_model, :timeout

        def initialize
          @api_key = ENV["OPENAI_API_KEY"]
          @base_url = "https://api.openai.com"
          @default_model = "gpt-4o"
          @timeout = 120
        end
      end

      PROVIDERS = %i[ollama anthropic openai].freeze

      attr_accessor :default_provider
      attr_reader :providers

      def initialize
        @default_provider = :ollama
        @providers = {
          ollama: OllamaConfig.new,
          anthropic: AnthropicConfig.new,
          openai: OpenAIConfig.new
        }
      end

      def ollama
        @providers[:ollama]
      end

      def anthropic
        @providers[:anthropic]
      end

      def openai
        @providers[:openai]
      end

      def provider_config(name)
        @providers.fetch(name.to_sym) { raise ArgumentError, "Unknown LLM provider: #{name}. Available: #{PROVIDERS.inspect}" }
      end
    end
  end
end
