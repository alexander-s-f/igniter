# frozen_string_literal: true

require "igniter/core/tool"
require_relative "../../../../lib/companion/shared/notes_store"

module Companion
  class GetNotesTool < Igniter::Tool
    description "Retrieve notes that were previously saved. " \
                "Use this when the user asks to recall something you were asked to remember."

    param :key, type: :string, required: false,
                desc: "Specific note key to look up. Omit to list all saved notes."

    requires_capability :storage

    def call(key: nil)
      if key
        value = NotesStore.get(key)
        value ? "#{key}: \"#{value}\"" : "No note found for \"#{key}\""
      else
        notes = NotesStore.all
        notes.empty? ? "No notes saved yet." : notes.map { |note_key, value| "  #{note_key}: \"#{value}\"" }.join("\n")
      end
    end
  end
end
