# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerApprovalReceiptContract, outputs: %i[status receipt summary] do
      input :approval_policy

      compute :status, depends_on: [:approval_policy] do |approval_policy:|
        approval_policy.fetch(:status)
      end

      compute :receipt, depends_on: [:approval_policy] do |approval_policy:|
        decision = approval_policy.fetch(:decision)
        {
          kind: :materializer_approval_receipt,
          status: approval_policy.fetch(:status),
          approved: approval_policy.fetch(:approved),
          approved_by: decision.fetch(:approved_by),
          contract: decision.fetch(:contract),
          requested_capabilities: approval_policy.fetch(:requested_capabilities),
          granted_capabilities: approval_policy.fetch(:granted_capabilities),
          rejected_capabilities: approval_policy.fetch(:rejected_capabilities),
          unknown_capabilities: approval_policy.fetch(:unknown_capabilities),
          reasons: approval_policy.fetch(:reasons),
          applies_capabilities: decision.fetch(:applies_capabilities),
          review_only: true
        }
      end

      compute :summary, depends_on: [:receipt] do |receipt:|
        "#{receipt.fetch(:status)} approval receipt: #{receipt.fetch(:granted_capabilities).length}/#{receipt.fetch(:requested_capabilities).length} capabilities, applies=#{receipt.fetch(:applies_capabilities)}."
      end

      output :status
      output :receipt
      output :summary
    end
  end
end
