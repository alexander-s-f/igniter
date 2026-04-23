# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/assistant_context"
require_relative "../views/assistant_page"
require_relative "support"

module Companion
  module Dashboard
    module AssistantReopenHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        request_id = body.fetch("request_id", "").to_s
        base_path = base_path_for(env)

        if request_id.empty?
          return render_error(env: env, base_path: base_path, error_message: "Request is required.")
        end

        Companion::DashboardApp.interface(:assistant_api).reopen_request_as_followup(
          request_id: request_id
        )

        {
          status: 303,
          body: "",
          headers: { "Location" => Handlers::Support.route_for(base_path, "/assistant") + "?assistant_reopened=1" }
        }
      rescue StandardError => e
        render_error(env: env, base_path: base_path, error_message: e.message)
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
