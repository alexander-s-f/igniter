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

      attr_accessor :default_provider
      attr_reader :providers

      def initialize
        @default_provider = :ollama
        @providers = { ollama: OllamaConfig.new }
      end

      def ollama
        @providers[:ollama]
      end

      def provider_config(name)
        @providers.fetch(name.to_sym) { raise ArgumentError, "Unknown LLM provider: #{name}" }
      end
    end
  end
end
