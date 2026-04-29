# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceStorageMigrationPlanContract,
              outputs: %i[schema_version descriptor status report_count candidate_count reports summary] do
      input :storage_plan
      input :previous_storage_plan

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :persistence_storage_migration_plan,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          migration_execution_allowed: false,
          sql_generation_allowed: false,
          source: :persistence_storage_plan_sketch
        }
      end

      compute :reports, depends_on: %i[storage_plan previous_storage_plan] do |storage_plan:, previous_storage_plan:|
        Companion::Contracts.storage_migration_reports(storage_plan, previous_storage_plan)
      end

      compute :candidate_count, depends_on: [:reports] do |reports:|
        reports.sum { |report| report.fetch(:candidates).length }
      end

      compute :report_count, depends_on: [:reports] do |reports:|
        reports.length
      end

      compute :status, depends_on: [:candidate_count] do |candidate_count:|
        candidate_count.zero? ? :stable : :review_required
      end

      compute :summary, depends_on: %i[status report_count candidate_count] do |status:, report_count:, candidate_count:|
        "#{report_count} storage reports, #{candidate_count} review-only storage migration candidates, status #{status}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :report_count
      output :candidate_count
      output :reports
      output :summary
    end

    def self.storage_migration_reports(current_plan, previous_plan)
      previous = previous_plan || current_plan
      storage_migration_reports_for(:record, current_plan.fetch(:records), previous.fetch(:records)) +
        storage_migration_reports_for(:history, current_plan.fetch(:histories), previous.fetch(:histories))
    end

    def self.storage_migration_reports_for(shape, current_entries, previous_entries)
      (current_entries.keys | previous_entries.keys).sort.map do |name|
        current = current_entries.fetch(name, nil)
        previous = previous_entries.fetch(name, nil)
        storage_migration_report(shape, name, current, previous)
      end
    end

    def self.storage_migration_report(shape, name, current, previous)
      diff = storage_migration_diff(current, previous)
      status = storage_migration_status(diff)
      {
        capability: name,
        shape: shape,
        status: status,
        previous_present: !previous.nil?,
        current_present: !current.nil?,
        table_candidate: current&.fetch(:table_candidate, nil) || previous&.fetch(:table_candidate, nil),
        added_columns: diff.fetch(:added_columns),
        removed_columns: diff.fetch(:removed_columns),
        changed_columns: diff.fetch(:changed_columns),
        added_indexes: diff.fetch(:added_indexes),
        removed_indexes: diff.fetch(:removed_indexes),
        changed_indexes: diff.fetch(:changed_indexes),
        added_scopes: diff.fetch(:added_scopes),
        removed_scopes: diff.fetch(:removed_scopes),
        changed_scopes: diff.fetch(:changed_scopes),
        key_changed: diff.fetch(:key_changed),
        adapter_changed: diff.fetch(:adapter_changed),
        append_only_changed: diff.fetch(:append_only_changed),
        candidates: storage_migration_candidates(status, diff)
      }
    end

    def self.storage_migration_diff(current, previous)
      current_columns = storage_named_entries(current, :columns)
      previous_columns = storage_named_entries(previous, :columns)
      current_indexes = storage_named_entries(current, :indexes)
      previous_indexes = storage_named_entries(previous, :indexes)
      current_scopes = storage_named_entries(current, :scopes)
      previous_scopes = storage_named_entries(previous, :scopes)

      {
        added_columns: current_columns.keys - previous_columns.keys,
        removed_columns: previous_columns.keys - current_columns.keys,
        changed_columns: storage_changed_names(current_columns, previous_columns),
        added_indexes: current_indexes.keys - previous_indexes.keys,
        removed_indexes: previous_indexes.keys - current_indexes.keys,
        changed_indexes: storage_changed_names(current_indexes, previous_indexes),
        added_scopes: current_scopes.keys - previous_scopes.keys,
        removed_scopes: previous_scopes.keys - current_scopes.keys,
        changed_scopes: storage_changed_names(current_scopes, previous_scopes),
        key_changed: storage_key_candidate(current) != storage_key_candidate(previous),
        adapter_changed: current&.fetch(:adapter, nil) != previous&.fetch(:adapter, nil),
        append_only_changed: current&.fetch(:append_only, nil) != previous&.fetch(:append_only, nil)
      }
    end

    def self.storage_migration_status(diff)
      return :destructive if diff.fetch(:removed_columns).any? || diff.fetch(:removed_indexes).any? || diff.fetch(:removed_scopes).any?

      ambiguous = diff.fetch(:changed_columns).any? ||
                  diff.fetch(:changed_indexes).any? ||
                  diff.fetch(:changed_scopes).any? ||
                  diff.fetch(:key_changed) ||
                  diff.fetch(:adapter_changed) ||
                  diff.fetch(:append_only_changed)
      return :ambiguous if ambiguous

      additive = diff.fetch(:added_columns).any? || diff.fetch(:added_indexes).any? || diff.fetch(:added_scopes).any?
      additive ? :additive : :stable
    end

    def self.storage_migration_candidates(status, diff)
      return [] if status == :stable

      [
        diff.merge(
          kind: status,
          review_only: true,
          migration_execution_allowed: false,
          sql_generation_allowed: false
        )
      ]
    end

    def self.storage_named_entries(plan, key)
      return {} unless plan

      plan.fetch(key, []).to_h { |entry| [entry.fetch(:name), entry] }
    end

    def self.storage_changed_names(current_entries, previous_entries)
      (current_entries.keys & previous_entries.keys).reject do |name|
        current_entries.fetch(name) == previous_entries.fetch(name)
      end
    end

    def self.storage_key_candidate(plan)
      return nil unless plan

      plan.fetch(:primary_key_candidate, plan.fetch(:partition_key_candidate, nil))
    end
  end
end
