# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionStoreSchemaGraphMetadataSidecarContract,
              outputs: %i[schema_version descriptor status checks graph manifest_scope_paths package_gap pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_store_schema_graph_metadata_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          store_side_execution: false,
          query_planner_promise: false,
          claim: :store_side_access_path_metadata_snapshot,
          declaration: :manifest_scope_paths_lower_to_schema_graph,
          lowers_to: :schema_graph_access_path_metadata
        }
      end

      compute :graph, depends_on: [:proof] do |proof:|
        proof.fetch(:graph)
      end

      compute :manifest_scope_paths, depends_on: [:proof] do |proof:|
        proof.fetch(:manifest_scope_paths)
      end

      compute :package_gap, depends_on: [:proof] do |proof:|
        proof.fetch(:package_gap)
      end

      compute :pressure, depends_on: [:proof] do |proof:|
        proof.fetch(:pressure)
      end

      compute :checks, depends_on: %i[descriptor graph manifest_scope_paths package_gap pressure proof] do |descriptor:, graph:, manifest_scope_paths:, package_gap:, pressure:, proof:|
        snapshot_paths = graph.fetch(:snapshot).values.flatten

        [
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime) == false),
          Companion::Contracts.check(:no_backend_replacement, descriptor.fetch(:replaces_app_backend) == false),
          Companion::Contracts.check(:no_main_state_mutation, proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:no_store_side_execution, descriptor.fetch(:store_side_execution) == false),
          Companion::Contracts.check(:no_query_planner_promise, descriptor.fetch(:query_planner_promise) == false),
          Companion::Contracts.check(:schema_graph_available, graph.fetch(:schema_graph_constant_present) &&
                                                              graph.fetch(:access_path_constant_present) &&
                                                              graph.fetch(:metadata_snapshot_api_present)),
          Companion::Contracts.check(:manifest_scope_paths_present, manifest_scope_paths.length == 3),
          Companion::Contracts.check(:snapshot_path_count_matches, graph.fetch(:path_count) == manifest_scope_paths.length),
          Companion::Contracts.check(:registered_stores_match, graph.fetch(:registered_stores).sort == manifest_scope_paths.map { |path| path.fetch(:store) }.uniq.sort),
          Companion::Contracts.check(:snapshot_preserves_filters, snapshot_paths.map { |path| [path.fetch(:store), path.fetch(:scope), path.fetch(:filters)] }.sort_by(&:inspect) ==
                                                                manifest_scope_paths.map { |path| [path.fetch(:store), path.fetch(:scope), path.fetch(:filters)] }.sort_by(&:inspect)),
          Companion::Contracts.check(:snapshot_does_not_expose_consumers, snapshot_paths.none? { |path| path.key?(:consumers) } &&
                                                                         snapshot_paths.all? { |path| path.fetch(:consumer_count).zero? }),
          Companion::Contracts.check(:package_schema_graph_gap_closed, package_gap.fetch(:status) == :closed &&
                                                                      package_gap.fetch(:expected_api) == :metadata_snapshot &&
                                                                      package_gap.fetch(:schema_graph_metadata_snapshot_present) == true),
          Companion::Contracts.check(:pressure_ready, pressure.fetch(:next_question) == :projection_descriptor_mirroring &&
                                                      pressure.fetch(:resolved) == :store_schema_graph_metadata_snapshot)
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks graph package_gap pressure] do |status:, checks:, graph:, package_gap:, pressure:|
        "#{status}: #{checks.length} schema graph metadata checks, " \
          "paths=#{graph.fetch(:path_count)}, gap=#{package_gap.fetch(:status)}, next=#{pressure.fetch(:next_question)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :graph
      output :manifest_scope_paths
      output :package_gap
      output :pressure
      output :summary
    end
  end
end
