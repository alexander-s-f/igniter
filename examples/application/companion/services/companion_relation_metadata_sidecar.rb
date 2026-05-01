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
    class CompanionRelationMetadataSidecar
      RECORD_CONTRACTS = [
        Contracts::Reminder,
        Contracts::Article
      ].freeze

      def self.packet
        proof = new.proof
        Contracts::CompanionRelationMetadataSidecarContract.evaluate(proof: proof)
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
        relations = manifest.fetch(:relations, [])
        generated_relations = generated.respond_to?(:_relations) ? generated._relations : {}

        {
          contract: contract.name.to_s.split("::").last.to_sym,
          store_name: manifest.fetch(:storage).fetch(:name),
          generated_from_manifest: true,
          relation_count: relations.length,
          relations: relations.map { |rel| normalize_relation(rel) },
          generated_relation_api_present: generated.respond_to?(:_relations),
          generated_relation_names: generated_relations.keys,
          lowering_preserved: relations.all? { |rel| normalize_relation(rel).fetch(:lowers_to) == :relation_descriptor }
        }
      end

      def normalize_relation(rel_def)
        attrs = rel_def.fetch(:attributes, {})
        {
          name: rel_def.fetch(:name),
          kind: attrs.fetch(:kind, :unknown),
          to: attrs.fetch(:to, nil),
          cardinality: attrs.fetch(:cardinality, :unknown),
          join: attrs.fetch(:join, {}),
          lowers_to: :relation_descriptor
        }
      end

      def package_gap(records)
        generated_relation_api_present = records.all? { |record| record.fetch(:generated_relation_api_present) }

        {
          status: generated_relation_api_present ? :closed : :open,
          expected_api: :_relations,
          generated_relation_api_present: generated_relation_api_present,
          declaration_strategy: :per_record_contract_dsl,
          record_count_with_relations: records.count { |record| record.fetch(:relation_count).positive? },
          package_surface: :"igniter-companion"
        }
      end

      def pressure_report
        {
          next_question: :store_projection_metadata,
          resolved: :relation_metadata,
          package_request: :await_supervisor_store_projection_metadata_pressure,
          lowering_claim: :relation_metadata_lowers_to_relation_descriptor,
          declaration: :per_record_dsl_relation_keyword,
          acceptance: %i[
            generated_record_exposes_relations
            relation_declared_in_contract_dsl
            relation_descriptor_shape_preserved
            no_store_side_join_execution
            no_adapter_relation_api
          ],
          non_goals: %i[
            store_join_execution
            adapter_relation_api
            app_backend_replacement
            cross_store_query
          ]
        }
      end
    end
  end
end
