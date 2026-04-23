# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/assistant_context"
require_relative "../views/assistant_page"
require_relative "support"

module Companion
  module Dashboard
    module AssistantHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview
        query = Handlers::Support.query_params_for(env)

        Igniter::Frontend::Response.html(
          Views::AssistantPage.render(
            context: Contexts::AssistantContext.build(
              snapshot: snapshot,
              base_path: Handlers::Support.base_path_for(env),
              filter_values: query,
              assistant_form_values: assistant_form_values_from(query)
            )
          )
        )
      end

      def assistant_form_values_from(query)
        query.slice(
          "requester",
          "scenario",
          "target_environment",
          "change_scope",
          "verification_plan",
          "rollback_plan",
          "affected_system",
          "urgency",
          "symptoms",
          "sources",
          "decision_focus",
          "constraints",
          "artifacts",
          "request"
        )
      end
    end
  end
end
