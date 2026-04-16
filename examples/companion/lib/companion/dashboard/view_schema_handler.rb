# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module ViewSchemaHandler
      module_function

      def call(params:, body:, headers:, env: nil, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        schema = ViewSchemaCatalog.store.get(params[:id])
        return json(404, ok: false, error: "view schema not found") unless schema

        json(200, schema: schema.to_h)
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
