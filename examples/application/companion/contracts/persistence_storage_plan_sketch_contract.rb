# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceStoragePlanSketchContract, outputs: %i[schema_version descriptor records histories summary] do
      input :manifest

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :persistence_storage_plan_sketch,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          schema_changes_allowed: false,
          sql_generation_allowed: false,
          role: :storage_lowering_sketch
        }
      end

      compute :records, depends_on: [:manifest] do |manifest:|
        manifest.fetch(:records).to_h do |name, entry|
          [name, Companion::Contracts.storage_record_plan(name, entry)]
        end
      end

      compute :histories, depends_on: [:manifest] do |manifest:|
        manifest.fetch(:histories).to_h do |name, entry|
          [name, Companion::Contracts.storage_history_plan(name, entry)]
        end
      end

      compute :summary, depends_on: %i[records histories descriptor] do |records:, histories:, descriptor:|
        column_count = records.values.sum { |record| record.fetch(:columns).length } +
                       histories.values.sum { |history| history.fetch(:columns).length }

        {
          status: :sketched,
          record_plan_count: records.length,
          history_plan_count: histories.length,
          column_candidate_count: column_count,
          index_candidate_count: records.values.sum { |record| record.fetch(:indexes).length },
          scope_descriptor_count: records.values.sum { |record| record.fetch(:scopes).length },
          schema_changes_allowed: descriptor.fetch(:schema_changes_allowed),
          sql_generation_allowed: descriptor.fetch(:sql_generation_allowed)
        }
      end

      output :schema_version
      output :descriptor
      output :records
      output :histories
      output :summary
    end

    def self.storage_record_plan(name, entry)
      storage = entry.fetch(:storage)
      {
        capability: name,
        source_shape: storage.fetch(:shape),
        store_lowering: :store_t,
        adapter: storage.fetch(:adapter),
        storage_name_candidate: name.to_s,
        table_candidate: name.to_s,
        primary_key_candidate: storage.fetch(:key),
        columns: storage_columns(entry),
        indexes: storage_indexes(entry),
        scopes: storage_scopes(entry),
        schema_changes_allowed: false
      }
    end

    def self.storage_history_plan(name, entry)
      storage = entry.fetch(:storage)
      {
        capability: name,
        source_shape: storage.fetch(:shape),
        history_lowering: :history_t,
        adapter: storage.fetch(:adapter),
        storage_name_candidate: name.to_s,
        table_candidate: name.to_s,
        partition_key_candidate: storage.fetch(:key),
        append_only: true,
        columns: storage_columns(entry),
        indexes: [],
        schema_changes_allowed: false
      }
    end

    def self.storage_columns(entry)
      storage_field_descriptors(entry).map do |field|
        attributes = field.fetch(:attributes, {})
        portable_type = attributes.fetch(:type, :unspecified)
        {
          name: field.fetch(:name),
          portable_type: portable_type,
          adapter_type_candidate: sqlite_adapter_type(portable_type),
          default: attributes.fetch(:default, nil),
          source: :field_descriptor
        }
      end
    end

    def self.storage_indexes(entry)
      entry.fetch(:indexes, []).map do |index|
        attributes = index.fetch(:attributes, {})
        {
          name: index.fetch(:name),
          fields: attributes.fetch(:fields, [index.fetch(:name)]),
          unique: attributes.fetch(:unique, false),
          source: :index_descriptor
        }
      end
    end

    def self.storage_scopes(entry)
      entry.fetch(:scopes, []).map do |scope|
        {
          name: scope.fetch(:name),
          where: scope.fetch(:attributes, {}).fetch(:where, {}),
          source: :scope_descriptor
        }
      end
    end

    def self.storage_field_descriptors(entry)
      entry.fetch(:field_descriptors, entry.fetch(:fields, [])).map do |field|
        field.is_a?(Hash) ? field : { name: field, attributes: {} }
      end
    end

    def self.sqlite_adapter_type(portable_type)
      case portable_type.to_sym
      when :json
        :json_document
      when :datetime
        :datetime_text
      when :integer
        :integer
      when :float
        :real
      when :boolean
        :boolean_integer
      else
        :text
      end
    end
  end
end
