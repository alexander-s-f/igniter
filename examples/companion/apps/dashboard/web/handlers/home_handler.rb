# frozen_string_literal: true

require "igniter-frontend"
require_relative "../../contexts/home_context"
require_relative "../views/home_page"

module Companion
  module Dashboard
    module HomeHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:)
        # rubocop:disable Lint/UnusedMethodArgument
        snapshot = Companion::DashboardApp.interface(:playground_ops_api).overview

        Igniter::Frontend::Response.html(
          Views::HomePage.render(
            context: Contexts::HomeContext.build(
              snapshot: snapshot,
              base_path: base_path_for(env)
            )
          )
        )
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
      end
    end
  end
end
