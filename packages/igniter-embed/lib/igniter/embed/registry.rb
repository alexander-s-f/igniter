# frozen_string_literal: true

module Igniter
  module Embed
    class Registry
      def initialize
        @contracts = {}
      end

      def register(name, block)
        key = normalize_name(name)
        raise DuplicateContractError, "contract #{key} is already registered" if contracts.key?(key)

        contracts[key] = block
      end

      def fetch(name)
        key = normalize_name(name)
        contracts.fetch(key)
      rescue KeyError
        raise UnknownContractError, "unknown contract #{key}"
      end

      def key?(name)
        contracts.key?(normalize_name(name))
      end

      def names
        contracts.keys
      end

      private

      attr_reader :contracts

      def normalize_name(name)
        name.to_sym
      end
    end
  end
end
