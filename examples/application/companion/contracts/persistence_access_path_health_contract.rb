# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceAccessPathHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :access_path_plan

      compute :descriptor, depends_on: [:access_path_plan] do |access_path_plan:|
        {
          schema_version: 1,
          kind: :persistence_access_path_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: access_path_plan.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:access_path_plan] do |access_path_plan:|
        descriptor = access_path_plan.fetch(:descriptor)
        summary = access_path_plan.fetch(:summary)
        record_reports = access_path_plan.fetch(:records).values
        history_reports = access_path_plan.fetch(:histories).values
        relation_reports = access_path_plan.fetch(:relations).values
        projection_reports = access_path_plan.fetch(:projections).values
        paths = (record_reports + history_reports + relation_reports).flat_map { |report| report.fetch(:paths) }

        [
          Companion::Contracts.check(:schema_version, access_path_plan.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :persistence_access_path_plan),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_store_read_node, descriptor.fetch(:store_read_node_allowed, nil) == false),
          Companion::Contracts.check(:no_runtime_planner, descriptor.fetch(:runtime_planner_allowed, nil) == false),
          Companion::Contracts.check(:no_cache_execution, descriptor.fetch(:cache_execution_allowed, nil) == false),
          Companion::Contracts.check(:storage_source, descriptor.fetch(:source, {}).fetch(:storage, nil) == :persistence_storage_plan_sketch),
          Companion::Contracts.check(:relation_type_source, descriptor.fetch(:source, {}).fetch(:relation_types, nil) == :persistence_relation_type_plan),
          Companion::Contracts.check(:store_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:persist, nil) == :store_t),
          Companion::Contracts.check(:history_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:history, nil) == :history_t),
          Companion::Contracts.check(:relation_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:relation, nil) == :relation_t),
          Companion::Contracts.check(:record_paths_present, record_reports.all? { |report| report.fetch(:paths).any? }),
          Companion::Contracts.check(:history_paths_present, history_reports.all? { |report| report.fetch(:paths).any? }),
          Companion::Contracts.check(:relation_paths_present, relation_reports.all? { |report| report.fetch(:paths).any? }),
          Companion::Contracts.check(:path_descriptors, paths.all? { |path| path.fetch(:kind) == :store_read_descriptor && path.fetch(:boundary) == :app }),
          Companion::Contracts.check(:no_mutating_paths, paths.none? { |path| path.fetch(:mutates) }),
          Companion::Contracts.check(:cache_hints_present, paths.all? { |path| path.key?(:cache_hint) && path.key?(:reactive_consumer_hint) }),
          Companion::Contracts.check(:projection_consumers_present, projection_reports.all? { |projection| projection.key?(:reads) && projection.key?(:consumer_hint) }),
          Companion::Contracts.check(:summary_counts, summary.fetch(:path_count) == access_path_plan.fetch(:path_count)),
          Companion::Contracts.check(:summary_non_executing, summary.fetch(:store_read_node_allowed) == false && summary.fetch(:runtime_planner_allowed) == false && summary.fetch(:cache_execution_allowed) == false)
        ]
      end

      compute :missing_terms, depends_on: [:checks] do |checks:|
        checks.reject { |check| check.fetch(:present) }.map { |check| check.fetch(:term) }
      end

      compute :check_count, depends_on: [:checks] do |checks:|
        checks.length
      end

      compute :status, depends_on: [:missing_terms] do |missing_terms:|
        missing_terms.empty? ? :stable : :drift
      end

      compute :summary, depends_on: %i[status check_count missing_terms] do |status:, check_count:, missing_terms:|
        if status == :stable
          "#{check_count} persistence access path terms stable."
        else
          "Persistence access path drift: #{missing_terms.join(", ")}."
        end
      end

      output :status
      output :check_count
      output :descriptor
      output :missing_terms
      output :checks
      output :summary
    end
  end
end
