# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffLifecycleContract, outputs: %i[status descriptor stages current_stage next_action summary] do
      input :setup_handoff
      input :setup_handoff_acceptance
      input :setup_handoff_approval_acceptance
      input :materializer_status

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_lifecycle,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          sources: %i[
            setup_handoff setup_handoff_acceptance
            setup_handoff_approval_acceptance materializer_status
          ]
        }
      end

      compute :stages,
              depends_on: %i[setup_handoff setup_handoff_acceptance setup_handoff_approval_acceptance] do |setup_handoff:, setup_handoff_acceptance:, setup_handoff_approval_acceptance:|
        [
          {
            name: :handoff_ready,
            status: setup_handoff.fetch(:status),
            complete: setup_handoff.fetch(:status) == :stable,
            view: "/setup/handoff.json",
            mutation: nil
          },
          {
            name: :attempt_receipt,
            status: setup_handoff_acceptance.fetch(:status),
            complete: setup_handoff_acceptance.fetch(:status) == :satisfied,
            view: "/setup/handoff/acceptance.json",
            mutation: "POST /setup/handoff/acceptance/record"
          },
          {
            name: :approval_receipt,
            status: setup_handoff_approval_acceptance.fetch(:status),
            complete: setup_handoff_approval_acceptance.fetch(:status) == :satisfied,
            view: "/setup/handoff/approval-acceptance.json",
            mutation: "POST /setup/handoff/approval-acceptance/record"
          }
        ]
      end

      compute :current_stage, depends_on: [:stages] do |stages:|
        stages.find { |stage| !stage.fetch(:complete) }&.fetch(:name) || :complete
      end

      compute :status, depends_on: [:stages] do |stages:|
        if stages.all? { |stage| stage.fetch(:complete) }
          :complete
        elsif stages.any? { |stage| stage.fetch(:status) == :needs_review }
          :needs_review
        else
          :pending
        end
      end

      compute :next_action, depends_on: %i[current_stage materializer_status] do |current_stage:, materializer_status:|
        case current_stage
        when :attempt_receipt
          :record_blocked_attempt
        when :approval_receipt
          :record_approval_receipt
        when :complete
          :review_materializer_status
        else
          materializer_status.fetch(:next_action)
        end
      end

      compute :summary, depends_on: %i[status current_stage next_action] do |status:, current_stage:, next_action:|
        "#{status}: current_stage=#{current_stage}, next=#{next_action}, report-only."
      end

      output :status
      output :descriptor
      output :stages
      output :current_stage
      output :next_action
      output :summary
    end
  end
end
