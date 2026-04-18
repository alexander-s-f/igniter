# frozen_string_literal: true

require "igniter-frontend"
require_relative "../shared/note_store"
require_relative "../shared/stack_overview"
require_relative "views/home_page"

module Companion
  module Dashboard
    module NotesCreateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        text = body.fetch("text", body.fetch("note", "")).to_s.strip
        base_path = base_path_for(env)

        if text.empty?
          snapshot = Companion::Shared::StackOverview.build
          html = Views::HomePage.render(
            snapshot: snapshot,
            error_message: "Note text cannot be blank.",
            form_values: body,
            base_path: base_path
          )
          return Igniter::Frontend::Response.html(html, status: 422)
        end

        Companion::Shared::NoteStore.add(text, source: "dashboard")
        location = [base_path, ""].reject(&:empty?).join("/") + "/?note_created=1"

        {
          status: 303,
          body: "",
          headers: { "Location" => location }
        }
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+z}, "")
      end
    end
  end
end
