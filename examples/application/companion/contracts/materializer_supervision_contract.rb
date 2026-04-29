# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerSupervisionContract,
              outputs: %i[status phase descriptor signals command_intent approval_command_intent audit approval_audit next_action summary] do
      input :materializer_gate
      input :materializer_preflight
      input :materializer_runbook
      input :materializer_receipt
      input :materializer_attempt_command
      input :materializer_audit_trail
      input :materializer_approval_command
      input :materializer_approval_audit_trail

      compute :signals,
              depends_on: %i[
                materializer_gate materializer_preflight materializer_runbook materializer_receipt
                materializer_attempt_command materializer_audit_trail materializer_approval_command
                materializer_approval_audit_trail
              ] do |materializer_gate:, materializer_preflight:, materializer_runbook:, materializer_receipt:, materializer_attempt_command:, materializer_audit_trail:, materializer_approval_command:, materializer_approval_audit_trail:|
        {
          gate_blocked: materializer_gate.fetch(:status) == :blocked,
          preflight_ready_for_review: materializer_preflight.fetch(:status) == :blocked_until_approval,
          runbook_fully_blocked: materializer_runbook.fetch(:steps).all? { |step| step.fetch(:status) == :blocked },
          receipt_non_executed: materializer_receipt.fetch(:receipt).fetch(:executed) == false,
          attempt_command_ready: materializer_attempt_command.fetch(:mutation).fetch(:operation) == :history_append,
          audit_has_attempts: materializer_audit_trail.fetch(:attempt_count).positive?,
          approval_command_ready: materializer_approval_command.fetch(:mutation).fetch(:operation) == :history_append,
          audit_has_approvals: materializer_approval_audit_trail.fetch(:approval_count).positive?,
          approval_application_absent: materializer_approval_audit_trail.fetch(:applied_count).zero?
        }
      end

      compute :status, depends_on: [:signals] do |signals:|
        if signals.fetch(:gate_blocked) && signals.fetch(:preflight_ready_for_review) && signals.fetch(:approval_application_absent)
          :blocked
        else
          :needs_review
        end
      end

      compute :phase, depends_on: [:signals] do |signals:|
        if signals.fetch(:audit_has_approvals)
          :approval_receipt_recorded
        elsif signals.fetch(:audit_has_attempts) && signals.fetch(:approval_command_ready)
          :awaiting_explicit_approval_record
        elsif signals.fetch(:audit_has_attempts)
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

      compute :approval_command_intent, depends_on: [:materializer_approval_command] do |materializer_approval_command:|
        mutation = materializer_approval_command.fetch(:mutation)
        {
          operation: mutation.fetch(:operation),
          target: mutation.fetch(:target, nil),
          review_only: mutation.fetch(:event, {}).fetch(:review_only, true),
          applies_capabilities: mutation.fetch(:event, {}).fetch(:applies_capabilities, false)
        }
      end

      compute :audit, depends_on: %i[materializer_audit_trail materializer_approval_audit_trail] do |materializer_audit_trail:, materializer_approval_audit_trail:|
        {
          attempt_count: materializer_audit_trail.fetch(:attempt_count),
          blocked_count: materializer_audit_trail.fetch(:blocked_count),
          executed_count: materializer_audit_trail.fetch(:executed_count),
          blocked_capabilities: materializer_audit_trail.fetch(:blocked_capabilities),
          last_attempt: materializer_audit_trail.fetch(:last_attempt),
          approval_count: materializer_approval_audit_trail.fetch(:approval_count),
          applied_count: materializer_approval_audit_trail.fetch(:applied_count)
        }
      end

      compute :approval_audit, depends_on: [:materializer_approval_audit_trail] do |materializer_approval_audit_trail:|
        {
          approval_count: materializer_approval_audit_trail.fetch(:approval_count),
          pending_count: materializer_approval_audit_trail.fetch(:pending_count),
          approved_count: materializer_approval_audit_trail.fetch(:approved_count),
          applied_count: materializer_approval_audit_trail.fetch(:applied_count),
          granted_capabilities: materializer_approval_audit_trail.fetch(:granted_capabilities),
          rejected_capabilities: materializer_approval_audit_trail.fetch(:rejected_capabilities),
          last_approval: materializer_approval_audit_trail.fetch(:last_approval)
        }
      end

      compute :next_action, depends_on: %i[phase status] do |phase:, status:|
        case phase
        when :awaiting_explicit_attempt_record
          :record_blocked_attempt
        when :awaiting_explicit_approval_record
          :record_approval_receipt
        when :approval_receipt_recorded
          :review_materializer_execution_request
        when :blocked_attempt_recorded
          :review_human_approval_request
        else
          status == :blocked ? :review_preflight_packet : :inspect_materializer_drift
        end
      end

      compute :descriptor, depends_on: %i[status phase command_intent approval_command_intent audit approval_audit next_action] do |status:, phase:, command_intent:, approval_command_intent:, audit:, approval_audit:, next_action:|
        {
          schema_version: 1,
          kind: :materializer_status,
          status: status,
          phase: phase,
          review_only: true,
          grants_capabilities: false,
          execution_allowed: false,
          app_boundary_required: true,
          histories: {
            attempts: :materializer_attempts,
            approvals: :materializer_approvals
          },
          command_intents: {
            attempt: command_intent,
            approval: approval_command_intent
          },
          audits: {
            attempts: {
              count: audit.fetch(:attempt_count),
              executed_count: audit.fetch(:executed_count)
            },
            approvals: {
              count: approval_audit.fetch(:approval_count),
              applied_count: approval_audit.fetch(:applied_count)
            }
          },
          next_action: next_action
        }
      end

      compute :summary, depends_on: %i[status phase audit approval_audit next_action] do |status:, phase:, audit:, approval_audit:, next_action:|
        "#{status}/#{phase}: attempts=#{audit.fetch(:attempt_count)}, approvals=#{approval_audit.fetch(:approval_count)}, applied=#{approval_audit.fetch(:applied_count)}, next=#{next_action}."
      end

      output :status
      output :phase
      output :descriptor
      output :signals
      output :command_intent
      output :approval_command_intent
      output :audit
      output :approval_audit
      output :next_action
      output :summary
    end
  end
end
