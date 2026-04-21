# frozen_string_literal: true

require "igniter-frontend"
require "uri"
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
              base_path: base_path_for(env),
              filter_values: query_params_for(env)
            )
          )
        )
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
      end

      def query_params_for(env)
        URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = value
        end
      end
    end
  end
end
