# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module ViewSchemaDeleteHandler
      module_function

      def call(params:, body:, headers:, env: nil, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        deleted = ViewSchemaCatalog.store.delete(params[:id])
        return json(404, ok: false, error: "view schema not found") unless deleted

        json(200, ok: true, deleted: deleted.id)
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
