# frozen_string_literal: true

require "igniter/sdk/ai"
require "igniter/core/tool"
require_relative "../tools/time_tool"
require_relative "../tools/weather_tool"
require_relative "../tools/save_note_tool"
require_relative "../tools/get_notes_tool"
require_relative "../skills/research_skill"
require_relative "../skills/remind_me_skill"

module Companion
  # Conversational response generator using a local LLM (Ollama).
  #
  # Equipped with atomic tools (TimeTool, WeatherTool, notes) for instant
  # lookups and agentic skills (ResearchSkill, RemindMeSkill) for tasks that
  # require multi-step reasoning. The auto tool-use loop in #complete selects
  # and dispatches tools/skills transparently.
  #
  # Config:
  #   CHAT_MODEL  — Ollama model name (default: llama3.1:8b)
  #   OLLAMA_URL  — Ollama HTTP URL  (default: http://localhost:11434)
  class ChatExecutor < Igniter::AI::Executor
    provider :ollama
    model ENV.fetch("CHAT_MODEL", "llama3.1:8b")
    temperature 0.7

    # This executor is allowed to exercise all sub-tool/skill capabilities.
    capabilities :network, :storage

    # ── Tools (atomic) + Skills (agentic) ─────────────────────────────────
    tools TimeTool,        # what time/date is it?
          WeatherTool,     # current weather for a location
          SaveNoteTool,    # save a named note
          GetNotesTool,    # recall saved notes
          ResearchSkill,   # deep-dive on a topic (own LLM loop inside)
          RemindMeSkill    # parse + persist a natural language reminder

    max_tool_iterations 6

    VOICE_SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a helpful voice assistant running on a local device.
      Keep responses concise (1-3 short sentences) — they will be spoken aloud.
      Avoid markdown, bullet points, or code unless explicitly asked.
      Be friendly and natural.

      You have tools for instant lookups (time, weather, notes) and skills for
      deeper tasks (ResearchSkill for factual questions, RemindMeSkill for reminders).
      Choose the most appropriate tool or skill for each request.
    PROMPT

    def call(message:, conversation_history:, intent:)
      ctx = build_history_context(conversation_history, intent)
      complete(message, context: ctx)
    end

    private

    def build_history_context(history, intent)
      system_msg = intent_aware_system(intent)
      ctx        = Igniter::AI::Context.empty(system: system_msg)

      (history || []).last(10).each do |turn|
        role    = (turn[:role]    || turn["role"]).to_s
        content = (turn[:content] || turn["content"]).to_s
        next unless %w[user assistant].include?(role) && !content.empty?

        ctx = role == "user" ? ctx.append_user(content) : ctx.append_assistant(content)
      end

      ctx
    end

    def intent_aware_system(intent)
      return VOICE_SYSTEM_PROMPT unless intent.is_a?(Hash)

      category = (intent[:category] || intent["category"]).to_s
      return VOICE_SYSTEM_PROMPT if category.empty? || category == "other"

      "#{VOICE_SYSTEM_PROMPT}\nThe user's intent is a #{category} — respond accordingly."
    end
  end
end
