# frozen_string_literal: true

module Igniter
  module Runtime
    class Resolver
      def initialize(execution)
        @execution = execution
      end

      def resolve(node_name)
        node = @execution.compiled_graph.fetch_node(node_name)
        resolution_status, cached = @execution.cache.begin_resolution(node)
        return cached if resolution_status == :cached

        @execution.events.emit(:node_started, node: node, status: :running)

        state = case node.kind
                when :input
                  resolve_input(node)
                when :compute
                  resolve_compute(node)
                when :composition
                  resolve_composition(node)
                else
                  raise ResolutionError, "Unsupported node kind: #{node.kind}"
                end

        @execution.cache.write(state)
        @execution.events.emit(
          state.failed? ? :node_failed : :node_succeeded,
          node: node,
          status: state.status,
          payload: success_payload(node, state)
        )
        state
      rescue StandardError => e
        state = NodeState.new(node: node, status: :failed, error: normalize_error(e, node))
        @execution.cache.write(state)
        @execution.events.emit(:node_failed, node: node, status: :failed, payload: { error: state.error.message })
        state
      end

      private

      def resolve_input(node)
        NodeState.new(node: node, status: :succeeded, value: @execution.fetch_input!(node.name))
      end

      def resolve_compute(node)
        dependencies = node.dependencies.each_with_object({}) do |dependency_name, memo|
          memo[dependency_name] = resolve_dependency_value(dependency_name)
        end

        value = call_compute(node.callable, dependencies)
        NodeState.new(node: node, status: :succeeded, value: value)
      end

      def call_compute(callable, dependencies)
        case callable
        when Proc
          callable.call(**dependencies)
        when Class
          call_compute_class(callable, dependencies)
        when Symbol, String
          @execution.contract_instance.public_send(callable.to_sym, **dependencies)
        else
          call_compute_object(callable, dependencies)
        end
      end

      def call_compute_class(callable, dependencies)
        if callable <= Igniter::Executor
          callable.new(execution: @execution, contract: @execution.contract_instance).call(**dependencies)
        elsif callable.respond_to?(:call)
          callable.call(**dependencies)
        else
          raise ResolutionError, "Unsupported callable: #{callable}"
        end
      end

      def call_compute_object(callable, dependencies)
        if callable.respond_to?(:call)
          callable.call(**dependencies)
        else
          raise ResolutionError, "Unsupported callable: #{callable.class}"
        end
      end

      def resolve_composition(node)
        child_inputs = node.input_mapping.each_with_object({}) do |(child_input_name, dependency_name), memo|
          memo[child_input_name] = resolve_dependency_value(dependency_name)
        end

        child_contract = node.contract_class.new(child_inputs)
        child_contract.resolve_all
        child_error = child_contract.result.errors.values.first
        raise child_error if child_error

        NodeState.new(node: node, status: :succeeded, value: child_contract.result)
      end

      def resolve_dependency_value(dependency_name)
        if @execution.compiled_graph.node?(dependency_name)
          dependency_state = resolve(dependency_name)
          raise dependency_state.error if dependency_state.failed?

          dependency_state.value
        elsif @execution.compiled_graph.outputs_by_name.key?(dependency_name.to_sym)
          output = @execution.compiled_graph.fetch_output(dependency_name)
          @execution.send(:resolve_exported_output, output)
        else
          raise ResolutionError, "Unknown dependency: #{dependency_name}"
        end
      end

      def success_payload(node, state)
        return {} unless node.kind == :composition
        return {} unless state.value.is_a?(Igniter::Runtime::Result)

        {
          child_execution_id: state.value.execution.events.execution_id,
          child_graph: state.value.execution.compiled_graph.name
        }
      end

      def normalize_error(error, node)
        return error if error.is_a?(Igniter::Error)

        ResolutionError.new(
          error.message,
          context: {
            graph: @execution.compiled_graph.name,
            node_id: node.id,
            node_name: node.name,
            node_path: node.path,
            source_location: node.source_location
          }
        )
      end
    end
  end
end
