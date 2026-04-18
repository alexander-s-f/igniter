# frozen_string_literal: true

require "json"
require_relative "../../../../lib/companion/shared/stack_overview"

module Companion
  module Dashboard
    module OverviewHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        {
          status: 200,
          body: JSON.generate(Companion::Shared::StackOverview.build),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
