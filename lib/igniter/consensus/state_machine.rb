# frozen_string_literal: true

module Igniter
  module Consensus
    # Base class for user-defined consensus state machines.
    #
    # Subclass and declare command handlers with +apply+. Each handler receives
    # the current state (Hash) and a command Hash and must return the NEW state —
    # without mutating the original.
    #
    #   class PriceStore < Igniter::Consensus::StateMachine
    #     apply :set    do |state, cmd| state.merge(cmd[:key] => cmd[:value]) end
    #     apply :delete do |state, cmd| state.reject { |k, _| k == cmd[:key] } end
    #   end
    #
    # Passing no subclass to Cluster uses the default KV protocol:
    # +{ key:, value: }+ sets a key; +{ key:, op: :delete }+ removes it.
    class StateMachine
      class << self
        # Declare a reducer for a named command type.
        # The block receives +(state, command)+ and must return the new state Hash.
        def apply(type, &block)
          reducers[type.to_sym] = block
        end

        # @api private
        def reducers
          @reducers ||= {}
        end

        # Apply +command+ to +state+ and return the resulting state.
        # Dispatches to the registered reducer for +command[:type]+, or falls back
        # to the built-in KV protocol when no reducer is found.
        #
        # @param state   [Hash] current state machine snapshot
        # @param command [Hash, nil] command to apply
        # @return [Hash] new state
        def call(state, command)
          return state unless command

          type = command[:type]&.to_sym
          if type && (reducer = reducers[type])
            reducer.call(state, command)
          else
            # Default KV protocol: { key:, value: } → set; { key:, op: :delete } → remove
            return state unless command.key?(:key)

            if command[:op] == :delete
              state.reject { |k, _| k == command[:key] }
            else
              state.merge(command[:key] => command[:value])
            end
          end
        end
      end
    end
  end
end
