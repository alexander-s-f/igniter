# frozen_string_literal: true

module Igniter
  module Embed
    class Config
      ContractRegistration = Struct.new(:definition, :name, keyword_init: true)

      attr_reader :name, :packs, :contract_registrations, :discovery_pattern
      attr_accessor :cache, :capture_exceptions, :executor_name

      def initialize(name:)
        @name = name.to_sym
        @cache = true
        @root = nil
        @packs = []
        @contract_registrations = []
        @discovery_enabled = false
        @discovery_pattern = "**/*_contract.rb"
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

      def root(path = nil)
        return @root if path.nil?

        @root = File.expand_path(path.to_s)
        self
      end

      def root=(path)
        root(path)
      end

      def discover!(pattern: "**/*_contract.rb")
        @discovery_enabled = true
        @discovery_pattern = pattern
        self
      end

      def cache?
        !!cache
      end

      def discovery_enabled?
        !!@discovery_enabled
      end

      def capture_exceptions?
        !!capture_exceptions
      end
    end
  end
end
