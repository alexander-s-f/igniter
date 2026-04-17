# frozen_string_literal: true

require "igniter/plugins/view"
require_relative "view_schema_catalog"
require_relative "view_shell"

module Companion
  module Dashboard
    module SchemaPageHandler
      module_function

      def call(params:, body:, headers:, env: nil, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        schema = ViewSchemaCatalog.store.get(params[:id])
        return not_found(params[:id]) unless schema

        body = Igniter::Plugins::View::SchemaRenderer.render(
          schema: schema,
          notice: "Schema-driven page rendered from persisted view definition."
        )
        Igniter::Plugins::View::Response.html(body)
      end

      def not_found(view_id)
        body = ViewShell.render_message_page(
          title: "View not found",
          eyebrow: "Schema Page",
          message: "No schema stored for #{view_id}.",
          detail: "view_id=#{view_id}",
          back_label: "Back to dashboard",
          back_path: "/"
        )

        Igniter::Plugins::View::Response.html(body, status: 404)
      end
    end
  end
end
