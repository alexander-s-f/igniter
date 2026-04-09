# frozen_string_literal: true

module Igniter
  class Agent
    # Mutex-guarded wrapper around an agent's current state hash.
    # The state is always stored as a frozen Hash so callers can read it
    # without holding the lock.
    class StateHolder
      def initialize(initial_state)
        @state = initial_state.freeze
        @mutex = Mutex.new
      end

      def get
        @mutex.synchronize { @state }
      end

      def set(new_state)
        @mutex.synchronize { @state = new_state.freeze }
      end
    end
  end
end
