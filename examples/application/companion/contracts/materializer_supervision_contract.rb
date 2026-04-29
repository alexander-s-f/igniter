# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerSupervisionContract, outputs: %i[status phase signals command_intent audit next_action summary] do
      input :materializer_gate
      input :materializer_preflight
      input :materializer_runbook
      input :materializer_receipt
      input :materializer_attempt_command
      input :materializer_audit_trail

      compute :signals, depends_on: %i[materializer_gate materializer_preflight materializer_runbook materializer_receipt materializer_attempt_command materializer_audit_trail] do |materializer_gate:, materializer_preflight:, materializer_runbook:, materializer_receipt:, materializer_attempt_command:, materializer_audit_trail:|
        {
          gate_blocked: materializer_gate.fetch(:status) == :blocked,
          preflight_ready_for_review: materializer_preflight.fetch(:status) == :blocked_until_approval,
          runbook_fully_blocked: materializer_runbook.fetch(:steps).all? { |step| step.fetch(:status) == :blocked },
          receipt_non_executed: materializer_receipt.fetch(:receipt).fetch(:executed) == false,
          attempt_command_ready: materializer_attempt_command.fetch(:mutation).fetch(:operation) == :history_append,
          audit_has_attempts: materializer_audit_trail.fetch(:attempt_count).positive?
        }
      end

      compute :status, depends_on: [:signals] do |signals:|
        if signals.fetch(:gate_blocked) && signals.fetch(:preflight_ready_for_review)
          :blocked
        else
          :needs_review
        end
      end

      compute :phase, depends_on: [:signals] do |signals:|
        if signals.fetch(:audit_has_attempts)
          :blocked_attempt_recorded
        elsif signals.fetch(:attempt_command_ready)
          :awaiting_explicit_attempt_record
        else
          :awaiting_preflight_review
        end
      end

      compute :command_intent, depends_on: [:materializer_attempt_command] do |materializer_attempt_command:|
        mutation = materializer_attempt_command.fetch(:mutation)
        {
          operation: mutation.fetch(:operation),
          target: mutation.fetch(:target, nil),
          review_only: mutation.fetch(:event, {}).fetch(:review_only, true)
        }
      end

      compute :audit, depends_on: [:materializer_audit_trail] do |materializer_audit_trail:|
        {
          attempt_count: materializer_audit_trail.fetch(:attempt_count),
          blocked_count: materializer_audit_trail.fetch(:blocked_count),
          executed_count: materializer_audit_trail.fetch(:executed_count),
          blocked_capabilities: materializer_audit_trail.fetch(:blocked_capabilities),
          last_attempt: materializer_audit_trail.fetch(:last_attempt)
        }
      end

      compute :next_action, depends_on: %i[phase status] do |phase:, status:|
        case phase
        when :awaiting_explicit_attempt_record
          :record_blocked_attempt
        when :blocked_attempt_recorded
          :review_human_approval_request
        else
          status == :blocked ? :review_preflight_packet : :inspect_materializer_drift
        end
      end

      compute :summary, depends_on: %i[status phase audit next_action] do |status:, phase:, audit:, next_action:|
        "#{status}/#{phase}: attempts=#{audit.fetch(:attempt_count)}, next=#{next_action}."
      end

      output :status
      output :phase
      output :signals
      output :command_intent
      output :audit
      output :next_action
      output :summary
    end
  end
end
