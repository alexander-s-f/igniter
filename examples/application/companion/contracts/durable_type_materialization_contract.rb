# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :DurableTypeMaterializationContract,
              outputs: %i[status static_required record_contract history_contracts relations required_capabilities validation_errors summary] do
      input :type_spec

      compute :validation_errors, depends_on: [:type_spec] do |type_spec:|
        errors = []
        errors << "name is required" unless type_spec.fetch(:name, nil)
        errors << "fields are required" if Array(type_spec.fetch(:fields, [])).empty?
        Array(type_spec.fetch(:histories, [])).each do |history|
          errors << "#{history.fetch(:name, :history)} relation is required" unless history.fetch(:relation, nil)
        end
        errors
      end

      compute :status, depends_on: [:validation_errors] do |validation_errors:|
        validation_errors.empty? ? :ready_for_static_materialization : :blocked
      end

      compute :static_required, depends_on: [:status] do |status:|
        status == :ready_for_static_materialization
      end

      compute :record_contract, depends_on: [:type_spec] do |type_spec:|
        {
          contract: type_spec.fetch(:name).to_sym,
          capability: type_spec.fetch(:capability, :"#{type_spec.fetch(:name).to_s.downcase}s"),
          persist: type_spec.fetch(:persist),
          fields: Array(type_spec.fetch(:fields)),
          indexes: Array(type_spec.fetch(:indexes, [])),
          scopes: Array(type_spec.fetch(:scopes, [])),
          commands: Array(type_spec.fetch(:commands, []))
        }
      end

      compute :history_contracts, depends_on: [:type_spec] do |type_spec:|
        Array(type_spec.fetch(:histories, [])).map do |history|
          {
            contract: history.fetch(:name).to_sym,
            capability: history.fetch(:capability, :"#{history.fetch(:name).to_s.downcase}s"),
            history: history.fetch(:history),
            fields: Array(history.fetch(:fields))
          }
        end
      end

      compute :relations, depends_on: [:type_spec] do |type_spec:|
        Array(type_spec.fetch(:histories, [])).each_with_object({}) do |history, result|
          relation = history.fetch(:relation, nil)
          next unless relation

          result[relation.fetch(:name).to_sym] = relation.merge(enforced: false)
        end
      end

      compute :required_capabilities, depends_on: [:static_required] do |static_required:|
        static_required ? %i[write git test restart] : []
      end

      compute :summary, depends_on: %i[status record_contract history_contracts relations required_capabilities validation_errors] do |status:, record_contract:, history_contracts:, relations:, required_capabilities:, validation_errors:|
        if status == :blocked
          "Materialization blocked: #{validation_errors.join("; ")}"
        else
          "#{record_contract.fetch(:contract)} requires #{history_contracts.length} history contracts, #{relations.length} relations, capabilities #{required_capabilities.join(",")}."
        end
      end

      output :status
      output :static_required
      output :record_contract
      output :history_contracts
      output :relations
      output :required_capabilities
      output :validation_errors
      output :summary
    end
  end
end
