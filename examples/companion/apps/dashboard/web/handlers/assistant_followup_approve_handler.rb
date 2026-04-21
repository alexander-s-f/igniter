# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/home_context"
require_relative "../views/home_page"
require_relative "home_handler"

module Companion
  module Dashboard
    module AssistantFollowupApproveHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        request_id = body.fetch("request_id", "").to_s
        briefing = body.fetch("briefing", "").to_s.strip
        note = body.fetch("note", "").to_s.strip
        base_path = base_path_for(env)

        if request_id.empty? || briefing.empty?
          return render_error(env: env, base_path: base_path, error_message: "Request and briefing response are required.")
        end

        Companion::DashboardApp.interface(:assistant_api).approve_request(
          request_id: request_id,
          briefing: briefing,
          note: note
        )

        {
          status: 303,
          body: "",
          headers: { "Location" => [base_path, ""].reject(&:empty?).join("/") + "/?assistant_completed=1" }
        }
      rescue StandardError => e
        render_error(env: env, base_path: base_path, error_message: e.message)
      end

      def render_error(env:, base_path:, error_message:)
        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
        html = Views::HomePage.render(
          context: Contexts::HomeContext.build(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            filter_values: HomeHandler.query_params_for(env)
          )
        )
        Igniter::Frontend::Response.html(html, status: 422)
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
      end
    end
  end
end
