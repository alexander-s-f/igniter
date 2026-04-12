# frozen_string_literal: true

require "igniter/ai"
require_relative "../tools/time_tool"
require_relative "../tools/save_note_tool"
require_relative "../tools/get_notes_tool"

module Companion
  class RemindMeSkill < Igniter::AI::Skill
    description "Set a reminder from a natural language request. " \
                "Parses when and what, then saves a structured reminder. " \
                "Use this when the user says things like " \
                "'remind me to...', 'don't let me forget...', 'set a reminder for...'."

    param :request, type: :string, required: true,
                    desc: "Full reminder request in natural language, e.g. " \
                          "'remind me to call Alice tomorrow at 9am'"

    requires_capability :storage

    provider :ollama
    model ENV.fetch("CHAT_MODEL", "llama3.1:8b")
    tools TimeTool, SaveNoteTool, GetNotesTool
    max_tool_iterations 4

    DURATION_PATTERNS = [
      [/in\s+(\d+)\s+minute/i, ->(match) { "in #{match[1]} minutes" }],
      [/in\s+(\d+)\s+hour/i, ->(match) { "in #{match[1]} hours" }],
      [/tomorrow/i, ->(_) { "tomorrow" }],
      [/on\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i,
       ->(match) { "on #{match[1].capitalize}" }],
      [/at\s+(\d{1,2}(?::\d{2})?\s*(?:am|pm)?)/i, ->(match) { "at #{match[1]}" }]
    ].freeze

    def call(request:)
      if ENV["COMPANION_REAL_LLM"]
        complete(
          "The user wants to set a reminder: \"#{request}\".\n" \
          "1. Use the time_tool to get the current date/time.\n" \
          "2. Parse the task and deadline from the request.\n" \
          "3. Use the save_note_tool to save it as key 'reminder_<task_slug>' " \
          "with value '<task> by <deadline>'.\n" \
          "4. Confirm what was saved in one friendly sentence."
        )
      else
        mock_reminder(request)
      end
    end

    private

    def mock_reminder(request)
      task = request
        .sub(/^remind\s+me\s+to\s+/i, "")
        .sub(/^don.t\s+let\s+me\s+forget\s+to?\s+/i, "")
        .sub(/^set\s+a\s+reminder\s+(?:for\s+)?/i, "")
        .split(/\s+(?:at|on|in|tomorrow)\s+/i).first
        .to_s.strip.capitalize

      timing = DURATION_PATTERNS
        .map { |pattern, formatter| (match = request.match(pattern)) ? formatter.call(match) : nil }
        .compact.first || "soon"

      slug = task.downcase.gsub(/\W+/, "_").slice(0, 20)
      key = "reminder_#{slug}"
      note = "#{task} — #{timing}"
      NotesStore.save(key, note)

      "[remind_me] Got it! Saved reminder: \"#{note}\""
    end
  end
end
