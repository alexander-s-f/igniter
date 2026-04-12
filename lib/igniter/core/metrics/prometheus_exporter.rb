# frozen_string_literal: true

module Igniter
  module Metrics
    # Formats a Collector snapshot into Prometheus text exposition format (0.0.4).
    #
    # https://prometheus.io/docs/instrumenting/exposition_formats/
    #
    # Usage:
    #   exporter = PrometheusExporter.new(collector, store: store, registry: registry)
    #   text = exporter.export          # → String in Prometheus text format
    #   content_type = exporter.content_type
    class PrometheusExporter
      CONTENT_TYPE = "text/plain; version=0.0.4; charset=utf-8"

      COUNTER_META = {
        "igniter_executions_total" =>
          "Total contract executions completed",
        "igniter_http_requests_total" =>
          "Total HTTP requests received by igniter-server"
      }.freeze

      HISTOGRAM_META = {
        "igniter_execution_duration_seconds" =>
          "Contract execution duration in seconds",
        "igniter_http_request_duration_seconds" =>
          "HTTP request processing duration in seconds"
      }.freeze

      def initialize(collector, store:, registry:)
        @collector = collector
        @store     = store
        @registry  = registry
      end

      def content_type
        CONTENT_TYPE
      end

      def export # rubocop:disable Metrics/MethodLength
        snap  = @collector.snapshot
        lines = []

        emit_counters(lines, snap.counters)
        emit_histograms(lines, snap.histograms)
        emit_pending_gauge(lines)

        lines.join("\n") + "\n"
      end

      private

      def emit_counters(lines, counters) # rubocop:disable Metrics/MethodLength
        by_metric = counters.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(key, val), memo|
          name = key.split("{").first
          memo[name] << [key, val]
        end

        by_metric.each do |name, entries|
          lines << "# HELP #{name} #{COUNTER_META.fetch(name, name)}"
          lines << "# TYPE #{name} counter"
          entries.each { |key, val| lines << "#{key} #{val}" }
          lines << ""
        end
      end

      def emit_histograms(lines, histograms)
        histograms.each do |name, by_label|
          lines << "# HELP #{name} #{HISTOGRAM_META.fetch(name, name)}"
          lines << "# TYPE #{name} histogram"
          by_label.each_value { |entry| emit_histogram_entry(lines, name, entry) }
          lines << ""
        end
      end

      def emit_histogram_entry(lines, name, entry) # rubocop:disable Metrics/MethodLength
        lstr = entry[:labels].map { |k, v| "#{k}=\"#{v}\"" }.join(",")
        sep  = lstr.empty? ? "" : ","

        Collector::HISTOGRAM_BUCKETS.each do |b|
          le = b.to_s
          lines << "#{name}_bucket{#{lstr}#{sep}le=\"#{le}\"} #{entry[:buckets][b]}"
        end
        lines << "#{name}_bucket{#{lstr}#{sep}le=\"+Inf\"} #{entry[:count]}"
        lines << "#{name}_sum{#{lstr}} #{format("%.6f", entry[:sum])}"
        lines << "#{name}_count{#{lstr}} #{entry[:count]}"
      end

      def emit_pending_gauge(lines) # rubocop:disable Metrics/MethodLength
        lines << "# HELP igniter_pending_executions Currently pending executions in store"
        lines << "# TYPE igniter_pending_executions gauge"

        @registry.names.each do |name|
          count = @store.list_pending(graph: name).size
          lines << "igniter_pending_executions{graph=\"#{name}\"} #{count}"
        rescue StandardError
          lines << "igniter_pending_executions{graph=\"#{name}\"} 0"
        end

        lines << ""
      end
    end
  end
end
