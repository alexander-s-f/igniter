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
                when :branch
                  resolve_branch(node)
                when :collection
                  resolve_collection(node)
                else
                  raise ResolutionError, "Unsupported node kind: #{node.kind}"
                end

        @execution.cache.write(state)
        emit_resolution_event(node, state)
        state
      rescue PendingDependencyError => e
        state = NodeState.new(
          node: node,
          status: :pending,
          value: Runtime::DeferredResult.build(
            token: e.deferred_result.token,
            payload: e.deferred_result.payload,
            source_node: e.deferred_result.source_node,
            waiting_on: e.deferred_result.waiting_on || node.name
          )
        )
        @execution.cache.write(state)
        @execution.events.emit(:node_pending, node: node, status: :pending, payload: pending_payload(state))
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
        return NodeState.new(node: node, status: :pending, value: normalize_deferred_result(value, node)) if deferred_result?(value)
        value = normalize_guard_value(node, value)

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

      def resolve_branch(node)
        selector_value = resolve_dependency_value(node.selector_dependency)
        selected_case = node.cases.find { |entry| entry[:match] == selector_value }
        selected_contract = selected_case ? selected_case[:contract] : node.default_contract
        matched_case = selected_case ? selected_case[:match] : :default

        raise BranchSelectionError, "Branch '#{node.name}' has no matching case and no default" unless selected_contract

        child_inputs = node.input_mapping.each_with_object({}) do |(child_input_name, dependency_name), memo|
          memo[child_input_name] = resolve_dependency_value(dependency_name)
        end

        @execution.events.emit(
          :branch_selected,
          node: node,
          status: :succeeded,
          payload: {
            selector: node.selector_dependency,
            selector_value: selector_value,
            matched_case: matched_case,
            selected_contract: selected_contract.name || "AnonymousContract"
          }
        )

        child_contract = selected_contract.new(child_inputs)
        child_contract.resolve_all
        child_error = child_contract.result.errors.values.first
        raise child_error if child_error

        NodeState.new(node: node, status: :succeeded, value: child_contract.result)
      end

      def resolve_collection(node)
        items = resolve_dependency_value(node.source_dependency)
        normalized_items = normalize_collection_items(node, items)
        collection_items = {}

        normalized_items.each do |item_inputs|
          item_key = extract_collection_key(node, item_inputs)
          child_contract = node.contract_class.new(item_inputs)
          begin
            child_contract.resolve_all
          rescue Igniter::Error
            nil
          end
          child_error = child_contract.execution.cache.values.find(&:failed?)&.error

          if child_error
            collection_items[item_key] = Runtime::CollectionResult::Item.new(
              key: item_key,
              status: :failed,
              error: child_error
            )
            raise child_error if node.mode == :fail_fast
          else
            collection_items[item_key] = Runtime::CollectionResult::Item.new(
              key: item_key,
              status: :succeeded,
              result: child_contract.result
            )
          end
        end

        NodeState.new(
          node: node,
          status: :succeeded,
          value: Runtime::CollectionResult.new(items: collection_items, mode: node.mode)
        )
      end

      def resolve_dependency_value(dependency_name)
        if @execution.compiled_graph.node?(dependency_name)
          dependency_state = resolve(dependency_name)
          raise dependency_state.error if dependency_state.failed?
          raise PendingDependencyError.new(dependency_state.value, context: pending_context(dependency_state.node)) if dependency_state.pending?

          dependency_state.value
        elsif @execution.compiled_graph.outputs_by_name.key?(dependency_name.to_sym)
          output = @execution.compiled_graph.fetch_output(dependency_name)
          value = @execution.send(:resolve_exported_output, output)
          raise PendingDependencyError.new(value) if deferred_result?(value)

          value
        else
          raise ResolutionError, "Unknown dependency: #{dependency_name}"
        end
      end

      def deferred_result?(value)
        value.is_a?(Runtime::DeferredResult)
      end

      def normalize_deferred_result(value, node)
        Runtime::DeferredResult.build(
          token: value.token,
          payload: value.payload,
          source_node: value.source_node || node.name,
          waiting_on: value.waiting_on
        )
      end

      def emit_resolution_event(node, state)
        event_type =
          if state.failed?
            :node_failed
          elsif state.pending?
            :node_pending
          else
            :node_succeeded
          end

        payload = state.pending? ? pending_payload(state) : success_payload(node, state)
        @execution.events.emit(event_type, node: node, status: state.status, payload: payload)
      end

      def pending_payload(state)
        return {} unless state.value.is_a?(Runtime::DeferredResult)

        state.value.to_h
      end

      def pending_context(node)
        {
          graph: @execution.compiled_graph.name,
          node_id: node.id,
          node_name: node.name,
          node_path: node.path,
          source_location: node.source_location
        }
      end

      def success_payload(node, state)
        return {} unless %i[composition branch].include?(node.kind)
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

      def normalize_guard_value(node, value)
        return value unless node.respond_to?(:guard?) && node.guard?
        return true if value

        raise ResolutionError.new(
          node.metadata[:guard_message] || "Guard '#{node.name}' failed",
          context: {
            graph: @execution.compiled_graph.name,
            node_id: node.id,
            node_name: node.name,
            node_path: node.path,
            source_location: node.source_location
          }
        )
      end

      def normalize_collection_items(node, items)
        unless items.is_a?(Array)
          raise CollectionInputError.new(
            "Collection '#{node.name}' expects an array, got #{items.class}",
            context: collection_context(node)
          )
        end

        items.each do |item|
          next if item.is_a?(Hash)

          raise CollectionInputError.new(
            "Collection '#{node.name}' expects item hashes, got #{item.class}",
            context: collection_context(node)
          )
        end

        ensure_unique_collection_keys!(node, items)
        items.map { |item| item.transform_keys(&:to_sym) }
      end

      def extract_collection_key(node, item_inputs)
        item_inputs.fetch(node.key_name)
      rescue KeyError
        raise CollectionKeyError.new(
          "Collection '#{node.name}' item is missing key '#{node.key_name}'",
          context: collection_context(node)
        )
      end

      def ensure_unique_collection_keys!(node, items)
        keys = items.map do |item|
          item.fetch(node.key_name) { raise CollectionKeyError.new("Collection '#{node.name}' item is missing key '#{node.key_name}'", context: collection_context(node)) }
        end

        duplicates = keys.group_by(&:itself).select { |_key, entries| entries.size > 1 }.keys
        return if duplicates.empty?

        raise CollectionKeyError.new(
          "Collection '#{node.name}' has duplicate keys: #{duplicates.join(', ')}",
          context: collection_context(node)
        )
      end

      def collection_context(node)
        {
          graph: @execution.compiled_graph.name,
          node_id: node.id,
          node_name: node.name,
          node_path: node.path,
          source_location: node.source_location
        }
      end
    end
  end
end
