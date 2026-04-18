# frozen_string_literal: true

require_relative "mesh/errors"
require_relative "mesh/peer_metadata"
require_relative "mesh/peer_identity_envelope"
require_relative "mesh/node_observation"
require_relative "mesh/observation_query"
require_relative "mesh/mesh_ql"
require_relative "mesh/placement_policy"
require_relative "mesh/placement_decision"
require_relative "mesh/placement_planner"
require_relative "mesh/rebalance_plan"
require_relative "mesh/rebalance_planner"
require_relative "mesh/workload_signal"
require_relative "mesh/peer_capacity_report"
require_relative "mesh/workload_tracker"
require_relative "mesh/peer"
require_relative "mesh/peer_registry"
require_relative "mesh/config"
require_relative "mesh/router"
require_relative "mesh/announcer"
require_relative "mesh/poller"
require_relative "mesh/repair_loop"
require_relative "mesh/discovery"
require_relative "mesh/gossip"

module Igniter
  module Cluster
    # Mesh routing for remote nodes inside the cluster layer.
    #
    # Phase 1 — Static Mesh:
    #   Declare peer topology via add_peer. capability: and pinned_to: routing
    #   modes select alive peers at resolution time.
    #
    # Phase 2 — Dynamic Discovery:
    #   Configure seed URLs and call start_discovery!. The local node announces
    #   itself to seeds and polls them for the current peer list in the background.
    module Mesh
      class << self
        def config
          @config ||= Config.new
        end

        def configure
          yield config
          self
        end

        def router
          @router ||= Router.new(config)
        end

        def start_discovery!
          discovery.start
          self
        end

        def stop_discovery!
          @discovery&.stop
          @discovery = nil
          self
        end

        def discovery
          @discovery ||= Discovery.new(config)
        end

        def query(now: Time.now.utc)
          config.peer_registry.query(now: now, workload_tracker: config.workload_tracker)
        end

        def meshql(source, now: Time.now.utc)
          observations = config.peer_registry.observations(now: now, workload_tracker: config.workload_tracker)
          MeshQL.parse(source).to_query(observations)
        end

        # Select the best peer for the given capabilities using multi-dimensional scoring.
        # Returns a PlacementDecision (placed? / failed? / degraded?).
        def place(capabilities = nil, policy: PlacementPolicy.new, now: Time.now.utc)
          observations = config.peer_registry.observations(now: now, workload_tracker: config.workload_tracker)
          PlacementPlanner.new(observations, policy: policy).place(capabilities)
        end

        # Analyse ownership distribution and recommend transfers to reduce skew.
        # Returns a RebalancePlan (balanced? / transfers / to_routing_plans).
        def rebalance(ownership_registry, capabilities: nil, skew_threshold: RebalancePlanner::DEFAULT_SKEW_THRESHOLD, now: Time.now.utc)
          observations = config.peer_registry.observations(now: now, workload_tracker: config.workload_tracker)
          RebalancePlanner.new(
            ownership_registry: ownership_registry,
            observations:       observations,
            capabilities:       capabilities,
            skew_threshold:     skew_threshold
          ).plan
        end

        # Execute a RebalancePlan by transferring ownership claims via RoutingPlanExecutor.
        # Sets config.ownership_registry to registry for the executor to pick up.
        # Returns a RoutingPlanResult (or nil when the plan is already balanced).
        def execute_rebalance_plan!(plan, ownership_registry:, approve: false, label: nil, limit: nil)
          return nil if plan.balanced?

          config.ownership_registry = ownership_registry
          execute_routing_plans!(
            plan.to_routing_plans,
            approve:   approve,
            label:     label,
            limit:     limit
          )
        end

        # Plan and execute rebalancing in one step.
        # Returns [RebalancePlan, RoutingPlanResult | nil].
        def rebalance_and_execute!(ownership_registry, capabilities: nil, skew_threshold: RebalancePlanner::DEFAULT_SKEW_THRESHOLD, approve: false, label: nil, limit: nil, now: Time.now.utc)
          plan = rebalance(ownership_registry, capabilities: capabilities, skew_threshold: skew_threshold, now: now)
          result = execute_rebalance_plan!(plan, ownership_registry: ownership_registry, approve: approve, label: label, limit: limit)
          [plan, result]
        end

        # ── Governance compaction (Phase 6) ────────────────────────────────

        # Compact the governance trail: collapse old events into a signed
        # Checkpoint, keep only `keep_last` recent events in memory/on disk,
        # and optionally persist the Checkpoint to the configured CheckpointStore.
        #
        # @param keep_last  [Integer]
        # @param identity   [Identity, nil]  defaults to Mesh identity
        # @param previous   [Checkpoint, nil] previous checkpoint to chain from
        # @return [CompactionRecord]
        def compact_governance!(keep_last: 20, identity: nil, previous: nil)
          trail    = config.governance_trail
          identity = identity || config.identity

          previous ||= config.checkpoint_store&.load

          rec = trail.compact!(
            keep_last: keep_last,
            identity:  identity,
            peer_name: config.peer_name,
            previous:  previous
          )

          config.checkpoint_store&.save(rec.checkpoint) if rec.checkpoint
          rec
        end

        # ── Peer admission workflow (Phase 8) ──────────────────────────────

        # Submit a peer admission request and receive an immediate decision.
        # The decision may be :admitted, :rejected, :pending_approval, or :already_trusted.
        #
        # @return [Governance::AdmissionDecision]
        def request_admission(peer_name:, node_id:, public_key:, capabilities: [], justification: nil)
          Igniter::Cluster::Governance::AdmissionWorkflow.new(config: config)
            .request_admission(
              peer_name:     peer_name,
              node_id:       node_id,
              public_key:    public_key,
              capabilities:  capabilities,
              justification: justification
            )
        end

        # Approve a pending admission request by its request_id.
        #
        # @return [Governance::AdmissionDecision]
        def approve_admission!(request_id)
          Igniter::Cluster::Governance::AdmissionWorkflow.new(config: config)
            .approve_pending!(request_id)
        end

        # Reject a pending admission request.
        #
        # @return [Governance::AdmissionDecision]
        def reject_admission!(request_id, reason: nil)
          Igniter::Cluster::Governance::AdmissionWorkflow.new(config: config)
            .reject_pending!(request_id, reason: reason)
        end

        # All currently pending admission requests.
        #
        # @return [Array<Governance::AdmissionRequest>]
        def pending_admissions
          (config.admission_queue ||= Igniter::Cluster::Governance::AdmissionQueue.new).pending
        end

        # Expire pending requests older than the policy TTL.
        #
        # @return [Array<Governance::AdmissionDecision>]
        def expire_stale_admissions!(now: Time.now.utc)
          Igniter::Cluster::Governance::AdmissionWorkflow.new(config: config)
            .expire_stale!(now: now)
        end

        # ── Workload signal tracking (Phase 9) ─────────────────────────────

        # Return (or lazily create) the singleton WorkloadTracker for this node.
        def workload_tracker
          config.workload_tracker ||= WorkloadTracker.new
        end

        # Record a single workload signal for a peer-capability interaction.
        # Also records governance trail events when a peer transitions into or
        # out of degraded/overloaded state.
        #
        # @param peer_name   [String]
        # @param capability  [Symbol, nil]
        # @param success     [Boolean]
        # @param duration_ms [Numeric, nil]
        # @param error       [Exception, nil]
        # @return [WorkloadSignal]
        def record_workload(peer_name, capability = nil, success:, duration_ms: nil, error: nil)
          was_degraded   = workload_tracker.report_for(peer_name).degraded?
          was_overloaded = workload_tracker.report_for(peer_name).overloaded?

          signal = workload_tracker.record(peer_name, capability, success: success,
                                           duration_ms: duration_ms, error: error)

          report = workload_tracker.report_for(peer_name)

          if !was_degraded && report.degraded?
            config.governance_trail&.record(:peer_degraded, source: :workload_tracker,
              payload: { peer_name: peer_name, failure_rate: report.failure_rate,
                         capability: capability })
          elsif was_degraded && !report.degraded?
            config.governance_trail&.record(:peer_recovered, source: :workload_tracker,
              payload: { peer_name: peer_name, failure_rate: report.failure_rate,
                         capability: capability })
          end

          if !was_overloaded && report.overloaded?
            config.governance_trail&.record(:peer_overloaded, source: :workload_tracker,
              payload: { peer_name: peer_name, avg_duration_ms: report.avg_duration_ms,
                         capability: capability })
          end

          signal
        end

        # Generate routing remediation plans for all currently degraded peers and,
        # if execute: true, run the automated ones immediately.
        #
        # @param degraded_threshold [Float, nil]
        # @param execute            [Boolean]  run automated plans (default false)
        # @param now                [Time]
        # @return [Hash]  { degraded: [...], plans: [...], results: [...] }
        def repair_from_workload_signals!(degraded_threshold: nil, execute: false, now: Time.now.utc)
          degraded = workload_tracker.degraded_peers(threshold: degraded_threshold)
          overloaded = workload_tracker.overloaded_peers

          problem_peers = (degraded + overloaded).uniq
          return { degraded: [], overloaded: [], plans: [], results: [] } if problem_peers.empty?

          tracker = config.workload_tracker
          registry_observations = config.peer_registry.observations(now: now, workload_tracker: tracker)
          static_observations   = config.peers.map { |p| p.to_observation(now: now, workload_tracker: tracker) }
          all_observations      = (registry_observations + static_observations).uniq(&:name)

          plans = problem_peers.flat_map do |peer_name|
            obs = all_observations.find { |o| o.name == peer_name }
            next [] unless obs

            [
              {
                id:       "workload-repair-#{peer_name}",
                action:   :refresh_capabilities,
                scope:    :mesh_router,
                automated: true,
                requires_approval: false,
                params:   { peer_name: peer_name, reason: :workload_degradation }
              }
            ]
          end

          results = []
          if execute && plans.any?
            results = execute_routing_plans!(plans, automated_only: true,
                                            peer_name: config.peer_name,
                                            label: "workload-repair")
          end

          { degraded: degraded, overloaded: overloaded, plans: plans, results: results }
        end

        # ── Knowledge shard (Phase 5 + 7) ──────────────────────────────────

        # Return (or lazily create) the local knowledge shard for this node.
        def shard
          config.knowledge_shard ||= Igniter::Cluster::RAG::KnowledgeShard.new(
            name: config.peer_name || "local"
          )
        end

        # Search the shard(s) and return ranked results.
        #
        # With distributed: false (default) only the local shard is searched.
        # With distributed: true the query fans out to all :rag-capable peers
        # discovered via the PeerRegistry and results are merged trust-awarely.
        #
        # @param text          [String]
        # @param tags          [Array<Symbol>]
        # @param limit         [Integer]
        # @param min_score     [Float]
        # @param distributed   [Boolean]   false = local only (default)
        # @param require_trust [Boolean]   skip untrusted peers in fan-out (default true)
        # @param timeout       [Numeric]   per-peer HTTP timeout in seconds
        # @param now           [Time]
        # @param http_adapter  [#call, nil]  injectable adapter (tests / custom transport)
        # @return [Array<RAG::RetrievalResult>]
        def retrieve(text, tags: [], limit: 10, min_score: 0.0,
                     distributed: false, require_trust: true, timeout: 5,
                     now: Time.now.utc, http_adapter: nil)
          query = Igniter::Cluster::RAG::RetrievalQuery.new(
            text:      text,
            tags:      tags,
            limit:     limit,
            min_score: min_score
          )

          unless distributed
            return shard.search(query)
          end

          Igniter::Cluster::RAG::FanoutRetriever.new(
            registry:      config.peer_registry,
            local_shard:   config.knowledge_shard,
            adapter:       http_adapter,
            now:           now,
            timeout:       timeout,
            require_trust: require_trust
          ).retrieve(query)
        end

        def trust_admission_plan(peer_name, label: nil)
          Igniter::Cluster::Trust::AdmissionPlanner.new(config: config).plan(peer_name, label: label)
        end

        def admit_trusted_peer!(peer_name, approve: false, label: nil)
          plan = trust_admission_plan(peer_name, label: label)
          Igniter::Cluster::Trust::AdmissionRunner.new(config: config).run(plan, approve: approve)
        end

        def execute_routing_plan!(plan, approve: false, peer_name: nil, label: nil)
          Igniter::Cluster::RoutingPlanExecutor.new(config: config).run(
            plan,
            approve: approve,
            peer_name: peer_name,
            label: label
          )
        end

        def execute_routing_plans!(plans, automated_only: false, approve: false, peer_name: nil, label: nil, limit: nil)
          Igniter::Cluster::RoutingPlanExecutor.new(config: config).run_many(
            plans,
            automated_only: automated_only,
            approve: approve,
            peer_name: peer_name,
            label: label,
            limit: limit
          )
        end

        def execute_reported_routing_plans!(target, automated_only: false, approve: false, peer_name: nil, label: nil, limit: nil)
          config.record_routing_report!(target)

          execute_routing_plans!(
            extract_routing_plans(target),
            automated_only: automated_only,
            approve: approve,
            peer_name: peer_name,
            label: label,
            limit: limit
          )
        end

        def self_heal_routing!(target, limit: nil)
          execute_reported_routing_plans!(target, automated_only: true, limit: limit)
        end

        def start_repair_loop!
          repair_loop.start
          self
        end

        def stop_repair_loop!
          @repair_loop&.stop
          @repair_loop = nil
          self
        end

        def repair_loop
          @repair_loop ||= RepairLoop.new(config)
        end

        def refresh_governance_checkpoint!
          execute_routing_plan!(
            {
              action: :refresh_governance_checkpoint,
              scope: :mesh_governance,
              automated: true,
              requires_approval: false,
              params: {}
            }
          )
        end

        def relax_governance_requirements!(governance_keys:, peer_candidates: [], approve: false)
          execute_routing_plan!(
            {
              action: :relax_governance_requirements,
              scope: :routing_governance,
              automated: false,
              requires_approval: true,
              params: {
                governance_keys: Array(governance_keys),
                peer_candidates: Array(peer_candidates)
              }
            },
            approve: approve
          )
        end

        def reset!
          stop_discovery!
          stop_repair_loop!
          @config = nil
          @router = nil
        end

        private

        def extract_routing_plans(target)
          report =
            if target.respond_to?(:diagnostics)
              target.diagnostics.to_h
            elsif target.is_a?(Hash)
              target
            elsif target.respond_to?(:to_h)
              target.to_h
            else
              {}
            end

          Array(report.dig(:routing, :plans))
        end
      end
    end
  end
end
