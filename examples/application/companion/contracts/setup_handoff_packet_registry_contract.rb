# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffPacketRegistryContract, outputs: %i[status descriptor packets read_order mutation_paths summary] do
      input :setup_health
      input :setup_handoff
      input :setup_handoff_supervision
      input :setup_handoff_lifecycle
      input :setup_handoff_lifecycle_health
      input :setup_handoff_acceptance
      input :setup_handoff_approval_acceptance
      input :setup_handoff_next_scope
      input :setup_handoff_next_scope_health
      input :materializer_status

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_packet_registry,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          role: :packet_index
        }
      end

      compute :packets,
              depends_on: %i[
                setup_health setup_handoff setup_handoff_supervision
                setup_handoff_lifecycle setup_handoff_lifecycle_health
                setup_handoff_acceptance setup_handoff_approval_acceptance
                setup_handoff_next_scope setup_handoff_next_scope_health
                materializer_status
              ] do |setup_health:, setup_handoff:, setup_handoff_supervision:, setup_handoff_lifecycle:, setup_handoff_lifecycle_health:, setup_handoff_acceptance:, setup_handoff_approval_acceptance:, setup_handoff_next_scope:, setup_handoff_next_scope_health:, materializer_status:|
        [
          Companion::Contracts.packet(:setup_health, "/setup/health.json", setup_health.fetch(:descriptor), :diagnostic),
          Companion::Contracts.packet(:setup_handoff, "/setup/handoff.json", setup_handoff.fetch(:descriptor), :context_rotation),
          Companion::Contracts.packet(:setup_handoff_next_scope, "/setup/handoff/next-scope.json", setup_handoff_next_scope.fetch(:descriptor), :supervised_backlog),
          Companion::Contracts.packet(:setup_handoff_next_scope_health, "/setup/handoff/next-scope-health.json", setup_handoff_next_scope_health.fetch(:descriptor), :drift_check),
          Companion::Contracts.packet(:setup_handoff_supervision, "/setup/handoff/supervision.json", setup_handoff_supervision.fetch(:descriptor), :agent_context),
          Companion::Contracts.packet(:setup_handoff_lifecycle, "/setup/handoff/lifecycle.json", setup_handoff_lifecycle.fetch(:descriptor), :lifecycle_map),
          Companion::Contracts.packet(:setup_handoff_lifecycle_health, "/setup/handoff/lifecycle-health.json", setup_handoff_lifecycle_health.fetch(:descriptor), :drift_check),
          Companion::Contracts.packet(:setup_handoff_acceptance, "/setup/handoff/acceptance.json", setup_handoff_acceptance.fetch(:descriptor), :acceptance),
          Companion::Contracts.packet(:setup_handoff_approval_acceptance, "/setup/handoff/approval-acceptance.json", setup_handoff_approval_acceptance.fetch(:descriptor), :acceptance),
          Companion::Contracts.packet(:materializer_status, "/setup/materializer.json", materializer_status.fetch(:descriptor), :materializer_review)
        ]
      end

      compute :read_order, depends_on: %i[setup_handoff packets] do |setup_handoff:, packets:|
        declared = setup_handoff.fetch(:reading_order)
        indexed = packets.map { |packet| packet.fetch(:endpoint) }
        declared.select { |endpoint| indexed.include?(endpoint) }
      end

      compute :mutation_paths, depends_on: [:setup_handoff_lifecycle] do |setup_handoff_lifecycle:|
        setup_handoff_lifecycle.fetch(:stages)
                               .map { |stage| stage.fetch(:mutation) }
                               .compact
      end

      compute :status, depends_on: [:packets] do |packets:|
        packets.all? { |packet| packet.fetch(:report_only) && packet.fetch(:gates_runtime) == false && packet.fetch(:grants_capabilities) == false } ? :stable : :needs_review
      end

      compute :summary, depends_on: %i[status packets mutation_paths] do |status:, packets:, mutation_paths:|
        "#{status}: #{packets.length} setup packets, #{mutation_paths.length} explicit mutation paths, report-only."
      end

      output :status
      output :descriptor
      output :packets
      output :read_order
      output :mutation_paths
      output :summary
    end

    def self.packet(name, endpoint, descriptor, role)
      {
        name: name,
        endpoint: endpoint,
        kind: descriptor.fetch(:kind),
        role: role,
        report_only: descriptor.fetch(:report_only, descriptor.fetch(:review_only, false)),
        gates_runtime: descriptor.fetch(:gates_runtime, descriptor.fetch(:execution_allowed, true)),
        grants_capabilities: descriptor.fetch(:grants_capabilities)
      }
    end
  end
end
