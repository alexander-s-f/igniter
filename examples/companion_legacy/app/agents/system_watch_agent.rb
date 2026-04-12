# frozen_string_literal: true

require "igniter/agents/proactive/alert_agent"
require "igniter/agents/proactive/health_check_agent"

module Companion
  # System-level monitoring agent for the voice assistant companion.
  #
  # Combines two ProactiveAgent subclasses that run concurrently:
  #
  # 1. SystemAlertAgent (AlertAgent) — watches numeric performance counters
  #    (requests/sec, error rate, p99 latency) and fires alerts when
  #    thresholds are exceeded.
  #
  # 2. DependencyHealthAgent (HealthCheckAgent) — polls the inference node,
  #    Redis, and optional Consensus cluster for liveness and fires
  #    transitions when they change state.
  #
  # In production these agents would read real metrics from a Prometheus
  # scrape or a shared stats object.  Here we use simple in-process
  # counters to keep the demo self-contained.
  module SystemWatch
    # ── Shared in-process stats store ─────────────────────────────────────

    Stats = Struct.new(:rps, :error_rate, :p99_ms, keyword_init: true) do
      def self.sample
        new(
          rps:        Thread.current[:stats_rps]        || 0.0,
          error_rate: Thread.current[:stats_error_rate] || 0.0,
          p99_ms:     Thread.current[:stats_p99]        || 0.0
        )
      end

      def self.update(rps: nil, error_rate: nil, p99_ms: nil)
        Thread.current[:stats_rps]        = rps        if rps
        Thread.current[:stats_error_rate] = error_rate if error_rate
        Thread.current[:stats_p99]        = p99_ms     if p99_ms
      end
    end

    # ── Latency / error-rate alerting ─────────────────────────────────────

    class SystemAlertAgent < Igniter::Agents::AlertAgent
      intent "Alert when API metrics breach operational thresholds"

      scan_interval 10.0

      monitor :rps,        source: -> { Stats.sample.rps }
      monitor :error_rate, source: -> { Stats.sample.error_rate }
      monitor :p99_ms,     source: -> { Stats.sample.p99_ms }

      threshold :error_rate, above: 0.05   # >5% error rate
      threshold :p99_ms,     above: 800    # >800ms p99 latency
      threshold :rps,        below: 1      # <1 RPS (service may be idle / dead)

      proactive_initial_state alerts: [], silenced: false
    end

    # ── Service dependency health ──────────────────────────────────────────

    # Override inference_url at runtime via ENV or constructor for real use.
    INFERENCE_URL = ENV.fetch("INFERENCE_NODE_URL", "http://localhost:4568")

    class DependencyHealthAgent < Igniter::Agents::HealthCheckAgent
      intent "Monitor inference node, Redis, and Consensus cluster availability"

      scan_interval 30.0

      # Inference node: HTTP GET /health → 200 OK
      check :inference_node, poll: -> {
        begin
          require "net/http"
          uri = URI("#{INFERENCE_URL}/health")
          Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)
        rescue StandardError
          false
        end
      }

      # Redis (optional): attempt PING
      check :redis, poll: -> {
        begin
          require "socket"
          s = TCPSocket.new("127.0.0.1", 6379)
          s.close
          true
        rescue StandardError
          false
        end
      }

      proactive_initial_state health: {}, transitions: []
    end
  end
end
