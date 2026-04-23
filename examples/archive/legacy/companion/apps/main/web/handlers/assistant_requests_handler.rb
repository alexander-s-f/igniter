# frozen_string_literal: true

require "json"
require_relative "../../support/assistant_api"

module Companion
  module Main
    module AssistantRequestsHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        return list_requests if env.fetch("REQUEST_METHOD", "GET") == "GET"

        create_request(body)
      rescue ArgumentError => e
        json_error(422, e.message)
      end

      def list_requests
        overview = Companion::Main::Support::AssistantAPI.overview

        {
          status: 200,
          body: JSON.generate(overview),
          headers: { "Content-Type" => "application/json" }
        }
      end

      def create_request(body)
        requester = body.fetch("requester", "")
        request = body.fetch("request", body.fetch("brief", ""))
        scenario = body.fetch("scenario", "")
        scenario_context = {
          target_environment: body.fetch("target_environment", ""),
          change_scope: body.fetch("change_scope", ""),
          verification_plan: body.fetch("verification_plan", ""),
          rollback_plan: body.fetch("rollback_plan", ""),
          affected_system: body.fetch("affected_system", ""),
          urgency: body.fetch("urgency", ""),
          symptoms: body.fetch("symptoms", ""),
          sources: body.fetch("sources", ""),
          decision_focus: body.fetch("decision_focus", ""),
          constraints: body.fetch("constraints", "")
        }
        artifacts = body.fetch("artifacts", "")
        result = Companion::Main::Support::AssistantAPI.submit_request(
          requester: requester,
          request: request,
          scenario: scenario,
          scenario_context: scenario_context,
          artifacts: artifacts
        )

        {
          status: 201,
          body: JSON.generate(
            ok: true,
            request: result.fetch(:request),
            followup: result.fetch(:followup)
          ),
          headers: { "Content-Type" => "application/json" }
        }
      end

      def json_error(status, message)
        {
          status: status,
          body: JSON.generate(error: message),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
