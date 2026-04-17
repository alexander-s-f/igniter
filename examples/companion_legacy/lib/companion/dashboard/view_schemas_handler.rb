# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module ViewSchemasHandler
      module_function

      def call(params:, body:, headers:, env: nil, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        store = ViewSchemaCatalog.store

        if raw_body.to_s.strip.empty? && body == {}
          schemas = store.all.values.map { |schema| schema_summary(schema) }
          return json(200, schemas: schemas)
        end

        schema = store.put(body)
        json(201, schema: schema.to_h)
      rescue Igniter::Plugins::View::Schema::Error => e
        json(422, ok: false, error: e.message)
      end

      def schema_summary(schema)
        {
          id: schema.id,
          version: schema.version,
          kind: schema.kind,
          title: schema.title
        }
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
