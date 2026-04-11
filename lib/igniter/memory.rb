# frozen_string_literal: true

require "igniter/errors"
require "igniter/memory/episode"
require "igniter/memory/fact"
require "igniter/memory/reflection_record"
require "igniter/memory/store"
require "igniter/memory/stores/in_memory"
require "igniter/memory/stores/sqlite"
require "igniter/memory/reflection_cycle"
require "igniter/memory/agent_memory"
require "igniter/memory/memorable"

module Igniter
  # Pluggable episodic memory system for Agents and Skills.
  #
  # Agents and Skills can record what happened (episodes), store learned facts,
  # and trigger reflection cycles that analyse past behaviour.
  #
  # == Quick start
  #
  #   require "igniter/memory"
  #
  #   class MyAgent < Igniter::Agent
  #     include Igniter::Memory::Memorable
  #     enable_memory  # uses the global default InMemory store
  #   end
  #
  # == Custom store
  #
  #   Igniter::Memory.default_store = Igniter::Memory::Stores::SQLite.new(path: "/tmp/mem.db")
  #
  #   class MyAgent < Igniter::Agent
  #     include Igniter::Memory::Memorable
  #     enable_memory store: Igniter::Memory.default_store
  #   end
  #
  # == Global configuration
  #
  #   Igniter::Memory.configure do |m|
  #     m.default_store = Igniter::Memory::Stores::SQLite.new(path: "/var/app/memory.db")
  #   end
  module Memory
    # Raised when a required dependency (e.g. sqlite3 gem) is missing or when
    # Memory is misconfigured.
    ConfigurationError = Class.new(Igniter::Error)

    class << self
      # Returns the global default store, creating an InMemory store on first access.
      #
      # @return [Store]
      def default_store
        @default_store ||= Stores::InMemory.new
      end

      # Override the global default store.
      #
      # @param store [Store]
      # @return [Store]
      attr_writer :default_store

      # Yield self for block-style configuration.
      #
      # @example
      #   Igniter::Memory.configure do |m|
      #     m.default_store = Igniter::Memory::Stores::SQLite.new(path: "/tmp/mem.db")
      #   end
      def configure
        yield self
      end

      # Reset module-level state (primarily useful in tests).
      #
      # @return [void]
      def reset!
        @default_store = nil
      end
    end
  end
end
