# frozen_string_literal: true

module Igniter
  module Metrics
    # Thread-safe event subscriber that collects execution-level metrics.
    #
    # Subscribes to an Igniter::Events::Bus (via the Events::Bus#subscribe interface)
    # and maintains in-memory counters and histograms for:
    #   - Total executions (by graph, by status)
    #   - Execution duration histogram (by graph)
    #   - HTTP request counts and durations (recorded directly by the server)
    #
    # All state is protected by a Mutex. Snapshot returns a frozen copy
    # safe to read outside the lock.
    class Collector
      HISTOGRAM_BUCKETS = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0].freeze

      def initialize
        @mutex = Mutex.new
        @counters   = Hash.new(0)  # String(metric{labels}) → Integer
        @histograms = {}           # String(metric_name) → Hash(label_key → histogram_entry)
        @exec_start = {}           # execution_id → Time (for duration tracking)
        @exec_graph = {}           # execution_id → graph_name
      end

      # Called by Events::Bus for every event emitted during an execution.
      def call(event) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
        case event.type
        when :execution_started   then on_execution_started(event)
        when :execution_finished  then on_execution_finished(event, "succeeded")
        when :execution_failed    then on_execution_finished(event, "failed")
        end
      end

      # Record an HTTP request (called directly by the server/router).
      def record_http(method:, path:, status:, duration:)
        @mutex.synchronize do
          inc("igniter_http_requests_total",
              method: method, path: normalized_path(path), status: status.to_s)
          observe_locked("igniter_http_request_duration_seconds", duration,
                         method: method, path: normalized_path(path))
        end
      end

      # Snapshot returns frozen copies of counters and histograms.
      def snapshot
        @mutex.synchronize do
          Snapshot.new(
            counters: @counters.dup.freeze,
            histograms: deep_freeze(@histograms)
          )
        end
      end

      private

      def on_execution_started(event)
        @mutex.synchronize do
          @exec_start[event.execution_id] = event.timestamp
          @exec_graph[event.execution_id] = event.payload[:graph].to_s
        end
      end

      def on_execution_finished(event, status)
        @mutex.synchronize do
          graph      = @exec_graph.delete(event.execution_id) || event.payload[:graph].to_s
          started_at = @exec_start.delete(event.execution_id)

          inc("igniter_executions_total", graph: graph, status: status)

          if started_at
            duration = event.timestamp - started_at
            observe_locked("igniter_execution_duration_seconds", duration, graph: graph)
          end
        end
      end

      def inc(name, labels)
        @counters[metric_key(name, labels)] += 1
      end

      def observe_locked(name, value, labels)
        lkey = label_key(labels)
        @histograms[name] ||= {}
        entry = @histograms[name][lkey] ||= new_histogram_entry(labels)
        HISTOGRAM_BUCKETS.each { |b| entry[:buckets][b] += 1 if value <= b }
        entry[:sum] += value
        entry[:count] += 1
      end

      def new_histogram_entry(labels)
        { labels: labels, buckets: Hash.new(0), sum: 0.0, count: 0 }
      end

      def metric_key(name, labels)
        "#{name}#{label_selector(labels)}"
      end

      def label_key(labels)
        label_selector(labels)
      end

      def label_selector(labels)
        return "" if labels.empty?

        pairs = labels.map { |k, v| "#{k}=\"#{v}\"" }.join(",")
        "{#{pairs}}"
      end

      def normalized_path(path)
        # Collapse dynamic path segments to avoid high-cardinality labels
        path.to_s
            .gsub(%r{/v1/contracts/[^/]+/}, "/v1/contracts/:name/")
            .gsub(%r{/v1/executions/[^/]+}, "/v1/executions/:id")
      end

      def deep_freeze(hash)
        hash.each_with_object({}) do |(name, by_label), memo|
          memo[name] = by_label.each_with_object({}) do |(lkey, entry), inner|
            inner[lkey] = {
              labels: entry[:labels].dup.freeze,
              buckets: entry[:buckets].dup.freeze,
              sum: entry[:sum],
              count: entry[:count]
            }.freeze
          end.freeze
        end.freeze
      end
    end
  end
end
