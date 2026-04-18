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
          config.peer_registry.query(now: now)
        end

        def meshql(source, now: Time.now.utc)
          MeshQL.parse(source).to_query(config.peer_registry.observations(now: now))
        end

        # Select the best peer for the given capabilities using multi-dimensional scoring.
        # Returns a PlacementDecision (placed? / failed? / degraded?).
        def place(capabilities = nil, policy: PlacementPolicy.new, now: Time.now.utc)
          observations = config.peer_registry.observations(now: now)
          PlacementPlanner.new(observations, policy: policy).place(capabilities)
        end

        # Analyse ownership distribution and recommend transfers to reduce skew.
        # Returns a RebalancePlan (balanced? / transfers / to_routing_plans).
        def rebalance(ownership_registry, capabilities: nil, skew_threshold: RebalancePlanner::DEFAULT_SKEW_THRESHOLD, now: Time.now.utc)
          observations = config.peer_registry.observations(now: now)
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

        # ── Knowledge shard (Phase 5) ───────────────────────────────────────

        # Return (or lazily create) the local knowledge shard for this node.
        def shard
          config.knowledge_shard ||= Igniter::Cluster::RAG::KnowledgeShard.new(
            name: config.peer_name || "local"
          )
        end

        # Search the local shard and return ranked results.
        # v1 — local only. v2 will fan-out to remote :rag-capable peers.
        #
        # @param text     [String]
        # @param tags     [Array<Symbol>]
        # @param limit    [Integer]
        # @param min_score [Float]
        # @return [Array<RAG::RetrievalResult>]
        def retrieve(text, tags: [], limit: 10, min_score: 0.0)
          query = Igniter::Cluster::RAG::RetrievalQuery.new(
            text:      text,
            tags:      tags,
            limit:     limit,
            min_score: min_score
          )
          shard.search(query)
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
