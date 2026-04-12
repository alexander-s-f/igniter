# frozen_string_literal: true

require "igniter/view"
require_relative "view_schema_catalog"

module Companion
  module Dashboard
    module SchemaPageHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        schema = ViewSchemaCatalog.store.get(params[:id])
        return not_found(params[:id]) unless schema

        body = Igniter::Plugins::View::SchemaRenderer.render(
          schema: schema,
          notice: "Schema-driven page rendered from persisted view definition."
        )
        Igniter::Plugins::View::Response.html(body)
      end

      def not_found(view_id)
        body = Igniter::Plugins::View.render do |view|
          view.doctype
          view.tag(:html, lang: "en") do |html|
            html.tag(:head) do |head|
              head.tag(:meta, charset: "utf-8")
              head.tag(:title, "View Not Found")
            end
            html.tag(:body) do |page|
              page.tag(:main) do |main|
                main.tag(:h1, "View not found")
                main.tag(:p, "No schema stored for #{view_id}.")
              end
            end
          end
        end

        Igniter::Plugins::View::Response.html(body, status: 404)
      end
    end
  end
end
