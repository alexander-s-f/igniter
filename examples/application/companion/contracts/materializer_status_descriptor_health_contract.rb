# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerStatusDescriptorHealthContract, outputs: %i[status check_count missing_terms checks summary] do
      input :materializer_status

      compute :descriptor, depends_on: [:materializer_status] do |materializer_status:|
        materializer_status.fetch(:descriptor, {})
      end

      compute :checks, depends_on: %i[materializer_status descriptor] do |materializer_status:, descriptor:|
        command_intents = descriptor.fetch(:command_intents, {})
        attempt = command_intents.fetch(:attempt, {})
        approval = command_intents.fetch(:approval, {})
        audits = descriptor.fetch(:audits, {})

        [
          Companion::Contracts.check(:schema_version, descriptor.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :materializer_status),
          Companion::Contracts.check(:review_only, descriptor.fetch(:review_only, nil) == true),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_execution, descriptor.fetch(:execution_allowed, nil) == false),
          Companion::Contracts.check(:app_boundary_required, descriptor.fetch(:app_boundary_required, nil) == true),
          Companion::Contracts.check(:history_targets, descriptor.fetch(:histories, {}) == { attempts: :materializer_attempts, approvals: :materializer_approvals }),
          Companion::Contracts.check(:command_intents, attempt.fetch(:operation, nil) == :history_append && approval.fetch(:operation, nil) == :history_append && approval.fetch(:applies_capabilities, nil) == false),
          Companion::Contracts.check(:audit_counts, audits.fetch(:attempts, {}).key?(:count) && audits.fetch(:approvals, {}).key?(:count)),
          Companion::Contracts.check(:status_alignment, descriptor.fetch(:status, nil) == materializer_status.fetch(:status, nil) && descriptor.fetch(:phase, nil) == materializer_status.fetch(:phase, nil))
        ]
      end

      compute :missing_terms, depends_on: [:checks] do |checks:|
        checks.reject { |check| check.fetch(:present) }.map { |check| check.fetch(:term) }
      end

      compute :check_count, depends_on: [:checks] do |checks:|
        checks.length
      end

      compute :status, depends_on: [:missing_terms] do |missing_terms:|
        missing_terms.empty? ? :stable : :drift
      end

      compute :summary, depends_on: %i[status check_count missing_terms] do |status:, check_count:, missing_terms:|
        if status == :stable
          "#{check_count} materializer status descriptor terms stable."
        else
          "Materializer status descriptor drift: #{missing_terms.join(", ")}."
        end
      end

      output :status
      output :check_count
      output :missing_terms
      output :checks
      output :summary
    end
  end
end
