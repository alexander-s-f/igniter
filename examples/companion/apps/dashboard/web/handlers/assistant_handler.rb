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

        Igniter::Frontend::Response.html(
          Views::AssistantPage.render(
            context: Contexts::AssistantContext.build(
              snapshot: snapshot,
              base_path: Handlers::Support.base_path_for(env),
              filter_values: Handlers::Support.query_params_for(env)
            )
          )
        )
      end
    end
  end
end
