# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :WizardTypeSpecMigrationPlanContract, outputs: %i[status report_count candidate_count reports summary] do
      input :spec_history

      compute :reports, depends_on: [:spec_history] do |spec_history:|
        Array(spec_history).group_by { |entry| entry.fetch(:spec_id) }.map do |spec_id, entries|
          ordered = entries.sort_by { |entry| entry.fetch(:index) }
          current = ordered.last
          previous = ordered[-2]

          if previous.nil?
            next {
              spec_id: spec_id,
              contract: current.fetch(:contract),
              status: :stable,
              previous_index: nil,
              current_index: current.fetch(:index),
              previous_schema_version: nil,
              current_schema_version: current.fetch(:spec).fetch(:schema_version, 0),
              added_fields: [],
              removed_fields: [],
              changed_fields: [],
              candidates: []
            }
          end

          previous_fields = Companion::Contracts.current_fields_by_name(previous.fetch(:spec))
          current_fields = Companion::Contracts.current_fields_by_name(current.fetch(:spec))
          added_fields = current_fields.keys - previous_fields.keys
          removed_fields = previous_fields.keys - current_fields.keys
          changed_fields = (current_fields.keys & previous_fields.keys).reject do |name|
            current_fields.fetch(name) == previous_fields.fetch(name)
          end
          status = Companion::Contracts.migration_status(added_fields, removed_fields, changed_fields)

          {
            spec_id: spec_id,
            contract: current.fetch(:contract),
            status: status,
            previous_index: previous.fetch(:index),
            current_index: current.fetch(:index),
            previous_schema_version: previous.fetch(:spec).fetch(:schema_version, 0),
            current_schema_version: current.fetch(:spec).fetch(:schema_version, 0),
            added_fields: added_fields,
            removed_fields: removed_fields,
            changed_fields: changed_fields,
            candidates: Companion::Contracts.migration_candidates(status, added_fields, removed_fields, changed_fields)
          }
        end
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
        "#{report_count} spec reports, #{candidate_count} review-only migration candidates, status #{status}."
      end

      output :status
      output :report_count
      output :candidate_count
      output :reports
      output :summary
    end

    def self.current_fields_by_name(spec)
      Array(spec.fetch(:fields, [])).to_h do |field|
        [field.fetch(:name).to_sym, field]
      end
    end

    def self.migration_status(added_fields, removed_fields, changed_fields)
      return :destructive if removed_fields.any?
      return :ambiguous if changed_fields.any?
      return :additive if added_fields.any?

      :stable
    end

    def self.migration_candidates(status, added_fields, removed_fields, changed_fields)
      return [] if status == :stable

      [
        {
          kind: status,
          review_only: true,
          added_fields: added_fields,
          removed_fields: removed_fields,
          changed_fields: changed_fields
        }
      ]
    end
  end
end
