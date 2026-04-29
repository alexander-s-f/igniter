# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :InfrastructureLoopHealthContract, outputs: %i[status loop_state signals summary] do
      input :readiness
      input :manifest_summary
      input :materialization_plan
      input :materialization_parity
      input :migration_plan

      compute :signals, depends_on: %i[readiness materialization_plan materialization_parity migration_plan] do |readiness:, materialization_plan:, materialization_parity:, migration_plan:|
        {
          persistence_ready: readiness.fetch(:ready),
          plan_ready: materialization_plan.fetch(:status) == :ready_for_static_materialization,
          parity_matched: materialization_parity.fetch(:status) == :matched,
          migration_review_only: migration_plan.fetch(:reports).all? do |report|
            report.fetch(:candidates).all? { |candidate| candidate.fetch(:review_only) }
          end,
          migration_stable: migration_plan.fetch(:status) == :stable
        }
      end

      compute :status, depends_on: [:signals] do |signals:|
        signals.values.all? ? :self_supporting : :needs_review
      end

      compute :loop_state, depends_on: %i[status manifest_summary materialization_plan materialization_parity migration_plan] do |status:, manifest_summary:, materialization_plan:, materialization_parity:, migration_plan:|
        {
          status: status,
          capabilities: manifest_summary.fetch(:capability_count),
          schema_version: materialization_plan.fetch(:schema_version),
          checked_capabilities: materialization_parity.fetch(:checked_capabilities),
          migration_candidates: migration_plan.fetch(:candidate_count),
          write_capability_requested: false
        }
      end

      compute :summary, depends_on: %i[status loop_state] do |status:, loop_state:|
        "#{status}: #{loop_state.fetch(:capabilities)} capabilities, schema v#{loop_state.fetch(:schema_version)}, #{loop_state.fetch(:migration_candidates)} migration candidates, no write capability requested."
      end

      output :status
      output :loop_state
      output :signals
      output :summary
    end
  end
end
