# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :MaterializerAttemptContract, outputs: %i[result mutation] do
      input :receipt

      compute :result, depends_on: [:receipt] do |receipt:|
        body = receipt.fetch(:receipt)
        if body.fetch(:review_only) && body.fetch(:executed) == false
          Companion::Contracts.command_result(
            :success,
            :materializer_attempt_recordable,
            body.fetch(:kind),
            :materializer_attempt_blocked,
            body.fetch(:status)
          )
        else
          Companion::Contracts.command_result(
            :failure,
            :materializer_attempt_not_review_only,
            body.fetch(:kind),
            :materializer_attempt_refused,
            :refused
          )
        end
      end

      compute :mutation, depends_on: %i[result receipt] do |result:, receipt:|
        body = receipt.fetch(:receipt)
        if result.fetch(:success)
          Companion::Contracts.history_append(
            :materializer_attempts,
            {
              kind: body.fetch(:kind),
              status: body.fetch(:status),
              approval_request: body.fetch(:approval_request),
              blocked_capabilities: body.fetch(:blocked_capabilities),
              blocked_step_count: body.fetch(:blocked_step_count),
              executed: body.fetch(:executed),
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
