# frozen_string_literal: true

require "igniter/plugins/view"
require_relative "../shared/stack_overview"
require_relative "views/home_page"

module Companion
  module Dashboard
    module HomeHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        snapshot = Companion::Shared::StackOverview.build

        Igniter::Plugins::View::Response.html(
          Views::HomePage.render(
            snapshot: snapshot,
            base_path: base_path_for(env)
          )
        )
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+z}, "")
      end
    end
  end
end
