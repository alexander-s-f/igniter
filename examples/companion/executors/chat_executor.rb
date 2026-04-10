# frozen_string_literal: true

require "igniter/integrations/llm"

module Companion
  # Conversational response generator using a local LLM via Ollama.
  #
  # Accepts full conversation history for multi-turn dialogue.
  # Responses are tuned for voice output: concise, no markdown.
  #
  # Config:
  #   CHAT_MODEL — Ollama model name (default: llama3.1:8b)
  #   OLLAMA_URL — Ollama HTTP URL (default: http://localhost:11434)
  class ChatExecutor < Igniter::LLM::Executor
    provider :ollama
    model ENV.fetch("CHAT_MODEL", "llama3.1:8b")
    temperature 0.7

    VOICE_SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a helpful voice assistant running on a local device.
      Keep responses concise (1-3 short sentences) — they will be spoken aloud.
      Avoid markdown, bullet points, or code unless explicitly asked.
      Be friendly and natural.
    PROMPT

    # message              — String: current user utterance
    # conversation_history — Array<Hash>: [{role:, content:}, ...] last ~10 turns
    # intent               — Hash: { category:, confidence:, language: } from IntentExecutor
    def call(message:, conversation_history:, intent:)
      ctx = build_context(message, conversation_history, intent)
      chat(context: ctx)
    end

    private

    def build_context(message, history, intent) # rubocop:disable Metrics/MethodLength
      system_msg = intent_aware_system(intent)
      ctx = Igniter::LLM::Context.empty(system: system_msg)

      # Replay prior turns (cap at 10 to limit token usage)
      (history || []).last(10).each do |turn|
        role    = (turn[:role]    || turn["role"]).to_s
        content = (turn[:content] || turn["content"]).to_s
        next unless %w[user assistant].include?(role) && !content.empty?

        ctx = role == "user" ? ctx.append_user(content) : ctx.append_assistant(content)
      end

      ctx.append_user(message)
    end

    def intent_aware_system(intent)
      return VOICE_SYSTEM_PROMPT unless intent.is_a?(Hash)

      category = (intent[:category] || intent["category"]).to_s
      return VOICE_SYSTEM_PROMPT if category.empty? || category == "other"

      "#{VOICE_SYSTEM_PROMPT}\nThe user's intent is a #{category} — respond accordingly."
    end
  end
end
