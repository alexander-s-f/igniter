# frozen_string_literal: true

module Igniter
  class Contract
    class << self
      def correlate_by(*keys)
        @correlation_keys = keys.map(&:to_sym).freeze
      end

      def correlation_keys
        @correlation_keys || []
      end

      def define(&block)
        @compiled_graph = DSL::ContractBuilder.compile(
          name: contract_name,
          correlation_keys: correlation_keys,
          &block
        )
      end

      def run_with(runner:, max_workers: nil, **opts)
        @execution_options = { runner: runner, max_workers: max_workers }.merge(opts).compact
      end

      # Ergonomic alias for run_with. Accepts pool_size: as a clearer name for
      # max_workers: when using the thread_pool runner.
      #
      #   class MyContract < Igniter::Contract
      #     runner :thread_pool, pool_size: 4
      #     define do ... end
      #   end
      def runner(strategy, pool_size: nil, max_workers: nil, **opts)
        workers = pool_size || max_workers
        @execution_options = { runner: strategy, max_workers: workers }.merge(opts).compact
      end

      def restore_from_store(execution_id, store: nil)
        resolved_store = store || Igniter.execution_store
        snapshot = resolved_store.fetch(execution_id)
        restore(snapshot, store: resolved_store)
      end

      def resume_from_store(execution_id, token:, value:, store: nil)
        Runtime::JobWorker.new(self, store: store || Igniter.execution_store).resume(
          execution_id: execution_id,
          token: token,
          value: value
        )
      end

      def resume_agent_session_from_store(execution_id, session:, node_name: nil, value: Runtime::Execution::UNDEFINED_RESUME_VALUE, store: nil)
        Runtime::JobWorker.new(self, store: store || Igniter.execution_store).resume_agent_session(
          execution_id: execution_id,
          session: session,
          node_name: node_name,
          value: value
        )
      end

      def continue_agent_session_from_store(execution_id, session:, payload:, trace: nil, token: nil, waiting_on: nil,
                                            request: nil, reply: nil, phase: nil, store: nil)
        Runtime::JobWorker.new(self, store: store || Igniter.execution_store).continue_agent_session(
          execution_id: execution_id,
          session: session,
          payload: payload,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )
      end

      def define_schema(schema)
        @compiled_graph = DSL::SchemaBuilder.compile(schema, name: contract_name)
      end

      def start(inputs = {}, store: nil, **keyword_inputs)
        resolved_store = store || Igniter.execution_store
        all_inputs = inputs.merge(keyword_inputs)

        instance = new(all_inputs, runner: :store, store: resolved_store)
        instance.resolve_all

        correlation = correlation_keys.each_with_object({}) do |key, hash|
          hash[key] = all_inputs[key] || all_inputs[key.to_s]
        end

        resolved_store.save(instance.snapshot, correlation: correlation.compact, graph: contract_name)
        instance
      end

      def deliver_event(event_name, correlation:, payload:, store: nil) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        resolved_store = store || Igniter.execution_store
        execution_id = resolved_store.find_by_correlation(
          graph: contract_name,
          correlation: correlation.transform_keys(&:to_sym)
        )
        unless execution_id
          raise ResolutionError,
                "No pending execution found for #{contract_name} with given correlation"
        end

        instance = restore_from_store(execution_id, store: resolved_store)

        await_node = instance.execution.compiled_graph.await_nodes
                             .find { |n| n.event_name == event_name.to_sym }
        raise ResolutionError, "No await node found for event '#{event_name}' in #{contract_name}" unless await_node

        instance.execution.resume(await_node.name, value: payload)
        instance.resolve_all

        resolved_store.save(instance.snapshot, correlation: correlation.transform_keys(&:to_sym), graph: contract_name)
        instance
      end

      def restore(snapshot, store: nil)
        instance = new(
          snapshot[:inputs] || snapshot["inputs"] || {},
          runner: snapshot[:runner] || snapshot["runner"],
          max_workers: snapshot[:max_workers] || snapshot["max_workers"],
          store: store
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

      def on_failure(&block)
        react_to(:execution_failed, once_per_execution: true) do |event:, contract:, execution:|
          block.call(
            event: event,
            contract: contract,
            execution: execution,
            status: :failed,
            errors: terminal_errors(execution),
            error: terminal_errors(execution).values.first
          )
        end
      end

      def on_exit(&block)
        terminal_hook = proc do |event:, contract:, execution:|
          status = event.type == :execution_failed ? :failed : :succeeded
          errors = status == :failed ? terminal_errors(execution) : {}

          block.call(
            event: event,
            contract: contract,
            execution: execution,
            status: status,
            errors: errors,
            error: errors.values.first
          )
        end

        react_to(:execution_finished, once_per_execution: true, &terminal_hook)
        react_to(:execution_failed, once_per_execution: true, &terminal_hook)
      end

      def present(output_name, with: nil, &block)
        raise CompileError, "present requires a block or `with:`" unless block || with
        raise CompileError, "present cannot use both a block and `with:`" if block && with

        own_output_presenters[output_name.to_sym] = with || block
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

      def output_presenters
        inherited = superclass.respond_to?(:output_presenters) ? superclass.output_presenters : {}
        inherited.merge(own_output_presenters)
      end

      private

      def own_output_presenters
        @output_presenters ||= {}
      end

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

      def terminal_errors(execution)
        execution.cache.values.each_with_object({}) do |state, memo|
          next unless state.failed?

          memo[state.node.name] = state.error
        end
      end
    end

    attr_reader :execution, :result, :reactive

    def initialize(inputs = nil, runner: nil, max_workers: nil, store: nil, **keyword_inputs)
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
        { runner: runner, max_workers: max_workers, store: store }.compact
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

    def orchestration_plan(output_names = nil)
      execution.orchestration_plan(output_names)
    end

    def success?
      execution.success?
    end

    def failed?
      execution.failed?
    end

    def pending?
      execution.pending?
    end
  end
end
