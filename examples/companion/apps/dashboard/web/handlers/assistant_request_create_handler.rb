# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/assistant_context"
require_relative "../views/assistant_page"
require_relative "support"

module Companion
  module Dashboard
    module AssistantRequestCreateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        requester = body.fetch("requester", "").to_s.strip
        request = body.fetch("request", "").to_s.strip
        scenario = body.fetch("scenario", "").to_s.strip
        scenario_context = {
          target_environment: body.fetch("target_environment", "").to_s.strip,
          change_scope: body.fetch("change_scope", "").to_s.strip,
          verification_plan: body.fetch("verification_plan", "").to_s.strip,
          rollback_plan: body.fetch("rollback_plan", "").to_s.strip,
          affected_system: body.fetch("affected_system", "").to_s.strip,
          urgency: body.fetch("urgency", "").to_s.strip,
          symptoms: body.fetch("symptoms", "").to_s.strip,
          sources: body.fetch("sources", "").to_s.strip,
          decision_focus: body.fetch("decision_focus", "").to_s.strip,
          constraints: body.fetch("constraints", "").to_s.strip
        }
        artifacts = body.fetch("artifacts", "").to_s
        base_path = base_path_for(env)

        if requester.empty? || request.empty?
          return render_error(
            env: env,
            base_path: base_path,
            error_message: "Requester and request are required.",
            assistant_form_values: body
          )
        end

        Companion::DashboardApp.interface(:assistant_api).submit_request(
          requester: requester,
          request: request,
          scenario: scenario,
          scenario_context: scenario_context,
          artifacts: artifacts
        )

        {
          status: 303,
          body: "",
          headers: { "Location" => Handlers::Support.route_for(base_path, "/assistant") + "?assistant_created=1" }
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
        html = Views::AssistantPage.render(
          context: Contexts::AssistantContext.build(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            assistant_form_values: assistant_form_values,
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
