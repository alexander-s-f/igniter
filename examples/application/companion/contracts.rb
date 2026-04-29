# frozen_string_literal: true

require "igniter/contracts"
require "igniter/extensions/contracts"

module Companion
  module Contracts
    module PersistenceSketchPack
      module_function

      def manifest
        Igniter::Contracts::PackManifest.new(
          name: :companion_persistence_sketch,
          registry_contracts: [
            Igniter::Contracts::PackManifest.dsl_keyword(:persist),
            Igniter::Contracts::PackManifest.dsl_keyword(:history),
            Igniter::Contracts::PackManifest.dsl_keyword(:field)
          ],
          metadata: { category: :persistence, report_only: true }
        )
      end

      def install_into(kernel)
        kernel.dsl_keywords.register(:persist, persist_keyword)
        kernel.dsl_keywords.register(:history, history_keyword)
        kernel.dsl_keywords.register(:field, field_keyword)
        kernel
      end

      def persist_keyword
        Igniter::Contracts::DslKeyword.new(:persist) do |name = :__persist, builder:, key:, adapter:, **attributes|
          builder.add_operation(
            kind: :const,
            name: name,
            value: {
              kind: :persist,
              key: key.to_sym,
              adapter: adapter.to_sym,
              attributes: attributes.transform_keys(&:to_sym)
            }
          )
        end
      end

      def history_keyword
        Igniter::Contracts::DslKeyword.new(:history) do |name = :__history, builder:, key:, adapter:, **attributes|
          builder.add_operation(
            kind: :const,
            name: name,
            value: {
              kind: :history,
              key: key.to_sym,
              adapter: adapter.to_sym,
              attributes: attributes.transform_keys(&:to_sym)
            }
          )
        end
      end

      def field_keyword
        Igniter::Contracts::DslKeyword.new(:field) do |name, builder:, **attributes|
          builder.add_operation(
            kind: :const,
            name: :"__field_#{name}",
            value: {
              kind: :field,
              name: name.to_sym,
              attributes: attributes.transform_keys(&:to_sym)
            }
          )
        end
      end
    end

    def self.contract(name, outputs: [], &block)
      contracts(name, outputs: outputs, &block)
    end

    def self.command_result(kind, feedback_code, subject_id, action_kind, action_status)
      {
        kind: kind,
        success: kind == :success,
        feedback_code: feedback_code,
        subject_id: subject_id,
        action_kind: action_kind,
        action_status: action_status
      }
    end

    def self.record_append(target, record)
      {
        operation: :record_append,
        target: target.to_sym,
        record: record
      }
    end

    def self.record_update(target, id, changes)
      {
        operation: :record_update,
        target: target.to_sym,
        id: id,
        changes: changes
      }
    end

    def self.history_append(target, event)
      {
        operation: :history_append,
        target: target.to_sym,
        event: event
      }
    end

    def self.no_mutation
      { operation: :none }
    end

    def self.contracts(name, outputs:, &block)
      contract_class = Class.new(Igniter::Contract)
      contract_class.profile = Igniter::Contracts.build_profile(
        Igniter::Extensions::Contracts::Language::FormulaPack,
        Igniter::Extensions::Contracts::Language::PiecewisePack,
        Igniter::Extensions::Contracts::Language::ScalePack,
        PersistenceSketchPack
      )
      contract_class.define(&block)
      contract_class.define_singleton_method(:evaluate) do |**inputs|
        contract = new(**inputs)
        outputs.to_h { |output_name| [output_name, contract.output(output_name)] }
      end
      contract_class.define_singleton_method(:persistence_manifest) do
        Companion::Contracts.persistence_manifest_for(self)
      end
      const_set(name, contract_class)
    end

    def self.persistence_manifest_for(contract_class)
      operations = contract_class.compile.operations
      persist = operations.find { |operation| operation.name == :__persist }&.attributes&.fetch(:value, nil)
      history = operations.find { |operation| operation.name == :__history }&.attributes&.fetch(:value, nil)
      fields = operations
               .select { |operation| operation.name.to_s.start_with?("__field_") }
               .map { |operation| operation.attributes.fetch(:value) }

      {
        persist: persist,
        history: history,
        fields: fields
      }
    end
  end
end
