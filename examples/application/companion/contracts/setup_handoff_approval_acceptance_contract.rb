# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffApprovalAcceptanceContract, outputs: %i[status descriptor checks missing_terms summary] do
      input :materializer_status
      input :materializer_attempts
      input :materializer_approvals

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_approval_acceptance,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          evaluates: :record_materializer_approval_receipt
        }
      end

      compute :checks, depends_on: %i[materializer_status materializer_attempts materializer_approvals] do |materializer_status:, materializer_attempts:, materializer_approvals:|
        descriptor = materializer_status.fetch(:descriptor)
        approval_audit = materializer_status.fetch(:approval_audit)

        [
          Companion::Contracts.check(:explicit_attempt_recorded, materializer_attempts.any?),
          Companion::Contracts.check(:explicit_approval_recorded, materializer_approvals.any?),
          Companion::Contracts.check(:expected_phase, materializer_status.fetch(:phase) == :approval_receipt_recorded),
          Companion::Contracts.check(:approval_application_absent, approval_audit.fetch(:applied_count).zero?),
          Companion::Contracts.check(:materializer_execution_blocked, descriptor.fetch(:execution_allowed) == false),
          Companion::Contracts.check(:capability_grants_blocked, descriptor.fetch(:grants_capabilities) == false)
        ]
      end

      compute :missing_terms, depends_on: [:checks] do |checks:|
        checks.reject { |check| check.fetch(:present) }.map { |check| check.fetch(:term) }
      end

      compute :status, depends_on: %i[materializer_approvals missing_terms] do |materializer_approvals:, missing_terms:|
        if missing_terms.empty?
          :satisfied
        elsif materializer_approvals.empty?
          :pending
        else
          :needs_review
        end
      end

      compute :summary, depends_on: %i[status missing_terms] do |status:, missing_terms:|
        if status == :satisfied
          "Approval receipt accepted as audit data; no capabilities were applied."
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
