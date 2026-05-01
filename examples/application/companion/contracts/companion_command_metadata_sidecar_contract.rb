# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionCommandMetadataSidecarContract,
              outputs: %i[schema_version descriptor status checks records package_gap pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_command_metadata_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          store_side_execution: false,
          claim: :portable_command_metadata_shape,
          db_command_promise: false,
          package_capability_closed: false,
          lowers_to: :mutation_intent
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
          Companion::Contracts.check(:no_store_side_execution, descriptor.fetch(:store_side_execution) == false),
          Companion::Contracts.check(:manifest_commands_present, records.all? { |record| record.fetch(:command_count).positive? }),
          Companion::Contracts.check(:command_operations_declared, records.all? { |record| record.fetch(:commands).all? { |cmd| !cmd.fetch(:operation).nil? } }),
          Companion::Contracts.check(:command_lowering_preserved, records.all? { |record| record.fetch(:lowering_preserved) }),
          Companion::Contracts.check(:generated_command_api_present, records.all? { |record| record.fetch(:generated_command_api_present) }),
          Companion::Contracts.check(:generated_command_names_match, records.all? { |record|
            manifest_names = record.fetch(:commands).map { |cmd| cmd.fetch(:name) }.sort
            generated_names = record.fetch(:generated_command_names).sort
            manifest_names == generated_names
          }),
          Companion::Contracts.check(:package_command_gap_closed, package_gap.fetch(:status) == :closed &&
                                                                   package_gap.fetch(:generated_command_api_present) == true),
          Companion::Contracts.check(:pressure_ready, pressure.fetch(:next_question) == :effect_metadata &&
                                                      pressure.fetch(:resolved) == :command_metadata)
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks package_gap pressure] do |status:, checks:, package_gap:, pressure:|
        "#{status}: #{checks.length} command metadata checks, " \
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
