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

      def scope(name)
        definition = scopes.find { |candidate| candidate.fetch(:name).to_sym == name.to_sym }
        return [] unless definition

        where = definition.fetch(:attributes).fetch(:where, {})
        collection.select do |record|
          where.all? { |attribute, value| read(record, attribute).to_s == value.to_s }
        end.map(&:dup).freeze
      end

      def command(name)
        commands.find { |candidate| candidate.fetch(:name).to_sym == name.to_sym }&.dup
      end

      def api_manifest
        {
          key: key,
          fields: field_names,
          indexes: indexes,
          scopes: scopes,
          commands: commands,
          operations: %i[all find save update delete clear scope command]
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

      def indexes
        manifest.fetch(:indexes, []).map do |index|
          {
            name: index.fetch(:name),
            attributes: index.fetch(:attributes)
          }
        end
      end

      def scopes
        manifest.fetch(:scopes, []).map do |scope|
          {
            name: scope.fetch(:name),
            attributes: scope.fetch(:attributes)
          }
        end
      end

      def commands
        manifest.fetch(:commands, []).map do |command|
          {
            name: command.fetch(:name),
            attributes: command.fetch(:attributes)
          }
        end
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
