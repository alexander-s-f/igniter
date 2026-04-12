# frozen_string_literal: true

require "json"
require_relative "overview_snapshot"

module Companion
  module Dashboard
    module OverviewHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        snapshot = OverviewSnapshot.build

        {
          status: 200,
          body: JSON.generate(snapshot),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
