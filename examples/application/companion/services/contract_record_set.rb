# frozen_string_literal: true

module Companion
  module Services
    class ContractRecordSet
      def initialize(contract_class:, collection:, record_class:)
        @contract_class = contract_class
        @collection = collection
        @record_class = record_class
        @manifest = contract_class.persistence_manifest
      end

      def all
        collection.map(&:dup).freeze
      end

      def find(id)
        collection.find { |record| read(record, key).to_s == id.to_s }
      end

      def save(attributes)
        payload = record_payload(attributes)
        existing = find(payload.fetch(key))
        return update(payload.fetch(key), payload) if existing

        record = record_class.new(**payload)
        collection << record
        record
      end

      def update(id, changes)
        record = find(id)
        return nil unless record

        normalize(changes).each do |attribute, value|
          record[attribute] = value if field_names.include?(attribute) && record_members.include?(attribute)
        end
        record
      end

      def delete(id)
        index = collection.index { |record| read(record, key).to_s == id.to_s }
        index ? collection.delete_at(index) : nil
      end

      def clear
        collection.clear
      end

      def api_manifest
        {
          key: key,
          fields: field_names,
          operations: %i[all find save update delete clear]
        }
      end

      private

      attr_reader :contract_class, :collection, :record_class, :manifest

      def key
        persist.fetch(:key)
      end

      def persist
        manifest.fetch(:persist)
      end

      def fields
        manifest.fetch(:fields)
      end

      def field_names
        @field_names ||= fields.map { |field| field.fetch(:name).to_sym }.freeze
      end

      def record_members
        @record_members ||= record_class.members.map(&:to_sym).freeze
      end

      def record_payload(attributes)
        normalized = normalize(attributes)
        fields.to_h do |field|
          name = field.fetch(:name).to_sym
          value = if normalized.key?(name)
                    normalized.fetch(name)
                  else
                    field.fetch(:attributes).fetch(:default, nil)
                  end
          [name, value]
        end
      end

      def normalize(attributes)
        attributes.transform_keys(&:to_sym)
      end

      def read(record, attribute)
        record[attribute.to_sym]
      end
    end
  end
end
