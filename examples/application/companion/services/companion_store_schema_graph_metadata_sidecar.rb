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
    class CompanionStoreSchemaGraphMetadataSidecar
      def self.packet
        proof = new.proof
        Contracts::CompanionStoreSchemaGraphMetadataSidecarContract.evaluate(proof: proof)
      end

      def proof
        persistence = CompanionPersistence.new(state: CompanionState.seeded)
        scope_paths = manifest_scope_paths(persistence)
        graph = Igniter::Store::SchemaGraph.new
        scope_paths.each { |path| graph.register(access_path_for(path)) }

        snapshot = graph.metadata_snapshot
        {
          main_state_mutated: false,
          manifest_scope_paths: scope_paths,
          graph: graph_report(graph, snapshot),
          package_gap: package_gap(graph),
          pressure: pressure_report
        }
      end

      private

      def manifest_scope_paths(persistence)
        persistence.access_path_plan.fetch(:records).flat_map do |_name, report|
          report.fetch(:paths).filter_map do |path|
            next unless path.fetch(:implemented) && path.fetch(:lookup_kind) == :scope

            filter_source = path.fetch(:filter_source)
            {
              capability: report.fetch(:capability),
              store: report.fetch(:storage_name_candidate),
              scope: filter_source.fetch(:scope),
              lookup: :primary_key,
              filters: filter_source.fetch(:where),
              cache_ttl: nil,
              lowers_to: :schema_graph_access_path
            }
          end
        end
      end

      def access_path_for(path)
        Igniter::Store::AccessPath.new(
          store: path.fetch(:store),
          lookup: path.fetch(:lookup),
          scope: path.fetch(:scope),
          filters: path.fetch(:filters),
          cache_ttl: path.fetch(:cache_ttl),
          consumers: []
        )
      end

      def graph_report(graph, snapshot)
        {
          schema_graph_constant_present: Igniter::Store.const_defined?(:SchemaGraph),
          access_path_constant_present: Igniter::Store.const_defined?(:AccessPath),
          metadata_snapshot_api_present: graph.respond_to?(:metadata_snapshot),
          registered_stores: graph.registered_stores,
          path_count: snapshot.values.sum(&:length),
          snapshot: snapshot
        }
      end

      def package_gap(graph)
        api_present = graph.respond_to?(:metadata_snapshot)
        {
          status: api_present ? :closed : :open,
          expected_api: :metadata_snapshot,
          schema_graph_metadata_snapshot_present: api_present,
          package_surface: :"igniter-store",
          lower_level_capability: :access_path_metadata
        }
      end

      def pressure_report
        {
          next_question: :projection_descriptor_mirroring,
          resolved: :store_schema_graph_metadata_snapshot,
          package_request: :use_schema_graph_snapshot_as_store_side_metadata_evidence,
          lowering_claim: :app_access_paths_lower_to_store_schema_graph_metadata,
          acceptance: %i[
            schema_graph_metadata_snapshot_present
            manifest_scope_paths_lower_to_access_paths
            snapshot_preserves_store_scope_filters
            snapshot_does_not_expose_consumer_callbacks
            no_query_planner_promise
            no_backend_migration
          ],
          non_goals: %i[
            projection_execution
            query_planner
            db_index_generation
            app_backend_migration
          ]
        }
      end
    end
  end
end
