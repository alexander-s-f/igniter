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
        result = Companion::Main::Support::AssistantAPI.submit_request(requester: requester, request: request)

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
