# frozen_string_literal: true

require_relative "../igniter"

module Igniter
  module Data
    ConfigurationError = Class.new(Igniter::Error)
  end
end

require_relative "data/store"
require_relative "data/stores/in_memory"
require_relative "data/stores/sqlite"

module Igniter
  module Data
    class << self
      def default_store
        @default_store ||= Stores::InMemory.new
      end

      attr_writer :default_store

      def configure
        yield self
      end

      def reset!
        @default_store = nil
      end
    end
  end
end
