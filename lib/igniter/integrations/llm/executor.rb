# frozen_string_literal: true

module Igniter
  module LLM
    # Base class for LLM-powered compute nodes.
    #
    # Subclass and override #call(**inputs) to build prompts and get completions.
    # Use the #complete and #chat helper methods inside #call.
    #
    # Example:
    #   class DocumentSummarizer < Igniter::LLM::Executor
    #     provider :ollama
    #     model "llama3.2"
    #     system_prompt "You are a concise technical writer."
    #
    #     def call(document:)
    #       complete("Summarize this in 3 bullet points:\n\n#{document}")
    #     end
    #   end
    #
    #   class OrderContract < Igniter::Contract
    #     define do
    #       input :document
    #       compute :summary, depends_on: :document, with: DocumentSummarizer
    #       output :summary
    #     end
    #   end
    class Executor < Igniter::Executor
      class << self
        def provider(name = nil)
          return @provider || Igniter::LLM.config.default_provider if name.nil?

          @provider = name.to_sym
        end

        def model(name = nil)
          return @model || provider_config.default_model if name.nil?

          @model = name
        end

        def system_prompt(text = nil)
          return @system_prompt if text.nil?

          @system_prompt = text
        end

        def temperature(val = nil)
          return @temperature if val.nil?

          @temperature = val
        end

        def tools(*tool_definitions)
          return @tools || [] if tool_definitions.empty?

          @tools = tool_definitions.flatten
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@provider, @provider)
          subclass.instance_variable_set(:@model, @model)
          subclass.instance_variable_set(:@system_prompt, @system_prompt)
          subclass.instance_variable_set(:@temperature, @temperature)
          subclass.instance_variable_set(:@tools, @tools&.dup)
        end

        private

        def provider_config
          Igniter::LLM.provider_instance(provider).instance_of?(Class) ? nil : Igniter::LLM.config.provider_config(provider)
        rescue StandardError
          Igniter::LLM.config.ollama
        end
      end

      attr_reader :last_usage, :last_context

      # Subclasses override this method. Use #complete or #chat inside.
      def call(**_inputs)
        raise NotImplementedError, "#{self.class.name}#call must be implemented"
      end

      protected

      # Single-turn completion. Builds a simple user message from prompt.
      def complete(prompt, context: nil)
        messages = build_messages(prompt: prompt, context: context)
        response = provider_instance.chat(
          messages: messages,
          model: self.class.model,
          **completion_options
        )
        @last_usage = provider_instance.last_usage
        @last_context = track_context(context, prompt, response[:content])
        response[:content]
      end

      # Multi-turn chat with a Context object or raw messages array.
      def chat(context:)
        messages = context.is_a?(Context) ? context.to_a : Array(context)
        response = provider_instance.chat(
          messages: messages,
          model: self.class.model,
          **completion_options
        )
        @last_usage = provider_instance.last_usage
        response[:content]
      end

      # Tool-use call. Returns DeferredResult if the LLM wants to call a tool.
      def complete_with_tools(prompt, context: nil) # rubocop:disable Metrics/MethodLength
        messages = build_messages(prompt: prompt, context: context)
        response = provider_instance.chat(
          messages: messages,
          model: self.class.model,
          tools: self.class.tools,
          **completion_options
        )
        @last_usage = provider_instance.last_usage

        if response[:tool_calls].any?
          defer(payload: { tool_calls: response[:tool_calls], messages: messages })
        else
          response[:content]
        end
      end

      private

      def provider_instance
        @provider_instance ||= Igniter::LLM.provider_instance(self.class.provider)
      end

      def build_messages(prompt:, context: nil)
        base = []
        base << { role: "system", content: self.class.system_prompt } if self.class.system_prompt

        if context.is_a?(Context)
          base + context.to_a + [{ role: "user", content: prompt }]
        else
          base + [{ role: "user", content: prompt }]
        end
      end

      def completion_options
        opts = {}
        opts[:temperature] = self.class.temperature if self.class.temperature
        opts
      end

      def track_context(existing, user_prompt, assistant_reply)
        ctx = existing.is_a?(Context) ? existing : Context.empty(system: self.class.system_prompt)
        ctx.append_user(user_prompt).append_assistant(assistant_reply)
      end
    end
  end
end
