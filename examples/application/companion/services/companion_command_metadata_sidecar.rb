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
    class CompanionCommandMetadataSidecar
      RECORD_CONTRACTS = [
        Contracts::Reminder,
        Contracts::Article
      ].freeze

      def self.packet
        proof = new.proof
        Contracts::CompanionCommandMetadataSidecarContract.evaluate(proof: proof)
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
        commands = manifest.fetch(:commands, []).map { |cmd| normalize_command(cmd) }

        {
          contract: contract.name.to_s.split("::").last.to_sym,
          store_name: manifest.fetch(:storage).fetch(:name),
          generated_from_manifest: true,
          command_count: commands.length,
          commands: commands,
          generated_command_api_present: generated.respond_to?(:_commands),
          generated_command_names: generated.respond_to?(:_commands) ? generated._commands.keys : [],
          lowering_preserved: commands.all? { |cmd| cmd.fetch(:lowers_to) == :mutation_intent }
        }
      end

      def normalize_command(command_def)
        attrs = command_def.fetch(:attributes, {})
        operation = attrs.fetch(:operation, nil)&.to_sym

        {
          name: command_def.fetch(:name).to_sym,
          operation: operation,
          changes: attrs.fetch(:changes, {}),
          lowers_to: :mutation_intent,
          store_side_execution: false,
          source: :command_descriptor
        }
      end

      def package_gap(records)
        generated_command_api_present = records.all? { |record| record.fetch(:generated_command_api_present) }

        {
          status: generated_command_api_present ? :closed : :open,
          expected_api: :_commands,
          generated_command_api_present: generated_command_api_present,
          record_count_with_manifest_commands: records.count { |record| record.fetch(:command_count).positive? },
          package_surface: :"igniter-companion"
        }
      end

      def pressure_report
        {
          next_question: :effect_metadata,
          resolved: :command_metadata,
          package_request: :await_supervisor_effect_metadata_pressure,
          lowering_claim: :command_metadata_lowers_to_mutation_intent,
          acceptance: %i[
            from_manifest_preserves_commands
            generated_record_exposes_commands
            command_lowers_to_mutation_intent
            no_store_side_execution
          ],
          non_goals: %i[
            store_command_execution
            adapter_action_api
            app_backend_replacement
          ]
        }
      end
    end
  end
end
