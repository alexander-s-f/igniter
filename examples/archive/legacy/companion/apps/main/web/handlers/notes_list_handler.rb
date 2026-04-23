# frozen_string_literal: true

require "json"
require_relative "../../support/notes_api"

module Companion
  module Main
    module NotesListHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        notes = Companion::Main::Support::NotesAPI.all

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
