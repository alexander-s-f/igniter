# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerReceiptContract, outputs: %i[status receipt events summary] do
      input :materializer_runbook

      compute :status, depends_on: [:materializer_runbook] do |materializer_runbook:|
        materializer_runbook.fetch(:status) == :blocked_until_approval ? :blocked : :needs_review
      end

      compute :events, depends_on: [:materializer_runbook] do |materializer_runbook:|
        materializer_runbook.fetch(:steps).map do |step|
          {
            kind: :materializer_step_blocked,
            step: step.fetch(:name),
            position: step.fetch(:position),
            capability: step.fetch(:capability),
            status: step.fetch(:status),
            reasons: step.fetch(:reasons),
            executed: false,
            review_only: true
          }
        end
      end

      compute :receipt, depends_on: %i[status materializer_runbook events] do |status:, materializer_runbook:, events:|
        {
          kind: :materializer_runbook_receipt,
          status: status,
          runbook_status: materializer_runbook.fetch(:status),
          approval_request: materializer_runbook.fetch(:approval_request),
          blocked_capabilities: materializer_runbook.fetch(:blocked_capabilities),
          step_count: materializer_runbook.fetch(:steps).length,
          blocked_step_count: events.count { |event| event.fetch(:status) == :blocked },
          executed: false,
          review_only: true
        }
      end

      compute :summary, depends_on: [:receipt] do |receipt:|
        "#{receipt.fetch(:status)}: #{receipt.fetch(:blocked_step_count)} materializer steps recorded without execution."
      end

      output :status
      output :receipt
      output :events
      output :summary
    end
  end
end
