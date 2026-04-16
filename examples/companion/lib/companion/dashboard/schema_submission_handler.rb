# frozen_string_literal: true

require "time"
require "igniter/plugins/view"
require_relative "view_shell"

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
        validation_errors = Igniter::Plugins::View::SubmissionValidator.new(schema).validate(
          normalized_payload,
          action_id: action_id
        )
        return validation_response(schema, raw_payload: body, errors: validation_errors) unless validation_errors.empty?

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
        field_errors = e.respond_to?(:field_errors) ? e.field_errors : {}
        return validation_response(schema, raw_payload: body, errors: field_errors) if field_errors && !field_errors.empty?

        error_response(view_id, e.message)
      end

      def not_found(view_id)
        body = ViewShell.render_message_page(
          title: "View schema not found",
          eyebrow: "Schema Submission",
          message: "No stored schema is available for #{view_id}.",
          detail: "view_id=#{view_id}",
          back_label: "Back to dashboard",
          back_path: "/"
        )

        Igniter::Plugins::View::Response.html(body, status: 404)
      end

      def error_response(view_id, message)
        body = ViewShell.render_message_page(
          title: "Submission could not be processed",
          eyebrow: "Schema Submission",
          message: message,
          detail: "view_id=#{view_id}",
          back_label: "Back to view",
          back_path: "/views/#{view_id}"
        )

        Igniter::Plugins::View::Response.html(body, status: 422)
      end

      def validation_response(schema, raw_payload:, errors:)
        body = Igniter::Plugins::View::SchemaRenderer.render(
          schema: schema,
          values: raw_payload.reject { |key, _| key.to_s == "_action" },
          errors: errors,
          notice: "Please review the highlighted fields."
        )

        Igniter::Plugins::View::Response.html(body, status: 422)
      end
    end
  end
end
