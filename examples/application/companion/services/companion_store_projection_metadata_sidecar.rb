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
    class CompanionStoreProjectionMetadataSidecar
      def self.packet
        proof = new.proof
        Contracts::CompanionStoreProjectionMetadataSidecarContract.evaluate(proof: proof)
      end

      def proof
        persistence = CompanionPersistence.new(state: CompanionState.seeded)
        projections = projection_reports(persistence)

        {
          main_state_mutated: false,
          projections: projections,
          package_gap: package_gap(projections),
          pressure: pressure_report
        }
      end

      private

      def projection_reports(persistence)
        manifest = persistence.manifest_snapshot
        access_path_plan = persistence.access_path_plan.fetch(:projections)

        manifest.fetch(:projections).map do |name, projection|
          access_path = access_path_plan.fetch(name)
          normalize_projection(name, projection, access_path)
        end
      end

      def normalize_projection(name, projection, access_path)
        reads = projection.fetch(:reads)
        relations = projection.fetch(:relations)

        {
          name: name,
          contract: projection.fetch(:contract).name.to_s.split("::").last.to_sym,
          reads: reads,
          relations: relations,
          lowers_to: :projection_descriptor,
          consumer_hint: access_path.fetch(:consumer_hint),
          reactive_consumer_hint: access_path.fetch(:reactive_consumer_hint),
          reads_record_or_history: reads.any?,
          relation_metadata_linked: relation_metadata_linked?(name, relations),
          store_side_execution: false,
          query_planner_promise: false
        }
      end

      def relation_metadata_linked?(name, relations)
        relations.empty? || relations == %i[tracker_logs_by_tracker] && name == :tracker_read_model
      end

      def package_gap(projections)
        {
          status: :open,
          expected_api: :_projections,
          generated_projection_api_present: false,
          projection_count: projections.length,
          package_surface: :"igniter-companion",
          lower_level_capability: :"Store[T]/History[T]"
        }
      end

      def pressure_report
        {
          next_question: :projection_descriptor_mirroring,
          resolved: :app_projection_metadata_shape,
          package_request: :mirror_projection_metadata_without_execution,
          lowering_claim: :projection_metadata_lowers_to_read_descriptor,
          acceptance: %i[
            projections_manifest_present
            projection_reads_known
            projection_relations_known
            tracker_projection_composes_record_and_history
            no_store_side_projection_execution
            no_query_planner_promise
            package_projection_gap_open
          ],
          non_goals: %i[
            store_projection_execution
            adapter_query_planner
            projection_cache_runtime
            backend_migration
          ]
        }
      end
    end
  end
end
