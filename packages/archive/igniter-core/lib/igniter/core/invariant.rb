# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/invariant")
module Igniter
  # Represents a named condition that must always hold for a contract's outputs.
  #
  # An Invariant wraps a block that receives the contract's declared output values
  # as keyword arguments and returns a truthy value when the condition holds.
  #
  # @example
  #   inv = Igniter::Invariant.new(:total_non_negative) { |total:, **| total >= 0 }
  #   inv.check(total: 42)    # => nil  (passed)
  #   inv.check(total: -1)    # => InvariantViolation
  class Invariant
    attr_reader :name, :block

    def initialize(name, &block)
      raise ArgumentError, "invariant :#{name} requires a block" unless block

      @name  = name.to_sym
      @block = block
      freeze
    end

    # Evaluate invariant against the resolved output values.
    #
    # @param resolved_values [Hash] output_name => value for all declared outputs
    # @return [InvariantViolation, nil] nil when the invariant holds
    def check(resolved_values)
      passed = block.call(**resolved_values)
      passed ? nil : InvariantViolation.new(name: name, passed: false)
    rescue StandardError => e
      InvariantViolation.new(name: name, passed: false, error: e)
    end
  end

  # Records a single invariant check outcome.
  class InvariantViolation
    attr_reader :name, :error

    def initialize(name:, passed:, error: nil)
      @name   = name.to_sym
      @passed = passed
      @error  = error
      freeze
    end

    def passed? = @passed
    def failed? = !@passed
  end
end
