# frozen_string_literal: true

require_relative "../routing_demo"

module Companion
  module Dashboard
    module SelfHealDemoHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        scenario = params.fetch("scenario", body.fetch("scenario", "governance_gate")).to_s
        Companion::Dashboard::RoutingDemo.run!(scenario: scenario)
        base_path = base_path_for(env)
        location = [base_path, ""].reject(&:empty?).join("/") + "/?demo=#{scenario}"

        {
          status: 303,
          body: "",
          headers: { "Location" => location }
        }
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+z}, "")
      end
    end
  end
end
