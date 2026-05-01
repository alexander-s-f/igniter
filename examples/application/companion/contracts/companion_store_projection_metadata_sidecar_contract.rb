# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionStoreProjectionMetadataSidecarContract,
              outputs: %i[schema_version descriptor status checks projections package_gap pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_store_projection_metadata_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          store_side_execution: false,
          query_planner_promise: false,
          claim: :portable_projection_metadata_shape,
          declaration: :projection_contract_reads_and_relations,
          lowers_to: :projection_descriptor
        }
      end

      compute :projections, depends_on: [:proof] do |proof:|
        proof.fetch(:projections)
      end

      compute :package_gap, depends_on: [:proof] do |proof:|
        proof.fetch(:package_gap)
      end

      compute :pressure, depends_on: [:proof] do |proof:|
        proof.fetch(:pressure)
      end

      compute :checks, depends_on: %i[descriptor projections package_gap pressure proof] do |descriptor:, projections:, package_gap:, pressure:, proof:|
        [
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime) == false),
          Companion::Contracts.check(:no_backend_replacement, descriptor.fetch(:replaces_app_backend) == false),
          Companion::Contracts.check(:no_main_state_mutation, proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:no_store_side_execution, descriptor.fetch(:store_side_execution) == false),
          Companion::Contracts.check(:no_query_planner_promise, descriptor.fetch(:query_planner_promise) == false),
          Companion::Contracts.check(:projections_manifest_present, projections.length >= 5),
          Companion::Contracts.check(:projection_reads_known, projections.all? { |projection| projection.fetch(:reads_record_or_history) }),
          Companion::Contracts.check(:projection_relations_known, projections.all? { |projection| projection.key?(:relations) }),
          Companion::Contracts.check(:tracker_projection_composes_record_and_history, projections.any? do |projection|
            projection.fetch(:name) == :tracker_read_model &&
              projection.fetch(:reads).sort == %i[tracker_logs trackers] &&
              projection.fetch(:relations) == %i[tracker_logs_by_tracker]
          end),
          Companion::Contracts.check(:relation_metadata_linked, projections.all? { |projection| projection.fetch(:relation_metadata_linked) }),
          Companion::Contracts.check(:reactive_consumer_hints_present, projections.all? { |projection| projection.fetch(:reactive_consumer_hint) }),
          Companion::Contracts.check(:package_projection_gap_open, package_gap.fetch(:status) == :open &&
                                                                    package_gap.fetch(:expected_api) == :_projections &&
                                                                    package_gap.fetch(:generated_projection_api_present) == false),
          Companion::Contracts.check(:pressure_ready, pressure.fetch(:next_question) == :projection_descriptor_mirroring &&
                                                      pressure.fetch(:resolved) == :app_projection_metadata_shape)
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks package_gap pressure] do |status:, checks:, package_gap:, pressure:|
        "#{status}: #{checks.length} projection metadata checks, " \
          "gap=#{package_gap.fetch(:status)}, next=#{pressure.fetch(:next_question)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :projections
      output :package_gap
      output :pressure
      output :summary
    end
  end
end
