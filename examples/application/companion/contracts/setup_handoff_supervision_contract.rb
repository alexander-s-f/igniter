# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffSupervisionContract, outputs: %i[status descriptor signals packet_refs next_action summary] do
      input :setup_health
      input :setup_handoff
      input :setup_handoff_lifecycle
      input :setup_handoff_lifecycle_health
      input :materializer_status

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_supervision,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          role: :agent_context_packet
        }
      end

      compute :signals,
              depends_on: %i[setup_health setup_handoff setup_handoff_lifecycle setup_handoff_lifecycle_health materializer_status] do |setup_health:, setup_handoff:, setup_handoff_lifecycle:, setup_handoff_lifecycle_health:, materializer_status:|
        {
          setup_stable: setup_health.fetch(:status) == :stable,
          handoff_stable: setup_handoff.fetch(:status) == :stable,
          lifecycle_status: setup_handoff_lifecycle.fetch(:status),
          lifecycle_stage: setup_handoff_lifecycle.fetch(:current_stage),
          lifecycle_health_stable: setup_handoff_lifecycle_health.fetch(:status) == :stable,
          materializer_phase: materializer_status.fetch(:phase),
          materializer_grants_capabilities: materializer_status.fetch(:descriptor).fetch(:grants_capabilities),
          materializer_execution_allowed: materializer_status.fetch(:descriptor).fetch(:execution_allowed)
        }
      end

      compute :status, depends_on: %i[signals setup_handoff_lifecycle] do |signals:, setup_handoff_lifecycle:|
        if signals.fetch(:setup_stable) && signals.fetch(:handoff_stable) && signals.fetch(:lifecycle_health_stable)
          setup_handoff_lifecycle.fetch(:status)
        else
          :needs_review
        end
      end

      compute :packet_refs do
        {
          setup_health: "/setup/health.json",
          handoff: "/setup/handoff.json",
          lifecycle: "/setup/handoff/lifecycle.json",
          lifecycle_health: "/setup/handoff/lifecycle-health.json",
          materializer: "/setup/materializer.json"
        }
      end

      compute :next_action, depends_on: %i[status setup_handoff_lifecycle] do |status:, setup_handoff_lifecycle:|
        status == :needs_review ? :review_handoff_supervision : setup_handoff_lifecycle.fetch(:next_action)
      end

      compute :summary, depends_on: %i[status signals next_action] do |status:, signals:, next_action:|
        "#{status}: stage=#{signals.fetch(:lifecycle_stage)}, phase=#{signals.fetch(:materializer_phase)}, next=#{next_action}, report-only."
      end

      output :status
      output :descriptor
      output :signals
      output :packet_refs
      output :next_action
      output :summary
    end
  end
end
