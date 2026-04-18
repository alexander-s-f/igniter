# frozen_string_literal: true

require_relative "errors"
require_relative "runtime/deferred_result"
require_relative "executor"

module Igniter
  # Base class for side-effect adapters.
  #
  # An Effect is a first-class node in the computation graph that encapsulates
  # an external interaction — database, HTTP call, cache write, queue publish, etc.
  #
  # Effects are declared in contracts via the `effect` DSL keyword:
  #
  #   class UserRepository < Igniter::Effect
  #     effect_type :database
  #     idempotent  false
  #
  #     def call(user_id:)
  #       { id: user_id, name: DB.find(user_id) }
  #     end
  #
  #     compensate do |inputs:, value:|
  #       DB.delete(value[:id])
  #     end
  #   end
  #
  #   class MyContract < Igniter::Contract
  #     define do
  #       input  :user_id
  #       effect :user_data, uses: UserRepository, depends_on: :user_id
  #       output :user_data
  #     end
  #   end
  #
  # Effects participate fully in the graph:
  #   - Dependency resolution and topological ordering
  #   - Execution reports (shown as `effect:database`)
  #   - Saga compensations (built-in or contract-level)
  #   - Provenance tracing
  class Effect < Executor
    class << self
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@effect_type, @effect_type)
        subclass.instance_variable_set(:@idempotent, @idempotent || false)
        subclass.instance_variable_set(:@_built_in_compensation, @_built_in_compensation)
      end

      # Declares the category of side effect (e.g., :database, :http, :cache).
      # Shown in execution reports as `effect:<type>`.
      #
      # @param value [Symbol, nil] — omit to read current value
      # @return [Symbol]
      def effect_type(value = nil)
        return @effect_type || :generic if value.nil?

        @effect_type = value.to_sym
      end

      # Marks this effect as idempotent — safe to retry without side effects.
      # Informational metadata; does not change execution behaviour.
      #
      # @param value [Boolean]
      def idempotent(value = true) # rubocop:disable Style/OptionalBooleanParameter
        @idempotent = value
      end

      # @return [Boolean]
      def idempotent?
        @idempotent || false
      end

      # Declares a built-in compensating action for this effect.
      #
      # Called automatically during a Saga rollback when this effect succeeded
      # but a downstream node failed. A contract-level `compensate :node_name`
      # block takes precedence over the built-in one.
      #
      # The block receives:
      #   inputs: — Hash of the node's dependency values when it ran
      #   value:  — the value produced by this effect (now being undone)
      def compensate(&block)
        raise ArgumentError, "Effect.compensate requires a block" unless block

        @_built_in_compensation = block
      end

      # @return [Proc, nil]
      def built_in_compensation
        @_built_in_compensation
      end
    end
  end
end
