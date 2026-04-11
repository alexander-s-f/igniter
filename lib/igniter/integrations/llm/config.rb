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

      class DeepgramConfig
        attr_accessor :api_key, :base_url, :timeout

        def initialize
          @api_key  = ENV["DEEPGRAM_API_KEY"]
          @base_url = "https://api.deepgram.com"
          @timeout  = 300
        end
      end

      class AssemblyAIConfig
        attr_accessor :api_key, :base_url, :timeout, :poll_interval, :poll_timeout

        def initialize
          @api_key       = ENV["ASSEMBLYAI_API_KEY"]
          @base_url      = "https://api.assemblyai.com"
          @timeout       = 60
          @poll_interval = 2
          @poll_timeout  = 300
        end
      end

      PROVIDERS                 = %i[ollama anthropic openai].freeze
      TRANSCRIPTION_PROVIDERS   = %i[openai deepgram assemblyai].freeze

      attr_accessor :default_provider
      attr_reader :providers, :transcription_providers

      def initialize # rubocop:disable Metrics/MethodLength
        @default_provider = :ollama
        @providers = {
          ollama: OllamaConfig.new,
          anthropic: AnthropicConfig.new,
          openai: OpenAIConfig.new
        }
        @transcription_providers = {
          openai: @providers[:openai], # reuse existing OpenAI config
          deepgram: DeepgramConfig.new,
          assemblyai: AssemblyAIConfig.new
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

      def deepgram
        @transcription_providers[:deepgram]
      end

      def assemblyai
        @transcription_providers[:assemblyai]
      end

      def provider_config(name)
        @providers.fetch(name.to_sym) do
          raise ArgumentError, "Unknown LLM provider: #{name}. Available: #{PROVIDERS.inspect}"
        end
      end

      def transcription_provider_config(name)
        @transcription_providers.fetch(name.to_sym) do
          raise ArgumentError, "Unknown transcription provider: #{name}. Available: #{TRANSCRIPTION_PROVIDERS.inspect}"
        end
      end
    end
  end
end
