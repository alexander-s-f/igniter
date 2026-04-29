# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :MaterializerApprovalContract, outputs: %i[result mutation] do
      input :receipt

      compute :result, depends_on: [:receipt] do |receipt:|
        body = receipt.fetch(:receipt)
        if body.fetch(:review_only) && body.fetch(:applies_capabilities) == false
          Companion::Contracts.command_result(
            :success,
            :materializer_approval_recordable,
            body.fetch(:kind),
            :materializer_approval_recorded,
            body.fetch(:status)
          )
        else
          Companion::Contracts.command_result(
            :failure,
            :materializer_approval_applies_capabilities,
            body.fetch(:kind),
            :materializer_approval_refused,
            :refused
          )
        end
      end

      compute :mutation, depends_on: %i[result receipt] do |result:, receipt:|
        body = receipt.fetch(:receipt)
        if result.fetch(:success)
          Companion::Contracts.history_append(
            :materializer_approvals,
            {
              kind: body.fetch(:kind),
              status: body.fetch(:status),
              approved: body.fetch(:approved),
              approved_by: body.fetch(:approved_by),
              contract: body.fetch(:contract),
              requested_capabilities: body.fetch(:requested_capabilities),
              granted_capabilities: body.fetch(:granted_capabilities),
              rejected_capabilities: body.fetch(:rejected_capabilities),
              unknown_capabilities: body.fetch(:unknown_capabilities),
              reasons: body.fetch(:reasons),
              applies_capabilities: body.fetch(:applies_capabilities),
              review_only: body.fetch(:review_only)
            }
          )
        else
          Companion::Contracts.no_mutation
        end
      end

      output :result
      output :mutation
    end
  end
end
