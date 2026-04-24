# frozen_string_literal: true

module Igniter
  module Embed
    class Config
      ContractRegistration = Struct.new(:definition, :name, keyword_init: true)

      attr_reader :name, :packs, :contract_registrations
      attr_accessor :cache, :root, :capture_exceptions, :executor_name

      def initialize(name:)
        @name = name.to_sym
        @cache = true
        @root = nil
        @packs = []
        @contract_registrations = []
        @capture_exceptions = false
        @executor_name = :inline
      end

      def pack(pack)
        packs << pack
        self
      end

      def contract(definition, as: nil)
        contract_registrations << ContractRegistration.new(definition: definition, name: as)
        self
      end

      def cache?
        !!cache
      end

      def capture_exceptions?
        !!capture_exceptions
      end
    end
  end
end
