# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceEffectIntentHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :effect_intent_plan

      compute :descriptor, depends_on: [:effect_intent_plan] do |effect_intent_plan:|
        {
          schema_version: 1,
          kind: :persistence_effect_intent_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: effect_intent_plan.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:effect_intent_plan] do |effect_intent_plan:|
        descriptor = effect_intent_plan.fetch(:descriptor)
        summary = effect_intent_plan.fetch(:summary)
        command_reports = effect_intent_plan.fetch(:commands).values
        intents = command_reports.flat_map { |report| report.fetch(:intents) }
        mutating_intents = intents.select { |intent| intent.fetch(:mutates) }
        none_intents = intents.reject { |intent| intent.fetch(:mutates) }

        [
          Companion::Contracts.check(:schema_version, effect_intent_plan.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :persistence_effect_intent_plan),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_store_write_node, descriptor.fetch(:store_write_node_allowed, nil) == false),
          Companion::Contracts.check(:no_store_append_node, descriptor.fetch(:store_append_node_allowed, nil) == false),
          Companion::Contracts.check(:no_saga_execution, descriptor.fetch(:saga_execution_allowed, nil) == false),
          Companion::Contracts.check(:app_boundary_required, descriptor.fetch(:app_boundary_required, nil) == true),
          Companion::Contracts.check(:command_source, descriptor.fetch(:source, {}).fetch(:commands, nil) == :operation_manifest),
          Companion::Contracts.check(:access_path_source, descriptor.fetch(:source, {}).fetch(:access_paths, nil) == :persistence_access_path_plan),
          Companion::Contracts.check(:store_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:persist, nil) == :store_t),
          Companion::Contracts.check(:history_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:history, nil) == :history_t),
          Companion::Contracts.check(:command_lowering_preserved, descriptor.fetch(:preserves, {}).fetch(:command, nil) == :mutation_intent),
          Companion::Contracts.check(:command_reports_present, command_reports.any? && command_reports.all? { |report| report.fetch(:intents).any? }),
          Companion::Contracts.check(:intent_descriptors, intents.all? { |intent| intent.fetch(:kind) == :typed_effect_intent && intent.fetch(:boundary) == :app }),
          Companion::Contracts.check(:mutation_intent_source, intents.all? { |intent| intent.fetch(:source_kind) == :mutation_intent && intent.fetch(:command_still_lowers_to) == :mutation_intent }),
          Companion::Contracts.check(:no_runtime_effect_node, intents.all? { |intent| intent.fetch(:runtime_effect_node_allowed) == false }),
          Companion::Contracts.check(:no_intent_saga_execution, intents.all? { |intent| intent.fetch(:saga_execution_allowed) == false }),
          Companion::Contracts.check(:mutating_targets_present, mutating_intents.all? { |intent| intent.fetch(:access_path_source).fetch(:present) }),
          Companion::Contracts.check(:mutating_effects_typed, mutating_intents.all? { |intent| %i[store_write store_append].include?(intent.fetch(:effect)) }),
          Companion::Contracts.check(:none_intents_non_mutating, none_intents.all? { |intent| intent.fetch(:effect) == :none && intent.fetch(:target_shape) == :none }),
          Companion::Contracts.check(:summary_counts, summary.fetch(:intent_count) == effect_intent_plan.fetch(:intent_count)),
          Companion::Contracts.check(:summary_non_executing, summary.fetch(:store_write_node_allowed) == false && summary.fetch(:store_append_node_allowed) == false && summary.fetch(:saga_execution_allowed) == false)
        ]
      end

      compute :missing_terms, depends_on: [:checks] do |checks:|
        checks.reject { |check| check.fetch(:present) }.map { |check| check.fetch(:term) }
      end

      compute :check_count, depends_on: [:checks] do |checks:|
        checks.length
      end

      compute :status, depends_on: [:missing_terms] do |missing_terms:|
        missing_terms.empty? ? :stable : :drift
      end

      compute :summary, depends_on: %i[status check_count missing_terms] do |status:, check_count:, missing_terms:|
        if status == :stable
          "#{check_count} persistence effect intent terms stable."
        else
          "Persistence effect intent drift: #{missing_terms.join(", ")}."
        end
      end

      output :status
      output :check_count
      output :descriptor
      output :missing_terms
      output :checks
      output :summary
    end
  end
end
