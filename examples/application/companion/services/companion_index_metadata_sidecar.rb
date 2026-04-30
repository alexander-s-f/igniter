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
    class CompanionIndexMetadataSidecar
      RECORD_CONTRACTS = [
        Contracts::Reminder,
        Contracts::Article
      ].freeze

      def self.packet
        proof = new.proof
        Contracts::CompanionIndexMetadataSidecarContract.evaluate(proof: proof)
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
        indexes = manifest.fetch(:indexes).map { |index| normalize_index(index, manifest) }
        scopes = manifest.fetch(:scopes).map { |scope| normalize_scope(scope, indexes) }

        {
          contract: contract.name.to_s.split("::").last.to_sym,
          store_name: manifest.fetch(:storage).fetch(:name),
          generated_from_manifest: true,
          index_count: indexes.length,
          indexes: indexes,
          scopes: scopes,
          generated_scope_names: generated._scopes.keys,
          generated_index_api_present: generated.respond_to?(:_indexes),
          generated_index_names: generated.respond_to?(:_indexes) ? generated._indexes.keys : []
        }
      end

      def normalize_index(index, manifest)
        attrs = index.fetch(:attributes, {})
        fields = Array(attrs.fetch(:fields, index.fetch(:name))).map(&:to_sym)
        declared_fields = manifest.fetch(:fields).map { |field| field.fetch(:name).to_sym }

        {
          name: index.fetch(:name).to_sym,
          fields: fields,
          fields_declared: (fields - declared_fields).empty?,
          unique: attrs.fetch(:unique, false),
          source: :index_descriptor,
          db_index_promise: false
        }
      end

      def normalize_scope(scope, indexes)
        where = scope.fetch(:attributes, {}).fetch(:where, {})
        where_fields = where.keys.map(&:to_sym)
        covering_index = indexes.find { |index| (where_fields - index.fetch(:fields)).empty? }

        {
          name: scope.fetch(:name).to_sym,
          where: where,
          covered_by_index: !covering_index.nil?,
          covering_index: covering_index&.fetch(:name)
        }
      end

      def package_gap(records)
        generated_index_api_present = records.all? { |record| record.fetch(:generated_index_api_present) }

        {
          status: generated_index_api_present ? :closed : :open,
          expected_api: :_indexes,
          generated_index_api_present: generated_index_api_present,
          record_count_with_manifest_indexes: records.count { |record| record.fetch(:index_count).positive? },
          package_surface: :"igniter-companion"
        }
      end

      def pressure_report
        {
          next_question: :index_metadata,
          package_request: :mirror_manifest_indexes_as_record_metadata,
          acceptance: %i[
            from_manifest_preserves_indexes
            generated_record_exposes_indexes
            scopes_remain_query_access_paths
            no_db_index_promise
          ],
          non_goals: %i[
            adapter_sql_index_generation
            runtime_db_migration
            app_backend_replacement
          ]
        }
      end
    end
  end
end
