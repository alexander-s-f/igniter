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
      end

      def resolve_output(name)
        output = compiled_graph.fetch_output(name)
        state = @resolver.resolve(output.source)
        raise state.error if state.failed?

        state.value
      end

      def resolve(name)
        @resolver.resolve(name)
      end

      def resolve_all
        @events.emit(:execution_started, payload: { graph: compiled_graph.name })
        compiled_graph.outputs.each { |output_node| resolve(output_node.source) }
        @events.emit(:execution_finished, payload: { graph: compiled_graph.name })
        self
      end

      def update_inputs(new_inputs)
        symbolize_keys(new_inputs).each do |name, value|
          @input_validator.validate_update!(name, value)

          @inputs[name] = value
          input_node = compiled_graph.fetch_node(name)
          cache.write(NodeState.new(node: input_node, status: :succeeded, value: value, invalidated_by: name))
          @events.emit(:input_updated, node: input_node, status: :succeeded, payload: { value: value })
          invalidate_dependents(name)
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

      private

      def invalidate_dependents(node_name)
        queue = compiled_graph.dependents.fetch(node_name.to_sym, []).dup
        seen = {}

        until queue.empty?
          dependent_name = queue.shift
          next if seen[dependent_name]

          seen[dependent_name] = true
          dependent_node = compiled_graph.fetch_node(dependent_name)
          cache.stale!(dependent_node, invalidated_by: node_name.to_sym)
          events.emit(:node_invalidated, node: dependent_node, status: :stale, payload: { cause: node_name.to_sym })
          emit_output_invalidations_for(dependent_node.name, node_name)
          queue.concat(compiled_graph.dependents.fetch(dependent_name, []))
        end
      end

      def emit_output_invalidations_for(source_name, cause_name)
        compiled_graph.outputs.each do |output_node|
          next unless output_node.source == source_name.to_sym

          events.emit(:node_invalidated, node: output_node, status: :stale, payload: { cause: cause_name.to_sym })
        end
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) { |(key, value), memo| memo[key.to_sym] = value }
      end

      public

      def fetch_input!(name)
        @input_validator.fetch_value!(name, @inputs)
      end
    end
  end
end
