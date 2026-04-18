# frozen_string_literal: true

require "igniter/core/metrics"

module Igniter
  module Server
    module Handlers
      # GET /v1/metrics — Prometheus text format metrics endpoint.
      #
      # Requires a Collector to be configured on the server:
      #   Igniter::Server.configure { |c| c.metrics_collector = Igniter::Metrics::Collector.new }
      #
      # When no collector is configured, returns a 501 Not Implemented response.
      class MetricsHandler < Base
        def initialize(registry, store, collector:)
          super(registry, store)
          @collector = collector
        end

        # Override Base#call to return Prometheus text/plain instead of JSON.
        def call(params:, body:)
          handle(params: params, body: body)
        rescue StandardError => e
          { status: 500,
            body: "# ERROR: #{e.message}\n",
            headers: { "Content-Type" => Igniter::Metrics::PrometheusExporter::CONTENT_TYPE } }
        end

        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          unless @collector
            return { status: 501,
                     body: JSON.generate({ error: "metrics_collector not configured" }),
                     headers: { "Content-Type" => "application/json" } }
          end

          exporter = Igniter::Metrics::PrometheusExporter.new(
            @collector,
            store: @store,
            registry: @registry
          )

          { status: 200,
            body: exporter.export,
            headers: { "Content-Type" => exporter.content_type } }
        end
      end
    end
  end
end
