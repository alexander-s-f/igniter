# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module ViewSchemaPatchHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        schema = ViewSchemaCatalog.store.patch(params[:id], patch: body)
        json(200, schema: schema.to_h)
      rescue KeyError
        json(404, ok: false, error: "view schema not found")
      rescue Igniter::Plugins::View::Schema::Error => e
        json(422, ok: false, error: e.message)
      end

      def json(status, payload)
        {
          status: status,
          body: JSON.generate(payload),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
