# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceRelationTypeHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :relation_type_plan

      compute :descriptor, depends_on: [:relation_type_plan] do |relation_type_plan:|
        {
          schema_version: 1,
          kind: :persistence_relation_type_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: relation_type_plan.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:relation_type_plan] do |relation_type_plan:|
        descriptor = relation_type_plan.fetch(:descriptor)
        relations = relation_type_plan.fetch(:relations).values
        joins = relations.flat_map { |relation| relation.fetch(:joins) }
        summary = relation_type_plan.fetch(:summary)

        [
          Companion::Contracts.check(:schema_version, relation_type_plan.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :persistence_relation_type_plan),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_relation_enforcement, descriptor.fetch(:relation_enforcement_allowed, nil) == false),
          Companion::Contracts.check(:no_foreign_key_generation, descriptor.fetch(:foreign_key_generation_allowed, nil) == false),
          Companion::Contracts.check(:source_field_type_plan, descriptor.fetch(:source, nil) == :persistence_field_type_plan),
          Companion::Contracts.check(:relation_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:relation, nil) == :relation_t),
          Companion::Contracts.check(:store_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:from, nil) == :store_t),
          Companion::Contracts.check(:history_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:to, nil) == :history_t),
          Companion::Contracts.check(:relation_shapes, relations.all? { |relation| relation.fetch(:lowering) == { shape: :relation, from: :store, to: :history } }),
          Companion::Contracts.check(:report_only_enforcement, relations.all? { |relation| relation.fetch(:enforcement) == { enforced: false, mode: :report_only } }),
          Companion::Contracts.check(:join_reports_present, joins.any? && joins.all? { |join| join.key?(:compatibility) && join.key?(:source) && join.key?(:target) }),
          Companion::Contracts.check(:no_missing_join_fields, joins.all? { |join| !join.fetch(:source).fetch(:missing) && !join.fetch(:target).fetch(:missing) }),
          Companion::Contracts.check(:no_join_type_mismatches, joins.none? { |join| join.fetch(:compatibility) == :mismatch }),
          Companion::Contracts.check(:no_type_issues, relation_type_plan.fetch(:issue_count).zero?),
          Companion::Contracts.check(:summary_counts, summary.fetch(:relation_count) == relation_type_plan.fetch(:relation_count) && summary.fetch(:issue_count) == relation_type_plan.fetch(:issue_count)),
          Companion::Contracts.check(:summary_non_enforcing, summary.fetch(:relation_enforcement_allowed) == false && summary.fetch(:foreign_key_generation_allowed) == false)
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
          "#{check_count} persistence relation type terms stable."
        else
          "Persistence relation type drift: #{missing_terms.join(", ")}."
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
