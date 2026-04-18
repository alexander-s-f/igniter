# frozen_string_literal: true

require "json"
require_relative "../../../../lib/companion/shared/note_store"

module Companion
  module Main
    module NotesCreateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        text = body.fetch("text", body.fetch("note", "")).to_s.strip

        if text.empty?
          return {
            status: 422,
            body: JSON.generate(error: "text is required"),
            headers: { "Content-Type" => "application/json" }
          }
        end

        note = Companion::Shared::NoteStore.add(text, source: "main")

        {
          status: 201,
          body: JSON.generate(
            ok: true,
            note: note,
            count: Companion::Shared::NoteStore.count
          ),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
