# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerApprovalPolicyContract,
              outputs: %i[status approved requested_capabilities granted_capabilities rejected_capabilities unknown_capabilities reasons decision summary] do
      input :approval_request
      input :approved_by
      input :approved_capabilities

      compute :requested_capabilities, depends_on: [:approval_request] do |approval_request:|
        approval_request.fetch(:requested_capabilities).map(&:to_sym)
      end

      compute :granted_capabilities, depends_on: %i[requested_capabilities approved_capabilities] do |requested_capabilities:, approved_capabilities:|
        Array(approved_capabilities).map(&:to_sym) & requested_capabilities
      end

      compute :rejected_capabilities, depends_on: %i[requested_capabilities granted_capabilities] do |requested_capabilities:, granted_capabilities:|
        requested_capabilities - granted_capabilities
      end

      compute :unknown_capabilities, depends_on: %i[requested_capabilities approved_capabilities] do |requested_capabilities:, approved_capabilities:|
        Array(approved_capabilities).map(&:to_sym) - requested_capabilities
      end

      compute :reasons, depends_on: %i[approved_by rejected_capabilities unknown_capabilities] do |approved_by:, rejected_capabilities:, unknown_capabilities:|
        reasons = []
        reasons << :human_approval_missing if approved_by.to_s.strip.empty?
        reasons << :requested_capabilities_not_fully_granted unless rejected_capabilities.empty?
        reasons << :unknown_capabilities_requested unless unknown_capabilities.empty?
        reasons
      end

      compute :approved, depends_on: [:reasons] do |reasons:|
        reasons.empty?
      end

      compute :status, depends_on: %i[approved approved_by] do |approved:, approved_by:|
        if approved
          :approved
        elsif approved_by.to_s.strip.empty?
          :pending
        else
          :needs_review
        end
      end

      compute :decision, depends_on: %i[status approved approval_request approved_by requested_capabilities granted_capabilities rejected_capabilities unknown_capabilities reasons] do |status:, approved:, approval_request:, approved_by:, requested_capabilities:, granted_capabilities:, rejected_capabilities:, unknown_capabilities:, reasons:|
        {
          kind: :materializer_approval_decision,
          status: status,
          approved: approved,
          approved_by: approved_by,
          contract: approval_request.fetch(:contract),
          requested_capabilities: requested_capabilities,
          granted_capabilities: granted_capabilities,
          rejected_capabilities: rejected_capabilities,
          unknown_capabilities: unknown_capabilities,
          reasons: reasons,
          applies_capabilities: false
        }
      end

      compute :summary, depends_on: %i[status requested_capabilities granted_capabilities reasons] do |status:, requested_capabilities:, granted_capabilities:, reasons:|
        "#{status}: #{granted_capabilities.length}/#{requested_capabilities.length} capabilities granted by policy; reasons=#{reasons.join(",")}."
      end

      output :status
      output :approved
      output :requested_capabilities
      output :granted_capabilities
      output :rejected_capabilities
      output :unknown_capabilities
      output :reasons
      output :decision
      output :summary
    end
  end
end
