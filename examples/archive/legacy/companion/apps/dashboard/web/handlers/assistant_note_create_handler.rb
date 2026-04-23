# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/assistant_context"
require_relative "../views/assistant_page"
require_relative "support"

module Companion
  module Dashboard
    module AssistantNoteCreateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        request_id = body.fetch("request_id", "").to_s
        base_path = base_path_for(env)

        if request_id.empty?
          return render_error(env: env, base_path: base_path, error_message: "Request is required.")
        end

        record = Companion::DashboardApp.interface(:assistant_api).fetch_request(request_id)
        briefing = record.fetch(:briefing, "").to_s.strip
        raise ArgumentError, "Completed briefing is required." if briefing.empty?

        Companion::DashboardApp.interface(:notes_api).add(note_text_for(record), source: "assistant")
        Companion::DashboardApp.interface(:assistant_api).observe_request(
          request_id: request_id,
          action: :saved_as_note,
          source: :dashboard,
          metadata: { note_source: :assistant }
        )

        {
          status: 303,
          body: "",
          headers: { "Location" => Handlers::Support.route_for(base_path, "/assistant") + "?assistant_noted=1" }
        }
      rescue StandardError => e
        render_error(env: env, base_path: base_path, error_message: e.message)
      end

      def note_text_for(record)
        scenario = record.dig(:scenario, :label) || record.fetch(:scenario_label, "General Brief")
        requester = record.fetch(:requester, "Operator")
        briefing = record.fetch(:briefing, "").to_s.strip

        "Assistant briefing (#{scenario}) for #{requester}: #{briefing}"
      end

      def render_error(env:, base_path:, error_message:)
        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
        html = Views::AssistantPage.render(
          context: Contexts::AssistantContext.build(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            filter_values: Handlers::Support.query_params_for(env)
          )
        )
        Igniter::Frontend::Response.html(html, status: 422)
      end

      def base_path_for(env)
        Handlers::Support.base_path_for(env)
      end
    end
  end
end
