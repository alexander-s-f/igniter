# frozen_string_literal: true

require "igniter"
require "igniter/metrics/snapshot"
require "igniter/metrics/collector"
require "igniter/metrics/prometheus_exporter"

module Igniter
  # Metrics collection for Igniter contracts and igniter-server.
  #
  # The Collector subscribes to an Igniter::Events::Bus and maintains
  # in-memory counters and histograms with zero external dependencies.
  #
  # Prometheus text format is exported via PrometheusExporter — usable
  # directly in the /v1/metrics endpoint of igniter-server.
  #
  # Usage (standalone):
  #   require "igniter/metrics"
  #
  #   collector = Igniter::Metrics::Collector.new
  #   contract.execution.events.subscribe(collector)
  #   contract.resolve_all
  #
  #   exporter = Igniter::Metrics::PrometheusExporter.new(
  #     collector, store: store, registry: registry
  #   )
  #   puts exporter.export
  #
  # Usage (igniter-server — automatic when metrics_collector is set):
  #   Igniter::Server.configure do |c|
  #     c.metrics_collector = Igniter::Metrics::Collector.new
  #   end
  #
  module Metrics
    class MetricsError < Igniter::Error; end
  end
end
