# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionStoreAppFlowSidecarContract,
              outputs: %i[schema_version descriptor status checks summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_store_app_flow_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          claim: "one app-pattern write flows through Igniter::Companion::Store " \
                 "and returns a normalized receipt without touching the main app state"
        }
      end

      compute :checks, depends_on: %i[descriptor proof] do |descriptor:, proof:|
        write   = proof.fetch(:write)
        read    = proof.fetch(:read)
        receipt = proof.fetch(:receipt)
        scope   = proof.fetch(:scope)

        [
          Companion::Contracts.check(:report_only,            descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_backend_replacement, descriptor.fetch(:replaces_app_backend) == false),
          Companion::Contracts.check(:no_main_state_mutation, proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:write_succeeds,         write.fetch(:ok)),
          Companion::Contracts.check(:read_round_trip,        read.fetch(:title) == write.fetch(:title) &&
                                                              read.fetch(:status) == write.fetch(:status)),
          Companion::Contracts.check(:receipt_intent,         receipt.fetch(:mutation_intent) == :record_write),
          Companion::Contracts.check(:receipt_fact_id,        !receipt.fetch(:fact_id).nil?),
          Companion::Contracts.check(:receipt_delegates,      receipt.fetch(:delegates_to_record)),
          Companion::Contracts.check(:scope_query_works,      scope.fetch(:open_count) == 1),
          Companion::Contracts.check(:generated_from_manifest, proof.fetch(:generated_from_manifest))
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |c| c.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks proof] do |status:, checks:, proof:|
        "#{status}: #{checks.length} app-flow checks, " \
          "store=#{proof.fetch(:store_name)}, " \
          "receipt_intent=#{proof.fetch(:receipt).fetch(:mutation_intent)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :summary
    end
  end
end
