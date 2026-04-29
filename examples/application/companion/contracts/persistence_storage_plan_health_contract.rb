# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceStoragePlanHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :storage_plan

      compute :descriptor, depends_on: [:storage_plan] do |storage_plan:|
        {
          schema_version: 1,
          kind: :persistence_storage_plan_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: storage_plan.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:storage_plan] do |storage_plan:|
        descriptor = storage_plan.fetch(:descriptor)
        records = storage_plan.fetch(:records)
        histories = storage_plan.fetch(:histories)
        summary = storage_plan.fetch(:summary)
        record_plans = records.values
        history_plans = histories.values

        [
          Companion::Contracts.check(:schema_version, storage_plan.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :persistence_storage_plan_sketch),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_schema_changes, descriptor.fetch(:schema_changes_allowed, nil) == false),
          Companion::Contracts.check(:no_sql_generation, descriptor.fetch(:sql_generation_allowed, nil) == false),
          Companion::Contracts.check(:record_lowerings, record_plans.all? { |plan| plan.fetch(:source_shape) == :store && plan.fetch(:store_lowering) == :store_t }),
          Companion::Contracts.check(:history_lowerings, history_plans.all? { |plan| plan.fetch(:source_shape) == :history && plan.fetch(:history_lowering) == :history_t && plan.fetch(:append_only) }),
          Companion::Contracts.check(:record_key_candidates, record_plans.all? { |plan| plan.key?(:primary_key_candidate) }),
          Companion::Contracts.check(:history_key_candidates, history_plans.all? { |plan| plan.key?(:partition_key_candidate) }),
          Companion::Contracts.check(:column_sources, (record_plans + history_plans).all? { |plan| plan.fetch(:columns).all? { |column| column.fetch(:source) == :field_descriptor } }),
          Companion::Contracts.check(:adapter_type_candidates, (record_plans + history_plans).all? { |plan| plan.fetch(:columns).all? { |column| column.key?(:adapter_type_candidate) } }),
          Companion::Contracts.check(:index_sources, record_plans.all? { |plan| plan.fetch(:indexes).all? { |index| index.fetch(:source) == :index_descriptor } }),
          Companion::Contracts.check(:scope_sources, record_plans.all? { |plan| plan.fetch(:scopes).all? { |scope| scope.fetch(:source) == :scope_descriptor } }),
          Companion::Contracts.check(:summary_counts, summary.fetch(:record_plan_count) == records.length && summary.fetch(:history_plan_count) == histories.length),
          Companion::Contracts.check(:summary_non_executing, summary.fetch(:schema_changes_allowed) == false && summary.fetch(:sql_generation_allowed) == false)
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
          "#{check_count} persistence storage plan terms stable."
        else
          "Persistence storage plan drift: #{missing_terms.join(", ")}."
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
