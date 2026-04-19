# frozen_string_literal: true

module Igniter
  module Diagnostics
    module AgentContributor
      class << self
        def augment(report:, execution:)
          agents = summarize_agents(execution)
          return report if agents[:entries].empty?

          report[:agents] = agents
          augment_outputs(report: report, execution: execution, agents: agents)
          augment_errors(report: report, agents: agents)
          report
        end

        def append_text(report:, lines:)
          agents = report[:agents]
          return unless agents

          summaries = agents[:entries].map do |entry|
            summary = "#{entry[:node_name]}(#{entry[:status]} #{entry[:agent_trace_summary]})"
            summary += " token=#{entry[:token]}" if entry[:token]
            summary += " phase=#{entry.dig(:agent_session, :phase)}" if entry.dig(:agent_session, :phase)
            summary += " turn=#{entry.dig(:agent_session, :turn)}" if entry.dig(:agent_session, :turn)
            summary
          end

          lines << "Agents: #{agents_overview(agents)} #{summaries.join(', ')}"
        end

        def append_markdown_summary(report:, lines:)
          agents = report[:agents]
          return unless agents

          lines << "- Agents: #{agents_overview(agents)}"
        end

        def append_markdown_sections(report:, lines:)
          agents = report[:agents]
          return unless agents

          lines << ""
          lines << "## Agents"
          agents[:entries].each do |entry|
            line = "- `#{entry[:node_name]}` `#{entry[:status]}`: `#{entry[:agent_trace_summary]}`"
            line += " token=`#{entry[:token]}`" if entry[:token]
            line += " phase=`#{entry.dig(:agent_session, :phase)}`" if entry.dig(:agent_session, :phase)
            line += " turn=`#{entry.dig(:agent_session, :turn)}`" if entry.dig(:agent_session, :turn)
            line += " error=`#{entry[:error][:message]}`" if entry[:error]
            lines << line
          end
        end

        private

        def summarize_agents(execution)
          entries = execution.cache.values.filter_map { |state| agent_entry_for(state, execution) }

          {
            total: entries.size,
            succeeded: entries.count { |entry| entry[:status] == :succeeded },
            pending: entries.count { |entry| entry[:status] == :pending },
            failed: entries.count { |entry| entry[:status] == :failed },
            facets: summarize_agent_facets(entries),
            entries: entries
          }
        end

        def agent_entry_for(state, execution)
          return unless state.node.kind == :agent

          trace = extract_agent_trace(state)
          return unless trace

          events = summarize_node_events(execution, state.node.name)
          entry = {
            node_name: state.node.name,
            path: state.node.path,
            status: state.status,
            events: events,
            agent_trace: trace,
            agent_trace_summary: summarize_agent_trace(trace)
          }

          entry[:agent_session] = state.details[:agent_session] if state.details[:agent_session]

          if state.pending? && state.value.is_a?(Igniter::Runtime::DeferredResult)
            entry[:token] = state.value.token
            entry[:waiting_on] = state.value.waiting_on
            entry[:source_node] = state.value.source_node
            entry[:agent_session] = state.value.agent_session_data if state.value.agent_session_data
          end

          if state.failed?
            entry[:error] = {
              type: state.error.class.name,
              message: state.error.message
            }
          end

          entry
        end

        def extract_agent_trace(state)
          return state.details[:agent_trace] if state.details[:agent_trace]
          return state.value.agent_trace if state.pending? && state.value.is_a?(Igniter::Runtime::DeferredResult) && state.value.agent_trace
          return nil unless state.failed?

          context = state.error.respond_to?(:context) ? state.error.context : {}
          context[:agent_trace] || context["agent_trace"]
        end

        def augment_outputs(report:, execution:, agents:)
          agent_by_node = agents[:entries].each_with_object({}) do |entry, memo|
            memo[entry[:node_name].to_sym] = entry
          end

          execution.compiled_graph.outputs.each do |output_node|
            entry = agent_by_node[output_node.source_root.to_sym]
            value = report[:outputs][output_node.name]
            next unless entry && value.is_a?(Hash)

            report[:outputs][output_node.name] = value.merge(
              agent_trace: entry[:agent_trace],
              agent_trace_summary: entry[:agent_trace_summary],
              agent_session: entry[:agent_session]
            )
          end
        end

        def augment_errors(report:, agents:)
          agent_by_node = agents[:entries].each_with_object({}) do |entry, memo|
            memo[entry[:node_name].to_sym] = entry
          end

          report[:errors].map! do |error|
            entry = agent_by_node[error[:node_name].to_sym]
            next error unless entry

            error.merge(
              agent_trace: entry[:agent_trace],
              agent_trace_summary: entry[:agent_trace_summary]
            )
          end
        end

        def summarize_agent_facets(entries)
          {
            by_status: count_by(entries) { |entry| entry[:status] },
            by_mode: count_by(entries) { |entry| hash_value(entry[:agent_trace], :mode) },
            by_adapter: count_by(entries) { |entry| hash_value(entry[:agent_trace], :adapter) },
            by_outcome: count_by(entries) { |entry| hash_value(entry[:agent_trace], :outcome) },
            by_reason: count_by(entries) { |entry| hash_value(entry[:agent_trace], :reason) },
            by_latest_event: count_by(entries) { |entry| entry.dig(:events, :latest_type) }
          }
        end

        def summarize_node_events(execution, node_name)
          events = execution.events.events.select { |event| event.node_name == node_name.to_sym }

          {
            total: events.size,
            latest_type: events.last&.type,
            types: events.map(&:type).uniq
          }
        end

        def summarize_agent_trace(trace)
          parts = []
          adapter = hash_value(trace, :adapter)
          mode = hash_value(trace, :mode)
          via = hash_value(trace, :via)
          message = hash_value(trace, :message)
          local = hash_value(trace, :local)
          registered = hash_value(trace, :registered)
          alive = hash_value(trace, :alive)
          outcome = hash_value(trace, :outcome)
          reason = hash_value(trace, :reason)

          parts << "adapter=#{adapter}" if adapter
          parts << "mode=#{mode}" if mode
          parts << "via=#{via}" if via
          parts << "message=#{message}" if message
          parts << "local=#{local}" unless local.nil?
          parts << "registered=#{registered}" unless registered.nil?
          parts << "alive=#{alive}" unless alive.nil?
          parts << "outcome=#{outcome}" if outcome
          parts << "reason=#{reason}" if reason
          parts.join(" ")
        end

        def agents_overview(agents)
          facets = agents[:facets] || {}
          parts = [
            "total=#{agents[:total]}",
            "succeeded=#{agents[:succeeded]}",
            "pending=#{agents[:pending]}",
            "failed=#{agents[:failed]}"
          ]
          parts << "modes=#{inline_counts(facets[:by_mode])}" if present_counts?(facets[:by_mode])
          parts << "adapters=#{inline_counts(facets[:by_adapter])}" if present_counts?(facets[:by_adapter])
          parts << "outcomes=#{inline_counts(facets[:by_outcome])}" if present_counts?(facets[:by_outcome])
          parts << "reasons=#{inline_counts(facets[:by_reason])}" if present_counts?(facets[:by_reason])
          parts.join(", ")
        end

        def count_by(entries)
          entries.each_with_object(Hash.new(0)) do |entry, memo|
            key = yield(entry)
            next if key.nil?

            memo[key.to_sym] += 1
          end
        end

        def inline_counts(counts)
          counts.map { |key, value| "#{key}=#{value}" }.join(", ")
        end

        def present_counts?(counts)
          counts && !counts.empty?
        end

        def hash_value(hash, key)
          return nil unless hash.is_a?(Hash)

          return hash[key] if hash.key?(key)
          return hash[key.to_s] if hash.key?(key.to_s)

          nil
        end
      end
    end
  end
end
