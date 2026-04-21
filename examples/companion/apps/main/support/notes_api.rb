# frozen_string_literal: true

require_relative "../../../lib/companion/shared/note_store"

module Companion
  module Main
    module Support
      module NotesAPI
        module_function

        def all
          Companion::Shared::NoteStore.all
        end

        def count
          Companion::Shared::NoteStore.count
        end

        def add(text, source: "operator")
          Companion::Shared::NoteStore.add(text, source: source)
        end

        def reset!
          Companion::Shared::NoteStore.reset!
        end
      end
    end
  end
end
