# frozen_string_literal: true

module Companion
  module Services
    class ContractHistory
      def initialize(contract_class:, entries:, append:)
        @contract_class = contract_class
        @entries = entries
        @appender = append
        @manifest = contract_class.persistence_manifest
      end

      def append(attributes)
        payload = event_payload(attributes)
        append_entry(payload)
        payload.freeze
      end

      def all
        entries.call.map { |entry| event_payload(entry).freeze }.freeze
      end

      def where(criteria)
        normalized = normalize(criteria)
        all.select do |entry|
          normalized.all? { |attribute, value| entry.fetch(attribute).to_s == value.to_s }
        end.freeze
      end

      def count(criteria = {})
        criteria.empty? ? all.length : where(criteria).length
      end

      def api_manifest
        {
          key: key,
          storage: storage,
          history: history_alias,
          fields: field_names,
          operations: %i[append all where count],
          operation_descriptors: history_operation_descriptors
        }
      end

      private

      attr_reader :contract_class, :entries, :appender, :manifest

      def key
        history.fetch(:key)
      end

      def history
        manifest.fetch(:history)
      end

      def storage
        manifest.fetch(:storage)
      end

      def history_alias
        {
          key: history.fetch(:key),
          adapter: history.fetch(:adapter)
        }
      end

      def fields
        manifest.fetch(:fields)
      end

      def field_names
        @field_names ||= fields.map { |field| field.fetch(:name).to_sym }.freeze
      end

      def history_operation_descriptors
        %i[append all where count].map do |operation|
          {
            name: operation,
            kind: :history_api,
            target_shape: :history,
            mutates: operation == :append,
            boundary: :app
          }
        end
      end

      def event_payload(attributes)
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

      def append_entry(payload)
        appender.call(payload)
      end

      def normalize(attributes)
        attributes.transform_keys(&:to_sym)
      end
    end
  end
end
