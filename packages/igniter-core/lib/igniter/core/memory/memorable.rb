# frozen_string_literal: true

module Igniter
  module Memory
    # Mixin that adds episodic memory capabilities to Igniter::Agent and
    # Igniter::AI::Executor subclasses (or any class that includes it).
    #
    # Including +Memorable+ adds:
    # * A class-level +enable_memory+ DSL method for opt-in activation
    # * A +memory+ instance accessor returning a bound AgentMemory facade
    # * Automatic agent_id derived from the class name and object_id
    #
    # Memory is NOT enabled by default — call +enable_memory+ in the class body.
    #
    # == Example
    #
    #   class MyAgent < Igniter::Agent
    #     include Igniter::Memory::Memorable
    #
    #     enable_memory store: Igniter::Memory::Stores::InMemory.new
    #
    #     on :task do |state:, payload:, **|
    #       memory.record(type: :task, content: payload[:description])
    #       # ... handle task
    #       state
    #     end
    #   end
    #
    # == Inheritance
    #
    # Subclasses inherit +memory_enabled?+ and +memory_store+ from their parent.
    # Each subclass can override them independently.
    module Memorable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_variable_set(:@memory_store, nil)
        base.instance_variable_set(:@memory_enabled, false)
      end

      module ClassMethods
        # Enable episodic memory for this class.
        #
        # @param store [Store, nil] backing store; falls back to Igniter::Memory.default_store
        # @return [void]
        def enable_memory(store: nil)
          @memory_enabled = true
          @memory_store   = store || Igniter::Memory.default_store
        end

        # Returns the configured memory store, walking up the inheritance chain
        # if none is set on this class.
        #
        # @return [Store]
        def memory_store
          @memory_store ||
            (superclass.respond_to?(:memory_store) ? superclass.memory_store : Igniter::Memory.default_store)
        end

        # Returns whether memory has been enabled for this class or any ancestor.
        #
        # @return [Boolean]
        def memory_enabled?
          @memory_enabled ||
            (superclass.respond_to?(:memory_enabled?) && superclass.memory_enabled?)
        end
      end

      # Returns the AgentMemory facade bound to this instance.
      #
      # Lazily initialised on first access. The agent_id incorporates the class
      # name and object_id to keep instances isolated.
      #
      # @return [AgentMemory]
      def memory
        @memory ||= AgentMemory.new(
          store: self.class.memory_store,
          agent_id: memory_agent_id,
          session_id: respond_to?(:session_id, true) ? session_id : nil
        )
      end

      private

      def memory_agent_id
        cls_name = self.class.name || "anonymous"
        "#{cls_name}:#{object_id}"
      end
    end
  end
end
