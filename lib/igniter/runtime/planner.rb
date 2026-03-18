# frozen_string_literal: true

module Igniter
  module Runtime
    class Planner
      def initialize(execution)
        @execution = execution
      end

      def targets_for_outputs(output_names = nil)
        selected_outputs = if output_names
          Array(output_names).map { |name| @execution.compiled_graph.fetch_output(name) }
        else
          @execution.compiled_graph.outputs
        end

        selected_outputs
          .map(&:source_root)
          .uniq
      end

      def plan(output_names = nil)
        targets = targets_for_outputs(output_names)
        nodes = relevant_nodes_for(targets)

        node_entries = nodes.each_with_object({}) do |node, memo|
          memo[node.name] = plan_entry(node)
        end

        {
          targets: targets,
          ready: node_entries.values.select { |entry| entry[:ready] }.map { |entry| entry[:name] },
          blocked: node_entries.values.select { |entry| entry[:blocked] }.map { |entry| entry[:name] },
          nodes: node_entries
        }
      end

      private

      def relevant_nodes_for(targets)
        seen = {}
        ordered = []

        targets.each do |target_name|
          visit(@execution.compiled_graph.fetch_node(target_name), seen, ordered)
        end

        ordered
      end

      def visit(node, seen, ordered)
        return if seen[node.name]

        seen[node.name] = true
        node.dependencies.each do |dependency_name|
          dependency = dependency_node_for(dependency_name)
          visit(dependency, seen, ordered)
        end
        ordered << node
      end

      def dependency_node_for(dependency_name)
        dependency = @execution.compiled_graph.fetch_dependency(dependency_name)
        return dependency if dependency.kind != :output

        @execution.compiled_graph.fetch_node(dependency.source_root)
      end

      def plan_entry(node)
        state = @execution.cache.fetch(node.name)
        dependency_entries = node.dependencies.map { |dependency_name| dependency_entry(dependency_name) }
        blocked_dependencies = dependency_entries.reject { |entry| entry[:satisfied] }.map { |entry| entry[:name] }
        ready = resolution_required?(state) && blocked_dependencies.empty?

        {
          id: node.id,
          name: node.name,
          path: node.path,
          kind: node.kind,
          status: state&.status || :pending,
          ready: ready,
          blocked: !ready && resolution_required?(state),
          dependencies: dependency_entries,
          waiting_on: blocked_dependencies
        }
      end

      def dependency_entry(dependency_name)
        dependency = @execution.compiled_graph.fetch_dependency(dependency_name)
        source_node = dependency.kind == :output ? @execution.compiled_graph.fetch_node(dependency.source_root) : dependency
        state = @execution.cache.fetch(source_node.name)

        {
          name: dependency_name.to_sym,
          source: source_node.name,
          kind: dependency.kind,
          status: state&.status || inferred_status(source_node),
          satisfied: dependency_satisfied?(source_node, state)
        }
      end

      def dependency_satisfied?(node, state)
        case node.kind
        when :input
          input_available?(node)
        else
          state&.succeeded?
        end
      end

      def inferred_status(node)
        return :ready if node.kind == :input && input_available?(node)

        :pending
      end

      def input_available?(node)
        @execution.inputs.key?(node.name) || node.default?
      end

      def resolution_required?(state)
        state.nil? || state.stale? || state.pending? || state.running?
      end
    end
  end
end
