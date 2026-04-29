# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffDigestContract, outputs: %i[status descriptor highlights next_reads diagram summary] do
      input :setup_handoff_supervision
      input :setup_handoff_extraction_sketch
      input :setup_handoff_promotion_readiness

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_digest,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          role: :compact_human_agent_summary
        }
      end

      compute :status, depends_on: [:setup_handoff_supervision] do |setup_handoff_supervision:|
        setup_handoff_supervision.fetch(:status)
      end

      compute :highlights,
              depends_on: %i[setup_handoff_supervision setup_handoff_extraction_sketch setup_handoff_promotion_readiness] do |setup_handoff_supervision:, setup_handoff_extraction_sketch:, setup_handoff_promotion_readiness:|
        signals = setup_handoff_supervision.fetch(:signals)
        {
          lifecycle_stage: signals.fetch(:lifecycle_stage),
          materializer_phase: signals.fetch(:materializer_phase),
          next_action: setup_handoff_supervision.fetch(:next_action),
          current_scope: setup_handoff_extraction_sketch.fetch(:constraints).fetch(:current_scope),
          promotion_status: setup_handoff_promotion_readiness.fetch(:status),
          promotion_blockers: setup_handoff_promotion_readiness.fetch(:blockers).length,
          package_promise: setup_handoff_extraction_sketch.fetch(:descriptor).fetch(:package_promise),
          grants_capabilities: setup_handoff_supervision.fetch(:descriptor).fetch(:grants_capabilities)
        }
      end

      compute :next_reads do
        [
          "/setup/handoff/supervision.json",
          "/setup/handoff/promotion-readiness.json",
          "/setup/handoff/extraction-sketch.json",
          "/setup/handoff/packet-registry.json"
        ]
      end

      compute :diagram, depends_on: [:highlights] do |highlights:|
        [
          "Companion app-local proof",
          "|-- lifecycle: #{highlights.fetch(:lifecycle_stage)}",
          "|-- materializer: #{highlights.fetch(:materializer_phase)}",
          "|-- next: #{highlights.fetch(:next_action)}",
          "|-- extraction: #{highlights.fetch(:current_scope)}, package_promise=#{highlights.fetch(:package_promise)}",
          "`-- promotion: #{highlights.fetch(:promotion_status)} (#{highlights.fetch(:promotion_blockers)} blockers)"
        ].join("\n")
      end

      compute :summary, depends_on: %i[status highlights] do |status:, highlights:|
        "#{status}: stage=#{highlights.fetch(:lifecycle_stage)}, next=#{highlights.fetch(:next_action)}, promotion=#{highlights.fetch(:promotion_status)}."
      end

      output :status
      output :descriptor
      output :highlights
      output :next_reads
      output :diagram
      output :summary
    end
  end
end
