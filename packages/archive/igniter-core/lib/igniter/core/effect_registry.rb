# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/effect_registry")
module Igniter
  # Registry for named effect adapters.
  #
  # Allows registering effects by symbolic keys and resolving them in the DSL:
  #
  #   Igniter.register_effect(:users_db, UserRepository)
  #
  #   # In a contract:
  #   effect :user_data, uses: :users_db, depends_on: :user_id
  #
  # This decouples contracts from concrete adapter classes and enables
  # environment-specific swaps (e.g. mock adapters in tests):
  #
  #   # In spec_helper.rb:
  #   Igniter.effect_registry.clear
  #   Igniter.register_effect(:users_db, FakeUserRepository)
  class EffectRegistry
    Registration = Struct.new(:key, :adapter_class, :metadata, keyword_init: true)

    def initialize
      @entries = {}
    end

    # Register an effect adapter under a symbolic key.
    #
    # @param key           [Symbol, String]
    # @param adapter_class [Class] must be a subclass of Igniter::Effect
    # @param metadata      [Hash]  optional arbitrary metadata
    # @return [self]
    def register(key, adapter_class, **metadata)
      key = key.to_sym
      unless adapter_class.is_a?(Class) && adapter_class <= Igniter::Effect
        raise ArgumentError, "#{adapter_class.inspect} must be a subclass of Igniter::Effect"
      end

      @entries[key] = Registration.new(key: key, adapter_class: adapter_class, metadata: metadata.freeze)
      self
    end

    # Fetch a registration by key.
    #
    # @param key [Symbol, String]
    # @return [Registration]
    # @raise [KeyError] if not registered
    def fetch(key)
      @entries.fetch(key.to_sym) do
        raise KeyError,
              "Effect '#{key}' is not registered. " \
              "Use Igniter.register_effect(:#{key}, AdapterClass) before compiling."
      end
    end

    # @param key [Symbol, String]
    # @return [Boolean]
    def registered?(key)
      @entries.key?(key.to_sym)
    end

    # @return [Array<Registration>]
    def all
      @entries.values.freeze
    end

    # @return [Integer]
    def size
      @entries.size
    end

    # Remove all registrations. Useful in tests.
    # @return [self]
    def clear
      @entries.clear
      self
    end
  end
end
