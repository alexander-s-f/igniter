# frozen_string_literal: true

module Igniter
  module Cluster
    class RoutingPlanExecutor
      def initialize(config:)
        @config = config
      end

      def run(plan, approve: false, peer_name: nil, label: nil)
        routing_plan = normalize_plan(plan)
        action = routing_plan[:action]&.to_sym

        case action
        when :admit_trusted_peer
          execute_trust_admission(routing_plan, approve: approve, peer_name: peer_name, label: label)
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
          summary: summary
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
