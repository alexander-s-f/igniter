# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Companion
  module Services
    module LLMProviders
      class OpenAIResponses
        ENDPOINT = URI("https://api.openai.com/v1/responses")

        def initialize(api_key:, model:)
          @api_key = api_key.to_s
          @model = model.to_s
        end

        def daily_summary(snapshot:)
          response = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true) do |http|
            request = Net::HTTP::Post.new(ENDPOINT)
            request["authorization"] = "Bearer #{@api_key}"
            request["content-type"] = "application/json"
            request.body = JSON.generate(
              model: @model,
              store: false,
              instructions: "You are Igniter Companion. Write a concise, practical daily summary for a personal assistant app.",
              input: prompt(snapshot)
            )
            http.request(request)
          end

          unless response.is_a?(Net::HTTPSuccess)
            return {
              success: false,
              text: nil,
              error: "openai_http_#{response.code}"
            }
          end

          payload = JSON.parse(response.body)
          text = output_text(payload)
          {
            success: !text.to_s.strip.empty?,
            text: text,
            error: text.to_s.strip.empty? ? "openai_empty_response" : nil
          }
        rescue StandardError => e
          {
            success: false,
            text: nil,
            error: e.class.name
          }
        end

        private

        def prompt(snapshot)
          <<~PROMPT
            Current companion state:
            - open reminders: #{snapshot.fetch(:open_reminders)}
            - tracker logs today: #{snapshot.fetch(:tracker_logs_today)}
            - countdowns: #{snapshot.fetch(:countdown_count)}
            - deterministic recommendation: #{snapshot.fetch(:daily_summary).fetch(:recommendation)}

            Return one short paragraph and one next action.
          PROMPT
        end

        def output_text(payload)
          direct = payload["output_text"]
          return direct if direct.is_a?(String)

          Array(payload["output"]).flat_map do |item|
            Array(item["content"]).filter_map { |content| content["text"] }
          end.join("\n")
        end
      end
    end
  end
end
