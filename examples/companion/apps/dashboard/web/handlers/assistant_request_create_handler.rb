# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/home_context"
require_relative "../views/home_page"
require_relative "home_handler"

module Companion
  module Dashboard
    module AssistantRequestCreateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        requester = body.fetch("requester", "").to_s.strip
        request = body.fetch("request", "").to_s.strip
        base_path = base_path_for(env)

        if requester.empty? || request.empty?
          return render_error(
            env: env,
            base_path: base_path,
            error_message: "Requester and request are required.",
            assistant_form_values: body
          )
        end

        Companion::DashboardApp.interface(:assistant_api).submit_request(requester: requester, request: request)

        {
          status: 303,
          body: "",
          headers: { "Location" => [base_path, ""].reject(&:empty?).join("/") + "/?assistant_created=1" }
        }
      rescue ArgumentError => e
        render_error(
          env: env,
          base_path: base_path,
          error_message: e.message,
          assistant_form_values: body
        )
      end

      def render_error(env:, base_path:, error_message:, assistant_form_values:)
        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
        html = Views::HomePage.render(
          context: Contexts::HomeContext.build(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            assistant_form_values: assistant_form_values,
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
