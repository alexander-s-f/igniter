# frozen_string_literal: true

require "igniter/core/errors"

module Igniter
  # Thread-safe process registry mapping names to agent Refs.
  #
  # Names can be any object that is a valid Hash key (Symbols recommended).
  #
  #   Igniter::Registry.register(:counter, ref)
  #   Igniter::Registry.find(:counter)    # => ref
  #   Igniter::Registry.unregister(:counter)
  #
  module Registry
    class RegistryError < Igniter::Error; end

    @store = {}
    @mutex = Mutex.new

    class << self
      # Register +ref+ under +name+. Raises RegistryError if the name is taken.
      def register(name, ref)
        @mutex.synchronize do
          raise RegistryError, "Name '#{name}' is already registered" if @store.key?(name)

          @store[name] = ref
        end
        ref
      end

      # Register (or replace) +ref+ under +name+ without uniqueness check.
      def register!(name, ref)
        @mutex.synchronize { @store[name] = ref }
        ref
      end

      # Return the Ref registered under +name+, or nil if not found.
      def find(name)
        @mutex.synchronize { @store[name] }
      end

      # Return the Ref or raise RegistryError if not found.
      def fetch(name)
        @mutex.synchronize do
          @store.fetch(name) { raise RegistryError, "No agent registered as '#{name}'" }
        end
      end

      # Remove and return the Ref registered under +name+.
      def unregister(name)
        @mutex.synchronize { @store.delete(name) }
      end

      def registered?(name)
        @mutex.synchronize { @store.key?(name) }
      end

      # Snapshot of the current name→Ref map.
      def all
        @mutex.synchronize { @store.dup }
      end

      # Remove all registrations (useful in tests).
      def clear
        @mutex.synchronize { @store.clear }
      end
    end
  end
end
