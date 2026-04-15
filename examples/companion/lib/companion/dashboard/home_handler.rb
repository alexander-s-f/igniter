# frozen_string_literal: true

require "igniter/plugins/view"
require_relative "overview_snapshot"
require_relative "views/home_page"

module Companion
  module Dashboard
    module HomeHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        snapshot = OverviewSnapshot.build

        Igniter::Plugins::View::Response.html(Views::HomePage.render(snapshot: snapshot))
      end
    end
  end
end
