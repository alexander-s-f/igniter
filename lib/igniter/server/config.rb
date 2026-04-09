# frozen_string_literal: true

module Igniter
  module Server
    class Config
      attr_accessor :host, :port, :store, :logger
      attr_reader   :registry

      def initialize
        @host     = "0.0.0.0"
        @port     = 4567
        @store    = Igniter::Runtime::Stores::MemoryStore.new
        @registry = Registry.new
        @logger   = nil
      end

      def register(name, contract_class)
        @registry.register(name, contract_class)
        self
      end

      def contracts=(hash)
        hash.each { |name, klass| register(name.to_s, klass) }
      end
    end
  end
end
