# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionEffectMetadataSidecarContract,
              outputs: %i[schema_version descriptor status checks records package_gap pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_effect_metadata_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          store_side_execution: false,
          claim: :portable_effect_metadata_shape,
          derivation: :derived_from_commands,
          lowers_to: :store_write_or_store_append
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
          Companion::Contracts.check(:effects_derived_from_commands, descriptor.fetch(:derivation) == :derived_from_commands),
          Companion::Contracts.check(:manifest_effects_present, records.all? { |record| record.fetch(:effect_count).positive? }),
          Companion::Contracts.check(:effects_cover_commands, records.all? { |record| record.fetch(:effects_cover_commands) }),
          Companion::Contracts.check(:store_write_intent_present, records.all? { |record| record.fetch(:store_write_effects).positive? }),
          Companion::Contracts.check(:lowering_chain_preserved, records.all? { |record| record.fetch(:lowering_preserved) }),
          Companion::Contracts.check(:package_effect_gap_closed, package_gap.fetch(:status) == :closed &&
                                                                   package_gap.fetch(:generated_effect_api_present) == true),
          Companion::Contracts.check(:pressure_ready, pressure.fetch(:next_question) == :relation_metadata &&
                                                      pressure.fetch(:resolved) == :effect_metadata)
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks package_gap pressure] do |status:, checks:, package_gap:, pressure:|
        "#{status}: #{checks.length} effect metadata checks, " \
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
