# frozen_string_literal: true

require "json"
require_relative "../../../../lib/companion/shared/stack_overview"

module Companion
  module Main
    module StatusHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:)
        # rubocop:disable Lint/UnusedMethodArgument
        snapshot = Companion::Shared::StackOverview.build

        {
          status: 200,
          body: JSON.generate(
            generated_at: snapshot.fetch(:generated_at),
            stack: snapshot.fetch(:stack),
            apps: snapshot.fetch(:apps),
            nodes: snapshot.fetch(:nodes),
            counts: snapshot.fetch(:counts),
            notes: snapshot.fetch(:notes)
          ),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
