# frozen_string_literal: true

require_relative "overview_snapshot"
require_relative "views/home_page"

module Companion
  module Dashboard
    module HomeHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        snapshot = OverviewSnapshot.build

        {
          status: 200,
          body: Views::HomePage.render(snapshot),
          headers: { "Content-Type" => "text/html; charset=utf-8" }
        }
      end
    end
  end
end
