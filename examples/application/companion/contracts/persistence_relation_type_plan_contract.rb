# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceRelationTypePlanContract,
              outputs: %i[schema_version descriptor status issue_count relation_count relations summary] do
      input :relation_manifest
      input :field_type_plan

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :persistence_relation_type_plan,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          relation_enforcement_allowed: false,
          foreign_key_generation_allowed: false,
          source: :persistence_field_type_plan,
          preserves: {
            relation: :relation_t,
            from: :store_t,
            to: :history_t
          }
        }
      end

      compute :relations, depends_on: %i[relation_manifest field_type_plan] do |relation_manifest:, field_type_plan:|
        relation_manifest.to_h do |name, relation|
          [name, Companion::Contracts.relation_type_report(name, relation, field_type_plan)]
        end
      end

      compute :relation_count, depends_on: [:relations] do |relations:|
        relations.length
      end

      compute :issue_count, depends_on: [:relations] do |relations:|
        relations.values.sum { |report| report.fetch(:issue_count) }
      end

      compute :status, depends_on: [:issue_count] do |issue_count:|
        issue_count.zero? ? :stable : :review_required
      end

      compute :summary, depends_on: %i[status relation_count issue_count descriptor] do |status:, relation_count:, issue_count:, descriptor:|
        {
          status: status,
          relation_count: relation_count,
          issue_count: issue_count,
          relation_enforcement_allowed: descriptor.fetch(:relation_enforcement_allowed),
          foreign_key_generation_allowed: descriptor.fetch(:foreign_key_generation_allowed)
        }
      end

      output :schema_version
      output :descriptor
      output :status
      output :issue_count
      output :relation_count
      output :relations
      output :summary
    end

    def self.relation_type_report(name, relation, field_type_plan)
      descriptor = relation.fetch(:descriptor)
      joins = relation.fetch(:join).map do |from_field, to_field|
        relation_type_join_report(from_field, to_field, descriptor, field_type_plan)
      end
      issues = joins.flat_map { |join| join.fetch(:issues) }
      {
        name: name,
        kind: relation.fetch(:kind),
        from: descriptor.fetch(:from),
        to: descriptor.fetch(:to),
        lowering: descriptor.fetch(:lowering),
        enforcement: descriptor.fetch(:enforcement),
        cardinality: relation.fetch(:cardinality),
        join_count: joins.length,
        issue_count: issues.length,
        joins: joins,
        issues: issues
      }
    end

    def self.relation_type_join_report(from_field, to_field, descriptor, field_type_plan)
      from_capability = descriptor.fetch(:from).fetch(:capability)
      to_capability = descriptor.fetch(:to).fetch(:capability)
      source = field_type_report_for(field_type_plan, descriptor.fetch(:from), from_field)
      target = field_type_report_for(field_type_plan, descriptor.fetch(:to), to_field)
      compatible = relation_field_types_compatible?(source.fetch(:declared_type), target.fetch(:declared_type))
      issues = []
      issues << relation_type_issue(:source_field_missing, capability: from_capability, field: from_field) if source.fetch(:missing)
      issues << relation_type_issue(:target_field_missing, capability: to_capability, field: to_field) if target.fetch(:missing)
      unless compatible
        issues << relation_type_issue(
          :join_type_mismatch,
          source_field: from_field,
          source_type: source.fetch(:declared_type),
          target_field: to_field,
          target_type: target.fetch(:declared_type)
        )
      end

      {
        from_field: from_field,
        to_field: to_field,
        source: source,
        target: target,
        compatibility: relation_type_compatibility(source.fetch(:declared_type), target.fetch(:declared_type), compatible),
        issues: issues
      }
    end

    def self.field_type_report_for(field_type_plan, endpoint, field)
      collection = endpoint.fetch(:storage_shape) == :store ? :records : :histories
      capability = endpoint.fetch(:capability)
      shape = field_type_plan.fetch(collection, {}).fetch(capability, {})
      report = Array(shape.fetch(:fields, [])).find { |candidate| candidate.fetch(:name).to_sym == field.to_sym }
      return report.merge(missing: false) if report

      {
        name: field,
        declared_type: :missing,
        required_key: false,
        enum_values: [],
        sample_count: 0,
        issues: [],
        missing: true
      }
    end

    def self.relation_field_types_compatible?(source_type, target_type)
      return false if [source_type, target_type].include?(:missing)
      return true if [source_type, target_type].include?(:unspecified)

      source_type.to_sym == target_type.to_sym
    end

    def self.relation_type_compatibility(source_type, target_type, compatible)
      if source_type == :unspecified || target_type == :unspecified
        :inferred
      elsif compatible
        :explicit
      else
        :mismatch
      end
    end

    def self.relation_type_issue(kind, **attributes)
      {
        kind: kind,
        attributes: attributes
      }
    end
  end
end
