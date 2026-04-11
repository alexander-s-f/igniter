# frozen_string_literal: true

module Igniter
  module Agents
    # In-process metrics collection with Prometheus text export.
    #
    # Supports three metric types:
    # * **counter**   — monotonically increasing value (:increment)
    # * **gauge**     — arbitrary current value (:gauge)
    # * **histogram** — observed value distribution (:observe)
    #
    # All metric names are coerced to strings. Tags (labels) are stored but not
    # yet aggregated — they are included in the snapshot for external processing.
    #
    # @example
    #   ref = MetricsAgent.start
    #   ref.send(:increment, name: "http.requests", by: 1, tags: { method: "GET" })
    #   ref.send(:gauge,     name: "queue.depth",   value: 42)
    #   ref.send(:observe,   name: "response_time", value: 0.123)
    #
    #   snap = ref.call(:snapshot)
    #   puts snap.counters["http.requests"]   # => 1.0
    #
    #   puts ref.call(:prometheus_text)
    class MetricsAgent < Igniter::Agent
      # Returned by the sync :snapshot query.
      Snapshot = Struct.new(:counters, :gauges, :histograms, keyword_init: true)

      initial_state counters: {}, gauges: {}, histograms: {}

      # Increment a counter.
      #
      # Payload keys:
      #   name [String, Symbol]  — metric name
      #   by   [Numeric]         — increment amount (default: 1)
      #   tags [Hash]            — labels (stored, not aggregated)
      on :increment do |state:, payload:|
        name     = payload.fetch(:name).to_s
        by       = payload.fetch(:by, 1).to_f
        counters = state[:counters].dup
        counters[name] = (counters[name] || 0.0) + by
        state.merge(counters: counters)
      end

      # Set a gauge to an exact value.
      #
      # Payload keys:
      #   name  [String, Symbol]
      #   value [Numeric]
      #   tags  [Hash]
      on :gauge do |state:, payload:|
        name   = payload.fetch(:name).to_s
        value  = payload.fetch(:value).to_f
        gauges = state[:gauges].merge(name => value)
        state.merge(gauges: gauges)
      end

      # Record a histogram observation.
      #
      # Payload keys:
      #   name  [String, Symbol]
      #   value [Numeric]
      on :observe do |state:, payload:|
        name       = payload.fetch(:name).to_s
        value      = payload.fetch(:value).to_f
        histograms = state[:histograms].dup
        bucket     = histograms[name] || { count: 0, sum: 0.0, min: Float::INFINITY,
                                           max: -Float::INFINITY, values: [] }
        updated    = bucket.merge(
          count:  bucket[:count] + 1,
          sum:    bucket[:sum]   + value,
          min:    [bucket[:min], value].min,
          max:    [bucket[:max], value].max,
          values: bucket[:values] + [value]
        )
        state.merge(histograms: histograms.merge(name => updated))
      end

      # Sync snapshot query — returns all current metric values.
      #
      # @return [Snapshot]
      on :snapshot do |state:, **|
        Snapshot.new(
          counters:   state[:counters].dup,
          gauges:     state[:gauges].dup,
          histograms: state[:histograms].transform_values { |h|
            { count: h[:count], sum: h[:sum], min: h[:min], max: h[:max],
              avg: h[:count] > 0 ? h[:sum] / h[:count] : 0.0 }
          }
        )
      end

      # Sync query — render metrics in Prometheus text format.
      #
      # @return [String]
      on :prometheus_text do |state:, **|
        render_prometheus(state)
      end

      # Reset all metrics.
      on :reset do |state:, **|
        state.merge(counters: {}, gauges: {}, histograms: {})
      end

      class << self
        # Render state as Prometheus exposition format.
        #
        # @param state [Hash]
        # @return [String]
        def render_prometheus(state)
          lines = []
          state[:counters].each do |name, value|
            lines << "# TYPE #{name} counter"
            lines << "#{name} #{value}"
          end
          state[:gauges].each do |name, value|
            lines << "# TYPE #{name} gauge"
            lines << "#{name} #{value}"
          end
          state[:histograms].each do |name, h|
            lines << "# TYPE #{name} histogram"
            lines << "#{name}_count #{h[:count]}"
            lines << "#{name}_sum #{h[:sum]}"
          end
          lines.join("\n")
        end
      end
    end
  end
end
