# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffAcceptanceContract, outputs: %i[status descriptor checks missing_terms summary] do
      input :setup_handoff
      input :materializer_status
      input :materializer_attempts

      compute :descriptor, depends_on: [:setup_handoff] do |setup_handoff:|
        {
          schema_version: 1,
          kind: :setup_handoff_acceptance,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          evaluates: setup_handoff.fetch(:acceptance_criteria).fetch(:recommended)
        }
      end

      compute :checks, depends_on: %i[setup_handoff materializer_status materializer_attempts] do |setup_handoff:, materializer_status:, materializer_attempts:|
        acceptance = setup_handoff.fetch(:acceptance_criteria)
        descriptor = materializer_status.fetch(:descriptor)

        [
          Companion::Contracts.check(:recommended_scope, acceptance.fetch(:recommended) == :record_blocked_materializer_attempt),
          Companion::Contracts.check(:explicit_attempt_recorded, materializer_attempts.any?),
          Companion::Contracts.check(:expected_phase, %i[awaiting_explicit_approval_record approval_receipt_recorded].include?(materializer_status.fetch(:phase))),
          Companion::Contracts.check(:setup_reads_side_effect_free, acceptance.fetch(:checks).any? { |check| check.fetch(:term) == :setup_reads_stay_side_effect_free }),
          Companion::Contracts.check(:materializer_execution_blocked, descriptor.fetch(:execution_allowed) == false),
          Companion::Contracts.check(:capability_grants_blocked, descriptor.fetch(:grants_capabilities) == false)
        ]
      end

      compute :missing_terms, depends_on: [:checks] do |checks:|
        checks.reject { |check| check.fetch(:present) }.map { |check| check.fetch(:term) }
      end

      compute :status, depends_on: %i[materializer_attempts missing_terms] do |materializer_attempts:, missing_terms:|
        if missing_terms.empty?
          :satisfied
        elsif materializer_attempts.empty?
          :pending
        else
          :needs_review
        end
      end

      compute :summary, depends_on: %i[status missing_terms] do |status:, missing_terms:|
        if status == :satisfied
          "Recommended handoff scope accepted without execution or capability grants."
        else
          "#{status}: waiting on #{missing_terms.join(", ")}."
        end
      end

      output :status
      output :descriptor
      output :checks
      output :missing_terms
      output :summary
    end
  end
end
