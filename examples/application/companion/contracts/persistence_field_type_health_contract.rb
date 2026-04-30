# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceFieldTypeHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :field_type_plan

      compute :descriptor, depends_on: [:field_type_plan] do |field_type_plan:|
        {
          schema_version: 1,
          kind: :persistence_field_type_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: field_type_plan.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:field_type_plan] do |field_type_plan:|
        descriptor = field_type_plan.fetch(:descriptor)
        reports = field_type_plan.fetch(:records).values + field_type_plan.fetch(:histories).values
        fields = reports.flat_map { |report| report.fetch(:fields) }
        summary = field_type_plan.fetch(:summary)

        [
          Companion::Contracts.check(:schema_version, field_type_plan.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :persistence_field_type_plan),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_schema_changes, descriptor.fetch(:schema_changes_allowed, nil) == false),
          Companion::Contracts.check(:no_sql_generation, descriptor.fetch(:sql_generation_allowed, nil) == false),
          Companion::Contracts.check(:no_materializer_execution, descriptor.fetch(:materializer_execution_allowed, nil) == false),
          Companion::Contracts.check(:store_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:persist, nil) == :store_t),
          Companion::Contracts.check(:history_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:history, nil) == :history_t),
          Companion::Contracts.check(:shape_lowerings, reports.all? { |report| %i[store_t history_t].include?(report.fetch(:lowering)) }),
          Companion::Contracts.check(:supported_field_types, fields.all? { |field| Companion::Contracts.supported_field_type?(field.fetch(:declared_type)) }),
          Companion::Contracts.check(:required_keys_checked, reports.all? { |report| report.fetch(:fields).any? { |field| field.fetch(:name).to_sym == report.fetch(:key).to_sym && field.fetch(:required_key) } }),
          Companion::Contracts.check(:json_fields_checked, fields.select { |field| field.fetch(:declared_type) == :json }.all? { |field| field.key?(:sample_count) }),
          Companion::Contracts.check(:enum_fields_checked, fields.select { |field| field.fetch(:declared_type) == :enum }.all? { |field| field.fetch(:enum_values).any? }),
          Companion::Contracts.check(:no_type_issues, field_type_plan.fetch(:issue_count).zero?),
          Companion::Contracts.check(:summary_counts, summary.fetch(:record_shape_count) == field_type_plan.fetch(:records).length && summary.fetch(:history_shape_count) == field_type_plan.fetch(:histories).length),
          Companion::Contracts.check(:summary_non_executing, summary.fetch(:schema_changes_allowed) == false && summary.fetch(:sql_generation_allowed) == false && summary.fetch(:materializer_execution_allowed) == false)
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
          "#{check_count} persistence field type terms stable."
        else
          "Persistence field type drift: #{missing_terms.join(", ")}."
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
