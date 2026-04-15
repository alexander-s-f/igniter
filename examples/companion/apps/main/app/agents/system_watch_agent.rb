# frozen_string_literal: true

require "igniter/sdk/agents/proactive/alert_agent"
require "igniter/sdk/agents/proactive/health_check_agent"

module Companion
  module SystemWatch
    Stats = Struct.new(:rps, :error_rate, :p99_ms, keyword_init: true) do
      def self.sample
        new(
          rps: Thread.current[:stats_rps] || 0.0,
          error_rate: Thread.current[:stats_error_rate] || 0.0,
          p99_ms: Thread.current[:stats_p99] || 0.0
        )
      end

      def self.update(rps: nil, error_rate: nil, p99_ms: nil)
        Thread.current[:stats_rps] = rps if rps
        Thread.current[:stats_error_rate] = error_rate if error_rate
        Thread.current[:stats_p99] = p99_ms if p99_ms
      end
    end

    class SystemAlertAgent < Igniter::Agents::AlertAgent
      intent "Alert when API metrics breach operational thresholds"

      scan_interval 10.0

      monitor :rps, source: -> { Stats.sample.rps }
      monitor :error_rate, source: -> { Stats.sample.error_rate }
      monitor :p99_ms, source: -> { Stats.sample.p99_ms }

      threshold :error_rate, above: 0.05
      threshold :p99_ms, above: 800
      threshold :rps, below: 1

      proactive_initial_state alerts: [], silenced: false
    end

    INFERENCE_URL = ENV.fetch("INFERENCE_NODE_URL", "http://localhost:4568")

    class DependencyHealthAgent < Igniter::Agents::HealthCheckAgent
      intent "Monitor inference node, Redis, and Consensus cluster availability"

      scan_interval 30.0

      check :inference_node, poll: lambda {
        begin
          require "net/http"
          uri = URI("#{INFERENCE_URL}/health")
          Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)
        rescue StandardError
          false
        end
      }

      check :redis, poll: lambda {
        begin
          require "socket"
          socket = TCPSocket.new("127.0.0.1", 6379)
          socket.close
          true
        rescue StandardError
          false
        end
      }

      proactive_initial_state health: {}, transitions: []
    end
  end
end
