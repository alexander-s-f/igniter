# frozen_string_literal: true

require "igniter/core/tool"
require_relative "../../../../lib/companion/shared/notes_store"

module Companion
  class SaveNoteTool < Igniter::Tool
    description "Save a note or piece of information to remember later. " \
                "Use this when the user asks you to remember something."

    param :key, type: :string, required: true,
                desc: "Short identifier for the note (e.g. 'shopping_list', 'reminder', 'favorite_color')"
    param :value, type: :string, required: true,
                  desc: "The content to save"

    requires_capability :storage

    def call(key:, value:)
      NotesStore.save(key, value)
      "Saved: #{key} = \"#{value}\""
    end
  end
end
