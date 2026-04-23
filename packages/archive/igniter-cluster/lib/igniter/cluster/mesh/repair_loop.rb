# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Background loop that periodically executes automated routing remediation
    # plans from two signal sources:
    #
    #   1. Routing diagnostics — plans extracted from the configured report provider
    #      (same as before; governs routing plan executor actions).
    #
    #   2. Workload signals — plans generated from WorkloadTracker degraded/overloaded
    #      peers (fires only when config.workload_tracker is set).
    #
    # Each tick calls heal_once which runs both sources in sequence and records
    # separate governance trail events for each: :routing_self_heal_tick and
    # :workload_self_heal_tick.
    #
    # heal_once is fully backward-compatible — it returns the RoutingPlanResult
    # from the routing repair path (or idle_result when no report is available).
    # Workload repair is a side-effect of the same tick.
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

      # One unified repair tick: routing plans + workload signals.
      #
      # Returns the RoutingPlanResult from the routing path (backward-compatible).
      # Workload repair runs as a side-effect and records :workload_self_heal_tick
      # in the governance trail when problem peers are found.
      def heal_once
        routing_result = execute_routing_heal
        execute_workload_heal if @config.workload_tracker
        routing_result
      end

      private

      def run_loop
        loop do
          sleep(@config.self_heal_interval)
          break unless @running

          heal_once
        end
      end

      def execute_routing_heal
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
            plans:   Array(report.dig(:routing, :plans)).size,
            applied: result.applied.size,
            blocked: result.blocked.size,
            skipped: result.skipped.size
          }
        )

        result
      rescue StandardError
        idle_result(:loop_error)
      end

      def execute_workload_heal
        tracker       = @config.workload_tracker
        degraded      = tracker.degraded_peers
        overloaded    = tracker.overloaded_peers
        problem_peers = (degraded + overloaded).uniq

        return if problem_peers.empty?

        now          = Time.now.utc
        registry_obs = @config.peer_registry.observations(now: now, workload_tracker: tracker)
        static_obs   = @config.peers.map { |p| p.to_observation(now: now, workload_tracker: tracker) }
        all_obs      = (registry_obs + static_obs).uniq(&:name)

        plans = problem_peers.flat_map do |peer_name|
          obs = all_obs.find { |o| o.name == peer_name }
          next [] unless obs

          [{
            id:                "workload-repair-#{peer_name}",
            action:            :refresh_capabilities,
            scope:             :mesh_router,
            automated:         true,
            requires_approval: false,
            params:            { peer_name: peer_name, reason: :workload_degradation }
          }]
        end

        return if plans.empty?

        result = Igniter::Cluster::RoutingPlanExecutor.new(config: @config).run_many(
          plans,
          automated_only: true,
          limit:          @config.self_heal_limit
        )

        @config.governance_trail&.record(
          :workload_self_heal_tick,
          source:  :repair_loop,
          payload: {
            degraded:   degraded,
            overloaded: overloaded,
            plans:      plans.size,
            applied:    result.applied.size,
            blocked:    result.blocked.size
          }
        )
      rescue StandardError
        nil
      end

      def idle_result(reason)
        Igniter::Cluster::RoutingPlanResult.new(
          applied: [],
          blocked: [],
          skipped: [],
          summary: {
            status:         :idle,
            reason:         reason,
            total:          0,
            applied:        0,
            blocked:        0,
            skipped:        0,
            automated_only: true
          }
        )
      end
    end
    end
  end
end
