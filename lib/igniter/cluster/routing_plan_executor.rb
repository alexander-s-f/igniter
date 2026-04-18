# frozen_string_literal: true

module Igniter
  module Cluster
    class RoutingPlanExecutor
      def initialize(config:)
        @config = config
      end

      def run_many(plans, automated_only: false, approve: false, peer_name: nil, label: nil, limit: nil)
        normalized_plans = Array(plans).map { |plan| normalize_plan(plan) }
        normalized_plans = normalized_plans.first(limit) if limit

        applied = []
        blocked = []
        skipped = []

        normalized_plans.each do |plan|
          if automated_only && !plan[:automated]
            skipped << {
              action: plan[:action],
              reason: :manual_plan,
              params: plan[:params]
            }
            next
          end

          result = run(plan, approve: approve, peer_name: peer_name, label: label)
          applied.concat(result.applied)
          blocked.concat(result.blocked)
          skipped.concat(result.skipped)
        end

        RoutingPlanResult.new(
          applied: applied,
          blocked: blocked,
          skipped: skipped,
          summary: {
            status: applied.any? ? :applied : (blocked.any? ? :blocked : :skipped),
            total: normalized_plans.size,
            applied: applied.size,
            blocked: blocked.size,
            skipped: skipped.size,
            automated_only: automated_only
          }
        )
      end

      def run(plan, approve: false, peer_name: nil, label: nil)
        routing_plan = normalize_plan(plan)
        action = routing_plan[:action]&.to_sym

        case action
        when :admit_trusted_peer
          execute_trust_admission(routing_plan, approve: approve, peer_name: peer_name, label: label)
        when :refresh_peer_health
          execute_peer_health_refresh(routing_plan)
        when :discover_capability_peers, :retry_after_discovery, :find_policy_compatible_peer, :retry_routing
          execute_topology_refresh(routing_plan)
        when :refresh_governance_checkpoint
          execute_governance_refresh(routing_plan)
        when :relax_governance_requirements
          execute_governance_relaxation(routing_plan, approve: approve)
        when :transfer_ownership
          execute_ownership_transfer(routing_plan)
        else
          blocked(:unsupported_action, routing_plan)
        end
      end

      private

      attr_reader :config

      def execute_trust_admission(plan, approve:, peer_name:, label:)
        candidate = peer_name || Array(plan.dig(:params, :peer_candidates)).first
        return blocked(:selection_required, plan) if candidate.to_s.strip.empty?

        admission = Igniter::Cluster::Trust::AdmissionPlanner.new(config: config).plan(candidate, label: label)
        result = Igniter::Cluster::Trust::AdmissionRunner.new(config: config).run(admission, approve: approve)
        summary = result.summary.merge(source_plan_action: plan[:action], candidate_peer: candidate)

        config.governance_trail&.record(
          result.applied? ? :routing_plan_applied : :routing_plan_blocked,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            candidate_peer: candidate,
            status: summary[:status],
            approve: approve
          }
        )

        RoutingPlanResult.new(
          applied: result.applied.map { |entry| entry.merge(source_plan_action: plan[:action], candidate_peer: candidate) },
          blocked: result.blocked.map { |entry| entry.merge(source_plan_action: plan[:action], candidate_peer: candidate) },
          skipped: Array(result.respond_to?(:skipped) ? result.skipped : []).map { |entry| entry.merge(source_plan_action: plan[:action], candidate_peer: candidate) },
          summary: summary
        )
      end

      def execute_peer_health_refresh(plan)
        selected_url = plan.dig(:params, :selected_url)
        peer_name = plan.dig(:params, :peer_name)
        reachable = probe_peer_health(selected_url)

        config.governance_trail&.record(
          :peer_health_refreshed,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            peer_name: peer_name,
            selected_url: selected_url,
            reachable: reachable
          }
        )
        config.governance_trail&.record(
          :routing_plan_applied,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            status: :applied,
            peer_name: peer_name
          }
        )

        RoutingPlanResult.new(
          applied: [
            {
              action: plan[:action],
              status: :applied,
              scope: plan[:scope],
              params: plan[:params],
              peer_name: peer_name,
              selected_url: selected_url,
              reachable: reachable
            }
          ],
          blocked: [],
          summary: {
            status: :applied,
            source_plan_action: plan[:action],
            peer_name: peer_name,
            reachable: reachable
          }
        )
      end

      def execute_topology_refresh(plan)
        seeds = Array(config.seeds)
        before = config.peer_registry.size
        refresh_topology!
        after = config.peer_registry.size

        config.governance_trail&.record(
          :mesh_topology_refreshed,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            seeds: seeds.size,
            peers_before: before,
            peers_after: after
          }
        )
        config.governance_trail&.record(
          :routing_plan_applied,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            status: :applied,
            seeds: seeds.size
          }
        )

        RoutingPlanResult.new(
          applied: [
            {
              action: plan[:action],
              status: :applied,
              scope: plan[:scope],
              params: plan[:params],
              seeds: seeds.size,
              peers_before: before,
              peers_after: after
            }
          ],
          blocked: [],
          summary: {
            status: :applied,
            source_plan_action: plan[:action],
            seeds: seeds.size,
            peers_before: before,
            peers_after: after
          }
        )
      end

      def execute_governance_refresh(plan)
        checkpoint = config.governance_checkpoint(limit: 10)
        announced = announce_governance_refresh

        config.governance_trail&.record(
          :governance_checkpoint_refreshed,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            crest_digest: checkpoint.crest_digest,
            latest_type: checkpoint.crest[:latest_type],
            total: checkpoint.crest[:total],
            announced_to: announced
          }
        )

        applied_entry = {
          action: plan[:action],
          status: :applied,
          scope: plan[:scope],
          params: plan[:params],
          checkpoint: {
            node_id: checkpoint.node_id,
            peer_name: checkpoint.peer_name,
            crest_digest: checkpoint.crest_digest,
            latest_type: checkpoint.crest[:latest_type],
            total: checkpoint.crest[:total]
          },
          announced_to: announced
        }

        config.governance_trail&.record(
          :routing_plan_applied,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            status: :applied,
            announced_to: announced
          }
        )

        RoutingPlanResult.new(
          applied: [applied_entry],
          blocked: [],
          summary: {
            status: :applied,
            source_plan_action: plan[:action],
            announced_to: announced,
            checkpoint: applied_entry[:checkpoint]
          }
        )
      end

      def execute_governance_relaxation(plan, approve:)
        return blocked(:approval_required, plan) if plan[:requires_approval] && !approve

        governance_keys = Array(plan.dig(:params, :governance_keys)).map(&:to_sym).uniq.sort
        peer_candidates = Array(plan.dig(:params, :peer_candidates)).map(&:to_s).reject(&:empty?).uniq.sort

        config.governance_trail&.record(
          :governance_requirements_relaxed,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            governance_keys: governance_keys,
            peer_candidates: peer_candidates,
            scope: plan[:scope]
          }
        )
        config.governance_trail&.record(
          :routing_plan_applied,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            status: :applied
          }
        )

        applied_entry = {
          action: plan[:action],
          status: :applied,
          scope: plan[:scope],
          params: plan[:params],
          advisory_only: true
        }

        RoutingPlanResult.new(
          applied: [applied_entry],
          blocked: [],
          summary: {
            status: :applied,
            source_plan_action: plan[:action],
            governance_keys: governance_keys,
            peer_candidates: peer_candidates,
            advisory_only: true
          }
        )
      end

      def execute_ownership_transfer(plan)
        registry = config.ownership_registry
        return blocked(:no_ownership_registry, plan) unless registry

        entity_type = plan.dig(:params, :entity_type).to_s
        entity_id   = plan.dig(:params, :entity_id).to_s
        from_owner  = plan.dig(:params, :from_owner).to_s
        to_owner    = plan.dig(:params, :to_owner).to_s

        existing = registry.lookup(entity_type, entity_id)
        return blocked(:claim_not_found, plan) unless existing
        return blocked(:owner_mismatch, plan) if existing.owner != from_owner

        registry.claim(entity_type, entity_id, owner: to_owner)

        config.governance_trail&.record(
          :ownership_transferred,
          source: :routing_plan_executor,
          payload: {
            action:      plan[:action],
            entity_type: entity_type,
            entity_id:   entity_id,
            from_owner:  from_owner,
            to_owner:    to_owner
          }
        )
        config.governance_trail&.record(
          :routing_plan_applied,
          source: :routing_plan_executor,
          payload: { action: plan[:action], status: :applied }
        )

        RoutingPlanResult.new(
          applied: [{
            action:      plan[:action],
            status:      :applied,
            scope:       plan[:scope],
            params:      plan[:params],
            entity_type: entity_type,
            entity_id:   entity_id,
            from_owner:  from_owner,
            to_owner:    to_owner
          }],
          blocked: [],
          summary: {
            status:             :applied,
            source_plan_action: plan[:action],
            entity_type:        entity_type,
            entity_id:          entity_id,
            from_owner:         from_owner,
            to_owner:           to_owner
          }
        )
      end

      def blocked(reason, plan)
        config.governance_trail&.record(
          :routing_plan_blocked,
          source: :routing_plan_executor,
          payload: {
            action: plan[:action],
            reason: reason
          }
        )

        RoutingPlanResult.new(
          applied: [],
          blocked: [
            {
              action: plan[:action],
              reason: reason,
              params: plan[:params]
            }
          ],
          summary: {
            status: :blocked,
            reason: reason,
            source_plan_action: plan[:action]
          }
        )
      end

      def announce_governance_refresh
        return 0 unless config.peer_name && config.local_url && Array(config.seeds).any?

        Igniter::Cluster::Mesh::Announcer.new(config).announce_all
        Array(config.seeds).size
      rescue StandardError
        0
      end

      def refresh_topology!
        Igniter::Cluster::Mesh::Announcer.new(config).announce_all
        Igniter::Cluster::Mesh::Poller.new(config).poll_once
      rescue StandardError
        nil
      end

      def probe_peer_health(selected_url)
        return nil if selected_url.to_s.strip.empty?

        Igniter::Cluster::Mesh.router.invalidate_health!(selected_url)
        Igniter::Server::Client.new(selected_url, timeout: 3).health
        true
      rescue StandardError
        false
      end

      def normalize_plan(plan)
        if plan.respond_to?(:to_h)
          symbolize(plan.to_h)
        else
          symbolize(Hash(plan || {}))
        end
      end

      def symbolize(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested), memo|
            memo[key.to_sym] = symbolize(nested)
          end
        when Array
          value.map { |item| symbolize(item) }
        else
          value
        end
      end
    end
  end
end
