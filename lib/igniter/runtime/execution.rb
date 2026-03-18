# frozen_string_literal: true

module Igniter
  module Runtime
    class Execution
      attr_reader :compiled_graph, :contract_instance, :inputs, :cache, :events, :audit, :runner_strategy, :max_workers

      def initialize(compiled_graph:, contract_instance:, inputs:, runner: :inline, max_workers: nil)
        @compiled_graph = compiled_graph
        @contract_instance = contract_instance
        @runner_strategy = runner
        @max_workers = max_workers
        @input_validator = InputValidator.new(compiled_graph)
        @inputs = @input_validator.normalize_initial_inputs(inputs)
        @cache = Cache.new
        @events = Events::Bus.new
        @audit = Extensions::Auditing::Timeline.new(self)
        @events.subscribe(@audit)
        @resolver = Resolver.new(self)
        @planner = Planner.new(self)
        @runner = RunnerFactory.build(@runner_strategy, self, resolver: @resolver, max_workers: @max_workers)
        @invalidator = Invalidator.new(self)
      end

      def resolve_output(name)
        output = compiled_graph.fetch_output(name)
        with_execution_lifecycle([output.source_root]) do
          run_targets([output.source_root])
          resolve_exported_output(output)
        end
      end

      def resolve(name)
        @resolver.resolve(name)
      end

      def resolve_all
        output_sources = @planner.targets_for_outputs

        with_execution_lifecycle(output_sources) do
          run_targets(output_sources)
          compiled_graph.outputs.each { |output_node| resolve_output_value(output_node) }
          self
        end
      end

      def update_inputs(new_inputs)
        symbolize_keys(new_inputs).each do |name, value|
          @input_validator.validate_update!(name, value)

          @inputs[name] = value
          input_node = compiled_graph.fetch_node(name)
          cache.write(NodeState.new(node: input_node, status: :succeeded, value: value, invalidated_by: name))
          @events.emit(:input_updated, node: input_node, status: :succeeded, payload: { value: value })
          @invalidator.invalidate_from(name)
        end

        self
      end

      def resume(node_name, value:)
        node = compiled_graph.fetch_node(node_name)
        current = cache.fetch(node.name)
        raise ResolutionError, "Node '#{node_name}' is not pending" unless current&.pending?

        cache.write(NodeState.new(node: node, status: :succeeded, value: value))
        @events.emit(:node_resumed, node: node, status: :succeeded, payload: { resumed: true })
        @invalidator.invalidate_from(node.name)
        self
      end

      def success?
        resolve_all
        !failed? && !pending?
      end

      def failed?
        resolve_all
        cache.values.any?(&:failed?)
      end

      def pending?
        resolve_all
        cache.values.any?(&:pending?)
      end

      def states
        Extensions::Introspection::RuntimeFormatter.states(self)
      end

      def explain_output(name)
        Extensions::Introspection::RuntimeFormatter.explain_output(self, name)
      end

      def diagnostics
        Diagnostics::Report.new(self)
      end

      def plan(output_names = nil)
        @planner.plan(output_names)
      end

      def to_h
        {
          graph: compiled_graph.name,
          execution_id: events.execution_id,
          inputs: inputs.dup,
          runner: runner_strategy,
          max_workers: max_workers,
          success: success?,
          failed: cache.values.any?(&:failed?),
          pending: cache.values.any?(&:pending?),
          plan: plan,
          states: states,
          event_count: events.events.size
        }
      end

      def as_json(*)
        to_h.merge(
          events: events.events.map(&:as_json)
        )
      end

      private

      def with_execution_lifecycle(node_names)
        if resolution_required_for_any?(node_names)
          @events.emit(:execution_started, payload: { graph: compiled_graph.name, targets: node_names.map(&:to_sym) })
          begin
            result = yield
            @events.emit(:execution_finished, payload: { graph: compiled_graph.name, targets: node_names.map(&:to_sym) })
            result
          rescue StandardError => e
            @events.emit(
              :execution_failed,
              status: :failed,
              payload: {
                graph: compiled_graph.name,
                targets: node_names.map(&:to_sym),
                error: e.message
              }
            )
            raise
          end
        else
          yield
        end
      end

      def resolution_required_for_any?(node_names)
        node_names.any? do |node_name|
          state = cache.fetch(node_name)
          state.nil? || state.stale?
        end
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) { |(key, value), memo| memo[key.to_sym] = value }
      end

      public

      def fetch_input!(name)
        @input_validator.fetch_value!(name, @inputs)
      end

      private

      def resolve_exported_output(output)
        state = @resolver.resolve(output.source_root)
        raise state.error if state.failed?
        return state.value if state.pending?

        return state.value unless output.composition_output?

        state.value.public_send(output.child_output_name)
      end

      def run_targets(node_names)
        @runner.run(node_names)
      end

      alias_method :resolve_output_value, :resolve_exported_output
    end
  end
end
