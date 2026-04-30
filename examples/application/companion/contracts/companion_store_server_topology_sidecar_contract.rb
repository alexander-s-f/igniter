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
          Companion::Contracts.check(:network_phase_recorded, backend_matrix.find { |entry| entry.fetch(:backend) == :network }.fetch(:phase) != :unknown),
          Companion::Contracts.check(:native_gap_explicit, %i[open closed].include?(package_gap.fetch(:status)) &&
                                                           package_gap.fetch(:name) == :native_wire_deserialization),
          Companion::Contracts.check(:package_request_scoped, pressure.fetch(:package_request) == :fact_deserialize_for_native_wire),
          Companion::Contracts.check(:main_convergence_unchanged, pressure.fetch(:does_not_replace_current_pressure) == :index_metadata)
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
