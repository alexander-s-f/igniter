# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module OverviewHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        {
          status: 200,
          body: JSON.generate(Companion::DashboardApp.interface(:playground_ops_api).overview),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
