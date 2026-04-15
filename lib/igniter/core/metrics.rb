# frozen_string_literal: true

require_relative "../../igniter"
require_relative "metrics/snapshot"
require_relative "metrics/collector"
require_relative "metrics/prometheus_exporter"

module Igniter
  # Metrics collection for Igniter contracts and igniter-stack.
  #
  # The Collector subscribes to an Igniter::Events::Bus and maintains
  # in-memory counters and histograms with zero external dependencies.
  #
  # Prometheus text format is exported via PrometheusExporter — usable
  # directly in the /v1/metrics endpoint of igniter-stack.
  #
  # Usage (standalone):
  #   require "igniter/core/metrics"
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
  # Usage (igniter-stack — automatic when metrics_collector is set):
  #   Igniter::Server.configure do |c|
  #     c.metrics_collector = Igniter::Metrics::Collector.new
  #   end
  #
  module Metrics
    class MetricsError < Igniter::Error; end
  end
end
