# frozen_string_literal: true

module Igniter
  module Runtime
    class Resolver
      def initialize(execution)
        @execution = execution
      end

      def resolve(node_name)
        node = @execution.compiled_graph.fetch_node(node_name)
        cached = @execution.cache.fetch(node.name)
        return cached if cached && !cached.stale?

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
        @execution.events.emit(state.failed? ? :node_failed : :node_succeeded, node: node, status: state.status)
        state
      rescue StandardError => e
        state = NodeState.new(node: node, status: :failed, error: normalize_error(e))
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
          dependency_state = resolve(dependency_name)
          raise dependency_state.error if dependency_state.failed?

          memo[dependency_name] = dependency_state.value
        end

        value = call_compute(node.callable, dependencies)
        NodeState.new(node: node, status: :succeeded, value: value)
      end

      def call_compute(callable, dependencies)
        case callable
        when Proc
          callable.call(**dependencies)
        when Symbol, String
          @execution.contract_instance.public_send(callable.to_sym, **dependencies)
        else
          raise ResolutionError, "Unsupported callable: #{callable.class}"
        end
      end

      def resolve_composition(node)
        child_inputs = node.input_mapping.each_with_object({}) do |(child_input_name, dependency_name), memo|
          dependency_state = resolve(dependency_name)
          raise dependency_state.error if dependency_state.failed?

          memo[child_input_name] = dependency_state.value
        end

        child_contract = node.contract_class.new(child_inputs)
        NodeState.new(node: node, status: :succeeded, value: child_contract.result)
      end

      def normalize_error(error)
        return error if error.is_a?(Igniter::Error)

        ResolutionError.new(error.message)
      end
    end
  end
end
