# frozen_string_literal: true

module Igniter
  module Runtime
    class Execution
      attr_reader :compiled_graph, :contract_instance, :inputs, :cache, :events, :audit

      def initialize(compiled_graph:, contract_instance:, inputs:)
        @compiled_graph = compiled_graph
        @contract_instance = contract_instance
        @input_validator = InputValidator.new(compiled_graph)
        @inputs = @input_validator.normalize_initial_inputs(inputs)
        @cache = Cache.new
        @events = Events::Bus.new
        @audit = Extensions::Auditing::Timeline.new(self)
        @events.subscribe(@audit)
        @resolver = Resolver.new(self)
        @invalidator = Invalidator.new(self)
      end

      def resolve_output(name)
        output = compiled_graph.fetch_output(name)
        with_execution_lifecycle([output.source_root]) do
          resolve_exported_output(output)
        end
      end

      def resolve(name)
        @resolver.resolve(name)
      end

      def resolve_all
        output_sources = compiled_graph.outputs.map(&:source_root)

        with_execution_lifecycle(output_sources) do
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

      def success?
        resolve_all
        !cache.values.any?(&:failed?)
      end

      def failed?
        resolve_all
        cache.values.any?(&:failed?)
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

      def to_h
        {
          graph: compiled_graph.name,
          execution_id: events.execution_id,
          inputs: inputs.dup,
          success: !cache.values.any?(&:failed?),
          failed: cache.values.any?(&:failed?),
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

        return state.value unless output.composition_output?

        state.value.public_send(output.child_output_name)
      end

      alias_method :resolve_output_value, :resolve_exported_output
    end
  end
end
