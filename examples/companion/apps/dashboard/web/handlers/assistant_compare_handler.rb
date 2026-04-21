# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/assistant_context"
require_relative "../views/assistant_page"
require_relative "support"

module Companion
  module Dashboard
    module AssistantCompareHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        requester = body.fetch("requester", "").to_s.strip
        request = body.fetch("request", "").to_s.strip
        models = parse_models(body.fetch("models", body.fetch("models_csv", "")))
        base_path = Handlers::Support.base_path_for(env)

        raise ArgumentError, "requester is required" if requester.empty?
        raise ArgumentError, "request is required" if request.empty?

        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
        comparison = Companion::DashboardApp.interface(:assistant_api).compare_runtime_outputs(
          requester: requester,
          request: request,
          models: models
        )

        html = Views::AssistantPage.render(
          context: Contexts::AssistantContext.build(
            snapshot: snapshot,
            base_path: base_path,
            assistant_form_values: body,
            filter_values: Handlers::Support.query_params_for(env),
            compare_form_values: {
              "requester" => requester,
              "request" => request,
              "models_csv" => models.join(", ")
            },
            compare_results: comparison
          )
        )

        Igniter::Frontend::Response.html(html)
      rescue ArgumentError => e
        render_error(
          env: env,
          base_path: base_path,
          error_message: e.message,
          compare_form_values: body
        )
      end

      def render_error(env:, base_path:, error_message:, compare_form_values:)
        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
        html = Views::AssistantPage.render(
          context: Contexts::AssistantContext.build(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            filter_values: Handlers::Support.query_params_for(env),
            compare_form_values: compare_form_values
          )
        )
        Igniter::Frontend::Response.html(html, status: 422)
      end

      def parse_models(raw)
        Array(raw)
          .flat_map { |value| value.to_s.split(",") }
          .map(&:strip)
          .reject(&:empty?)
          .uniq
      end
    end
  end
end
