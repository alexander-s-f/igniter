# frozen_string_literal: true

begin
  require "igniter/companion"
rescue LoadError
  root = File.expand_path("../../../..", __dir__)
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-store/lib"))
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-companion/lib"))
  require "igniter/companion"
end

module Companion
  module Services
    class CompanionEffectMetadataSidecar
      RECORD_CONTRACTS = [
        Contracts::Reminder,
        Contracts::Article
      ].freeze

      def self.packet
        proof = new.proof
        Contracts::CompanionEffectMetadataSidecarContract.evaluate(proof: proof)
      end

      def proof
        records = RECORD_CONTRACTS.map { |contract| record_report(contract) }

        {
          main_state_mutated: false,
          records: records,
          package_gap: package_gap(records),
          pressure: pressure_report
        }
      end

      private

      def record_report(contract)
        manifest = contract.persistence_manifest
        generated = Igniter::Companion.from_manifest(manifest)
        effects = generated.respond_to?(:_effects) ? generated._effects : {}
        commands = manifest.fetch(:commands, [])

        {
          contract: contract.name.to_s.split("::").last.to_sym,
          store_name: manifest.fetch(:storage).fetch(:name),
          generated_from_manifest: true,
          command_count: commands.length,
          effect_count: effects.length,
          effects: effects.map { |name, attrs| attrs.merge(name: name) },
          generated_effect_api_present: generated.respond_to?(:_effects),
          generated_effect_names: effects.keys,
          effects_cover_commands: effects.length == commands.length,
          lowering_preserved: effects.values.all? { |e| %i[store_t history_t].include?(e[:lowers_to]) || e[:store_op] == :none },
          store_write_effects: effects.count { |_, e| e[:store_op] == :store_write },
          store_append_effects: effects.count { |_, e| e[:store_op] == :store_append }
        }
      end

      def package_gap(records)
        generated_effect_api_present = records.all? { |record| record.fetch(:generated_effect_api_present) }

        {
          status: generated_effect_api_present ? :closed : :open,
          expected_api: :_effects,
          generated_effect_api_present: generated_effect_api_present,
          derivation_strategy: :derived_from_commands,
          record_count_with_effects: records.count { |record| record.fetch(:effect_count).positive? },
          package_surface: :"igniter-companion"
        }
      end

      def pressure_report
        {
          next_question: :relation_metadata,
          resolved: :effect_metadata,
          package_request: :await_supervisor_relation_metadata_pressure,
          lowering_claim: :effect_metadata_lowers_to_store_write_or_store_append,
          derivation: :computed_from_commands_no_new_dsl,
          acceptance: %i[
            generated_record_exposes_effects
            effects_derived_from_commands
            store_write_store_append_intents_covered
            lowering_chain_preserved
            no_store_side_execution
          ],
          non_goals: %i[
            store_effect_execution
            adapter_effect_api
            app_backend_replacement
            new_contract_dsl
          ]
        }
      end
    end
  end
end
