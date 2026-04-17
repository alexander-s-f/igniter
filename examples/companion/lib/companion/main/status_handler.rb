# frozen_string_literal: true

require "json"
require_relative "../shared/stack_overview"

module Companion
  module Main
    module StatusHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        snapshot = Companion::Shared::StackOverview.build

        {
          status: 200,
          body: JSON.generate(
            generated_at: snapshot.fetch(:generated_at),
            stack: snapshot.fetch(:stack),
            apps: snapshot.fetch(:apps),
            current_node: snapshot.fetch(:current_node),
            routing: snapshot.fetch(:routing),
            discovered_peers: snapshot.fetch(:discovered_peers),
            services: snapshot.fetch(:services),
            counts: snapshot.fetch(:counts),
            notes: snapshot.fetch(:notes)
          ),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
