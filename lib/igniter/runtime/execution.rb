# frozen_string_literal: true

module Igniter
  module Runtime
    class Execution
      attr_reader :compiled_graph, :contract_instance, :inputs, :cache, :events, :audit, :runner_strategy, :max_workers, :store

      def initialize(compiled_graph:, contract_instance:, inputs:, runner: :inline, max_workers: nil, store: nil)
        @compiled_graph = compiled_graph
        @contract_instance = contract_instance
        @runner_strategy = runner
        @max_workers = max_workers
        @store = store
        @input_validator = InputValidator.new(compiled_graph)
        @inputs = @input_validator.normalize_initial_inputs(inputs)
        @cache = Cache.new
        @events = Events::Bus.new
        @audit = Extensions::Auditing::Timeline.new(self)
        @events.subscribe(@audit)
        @resolver = Resolver.new(self)
        @planner = Planner.new(self)
        @runner = RunnerFactory.build(@runner_strategy, self, resolver: @resolver, max_workers: @max_workers, store: @store)
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
        persist_runtime_state!
        self
      end

      def resume_by_token(token, value:)
        node_name = pending_node_name_for_token(token)
        raise ResolutionError, "No pending node found for token '#{token}'" unless node_name

        resume(node_name, value: value)
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

      def explain_plan(output_names = nil)
        Extensions::Introspection::PlanFormatter.to_text(self, output_names)
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

      def snapshot(include_resolution: true)
        resolve_pending_safe if include_resolution

        {
          graph: compiled_graph.name,
          execution_id: events.execution_id,
          runner: runner_strategy,
          max_workers: max_workers,
          inputs: inputs.dup,
          states: serialize_states,
          events: events.events.map(&:as_json)
        }
      end

      def restore!(snapshot)
        @inputs.replace(symbolize_keys(value_from(snapshot, :inputs) || {}))
        cache.restore!(deserialize_states(value_from(snapshot, :states) || {}))
        events.restore!(events: value_from(snapshot, :events) || [], execution_id: value_from(snapshot, :execution_id))
        audit.restore!(events.events)
        self
      end

      private

      def with_execution_lifecycle(node_names)
        if resolution_required_for_any?(node_names)
          @events.emit(:execution_started, payload: { graph: compiled_graph.name, targets: node_names.map(&:to_sym) })
          begin
            result = yield
            persist_runtime_state!
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
            persist_runtime_state!
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

      def persist_runtime_state!
        return unless @runner.respond_to?(:persist!)

        @runner.persist!
      end

      def pending_node_name_for_token(token)
        source_match = cache.values.find do |state|
          state.pending? &&
            state.value.is_a?(Runtime::DeferredResult) &&
            state.value.token == token &&
            state.value.source_node == state.node.name
        end
        return source_match.node.name if source_match

        cache.values.find do |state|
          state.pending? &&
            state.value.is_a?(Runtime::DeferredResult) &&
            state.value.token == token
        end&.node&.name
      end

      def resolve_pending_safe
        resolve_all
      rescue Igniter::Error
        nil
      end

      def serialize_states
        cache.to_h.each_with_object({}) do |(node_name, state), memo|
          memo[node_name] = {
            status: state.status,
            version: state.version,
            resolved_at: state.resolved_at&.iso8601,
            invalidated_by: state.invalidated_by,
            value: serialize_state_value(state.value),
            error: serialize_state_error(state.error)
          }
        end
      end

      def deserialize_states(snapshot_states)
        snapshot_states.each_with_object({}) do |(node_name, state_data), memo|
          node = compiled_graph.fetch_node(node_name)
          memo[node.name] = NodeState.new(
            node: node,
            status: (state_data[:status] || state_data["status"]).to_sym,
            value: deserialize_state_value(node, state_data[:value] || state_data["value"]),
            error: deserialize_state_error(state_data[:error] || state_data["error"]),
            version: state_data[:version] || state_data["version"],
            resolved_at: deserialize_time(state_data[:resolved_at] || state_data["resolved_at"]),
            invalidated_by: (state_data[:invalidated_by] || state_data["invalidated_by"])&.to_sym
          )
        end
      end

      def serialize_state_value(value)
        case value
        when Runtime::DeferredResult
          { type: :deferred, data: value.as_json }
        when Runtime::Result
          {
            type: :result_snapshot,
            snapshot: value.execution.snapshot(include_resolution: false)
          }
        else
          value
        end
      end

      def deserialize_state_value(node, value)
        if value.is_a?(Hash) && (value[:type] || value["type"])&.to_sym == :deferred
          data = value[:data] || value["data"] || {}
          return Runtime::DeferredResult.build(
            token: data[:token] || data["token"],
            payload: data[:payload] || data["payload"] || {},
            source_node: data[:source_node] || data["source_node"],
            waiting_on: data[:waiting_on] || data["waiting_on"]
          )
        end

        if value.is_a?(Hash) && (value[:type] || value["type"])&.to_sym == :result_snapshot
          snapshot = value[:snapshot] || value["snapshot"] || {}
          if node.kind == :composition
            child_contract = node.contract_class.restore(snapshot)
            return child_contract.result
          end
        end

        value
      end

      def serialize_state_error(error)
        return nil unless error

        {
          type: error.class.name,
          message: error.message,
          context: error.respond_to?(:context) ? error.context : {}
        }
      end

      def deserialize_state_error(error_data)
        return nil unless error_data

        ResolutionError.new(
          error_data[:message] || error_data["message"],
          context: error_data[:context] || error_data["context"] || {}
        )
      end

      def deserialize_time(value)
        case value
        when Time
          value
        when String
          Time.iso8601(value)
        else
          value || Time.now.utc
        end
      end

      def value_from(data, key)
        data[key] || data[key.to_s]
      end

      alias_method :resolve_output_value, :resolve_exported_output
    end
  end
end
