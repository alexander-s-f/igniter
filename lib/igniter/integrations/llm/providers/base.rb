# frozen_string_literal: true

module Igniter
  module LLM
    module Providers
      class Base
        attr_reader :last_usage

        def chat(messages:, model:, tools: [], **options)
          raise NotImplementedError, "#{self.class}#chat must be implemented"
        end

        def complete(prompt:, model:, system: nil, **options)
          messages = []
          messages << { role: "system", content: system } if system
          messages << { role: "user", content: prompt }
          response = chat(messages: messages, model: model, **options)
          response[:content]
        end

        private

        def record_usage(prompt_tokens: 0, completion_tokens: 0)
          @last_usage = {
            prompt_tokens: prompt_tokens,
            completion_tokens: completion_tokens,
            total_tokens: prompt_tokens + completion_tokens
          }.freeze
        end
      end
    end
  end
end
