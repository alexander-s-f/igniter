# frozen_string_literal: true

require "json"
require_relative "../shared/note_store"

module Companion
  module Main
    module NotesListHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        notes = Companion::Shared::NoteStore.all

        {
          status: 200,
          body: JSON.generate(
            count: notes.size,
            notes: notes
          ),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
