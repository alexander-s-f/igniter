# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceEffectIntentPlanContract,
              outputs: %i[schema_version descriptor status intent_count commands summary] do
      input :manifest
      input :access_path_plan

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :persistence_effect_intent_plan,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          store_write_node_allowed: false,
          store_append_node_allowed: false,
          saga_execution_allowed: false,
          app_boundary_required: true,
          source: {
            commands: :operation_manifest,
            access_paths: :persistence_access_path_plan
          },
          preserves: {
            persist: :store_t,
            history: :history_t,
            command: :mutation_intent
          }
        }
      end

      compute :commands, depends_on: %i[manifest access_path_plan] do |manifest:, access_path_plan:|
        manifest.fetch(:commands).to_h do |name, command|
          [name, Companion::Contracts.effect_intent_command_report(name, command, access_path_plan)]
        end
      end

      compute :intent_count, depends_on: [:commands] do |commands:|
        commands.values.sum { |report| report.fetch(:intents).length }
      end

      compute :status do
        :sketched
      end

      compute :summary, depends_on: %i[status intent_count commands descriptor] do |status:, intent_count:, commands:, descriptor:|
        {
          status: status,
          command_group_count: commands.length,
          intent_count: intent_count,
          store_write_node_allowed: descriptor.fetch(:store_write_node_allowed),
          store_append_node_allowed: descriptor.fetch(:store_append_node_allowed),
          saga_execution_allowed: descriptor.fetch(:saga_execution_allowed),
          app_boundary_required: descriptor.fetch(:app_boundary_required)
        }
      end

      output :schema_version
      output :descriptor
      output :status
      output :intent_count
      output :commands
      output :summary
    end

    def self.effect_intent_command_report(name, command, access_path_plan)
      target = command.fetch(:target, nil)
      intents = command.fetch(:operation_descriptors).map do |operation|
        effect_intent_descriptor(name, command, operation, target, access_path_plan)
      end

      {
        command_group: name,
        contract: command.fetch(:contract),
        target: target,
        target_shape: command.fetch(:target_shape, nil),
        commands: command.fetch(:commands),
        intents: intents
      }
    end

    def self.effect_intent_descriptor(command_group, command, operation, target, access_path_plan)
      operation_name = operation.fetch(:name)
      target_shape = operation.fetch(:target_shape)
      actual_target = operation.fetch(:target, target)
      {
        kind: :typed_effect_intent,
        command_group: command_group,
        operation: operation_name,
        source_kind: operation.fetch(:kind),
        source_boundary: operation.fetch(:boundary),
        target: actual_target,
        target_shape: target_shape,
        effect: effect_intent_kind(operation_name),
        write_kind: effect_intent_write_kind(operation_name),
        lowering: effect_intent_lowering(target_shape),
        mutates: operation.fetch(:mutates),
        boundary: :app,
        app_boundary_required: true,
        runtime_effect_node_allowed: false,
        saga_execution_allowed: false,
        command_still_lowers_to: :mutation_intent,
        access_path_source: access_path_source_status(actual_target, target_shape, access_path_plan),
        metadata: {
          command_names: command.fetch(:commands),
          future_node: effect_intent_future_node(operation_name)
        }
      }
    end

    def self.effect_intent_kind(operation)
      case operation
      when :record_append, :record_update
        :store_write
      when :history_append
        :store_append
      else
        :none
      end
    end

    def self.effect_intent_write_kind(operation)
      case operation
      when :record_append
        :insert
      when :record_update
        :update
      when :history_append
        :append
      else
        :none
      end
    end

    def self.effect_intent_lowering(target_shape)
      case target_shape
      when :store
        :store_t
      when :history
        :history_t
      else
        :none
      end
    end

    def self.effect_intent_future_node(operation)
      case effect_intent_kind(operation)
      when :store_write
        :store_write
      when :store_append
        :store_append
      else
        :none
      end
    end

    def self.access_path_source_status(target, target_shape, access_path_plan)
      return { present: false, reason: :none_operation } unless target

      collection = target_shape == :history ? :histories : :records
      present = access_path_plan.fetch(collection, {}).key?(target)
      {
        present: present,
        source: :persistence_access_path_plan,
        collection: collection
      }
    end
  end
end
