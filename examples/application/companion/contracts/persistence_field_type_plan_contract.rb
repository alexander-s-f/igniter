# frozen_string_literal: true

require "date"
require "time"

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceFieldTypePlanContract,
              outputs: %i[schema_version descriptor status issue_count records histories summary] do
      input :manifest
      input :samples

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :persistence_field_type_plan,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          schema_changes_allowed: false,
          sql_generation_allowed: false,
          materializer_execution_allowed: false,
          preserves: {
            persist: :store_t,
            history: :history_t
          }
        }
      end

      compute :records, depends_on: %i[manifest samples] do |manifest:, samples:|
        manifest.fetch(:records).to_h do |name, entry|
          [name, Companion::Contracts.field_type_shape_report(:record, name, entry, samples.fetch(:records, {}).fetch(name, []))]
        end
      end

      compute :histories, depends_on: %i[manifest samples] do |manifest:, samples:|
        manifest.fetch(:histories).to_h do |name, entry|
          [name, Companion::Contracts.field_type_shape_report(:history, name, entry, samples.fetch(:histories, {}).fetch(name, []))]
        end
      end

      compute :issue_count, depends_on: %i[records histories] do |records:, histories:|
        (records.values + histories.values).sum { |report| report.fetch(:issue_count) }
      end

      compute :status, depends_on: [:issue_count] do |issue_count:|
        issue_count.zero? ? :stable : :review_required
      end

      compute :summary, depends_on: %i[status records histories issue_count descriptor] do |status:, records:, histories:, issue_count:, descriptor:|
        {
          status: status,
          record_shape_count: records.length,
          history_shape_count: histories.length,
          field_count: (records.values + histories.values).sum { |report| report.fetch(:field_count) },
          issue_count: issue_count,
          schema_changes_allowed: descriptor.fetch(:schema_changes_allowed),
          sql_generation_allowed: descriptor.fetch(:sql_generation_allowed),
          materializer_execution_allowed: descriptor.fetch(:materializer_execution_allowed)
        }
      end

      output :schema_version
      output :descriptor
      output :status
      output :issue_count
      output :records
      output :histories
      output :summary
    end

    def self.field_type_shape_report(shape, name, entry, samples)
      storage = entry.fetch(:storage)
      fields = storage_field_descriptors(entry)
      field_reports = fields.map do |field|
        field_type_report(field, samples, storage.fetch(:key))
      end
      issues = field_reports.flat_map { |report| report.fetch(:issues) }
      {
        capability: name,
        shape: shape,
        storage_shape: storage.fetch(:shape),
        lowering: shape == :record ? :store_t : :history_t,
        key: storage.fetch(:key),
        sample_count: samples.length,
        field_count: fields.length,
        issue_count: issues.length,
        fields: field_reports,
        issues: issues
      }
    end

    def self.field_type_report(field, samples, key)
      name = field.fetch(:name)
      attributes = field.fetch(:attributes, {})
      type = attributes.fetch(:type, :unspecified).to_sym
      issues = []
      issues << field_type_issue(name, :unsupported_type, type: type) unless supported_field_type?(type)
      issues << field_type_issue(name, :enum_values_missing) if type == :enum && Array(attributes.fetch(:values, [])).empty?
      issues.concat(field_default_issues(name, attributes, type))
      issues.concat(field_sample_issues(name, attributes, type, samples))
      issues.concat(field_key_issues(name, samples)) if name.to_sym == key.to_sym

      {
        name: name,
        declared_type: type,
        required_key: name.to_sym == key.to_sym,
        default: attributes.fetch(:default, nil),
        enum_values: Array(attributes.fetch(:values, [])).map(&:to_sym),
        sample_count: samples.count { |sample| sample.key?(name.to_sym) || sample.key?(name.to_s) },
        issues: issues
      }
    end

    def self.field_default_issues(name, attributes, type)
      return [] unless attributes.key?(:default)

      value = attributes.fetch(:default)
      return [] if value_matches_field_type?(value, type, attributes)

      [field_type_issue(name, :default_type_mismatch, value: value, type: type)]
    end

    def self.field_sample_issues(name, attributes, type, samples)
      samples.each_with_index.filter_map do |sample, index|
        value = sample.fetch(name.to_sym, sample.fetch(name.to_s, nil))
        next if value.nil? || type == :unspecified || value_matches_field_type?(value, type, attributes)

        field_type_issue(name, :sample_type_mismatch, sample_index: index, value: value, type: type)
      end
    end

    def self.field_key_issues(name, samples)
      samples.each_with_index.filter_map do |sample, index|
        value = sample.fetch(name.to_sym, sample.fetch(name.to_s, nil))
        next unless value.nil? || value.to_s.strip.empty?

        field_type_issue(name, :required_key_missing, sample_index: index)
      end
    end

    def self.field_type_issue(field, kind, **attributes)
      {
        field: field,
        kind: kind,
        attributes: attributes
      }
    end

    def self.supported_field_type?(type)
      %i[unspecified string integer float boolean datetime enum json].include?(type.to_sym)
    end

    def self.value_matches_field_type?(value, type, attributes)
      case type.to_sym
      when :unspecified
        true
      when :string
        value.is_a?(String)
      when :integer
        value.is_a?(Integer) && !boolean?(value)
      when :float
        value.is_a?(Numeric) && !boolean?(value)
      when :boolean
        boolean?(value)
      when :datetime
        datetime_value?(value)
      when :enum
        Array(attributes.fetch(:values, [])).map(&:to_sym).include?(value.to_sym)
      when :json
        json_value?(value)
      else
        false
      end
    rescue NoMethodError
      false
    end

    def self.boolean?(value)
      [true, false].include?(value)
    end

    def self.datetime_value?(value)
      return true if value.is_a?(Time) || value.is_a?(Date)
      return false unless value.is_a?(String)

      begin
        Time.iso8601(value)
      rescue ArgumentError
        Date.iso8601(value)
      end
      true
    rescue ArgumentError
      false
    end

    def self.json_value?(value)
      value.nil? ||
        value.is_a?(Hash) ||
        value.is_a?(Array) ||
        value.is_a?(String) ||
        value.is_a?(Numeric) ||
        boolean?(value)
    end
  end
end
