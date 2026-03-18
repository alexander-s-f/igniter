# frozen_string_literal: true

module Igniter
  class Contract
    class << self
      def define(&block)
        @compiled_graph = DSL::ContractBuilder.compile(name: contract_name, &block)
      end

      def run_with(runner:, max_workers: nil)
        @execution_options = { runner: runner, max_workers: max_workers }.compact
      end

      def restore_from_store(execution_id, store: nil)
        snapshot = (store || Igniter.execution_store).fetch(execution_id)
        restore(snapshot)
      end

      def resume_from_store(execution_id, token:, value:, store: nil)
        Runtime::JobWorker.new(self, store: store || Igniter.execution_store).resume(
          execution_id: execution_id,
          token: token,
          value: value
        )
      end

      def define_schema(schema)
        @compiled_graph = DSL::SchemaBuilder.compile(schema, name: contract_name)
      end

      def restore(snapshot)
        instance = new(
          snapshot[:inputs] || snapshot["inputs"] || {},
          runner: snapshot[:runner] || snapshot["runner"],
          max_workers: snapshot[:max_workers] || snapshot["max_workers"]
        )
        instance.restore_execution(snapshot)
      end

      def react_to(event_type, path: nil, once_per_execution: false, &block)
        raise CompileError, "react_to requires a block" unless block

        reactions << Extensions::Reactive::Reaction.new(
          event_type: event_type,
          path: path,
          action: block,
          once_per_execution: once_per_execution
        )
      end

      def effect(path = nil, event_type: :node_succeeded, &block)
        react_to(event_type, path: path, &block)
      end

      def on_success(target, &block)
        graph = compiled_graph
        if graph&.output?(target)
          react_to(:execution_finished, once_per_execution: true) do |event:, contract:, execution:|
            next if execution.cache.values.any?(&:failed?)
            next if execution.cache.values.any?(&:pending?)

            block.call(
              event: event,
              contract: contract,
              execution: execution,
              value: contract.result.public_send(target)
            )
          end
        else
          effect(target.to_s, event_type: :node_succeeded, &block)
        end
      end

      def compiled_graph
        @compiled_graph || superclass_compiled_graph
      end
      alias graph compiled_graph

      def reactions
        @reactions ||= []
      end

      def execution_options
        @execution_options || superclass_execution_options || {}
      end

      private

      def contract_name
        name || "AnonymousContract"
      end

      def superclass_compiled_graph
        return unless superclass.respond_to?(:compiled_graph)

        superclass.compiled_graph
      end

      def superclass_execution_options
        return unless superclass.respond_to?(:execution_options)

        superclass.execution_options
      end
    end

    attr_reader :execution, :result

    def initialize(inputs = nil, runner: nil, max_workers: nil, **keyword_inputs)
      graph = self.class.compiled_graph
      raise CompileError, "#{self.class.name} has no compiled graph. Use `define`." unless graph

      normalized_inputs =
        if inputs.nil?
          keyword_inputs
        elsif keyword_inputs.empty?
          inputs
        else
          inputs.to_h.merge(keyword_inputs)
        end

      execution_options = self.class.execution_options.merge(
        { runner: runner, max_workers: max_workers }.compact
      )
      execution_options[:store] ||= Igniter.execution_store if execution_options[:runner]&.to_sym == :store

      @execution = Runtime::Execution.new(
        compiled_graph: graph,
        contract_instance: self,
        inputs: normalized_inputs,
        **execution_options
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

    def diagnostics
      Diagnostics::Report.new(execution)
    end

    def snapshot
      execution.snapshot
    end

    def restore_execution(snapshot)
      execution.restore!(snapshot)
      self
    end

    def diagnostics_text
      diagnostics.to_text
    end

    def diagnostics_markdown
      diagnostics.to_markdown
    end

    def explain_plan(output_names = nil)
      execution.explain_plan(output_names)
    end

    def success?
      execution.success?
    end

    def failed?
      execution.failed?
    end
  end
end
