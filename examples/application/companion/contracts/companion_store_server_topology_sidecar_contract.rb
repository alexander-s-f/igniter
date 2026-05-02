# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionStoreServerTopologySidecarContract,
              outputs: %i[schema_version descriptor status checks topology backend_matrix package_gap pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_store_server_topology_sidecar,
          report_only: true,
          gates_runtime: false,
          mutates_main_state: false,
          executes_network: false,
          claim: :store_server_projection_topology,
          preserves: {
            app: :contract_computation,
            server: :durable_fact_projection,
            boundary: :backend_swap
          }
        }
      end

      compute :topology, depends_on: [:proof] do |proof:|
        proof.fetch(:topology)
      end

      compute :backend_matrix, depends_on: [:proof] do |proof:|
        proof.fetch(:backend_matrix)
      end

      compute :package_gap, depends_on: [:proof] do |proof:|
        proof.fetch(:package_gap)
      end

      compute :pressure, depends_on: [:proof] do |proof:|
        proof.fetch(:pressure)
      end

      compute :checks, depends_on: %i[descriptor topology backend_matrix package_gap pressure proof] do |descriptor:, topology:, backend_matrix:, package_gap:, pressure:, proof:|
        [
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime) == false),
          Companion::Contracts.check(:no_main_state_mutation, descriptor.fetch(:mutates_main_state) == false && proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:no_network_execution, descriptor.fetch(:executes_network) == false && proof.fetch(:network_executed) == false),
          Companion::Contracts.check(:app_computation_preserved, topology.fetch(:app_process).fetch(:owns).include?(:contract_computation)),
          Companion::Contracts.check(:server_projection_host, topology.fetch(:store_server).fetch(:owns).include?(:durable_facts) &&
                                                            topology.fetch(:store_server).fetch(:owns).include?(:replay)),
          Companion::Contracts.check(:backend_swap_shape, backend_matrix.map { |entry| entry.fetch(:backend) } == %i[memory file network]),
          Companion::Contracts.check(:wire_protocol_known, proof.fetch(:wire_protocol_known)),
          Companion::Contracts.check(:server_support_constants_known, proof.fetch(:server_config_known) &&
                                                                      proof.fetch(:server_logger_known) &&
                                                                      proof.fetch(:subscription_registry_known)),
          Companion::Contracts.check(:server_lifecycle_shape, topology.fetch(:operational_lifecycle).fetch(:config) == :server_config &&
                                                              topology.fetch(:operational_lifecycle).fetch(:readiness) == :wait_until_ready &&
                                                              topology.fetch(:operational_lifecycle).fetch(:shutdown) == :graceful_drain),
          Companion::Contracts.check(:subscription_boundary_shape, topology.fetch(:subscription_boundary).fetch(:registry) == :subscription_registry &&
                                                                  topology.fetch(:subscription_boundary).fetch(:server_event) == :fact_written &&
                                                                  topology.fetch(:subscription_boundary).fetch(:app_contract_logic) == :not_in_callback),
          Companion::Contracts.check(:network_phase_recorded, backend_matrix.find { |entry| entry.fetch(:backend) == :network }.fetch(:phase) != :unknown),
          Companion::Contracts.check(:native_gap_explicit, %i[open closed].include?(package_gap.fetch(:status)) &&
                                                           package_gap.fetch(:name) == :native_wire_deserialization),
          Companion::Contracts.check(:native_parity_resolved, Array(pressure.fetch(:resolved)).include?(:network_backend_native_parity)),
          Companion::Contracts.check(:next_question_known, %i[
            reactive_derivation
            projection_descriptor_mirroring
            companion_resolve_time_travel
          ].include?(pressure.fetch(:next_question)))
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks package_gap pressure] do |status:, checks:, package_gap:, pressure:|
        "#{status}: #{checks.length} store-server topology checks, " \
          "gap=#{package_gap.fetch(:status)}, next=#{pressure.fetch(:next_question)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :topology
      output :backend_matrix
      output :package_gap
      output :pressure
      output :summary
    end
  end
end
