# frozen_string_literal: true

module Igniter
  module Embed
    class SugarExpansion
      def initialize(config:)
        @config = config
      end

      def to_h
        {
          host: config.name,
          owner: owner_name,
          root: config.root,
          cache: config.cache?,
          contracts: contracts,
          contractables: [],
          capabilities: [],
          events: [],
          clean_config: clean_config
        }
      end

      private

      attr_reader :config

      def owner_name
        owner = config.owner
        return nil unless owner
        return owner.name if owner.respond_to?(:name) && owner.name

        owner.inspect
      end

      def contracts
        config.contract_registrations.map do |registration|
          {
            name: registration_name(registration),
            class: registration_class(registration),
            kind: registration_kind(registration)
          }
        end
      end

      def clean_config
        {
          name: config.name,
          owner: owner_name,
          root: config.root,
          cache: config.cache?,
          contracts: contracts
        }
      end

      def registration_name(registration)
        return registration.name.to_sym if registration.name
        return ContractNaming.infer_contract_name(registration.definition) if ContractNaming.contract_class?(registration.definition)

        nil
      end

      def registration_class(registration)
        definition = registration.definition
        return definition.name if ContractNaming.contract_class?(definition) && definition.name

        nil
      end

      def registration_kind(registration)
        ContractNaming.contract_class?(registration.definition) ? :class : :block
      end
    end
  end
end
