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
        agent_entries = node_entries.values.select { |entry| entry[:kind] == :agent }
        orchestration_entries = agent_entries.map { |entry| entry[:orchestration] }.compact
        orchestration_actions = orchestration_actions_for(orchestration_entries)

        {
          targets: targets,
          ready: node_entries.values.select { |entry| entry[:ready] }.map { |entry| entry[:name] },
          blocked: node_entries.values.select { |entry| entry[:blocked] }.map { |entry| entry[:name] },
          agent_profiles: {
            total: agent_entries.size,
            interactive: agent_entries.count { |entry| entry.dig(:execution_profile, :interactive) },
            manual: agent_entries.count { |entry| entry.dig(:execution_profile, :manual_completion) },
            single_turn: agent_entries.count { |entry| entry.dig(:execution_profile, :single_turn) },
            streaming: agent_entries.count { |entry| entry.dig(:execution_profile, :streaming) },
            deferred: agent_entries.count { |entry| entry[:reply_mode] == :deferred }
          },
          orchestration: orchestration_summary(orchestration_entries, orchestration_actions),
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
        entry = {
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
        return entry unless node.kind == :agent

        entry.merge(
          via: node.agent_name,
          message: node.message_name,
          mode: node.mode,
          routing_mode: node.routing_mode,
          node: (node.node_url if node.routing_mode == :static),
          capability: node.capability,
          query: node.capability_query,
          pinned_to: node.pinned_to,
          reply_mode: node.reply_mode,
          finalizer: serialized_agent_finalizer(node.finalizer),
          session_policy: node.session_policy,
          tool_loop_policy: node.tool_loop_policy,
          interaction_contract: node.interaction_contract.to_h,
          execution_profile: agent_execution_profile(node),
          orchestration: orchestration_hint(node, status: entry[:status])
        )
      end

      def agent_execution_profile(node)
        interaction = node.interaction_contract

        {
          delivery: interaction.mode,
          routing_mode: interaction.routing_mode,
          streaming: interaction.reply_mode == :stream,
          deferred: interaction.reply_mode == :deferred,
          resumable: %i[deferred stream].include?(interaction.reply_mode),
          interactive: interaction.reply_mode == :stream && interaction.session_policy == :interactive,
          manual_completion: interaction.reply_mode == :stream && interaction.session_policy == :manual,
          single_turn: interaction.reply_mode == :stream && interaction.session_policy == :single_turn
        }
      end

      def serialized_agent_finalizer(finalizer)
        return nil if finalizer.nil?
        return finalizer if finalizer.is_a?(Symbol)

        finalizer.to_s
      end

      def orchestration_summary(entries, actions)
        {
          total: entries.size,
          attention_required: entries.count { |entry| entry[:attention_required] },
          resumable: entries.count { |entry| entry[:resumable] },
          interactive_sessions: entries.count { |entry| entry[:interaction] == :interactive_session },
          manual_sessions: entries.count { |entry| entry[:interaction] == :manual_session },
          single_turn_sessions: entries.count { |entry| entry[:interaction] == :single_turn_session },
          deferred_calls: entries.count { |entry| entry[:interaction] == :deferred_call },
          single_reply_calls: entries.count { |entry| entry[:interaction] == :single_reply_call },
          delivery_only: entries.count { |entry| entry[:interaction] == :delivery_only },
          attention_nodes: entries.select { |entry| entry[:attention_required] }.map { |entry| entry[:node] },
          actions: actions,
          by_action: count_many(actions) { |action| action[:action] }
        }
      end

      def orchestration_actions_for(entries)
        entries.filter_map do |entry|
          next unless orchestration_actionable?(entry)

          action, reason = orchestration_action_for(entry)
          next unless action

          {
            id: "agent_orchestration:#{action}:#{entry[:node]}",
            action: action,
            node: entry[:node],
            interaction: entry[:interaction],
            reason: reason,
            guidance: entry[:guidance],
            attention_required: entry[:attention_required],
            resumable: entry[:resumable]
          }.freeze
        end
      end

      def orchestration_actionable?(entry)
        !%i[succeeded failed].include?(entry[:status])
      end

      def orchestration_action_for(entry)
        case entry[:interaction]
        when :interactive_session
          [:open_interactive_session, :interactive_session]
        when :manual_session
          [:require_manual_completion, :manual_session]
        when :single_turn_session
          [:await_single_turn_completion, :single_turn_session]
        when :deferred_call
          [:await_deferred_reply, :deferred_call]
        else
          nil
        end
      end

      def orchestration_hint(node, status:)
        interaction, guidance = orchestration_profile_for(node)

        {
          node: node.name,
          status: status,
          interaction: interaction,
          guidance: guidance,
          attention_required: attention_required_for?(node, interaction),
          resumable: %i[deferred stream].include?(node.reply_mode),
          allows_continuation: node.reply_mode == :stream && node.session_policy != :single_turn,
          requires_explicit_completion: node.reply_mode == :stream && node.session_policy == :manual,
          auto_finalization: auto_finalization_mode(node)
        }
      end

      def orchestration_profile_for(node)
        case node.mode
        when :cast
          [:delivery_only, "fire-and-forget delivery; no reply path"]
        when :call
          case node.reply_mode
          when :single
            [:single_reply_call, "synchronous call; must resolve in the current turn"]
          when :deferred
            [:deferred_call, "resumable call; may complete later through session resume"]
          when :stream
            case node.session_policy
            when :manual
              [:manual_session, "streaming session; requires explicit completion value"]
            when :single_turn
              [:single_turn_session, "streaming session; continuation is not allowed after opening"]
            else
              [:interactive_session, "streaming session; multi-turn continuation is allowed"]
            end
          else
            [:agent_step, "agent-backed execution step"]
          end
        else
          [:agent_step, "agent-backed execution step"]
        end
      end

      def attention_required_for?(node, interaction)
        return true if interaction == :manual_session
        return true if interaction == :interactive_session

        node.reply_mode == :deferred
      end

      def auto_finalization_mode(node)
        return :not_applicable unless node.reply_mode == :stream
        return :disabled if node.session_policy == :manual

        node.tool_loop_policy || :complete
      end

      def count_many(entries)
        entries.each_with_object(Hash.new(0)) do |entry, memo|
          Array(yield(entry)).each do |key|
            next if key.nil?

            memo[key] += 1
          end
        end
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
