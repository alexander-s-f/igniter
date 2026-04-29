# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerApprovalAuditTrailContract,
              outputs: %i[approval_count pending_count approved_count applied_count granted_capabilities rejected_capabilities last_approval summary] do
      input :approvals

      compute :ordered_approvals, depends_on: [:approvals] do |approvals:|
        Array(approvals).sort_by { |approval| approval.fetch(:index).to_i }
      end

      compute :approval_count, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals.length
      end

      compute :pending_count, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals.count { |approval| approval.fetch(:status).to_sym == :pending }
      end

      compute :approved_count, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals.count { |approval| approval.fetch(:approved) || approval.fetch(:status).to_sym == :approved }
      end

      compute :applied_count, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals.count { |approval| approval.fetch(:applies_capabilities) }
      end

      compute :granted_capabilities, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals
          .flat_map { |approval| Array(approval.fetch(:granted_capabilities, [])) }
          .map(&:to_sym)
          .uniq
          .sort
      end

      compute :rejected_capabilities, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals
          .flat_map { |approval| Array(approval.fetch(:rejected_capabilities, [])) }
          .map(&:to_sym)
          .uniq
          .sort
      end

      compute :last_approval, depends_on: [:ordered_approvals] do |ordered_approvals:|
        ordered_approvals.last&.dup
      end

      compute :summary, depends_on: %i[approval_count pending_count approved_count applied_count] do |approval_count:, pending_count:, approved_count:, applied_count:|
        "#{approval_count} materializer approvals, #{pending_count} pending, #{approved_count} approved, #{applied_count} applied."
      end

      output :approval_count
      output :pending_count
      output :approved_count
      output :applied_count
      output :granted_capabilities
      output :rejected_capabilities
      output :last_approval
      output :summary
    end
  end
end
