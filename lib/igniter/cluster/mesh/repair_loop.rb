# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Background loop that periodically executes automated routing remediation
    # plans derived from the latest known routing diagnostics report.
    class RepairLoop
      def initialize(config)
        @config  = config
        @running = false
        @thread  = nil
        @mutex   = Mutex.new
      end

      def start
        @mutex.synchronize do
          return if @running

          @running = true
          @thread  = Thread.new { run_loop }
          @thread.abort_on_exception = false
        end
      end

      def stop
        @mutex.synchronize do
          @running = false
          @thread&.kill
          @thread = nil
        end
      end

      def running?
        @mutex.synchronize { @running }
      end

      def heal_once
        report = @config.current_routing_report
        return idle_result(:no_report) unless report

        result = Igniter::Cluster::RoutingPlanExecutor.new(config: @config).run_many(
          Array(report.dig(:routing, :plans)),
          automated_only: true,
          limit: @config.self_heal_limit
        )

        @config.governance_trail&.record(
          :routing_self_heal_tick,
          source: :repair_loop,
          payload: {
            plans: Array(report.dig(:routing, :plans)).size,
            applied: result.applied.size,
            blocked: result.blocked.size,
            skipped: result.skipped.size
          }
        )

        result
      rescue StandardError
        idle_result(:loop_error)
      end

      private

      def run_loop
        loop do
          sleep(@config.self_heal_interval)
          break unless @running

          heal_once
        end
      end

      def idle_result(reason)
        Igniter::Cluster::RoutingPlanResult.new(
          applied: [],
          blocked: [],
          skipped: [],
          summary: {
            status: :idle,
            reason: reason,
            total: 0,
            applied: 0,
            blocked: 0,
            skipped: 0,
            automated_only: true
          }
        )
      end
    end
    end
  end
end
