# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffPromotionReadinessContract, outputs: %i[status descriptor blockers allowed_next_steps summary] do
      input :setup_handoff_extraction_sketch
      input :setup_handoff_packet_registry

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_promotion_readiness,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          evaluates: :package_promotion_readiness
        }
      end

      compute :blockers, depends_on: %i[setup_handoff_extraction_sketch setup_handoff_packet_registry] do |setup_handoff_extraction_sketch:, setup_handoff_packet_registry:|
        constraints = setup_handoff_extraction_sketch.fetch(:constraints)
        blockers = []
        blockers << :single_app_pressure_only if constraints.fetch(:current_scope) == :companion_app_local
        blockers << :public_api_not_promised unless constraints.fetch(:public_api_promise)
        blockers << :package_split_disabled unless constraints.fetch(:package_split_now)
        blockers << :dynamic_runtime_contracts_disabled unless constraints.fetch(:dynamic_runtime_contracts)
        blockers << :materializer_execution_blocked unless constraints.fetch(:materializer_execution)
        blockers << :capability_grants_blocked unless constraints.fetch(:capability_grants)
        blockers << :packet_surface_report_only if setup_handoff_packet_registry.fetch(:packets).all? { |packet| packet.fetch(:report_only) }
        blockers
      end

      compute :allowed_next_steps do
        %i[
          keep_companion_app_local
          stabilize_manifest_vocabulary
          repeat_pressure_in_another_app
          keep_receipt_writes_explicit
          keep_lowerings_to_store_t_history_t
        ]
      end

      compute :status, depends_on: [:blockers] do |blockers:|
        blockers.empty? ? :ready : :blocked
      end

      compute :summary, depends_on: %i[status blockers allowed_next_steps] do |status:, blockers:, allowed_next_steps:|
        "#{status}: #{blockers.length} promotion blockers, next=#{allowed_next_steps.first}."
      end

      output :status
      output :descriptor
      output :blockers
      output :allowed_next_steps
      output :summary
    end
  end
end
