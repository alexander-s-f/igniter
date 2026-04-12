# frozen_string_literal: true

require "igniter/ai"

module Companion
  class IntentExecutor < Igniter::AI::Executor
    VALID_CATEGORIES = %w[question command greeting farewell clarification other].freeze

    provider :ollama
    model ENV.fetch("INTENT_MODEL", "qwen2.5:1.5b")

    CLASSIFICATION_SYSTEM_PROMPT = <<~PROMPT.freeze
      Classify the user message intent. Reply with valid JSON only, no explanation.
      Schema: {"category": string, "confidence": float, "language": string}
      Valid categories: question, command, greeting, farewell, clarification, other
      confidence must be between 0.0 and 1.0.
    PROMPT

    def call(text:)
      return default_intent if text.to_s.strip.empty?

      ctx = Igniter::AI::Context.empty(system: CLASSIFICATION_SYSTEM_PROMPT)
      ctx = ctx.append_user(text)
      raw = chat(context: ctx)
      parse_intent(raw)
    rescue StandardError
      default_intent
    end

    private

    def parse_intent(raw)
      json_str = raw.to_s.match(/\{[^}]+\}/)&.to_s || "{}"
      parsed = JSON.parse(json_str)

      category = parsed["category"].to_s.downcase
      category = "other" unless VALID_CATEGORIES.include?(category)

      {
        category: category,
        confidence: parsed["confidence"].to_f.clamp(0.0, 1.0),
        language: parsed["language"].to_s.then { |language| language.empty? ? "en" : language }
      }
    rescue JSON::ParserError
      default_intent
    end

    def default_intent
      { category: "other", confidence: 0.5, language: "en" }
    end
  end
end
