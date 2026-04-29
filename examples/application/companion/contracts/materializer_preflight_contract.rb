# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerPreflightContract, outputs: %i[status checklist evidence approval_request summary] do
      input :infrastructure_loop_health
      input :materialization_parity
      input :migration_plan
      input :materializer_gate

      compute :checklist, depends_on: %i[infrastructure_loop_health materialization_parity migration_plan materializer_gate] do |infrastructure_loop_health:, materialization_parity:, migration_plan:, materializer_gate:|
        {
          infrastructure_loop_self_supporting: infrastructure_loop_health.fetch(:status) == :self_supporting,
          parity_matched: materialization_parity.fetch(:status) == :matched,
          migration_review_only: migration_plan.fetch(:reports).all? do |report|
            report.fetch(:candidates).all? { |candidate| candidate.fetch(:review_only) }
          end,
          human_approval_required: materializer_gate.fetch(:reasons).include?(:human_approval_required),
          capabilities_blocked: materializer_gate.fetch(:blocked_capabilities).any?,
          no_capabilities_granted: materializer_gate.fetch(:approved_capabilities).empty?
        }
      end

      compute :status, depends_on: [:checklist] do |checklist:|
        if checklist.values.all?
          :blocked_until_approval
        else
          :needs_review
        end
      end

      compute :evidence, depends_on: %i[infrastructure_loop_health materialization_parity migration_plan materializer_gate] do |infrastructure_loop_health:, materialization_parity:, migration_plan:, materializer_gate:|
        {
          loop_status: infrastructure_loop_health.fetch(:status),
          schema_version: infrastructure_loop_health.fetch(:loop_state).fetch(:schema_version),
          checked_capabilities: materialization_parity.fetch(:checked_capabilities),
          migration_status: migration_plan.fetch(:status),
          migration_candidates: migration_plan.fetch(:candidate_count),
          blocked_capabilities: materializer_gate.fetch(:blocked_capabilities),
          reasons: materializer_gate.fetch(:reasons)
        }
      end

      compute :approval_request, depends_on: [:materializer_gate] do |materializer_gate:|
        materializer_gate.fetch(:approval_request)
      end

      compute :summary, depends_on: %i[status approval_request] do |status:, approval_request:|
        "#{status}: #{approval_request.fetch(:contract)} materializer request remains review-only."
      end

      output :status
      output :checklist
      output :evidence
      output :approval_request
      output :summary
    end
  end
end
