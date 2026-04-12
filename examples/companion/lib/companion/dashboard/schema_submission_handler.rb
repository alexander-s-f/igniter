# frozen_string_literal: true

require "time"
require "igniter/view"

module Companion
  module Dashboard
    module SchemaSubmissionHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        view_id = params[:id].to_s
        schema = ViewSchemaCatalog.store.get(view_id)
        return not_found(view_id) unless schema

        action_id = body.fetch("_action", "").to_s
        return error_response(view_id, "missing form action") if action_id.empty?

        normalized_payload = Igniter::Plugins::View::SubmissionNormalizer.new(schema).normalize(
          body,
          action_id: action_id
        )

        submission = ViewSubmissionStore.create(
          view_id: view_id,
          action_id: action_id,
          schema_version: schema.version,
          raw_payload: body,
          normalized_payload: normalized_payload
        )

        processing_result = Igniter::Plugins::View::SubmissionProcessor.call(
          schema: schema,
          action_id: action_id,
          submission: submission
        )

        ViewSubmissionStore.update(
          submission.fetch("id"),
          status: processing_result["ok"] ? "processed" : "failed",
          processing_result: processing_result,
          processed_at: Time.now.utc.iso8601
        )

        {
          status: 303,
          body: "",
          headers: {
            "Location" => "/views/#{view_id}?submission=#{submission.fetch("id")}"
          }
        }
      rescue Igniter::Plugins::View::SubmissionNormalizer::Error,
             Igniter::Plugins::View::Schema::Error,
             ArgumentError,
             NameError => e
        error_response(view_id, e.message)
      end

      def not_found(view_id)
        {
          status: 404,
          body: "View schema not found: #{view_id}",
          headers: { "Content-Type" => "text/plain; charset=utf-8" }
        }
      end

      def error_response(view_id, message)
        body = Igniter::Plugins::View.render do |view|
          view.doctype
          view.tag(:html, lang: "en") do |html|
            html.tag(:head) do |head|
              head.tag(:meta, charset: "utf-8")
              head.tag(:title, "Submission Error")
            end
            html.tag(:body) do |page|
              page.tag(:main) do |main|
                main.tag(:h1, "Submission could not be processed")
                main.tag(:p, message)
                main.tag(:p) do |paragraph|
                  paragraph.tag(:a, "Back to view", href: "/views/#{view_id}")
                end
              end
            end
          end
        end

        Igniter::Plugins::View::Response.html(body, status: 422)
      end
    end
  end
end
