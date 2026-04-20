# frozen_string_literal: true

module Igniter
  module Runtime
    class Execution
      UNDEFINED_RESUME_VALUE = Object.new

      attr_reader :compiled_graph, :contract_instance, :inputs, :cache, :events, :audit,
                  :runner_strategy, :max_workers, :store, :remote_adapter, :agent_adapter

      def initialize(compiled_graph:, contract_instance:, inputs:, runner: :inline, max_workers: nil,
                     store: nil, remote_adapter: nil, agent_adapter: nil)
        @compiled_graph = compiled_graph
        @contract_instance = contract_instance
        @runner_strategy = runner
        @max_workers = max_workers
        @store = store
        @remote_adapter = remote_adapter || Runtime.remote_adapter
        @agent_adapter = agent_adapter || Runtime.agent_adapter
        @events = Events::Bus.new
        @input_validator = InputValidator.new(compiled_graph, execution_id: @events.execution_id)
        @inputs = @input_validator.normalize_initial_inputs(inputs)
        @cache = Cache.new
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
        state = @resolver.resolve(name)
        persist_runtime_state!
        state
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

      # Returns the DiffState for an incremental collection node (created on first access).
      # Persists across update_inputs calls for the lifetime of this Execution.
      def diff_state_for(node_name)
        @diff_states ||= {}
        @diff_states[node_name.to_sym] ||= Igniter::Dataflow::DiffState.new
      end


      # Returns the AggregateState for an aggregate node (created on first access).
      # Persists across update_inputs calls for the lifetime of this Execution.
      def aggregate_state_for(node_name)
        @aggregate_states ||= {}
        @aggregate_states[node_name.to_sym] ||= begin
          node = compiled_graph.fetch_node(node_name)
          Igniter::Dataflow::AggregateState.new(node.operator)
        end
      end

      def resume(node_name, value: UNDEFINED_RESUME_VALUE)
        node = compiled_graph.fetch_node(node_name)
        current = cache.fetch(node.name)
        raise ResolutionError, "Node '#{node_name}' is not pending" unless current&.pending?

        resolved_value = resolved_resume_value(current, value)
        completed_session = completed_agent_session(current, resolved_value)
        cache.write(
          NodeState.new(
            node: node,
            status: :succeeded,
            value: resolved_value,
            details: resumed_node_details(current, completed_session)
          )
        )
        if completed_session
          @events.emit(
            :agent_session_completed,
            node: node,
            status: :succeeded,
            payload: {
              token: completed_session.token,
              turn: completed_session.turn,
              agent_session: completed_session.to_h
            }
          )
        end
        @events.emit(:node_resumed, node: node, status: :succeeded, payload: { resumed: true })
        @invalidator.invalidate_from(node.name)
        persist_runtime_state!
        self
      end

      def resume_by_token(token, value: UNDEFINED_RESUME_VALUE)
        node_name = pending_node_name_for_token(token)
        raise ResolutionError, "No pending node found for token '#{token}'" unless node_name

        resume(node_name, value: value)
      end

      def agent_sessions
        cache.values.filter_map do |state|
          next unless state.pending?
          next unless state.node.kind == :agent
          next unless state.value.is_a?(Runtime::DeferredResult)

          agent_session_for_state(state)
        end
      end

      def agent_session_query
        Runtime::AgentSessionQuery.new(agent_sessions, execution: self)
      end

      def agent_session_summary
        agent_session_query.summary
      end

      def find_agent_session(token)
        agent_sessions.find { |session| session.token == token }
      end

      def resume_agent_session(session_or_token, node_name: nil, value: UNDEFINED_RESUME_VALUE)
        if node_name
          token = session_or_token.is_a?(Runtime::AgentSession) ? session_or_token.token : session_or_token
          state = cache.fetch(node_name.to_sym)
          raise ResolutionError, "Agent session node '#{node_name}' is not pending" unless state&.pending?
          raise ResolutionError, "Node '#{node_name}' is not an agent session" unless state.node.kind == :agent
          raise ResolutionError, "Node '#{node_name}' does not carry a deferred agent result" unless state.value.is_a?(Runtime::DeferredResult)
          if token && state.value.token != token
            raise ResolutionError, "Pending agent node '#{node_name}' does not match token '#{token}'"
          end

          session = agent_session_for_state(state)
          handled = handle_remote_agent_session_resume(state, session, value)
          return handled if handled

          return resume(node_name, value: value)
        end

        session = resolve_agent_session(session_or_token)
        handled = handle_remote_agent_session_resume(
          pending_state_for_token(session.token, source_only: true),
          session,
          value
        )
        return handled if handled

        raise ResolutionError, "Agent session token is required" if session.token.nil? || session.token.to_s.empty?

        resume_by_token(session.token, value: value)
      end

      def continue_agent_session(session_or_token, payload:, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil)
        session = resolve_agent_session(session_or_token)
        state = pending_state_for_token(session.token, source_only: true)
        raise ResolutionError, "No pending agent session found for token '#{session.token}'" unless state
        if state.node.reply_mode == :stream && state.node.session_policy == :single_turn
          raise ResolutionError, "Streaming agent session '#{session.node_name}' does not allow continuation under session_policy :single_turn"
        end
        session.validate_stream_reply!(reply) if state.node.reply_mode == :stream

        handled = handle_remote_agent_session_continue(
          state,
          session,
          payload: payload,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )
        return handled if handled

        continued_session = session.continue(
          payload: payload,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )
        deferred = deferred_for_continued_agent_session(state, continued_session)

        cache.write(
          NodeState.new(
            node: state.node,
            status: :pending,
            value: deferred,
            details: {
              agent_trace: continued_session.trace,
              agent_session: continued_session.to_h
            }.compact
          )
        )
        @events.emit(
          :agent_session_continued,
          node: state.node,
          status: :pending,
          payload: {
            token: continued_session.token,
            turn: continued_session.turn,
            phase: continued_session.phase,
            waiting_on: continued_session.waiting_on,
            agent_trace: continued_session.trace,
            agent_session: continued_session.to_h
          }.compact
        )
        @events.emit(:node_pending, node: state.node, status: :pending, payload: deferred.to_h)
        persist_runtime_state!
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

      def orchestration_plan(output_names = nil)
        plan(output_names)[:orchestration]
      end

      def orchestration_overview(output_names = nil)
        Runtime::OrchestrationOverview.new(execution: self, plan: plan(output_names)).to_h
      end

      def orchestration_summary(output_names = nil)
        orchestration_overview(output_names)[:summary]
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
        source_match = pending_state_for_token(token, source_only: true)
        return source_match.node.name if source_match

        pending_state_for_token(token)&.node&.name
      end

      def resolve_pending_safe
        resolve_all
      rescue Igniter::Error
        nil
      end

      def agent_session_for_state(state)
        data = state.value.agent_session_data
        data = default_agent_session_data(state) if data.nil? || data.empty?

        Runtime::AgentSession.from_h(
          data.merge(
            execution_id: events.execution_id,
            graph: compiled_graph.name
          )
        )
      end

      def serialize_states
        cache.to_h.each_with_object({}) do |(node_name, state), memo|
          memo[node_name] = {
            status: state.status,
            version: state.version,
            value_version: state.value_version,
            resolved_at: state.resolved_at&.iso8601,
            invalidated_by: state.invalidated_by,
            value: serialize_state_value(state.value),
            error: serialize_state_error(state.error),
            dep_snapshot: state.dep_snapshot,
            details: state.details
          }
        end
      end

      def deserialize_states(snapshot_states)
        snapshot_states.each_with_object({}) do |(node_name, state_data), memo|
          node = compiled_graph.fetch_node(node_name)
          raw_dep_snapshot = state_data[:dep_snapshot] || state_data["dep_snapshot"]
          dep_snapshot = raw_dep_snapshot&.transform_keys(&:to_sym)
          memo[node.name] = NodeState.new(
            node: node,
            status: (state_data[:status] || state_data["status"]).to_sym,
            value: deserialize_state_value(node, state_data[:value] || state_data["value"]),
            error: deserialize_state_error(state_data[:error] || state_data["error"]),
            version: state_data[:version] || state_data["version"],
            value_version: state_data[:value_version] || state_data["value_version"],
            resolved_at: deserialize_time(state_data[:resolved_at] || state_data["resolved_at"]),
            invalidated_by: (state_data[:invalidated_by] || state_data["invalidated_by"])&.to_sym,
            dep_snapshot: dep_snapshot,
            details: state_data[:details] || state_data["details"] || {}
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
        when Runtime::CollectionResult
          {
            type: :collection_result,
            mode: value.mode,
            items: value.items.transform_values do |item|
              {
                key: item.key,
                status: item.status,
                result: serialize_state_value(item.result),
                error: serialize_state_error(item.error)
              }
            end
          }
        else
          value
        end
      end

      def deserialize_state_value(node, value)
        if value.is_a?(Hash) && (value[:type] || value["type"])&.to_sym == :deferred
          data = value[:data] || value["data"] || {}
          return build_pending_value(
            node,
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

          if node.kind == :branch
            snapshot_graph = snapshot[:graph] || snapshot["graph"]
            contract_class = node.possible_contracts.find { |candidate| candidate.compiled_graph.name == snapshot_graph }
            return value unless contract_class

            child_contract = contract_class.restore(snapshot)
            return child_contract.result
          end

          if node.kind == :collection
            child_contract = node.contract_class.restore(snapshot)
            return child_contract.result
          end
        end

        if value.is_a?(Hash) && (value[:type] || value["type"])&.to_sym == :collection_result
          items = (value[:items] || value["items"] || {}).each_with_object({}) do |(key, item), memo|
            memo[key.is_a?(String) && key.match?(/\A\d+\z/) ? key.to_i : key] = Runtime::CollectionResult::Item.new(
              key: item[:key] || item["key"] || key,
              status: (item[:status] || item["status"]).to_sym,
              result: deserialize_state_value(node, item[:result] || item["result"]),
              error: deserialize_state_error(item[:error] || item["error"])
            )
          end
          return Runtime::CollectionResult.new(
            items: items,
            mode: (value[:mode] || value["mode"] || :collect).to_sym
          )
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

      def default_agent_session_data(state)
        trace = state.value.agent_trace || state.details[:agent_trace]

        Runtime::AgentSession.new(
          token: state.value.token,
          node_name: state.node.name,
          node_path: state.node.path,
          agent_name: state.node.agent_name,
          message_name: state.node.message_name,
          mode: state.node.mode,
          reply_mode: state.node.reply_mode,
          waiting_on: state.value.waiting_on,
          source_node: state.value.source_node,
          trace: trace,
          payload: session_payload_from(state.value.payload),
          turn: 1,
          phase: default_agent_session_phase(state.node),
          history: [
            {
              turn: 1,
              event: :opened,
              token: state.value.token,
              waiting_on: state.value.waiting_on,
              payload: session_payload_from(state.value.payload),
              phase: default_agent_session_phase(state.node)
            }
          ]
        ).to_h
      end

      def resolve_agent_session(session_or_token)
        return session_or_token if session_or_token.is_a?(Runtime::AgentSession)

        session = find_agent_session(session_or_token)
        raise ResolutionError, "No pending agent session found for token '#{session_or_token}'" unless session

        session
      end

      def pending_state_for_token(token, source_only: false)
        cache.values.find do |state|
          next false unless state.pending? && state.value.is_a?(Runtime::DeferredResult)
          next false unless state.value.token == token

          !source_only || state.value.source_node == state.node.name
        end
      end

      def handle_remote_agent_session_continue(state, session, payload:, trace:, token:, waiting_on:, request:, reply:, phase:) # rubocop:disable Metrics/ParameterLists
        return nil unless state
        return nil unless session.remote_owned?

        response = @agent_adapter.continue_session(
          session: session,
          payload: payload,
          execution: self,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )
        return nil unless response

        apply_remote_agent_session_response(
          state,
          session,
          response,
          payload: payload,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )
      end

      def handle_remote_agent_session_resume(state, session, value)
        return nil unless state
        return nil unless session.remote_owned?

        response = @agent_adapter.resume_session(
          session: session,
          execution: self,
          value: value.equal?(UNDEFINED_RESUME_VALUE) ? nil : value
        )
        return nil unless response

        apply_remote_agent_session_response(state, session, response)
      end

      def apply_remote_agent_session_response(state, session, response, payload: nil, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil) # rubocop:disable Metrics/ParameterLists
        status = value_from(response, :status)&.to_sym

        case status
        when :pending
          apply_remote_pending_agent_session_response(
            state,
            session,
            response,
            payload: payload,
            trace: trace,
            token: token,
            waiting_on: waiting_on,
            request: request,
            reply: reply,
            phase: phase
          )
        when :succeeded
          apply_remote_completed_agent_session_response(state, session, response)
        when :failed
          error = value_from(response, :error) || {}
          message = value_from(error, :message) || value_from(response, :message) || "remote agent session failed"
          raise ResolutionError.new(message, context: { agent_trace: value_from(response, :agent_trace) }.compact)
        else
          raise ResolutionError, "Remote agent session '#{session.token}' returned unexpected status '#{status}'"
        end
      end

      def apply_remote_pending_agent_session_response(state, session, response, payload:, trace:, token:, waiting_on:, request:, reply:, phase:) # rubocop:disable Metrics/ParameterLists
        continued_session =
          if (raw_session = value_from(response, :agent_session) || value_from(response, :session))
            normalize_remote_agent_session(raw_session, session)
          else
            session.continue(
              payload: payload || session.payload,
              trace: value_from(response, :agent_trace) || trace,
              token: token,
              waiting_on: waiting_on,
              request: request,
              reply: reply,
              phase: phase
            )
          end

        deferred = deferred_for_remote_agent_session_response(state, continued_session, response)

        cache.write(
          NodeState.new(
            node: state.node,
            status: :pending,
            value: deferred,
            details: {
              agent_trace: continued_session.trace,
              agent_session: continued_session.to_h
            }.compact
          )
        )
        @events.emit(
          :agent_session_continued,
          node: state.node,
          status: :pending,
          payload: {
            token: continued_session.token,
            turn: continued_session.turn,
            phase: continued_session.phase,
            waiting_on: continued_session.waiting_on,
            agent_trace: continued_session.trace,
            agent_session: continued_session.to_h
          }.compact
        )
        @events.emit(:node_pending, node: state.node, status: :pending, payload: deferred.to_h)
        persist_runtime_state!
        self
      end

      def apply_remote_completed_agent_session_response(state, session, response)
        resolved_value =
          if response.respond_to?(:key?) && (response.key?(:output) || response.key?("output"))
            value_from(response, :output)
          else
            value_from(response, :value)
          end

        completed_session =
          if (raw_session = value_from(response, :agent_session) || value_from(response, :session))
            normalize_remote_agent_session(raw_session, session)
          else
            session.complete(
              value: resolved_value,
              reply: value_from(response, :reply),
              trace: value_from(response, :agent_trace)
            )
          end

        cache.write(
          NodeState.new(
            node: state.node,
            status: :succeeded,
            value: resolved_value,
            details: resumed_node_details(state, completed_session)
          )
        )
        @events.emit(
          :agent_session_completed,
          node: state.node,
          status: :succeeded,
          payload: {
            token: completed_session.token,
            turn: completed_session.turn,
            agent_session: completed_session.to_h
          }
        )
        @events.emit(:node_resumed, node: state.node, status: :succeeded, payload: { resumed: true })
        @invalidator.invalidate_from(state.node.name)
        persist_runtime_state!
        self
      end

      def normalize_remote_agent_session(raw_session, session)
        data = raw_session.respond_to?(:to_h) ? raw_session.to_h : raw_session
        Runtime::AgentSession.from_h(session.to_h.merge(data.transform_keys(&:to_sym)))
      end

      def deferred_for_remote_agent_session_response(state, session, response)
        base_deferred = value_from(response, :deferred_result)
        base_payload = value_from(response, :payload) || strip_agent_keys(state.value.payload)
        payload = strip_agent_keys(base_payload).merge(
          agent_trace: session.trace,
          agent_session: session.to_h
        ).compact

        build_pending_value(
          state.node,
          token: base_deferred&.token || session.token,
          payload: payload,
          source_node: base_deferred&.source_node || state.value.source_node || state.node.name,
          waiting_on: base_deferred&.waiting_on || session.waiting_on
        )
      end

      def deferred_for_continued_agent_session(state, session)
        payload = strip_agent_keys(state.value.payload).merge(
          agent_trace: session.trace,
          agent_session: session.to_h
        ).compact

        build_pending_value(
          state.node,
          token: session.token,
          payload: payload,
          source_node: state.value.source_node || state.node.name,
          waiting_on: session.waiting_on
        )
      end

      def completed_agent_session(state, value)
        return nil unless state.node.kind == :agent
        return nil unless state.value.is_a?(Runtime::DeferredResult)

        agent_session_for_state(state).complete(value: value)
      end

      def resolved_resume_value(state, value)
        return value unless value.equal?(UNDEFINED_RESUME_VALUE)

        if state.node.kind == :agent && state.node.reply_mode == :stream
          session = agent_session_for_state(state)
          if state.node.session_policy == :manual
            raise ResolutionError, "Streaming agent session '#{state.node.name}' requires explicit value under session_policy :manual"
          end
          session.ensure_ready_to_finalize_stream!(policy: state.node.tool_loop_policy)
          return session.finalized_value(
            finalizer: state.node.finalizer,
            contract: contract_instance,
            execution: self
          )
        end

        raise ResolutionError, "A resume value is required for node '#{state.node.name}'"
      end

      def resumed_node_details(state, completed_session)
        details = state.details.dup
        details[:agent_session] = completed_session.to_h if completed_session
        details[:agent_trace] = completed_session.trace if completed_session&.trace
        details
      end

      def session_payload_from(payload)
        return {} unless payload.is_a?(Hash)

        payload.each_with_object({}) do |(key, value), memo|
          next if %i[agent_trace agent_session].include?(key.to_sym)

          memo[key] = value
        end
      end

      def strip_agent_keys(payload)
        return {} unless payload.is_a?(Hash)

        payload.each_with_object({}) do |(key, value), memo|
          next if %i[agent_trace agent_session].include?(key.to_sym)

          memo[key] = value
        end
      end

      def default_agent_session_phase(node)
        node.reply_mode == :stream ? :streaming : :waiting
      end

      def build_pending_value(node, token:, payload:, source_node:, waiting_on:)
        result_class = node.kind == :agent && node.reply_mode == :stream ? Runtime::StreamResult : Runtime::DeferredResult

        result_class.build(
          token: token,
          payload: payload,
          source_node: source_node,
          waiting_on: waiting_on
        )
      end

      alias_method :resolve_output_value, :resolve_exported_output
    end
  end
end
