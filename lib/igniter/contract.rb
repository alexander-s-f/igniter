# frozen_string_literal: true

module Igniter
  class Contract
    class << self
      def define(&block)
        @compiled_graph = DSL::ContractBuilder.compile(name: contract_name, &block)
      end

      def react_to(event_type, path: nil, &block)
        raise CompileError, "react_to requires a block" unless block

        reactions << Extensions::Reactive::Reaction.new(
          event_type: event_type,
          path: path,
          action: block
        )
      end

      def compiled_graph
        @compiled_graph || superclass_compiled_graph
      end
      alias graph compiled_graph

      def reactions
        @reactions ||= []
      end

      private

      def contract_name
        name || "AnonymousContract"
      end

      def superclass_compiled_graph
        return unless superclass.respond_to?(:compiled_graph)

        superclass.compiled_graph
      end
    end

    attr_reader :execution, :result

    def initialize(inputs = {})
      graph = self.class.compiled_graph
      raise CompileError, "#{self.class.name} has no compiled graph. Use `define`." unless graph

      @execution = Runtime::Execution.new(
        compiled_graph: graph,
        contract_instance: self,
        inputs: inputs
      )
      @reactive = Extensions::Reactive::Engine.new(
        execution: @execution,
        contract: self,
        reactions: self.class.reactions
      )
      @execution.events.subscribe(@reactive)
      @result = Runtime::Result.new(@execution)
    end

    def resolve
      execution.resolve_all
      self
    end

    def resolve_all
      resolve
    end

    def update_inputs(inputs)
      execution.update_inputs(inputs)
      self
    end

    def events
      execution.events.events
    end

    def audit
      execution.audit
    end

    def audit_snapshot
      execution.audit.snapshot
    end

    def reactive
      @reactive
    end

    def subscribe(subscriber = nil, &block)
      execution.events.subscribe(subscriber, &block)
      self
    end

    def success?
      execution.success?
    end

    def failed?
      execution.failed?
    end
  end
end
