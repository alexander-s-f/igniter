# frozen_string_literal: true

module Igniter
  module Embed
    class ContractsBuilder
      def initialize(config:)
        @config = config
      end

      def add(name_or_definition, definition = nil, as: nil, &block)
        name, contract_definition = normalize_add_arguments(name_or_definition, definition, as: as)
        config.contract(contract_definition, as: name)
        evaluate_add_block(&block) if block
        self
      end

      private

      attr_reader :config

      def normalize_add_arguments(name_or_definition, definition, as:)
        if ContractNaming.contract_class?(name_or_definition)
          name = as && ContractNaming.normalize_contract_name(as)
          return [name, name_or_definition]
        end

        name = ContractNaming.normalize_contract_name(as || name_or_definition)
        raise InvalidContractRegistrationError, "contract definition is required" unless definition

        [name, definition]
      end

      def evaluate_add_block(&block)
        if block.arity.zero?
          instance_eval(&block)
        else
          block.call(self)
        end
      end
    end
  end
end
