# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionIndexMetadataSidecarContract,
              outputs: %i[schema_version descriptor status checks records package_gap pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_index_metadata_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          claim: :portable_index_metadata_shape,
          db_index_promise: false,
          package_capability_closed: false,
          lowers_to: :store_access_path_metadata
        }
      end

      compute :records, depends_on: [:proof] do |proof:|
        proof.fetch(:records)
      end

      compute :package_gap, depends_on: [:proof] do |proof:|
        proof.fetch(:package_gap)
      end

      compute :pressure, depends_on: [:proof] do |proof:|
        proof.fetch(:pressure)
      end

      compute :checks, depends_on: %i[descriptor records package_gap pressure proof] do |descriptor:, records:, package_gap:, pressure:, proof:|
        [
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime) == false),
          Companion::Contracts.check(:no_backend_replacement, descriptor.fetch(:replaces_app_backend) == false),
          Companion::Contracts.check(:no_main_state_mutation, proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:no_db_index_promise, descriptor.fetch(:db_index_promise) == false),
          Companion::Contracts.check(:manifest_indexes_present, records.all? { |record| record.fetch(:index_count).positive? }),
          Companion::Contracts.check(:index_fields_normalized, records.all? { |record| record.fetch(:indexes).all? { |index| index.fetch(:fields) == [:status] } }),
          Companion::Contracts.check(:index_fields_declared, records.all? { |record| record.fetch(:indexes).all? { |index| index.fetch(:fields_declared) } }),
          Companion::Contracts.check(:scope_coverage_explained, records.all? { |record| record.fetch(:scopes).all? { |scope| scope.fetch(:covered_by_index) } }),
          Companion::Contracts.check(:generated_scope_metadata_present, records.all? { |record| record.fetch(:generated_scope_names).any? }),
          Companion::Contracts.check(:package_index_gap_detected, package_gap.fetch(:status) == :open &&
                                                                       package_gap.fetch(:generated_index_api_present) == false),
          Companion::Contracts.check(:pressure_ready, pressure.fetch(:next_question) == :index_metadata &&
                                                       pressure.fetch(:package_request) == :mirror_manifest_indexes_as_record_metadata)
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks package_gap pressure] do |status:, checks:, package_gap:, pressure:|
        "#{status}: #{checks.length} index metadata checks, " \
          "gap=#{package_gap.fetch(:status)}, next=#{pressure.fetch(:next_question)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :records
      output :package_gap
      output :pressure
      output :summary
    end
  end
end
