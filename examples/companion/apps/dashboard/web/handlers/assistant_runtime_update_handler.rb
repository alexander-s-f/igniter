# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/assistant_context"
require_relative "../views/assistant_page"
require_relative "support"

module Companion
  module Dashboard
    module AssistantRuntimeUpdateHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        base_path = Handlers::Support.base_path_for(env)

        Companion::DashboardApp.interface(:assistant_api).configure_runtime(
          mode: body.fetch("mode", "manual"),
          provider: body.fetch("provider", "ollama"),
          model: body.fetch("model", ""),
          base_url: body.fetch("base_url", ""),
          timeout_seconds: body.fetch("timeout_seconds", 20),
          delivery_strategy: body.fetch("delivery_strategy", "prefer_openai"),
          openai_model: body.fetch("openai_model", ""),
          anthropic_model: body.fetch("anthropic_model", "")
        )

        {
          status: 303,
          body: "",
          headers: { "Location" => Handlers::Support.route_for(base_path, "/assistant") + "?runtime_updated=1" }
        }
      rescue ArgumentError => e
        render_error(
          env: env,
          base_path: base_path,
          error_message: e.message
        )
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
    end
  end
end
