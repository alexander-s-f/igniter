# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/home_context"
require_relative "../views/home_page"

module Companion
  module Dashboard
    module NotesCreateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:)
        # rubocop:disable Lint/UnusedMethodArgument
        text = body.fetch("text", body.fetch("note", "")).to_s.strip
        base_path = base_path_for(env)

        if text.empty?
          snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
          html = Views::HomePage.render(
            context: Contexts::HomeContext.build(
              snapshot: snapshot,
              base_path: base_path,
              error_message: "Note text cannot be blank.",
              form_values: body
            )
          )
          return Igniter::Frontend::Response.html(html, status: 422)
        end

        Companion::DashboardApp.interface(:notes_api).add(text, source: "dashboard")
        location = [ base_path, "" ].reject(&:empty?).join("/") + "/?note_created=1"

        {
          status: 303,
          body: "",
          headers: { "Location" => location }
        }
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
      end
    end
  end
end
