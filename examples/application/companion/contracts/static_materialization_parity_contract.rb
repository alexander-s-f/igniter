# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :StaticMaterializationParityContract,
              outputs: %i[schema_version status plan_status static_required checked_capabilities mismatches summary] do
      input :materialization_plan
      input :manifest_snapshot

      compute :schema_version, depends_on: [:materialization_plan] do |materialization_plan:|
        materialization_plan.fetch(:schema_version, 0)
      end

      compute :plan_status, depends_on: [:materialization_plan] do |materialization_plan:|
        materialization_plan.fetch(:status)
      end

      compute :static_required, depends_on: [:materialization_plan] do |materialization_plan:|
        materialization_plan.fetch(:static_required)
      end

      compute :checked_capabilities, depends_on: [:materialization_plan] do |materialization_plan:|
        record = materialization_plan.fetch(:record_contract)
        histories = materialization_plan.fetch(:history_contracts)
        relations = materialization_plan.fetch(:relations)

        [record.fetch(:capability)] +
          histories.map { |history| history.fetch(:capability) } +
          relations.keys
      end

      compute :mismatches, depends_on: %i[schema_version materialization_plan manifest_snapshot] do |schema_version:, materialization_plan:, manifest_snapshot:|
        record = materialization_plan.fetch(:record_contract)
        histories = materialization_plan.fetch(:history_contracts)
        relations = materialization_plan.fetch(:relations)
        records = manifest_snapshot.fetch(:records)
        actual_histories = manifest_snapshot.fetch(:histories)
        actual_relations = manifest_snapshot.fetch(:relations)
        errors = []

        errors << "schema_version missing" if schema_version.to_i <= 0
        expected_record_fields = record.fetch(:fields).map { |field| field.fetch(:name).to_sym }
        actual_record = records.fetch(record.fetch(:capability), nil)
        if actual_record
          errors << "#{record.fetch(:capability)} fields differ" unless actual_record.fetch(:fields) == expected_record_fields
          errors << "#{record.fetch(:capability)} indexes differ" unless actual_record.fetch(:indexes).map { |index| index.fetch(:name).to_sym } == record.fetch(:indexes).map { |index| index.fetch(:name).to_sym }
          errors << "#{record.fetch(:capability)} scopes differ" unless actual_record.fetch(:scopes).map { |scope| scope.fetch(:name).to_sym } == record.fetch(:scopes).map { |scope| scope.fetch(:name).to_sym }
          errors << "#{record.fetch(:capability)} commands differ" unless actual_record.fetch(:commands).map { |command| command.fetch(:name).to_sym } == record.fetch(:commands).map { |command| command.fetch(:name).to_sym }
        else
          errors << "#{record.fetch(:capability)} record missing"
        end

        histories.each do |history|
          actual_history = actual_histories.fetch(history.fetch(:capability), nil)
          expected_fields = history.fetch(:fields).map { |field| field.fetch(:name).to_sym }
          if actual_history
            errors << "#{history.fetch(:capability)} fields differ" unless actual_history.fetch(:fields) == expected_fields
          else
            errors << "#{history.fetch(:capability)} history missing"
          end
        end

        relations.each do |name, relation|
          actual_relation = actual_relations.fetch(name, nil)
          if actual_relation
            errors << "#{name} relation differs" unless actual_relation.slice(:from, :to, :join, :enforced) == relation.slice(:from, :to, :join, :enforced)
          else
            errors << "#{name} relation missing"
          end
        end

        errors
      end

      compute :status, depends_on: %i[plan_status mismatches] do |plan_status:, mismatches:|
        plan_status == :ready_for_static_materialization && mismatches.empty? ? :matched : :drift
      end

      compute :summary, depends_on: %i[status checked_capabilities mismatches] do |status:, checked_capabilities:, mismatches:|
        if status == :matched
          "Static materialization matches #{checked_capabilities.length} planned capabilities."
        else
          "Static materialization drift: #{mismatches.join("; ")}"
        end
      end

      output :schema_version
      output :status
      output :plan_status
      output :static_required
      output :checked_capabilities
      output :mismatches
      output :summary
    end
  end
end
