# frozen_string_literal: true

module Igniter
  module Diagnostics
    class Report
      def initialize(execution)
        @execution = execution
      end

      def to_h
        safely_resolve_execution

        {
          graph: execution.compiled_graph.name,
          execution_id: execution.events.execution_id,
          status: status,
          outputs: serialize_outputs,
          errors: serialize_errors,
          routing: summarize_routing,
          nodes: summarize_nodes,
          collection_nodes: summarize_collection_nodes,
          events: summarize_events
        }
      end

      def as_json(*)
        to_h
      end

      def to_text
        report = to_h
        lines = []
        lines << "Diagnostics #{report[:graph]}"
        lines << "Execution #{report[:execution_id]}"
        lines << "Status: #{report[:status]}"
        lines << format_outputs(presented_outputs)
        lines << format_nodes(report[:nodes])
        lines << format_collection_nodes(report[:collection_nodes])
        lines << format_errors(report[:errors])
        lines << format_routing(report[:routing])
        lines << format_events(report[:events])
        lines.compact.join("\n")
      end

      def to_markdown
        report = to_h
        lines = []
        lines << "# Diagnostics #{report[:graph]}"
        lines << ""
        lines << "- Execution: `#{report[:execution_id]}`"
        lines << "- Status: `#{report[:status]}`"
        lines << "- Outputs: #{inline_hash(presented_outputs)}"
        lines << "- Nodes: total=#{report[:nodes][:total]}, succeeded=#{report[:nodes][:succeeded]}, failed=#{report[:nodes][:failed]}, stale=#{report[:nodes][:stale]}"
        unless report[:collection_nodes].empty?
          lines << "- Collections: #{report[:collection_nodes].map { |node| "#{node[:node_name]} total=#{node[:total]} succeeded=#{node[:succeeded]} failed=#{node[:failed]} status=#{node[:status]}" }.join('; ')}"
        end
        unless report[:routing][:entries].empty?
          lines << "- Routing: total=#{report[:routing][:total]}, pending=#{report[:routing][:pending]}, failed=#{report[:routing][:failed]}"
        end
        lines << "- Events: total=#{report[:events][:total]}, latest=#{report[:events][:latest_type] || 'none'}"

        unless report[:errors].empty?
          lines << ""
          lines << "## Errors"
          report[:errors].each do |error|
            line = "- `#{error[:node_name]}`: #{error[:message]}"
            line += " (`#{error[:routing_trace_summary]}`)" if error[:routing_trace_summary]
            lines << line
          end
        end

        unless report[:collection_nodes].empty?
          lines << ""
          lines << "## Collections"
          report[:collection_nodes].each do |node|
            lines << "- `#{node[:node_name]}`: total=#{node[:total]}, succeeded=#{node[:succeeded]}, failed=#{node[:failed]}, status=#{node[:status]}"
            node[:failed_items].each do |item|
              lines << "- `#{node[:node_name]}[#{item[:key]}]` failed: #{item[:message]}"
            end
          end
        end

        unless report[:routing][:entries].empty?
          lines << ""
          lines << "## Routing"
          report[:routing][:entries].each do |entry|
            line = "- `#{entry[:node_name]}` `#{entry[:status]}`: `#{entry[:routing_trace_summary]}`"
            line += " token=`#{entry[:token]}`" if entry[:token]
            line += " error=`#{entry[:error][:message]}`" if entry[:error]
            lines << line
          end
        end

        lines.join("\n")
      end

      private

      attr_reader :execution

      def execution_result
        @execution_result ||= Runtime::Result.new(execution)
      end

      def safely_resolve_execution
        execution.resolve_all
      rescue Igniter::Error
        nil
      end

      def status
        return :failed if execution.cache.values.any?(&:failed?)
        return :pending if execution.cache.values.any?(&:pending?)
        return :stale if execution.cache.values.any?(&:stale?)

        :succeeded
      end

      def serialize_errors
        execution.cache.values.filter_map do |state|
          next unless state.failed?

          serialize_error(state.node.name, state.error)
        end
      end

      def serialize_outputs
        execution.compiled_graph.outputs.each_with_object({}) do |output_node, memo|
          state = execution.cache.fetch(output_node.source_root)
          memo[output_node.name] = serialize_output_value(output_node, state)
        end
      end

      def serialize_output_value(output_node, state)
        return nil unless state
        return serialize_failed_output(state.error, state.status) if state.failed?

        if output_node.composition_output?
          return serialize_output_from_child(output_node, state.value)
        end

        serialize_value(state.value)
      end

      def serialize_output_from_child(output_node, child_result)
        return nil unless child_result.is_a?(Runtime::Result)

        child_errors = child_result.execution.cache.values.select(&:failed?)
        return serialize_failed_output(child_errors.first.error, :failed) unless child_errors.empty?

        child_result.public_send(output_node.child_output_name)
      end

      def summarize_nodes
        states = execution.states

        {
          total: states.size,
          succeeded: states.values.count { |state| state[:status] == :succeeded },
          failed: states.values.count { |state| state[:status] == :failed },
          pending: states.values.count { |state| state[:status] == :pending },
          stale: states.values.count { |state| state[:status] == :stale },
          failed_nodes: states.filter_map do |node_name, state|
            next unless state[:status] == :failed

            { node_name: node_name, path: state[:path], error: state[:error] }
          end
        }
      end

      def summarize_events
        events = execution.events.events

        {
          total: events.size,
          latest_type: events.last&.type,
          latest_at: events.last&.timestamp,
          by_type: events.each_with_object(Hash.new(0)) { |event, memo| memo[event.type] += 1 }
        }
      end

      def format_outputs(outputs)
        "Outputs: #{inline_hash(outputs)}"
      end

      def presented_outputs
        @presented_outputs ||= execution.compiled_graph.outputs.each_with_object({}) do |output_node, memo|
          raw_value = to_h[:outputs][output_node.name]
          memo[output_node.name] = present_output(output_node.name, raw_value)
        end
      end

      def format_nodes(nodes)
        line = "Nodes: total=#{nodes[:total]}, succeeded=#{nodes[:succeeded]}, failed=#{nodes[:failed]}, stale=#{nodes[:stale]}"
        line = "Nodes: total=#{nodes[:total]}, succeeded=#{nodes[:succeeded]}, failed=#{nodes[:failed]}, pending=#{nodes[:pending]}, stale=#{nodes[:stale]}"
        return line if nodes[:failed_nodes].empty?

        failures = nodes[:failed_nodes].map { |node| "#{node[:node_name]}(#{node[:error]})" }.join(", ")
        "#{line}\nFailed Nodes: #{failures}"
      end

      def format_errors(errors)
        return "Errors: none" if errors.empty?

        "Errors: #{errors.map { |error| format_error_summary(error) }.join(', ')}"
      end

      def format_collection_nodes(collection_nodes)
        return nil if collection_nodes.empty?

        summaries = collection_nodes.map do |node|
          summary = "#{node[:node_name]} total=#{node[:total]} succeeded=#{node[:succeeded]} failed=#{node[:failed]} status=#{node[:status]}"
          next summary if node[:failed_items].empty?

          "#{summary} failed_items=#{node[:failed_items].map { |item| "#{item[:key]}(#{item[:message]})" }.join(', ')}"
        end

        "Collections: #{summaries.join('; ')}"
      end

      def format_events(events)
        "Events: total=#{events[:total]}, latest=#{events[:latest_type] || 'none'}"
      end

      def format_routing(routing)
        return nil if routing[:entries].empty?

        summaries = routing[:entries].map do |entry|
          summary = "#{entry[:node_name]}(#{entry[:status]} #{entry[:routing_trace_summary]})"
          summary += " token=#{entry[:token]}" if entry[:token]
          summary
        end

        "Routing: total=#{routing[:total]}, pending=#{routing[:pending]}, failed=#{routing[:failed]} #{summaries.join(', ')}"
      end

      def inline_hash(hash)
        hash.map { |key, value| "#{key}=#{inline_value(value)}" }.join(", ")
      end

      def present_output(output_name, raw_value)
        presenter = execution.contract_instance.class.output_presenters[output_name.to_sym]
        return raw_value unless presenter

        if presenter.is_a?(Symbol) || presenter.is_a?(String)
          execution.contract_instance.public_send(
            presenter,
            value: raw_value,
            contract: execution.contract_instance,
            execution: execution
          )
        else
          presenter.call(
            value: raw_value,
            contract: execution.contract_instance,
            execution: execution
          )
        end
      end

      def serialize_value(value)
        case value
        when Runtime::DeferredResult
          serialize_deferred_result(value)
        when Runtime::Result
          value.to_h
        when Runtime::CollectionResult
          value.as_json
        when Array
          value.map { |item| serialize_value(item) }
        else
          value
        end
      end

      def inline_value(value)
        case value
        when Hash
          return summarize_serialized_deferred_hash(value) if serialized_deferred_hash?(value)
          return summarize_serialized_failed_output_hash(value) if serialized_failed_output_hash?(value)
          return summarize_serialized_collection_hash(value) if serialized_collection_hash?(value)
          return summarize_serialized_collection_items_hash(value) if serialized_collection_items_hash?(value)

          "{#{value.map { |key, nested| "#{key}: #{inline_value(nested)}" }.join(', ')}}"
        when Array
          "[#{value.map { |item| inline_value(item) }.join(', ')}]"
        when Runtime::Result
          summarize_nested_result(value)
        when Runtime::CollectionResult
          summarize_collection_result(value)
        else
          value.inspect
        end
      end

      def summarize_nested_result(result)
        outputs = result.to_h.keys
        "{graph=#{result.execution.compiled_graph.name.inspect}, status=#{nested_result_status(result).inspect}, outputs=#{outputs.inspect}}"
      end

      def summarize_collection_result(result)
        summary = result.summary
        failed_keys = result.failures.keys
        "{mode=#{result.mode.inspect}, total=#{summary[:total]}, succeeded=#{summary[:succeeded]}, failed=#{summary[:failed]}, status=#{summary[:status].inspect}, keys=#{result.keys.inspect}, failed_keys=#{failed_keys.inspect}}"
      end

      def serialized_collection_hash?(value)
        value.key?(:mode) && value.key?(:summary) && value.key?(:items)
      end

      def summarize_serialized_collection_hash(value)
        summary = value[:summary] || {}
        items = value[:items] || {}
        failed_keys = items.each_with_object([]) do |(key, item), memo|
          memo << key if item[:status] == :failed || item["status"] == :failed
        end

        "{mode=#{value[:mode].inspect}, total=#{summary[:total]}, succeeded=#{summary[:succeeded]}, failed=#{summary[:failed]}, status=#{summary[:status].inspect}, keys=#{items.keys.inspect}, failed_keys=#{failed_keys.inspect}}"
      end

      def serialized_deferred_hash?(value)
        (value.key?(:token) || value.key?("token")) &&
          (value.key?(:waiting_on) || value.key?("waiting_on"))
      end

      def summarize_serialized_deferred_hash(value)
        token = hash_value(value, :token)
        waiting_on = hash_value(value, :waiting_on)
        payload = hash_value(value, :payload)
        routing_summary = hash_value(value, :routing_trace_summary)

        parts = ["token=#{token.inspect}", "waiting_on=#{waiting_on.inspect}"]
        parts << "payload_keys=#{payload.keys.inspect}" if payload.is_a?(Hash) && !payload.empty?
        parts << "routing=#{routing_summary}" if routing_summary
        "{#{parts.join(', ')}}"
      end

      def serialized_failed_output_hash?(value)
        (value.key?(:error) || value.key?("error")) &&
          (value.key?(:status) || value.key?("status"))
      end

      def summarize_serialized_failed_output_hash(value)
        status = hash_value(value, :status)
        error = hash_value(value, :error)
        routing_summary = hash_value(value, :routing_trace_summary)

        parts = ["status=#{status.inspect}", "error=#{error.inspect}"]
        parts << "routing=#{routing_summary}" if routing_summary
        "{#{parts.join(', ')}}"
      end

      def serialized_collection_items_hash?(value)
        return false if value.empty?

        value.values.all? do |item|
          item.is_a?(Hash) && (item.key?(:key) || item.key?("key")) && (item.key?(:status) || item.key?("status"))
        end
      end

      def summarize_serialized_collection_items_hash(value)
        failed_keys = value.each_with_object([]) do |(key, item), memo|
          status = item[:status] || item["status"]
          memo << key if status == :failed || status == "failed"
        end

        total = value.size
        failed = failed_keys.size
        succeeded = total - failed
        status = failed.zero? ? :succeeded : :partial_failure

        "{mode=:collect, total=#{total}, succeeded=#{succeeded}, failed=#{failed}, status=#{status.inspect}, keys=#{value.keys.inspect}, failed_keys=#{failed_keys.inspect}}"
      end

      def nested_result_status(result)
        return :failed if result.failed?
        return :pending if result.pending?

        :succeeded
      end

      def summarize_collection_nodes
        execution.cache.values.filter_map do |state|
          next unless state.value.is_a?(Runtime::CollectionResult)

          result = state.value
          {
            node_name: state.node.name,
            path: state.node.path,
            mode: result.mode,
            total: result.items.size,
            succeeded: result.successes.size,
            failed: result.failures.size,
            status: result.failures.empty? ? :succeeded : :partial_failure,
            failed_items: result.failures.values.map do |item|
              {
                key: item.key,
                type: item.error.class.name,
                message: item.error.message,
                context: item.error.respond_to?(:context) ? item.error.context : {}
              }
            end
          }
        end
      end

      def summarize_routing
        entries = execution.cache.values.filter_map do |state|
          routing_entry_for(state)
        end

        {
          total: entries.size,
          pending: entries.count { |entry| entry[:status] == :pending },
          failed: entries.count { |entry| entry[:status] == :failed },
          entries: entries
        }
      end

      def serialize_error(node_name, error)
        context = error.respond_to?(:context) ? error.context : {}
        routing_trace = extract_routing_trace(context)

        {
          node_name: node_name,
          type: error.class.name,
          message: error.message,
          context: context
        }.tap do |payload|
          next unless routing_trace

          payload[:routing_trace] = routing_trace
          payload[:routing_trace_summary] = summarize_routing_trace(routing_trace)
        end
      end

      def serialize_failed_output(error, status)
        context = error.respond_to?(:context) ? error.context : {}
        routing_trace = extract_routing_trace(context)

        {
          error: error.message,
          status: status
        }.tap do |payload|
          next unless routing_trace

          payload[:routing_trace] = routing_trace
          payload[:routing_trace_summary] = summarize_routing_trace(routing_trace)
        end
      end

      def serialize_deferred_result(value)
        value.as_json.tap do |payload|
          next unless value.routing_trace

          payload[:routing_trace] = value.routing_trace
          payload[:routing_trace_summary] = summarize_routing_trace(value.routing_trace)
        end
      end

      def format_error_summary(error)
        summary = "#{error[:node_name]}=#{error[:type]}"
        routing_summary = error[:routing_trace_summary]
        return summary unless routing_summary

        "#{summary}[#{routing_summary}]"
      end

      def routing_entry_for(state)
        if state.pending? && state.value.is_a?(Runtime::DeferredResult) && state.value.routing_trace
          return {
            node_name: state.node.name,
            path: state.node.path,
            status: :pending,
            token: state.value.token,
            waiting_on: state.value.waiting_on,
            source_node: state.value.source_node,
            routing_trace: state.value.routing_trace,
            routing_trace_summary: summarize_routing_trace(state.value.routing_trace)
          }
        end

        return unless state.failed?

        context = state.error.respond_to?(:context) ? state.error.context : {}
        routing_trace = extract_routing_trace(context)
        return unless routing_trace

        {
          node_name: state.node.name,
          path: state.node.path,
          status: :failed,
          error: {
            type: state.error.class.name,
            message: state.error.message
          },
          routing_trace: routing_trace,
          routing_trace_summary: summarize_routing_trace(routing_trace)
        }
      end

      def extract_routing_trace(context)
        return nil unless context.is_a?(Hash)

        hash_value(context, :routing_trace)
      end

      def summarize_routing_trace(trace)
        return nil unless trace.is_a?(Hash)

        parts = []
        routing_mode = hash_value(trace, :routing_mode)
        query = hash_value(trace, :query)
        capability = hash_value(trace, :capability)
        peer_name = hash_value(trace, :peer_name)
        eligible_count = hash_value(trace, :eligible_count)
        selected_url = hash_value(trace, :selected_url)
        reachable = hash_value(trace, :reachable)
        reasons = routing_reasons(trace)

        parts << "mode=#{routing_mode}" if routing_mode
        parts << "query=#{query.inspect}" if query
        parts << "capability=#{capability.inspect}" if capability
        parts << "peer=#{peer_name}" if peer_name
        parts << "eligible=#{eligible_count}" unless eligible_count.nil?
        parts << "selected=#{selected_url || 'none'}" if trace.key?(:selected_url) || trace.key?("selected_url")
        parts << "reachable=#{reachable}" unless reachable.nil?
        parts << "reasons=#{reasons.join('+')}" unless reasons.empty?
        parts.empty? ? nil : parts.join(" ")
      end

      def routing_reasons(trace)
        reasons = Array(hash_value(trace, :reasons)).compact
        return reasons unless reasons.empty?

        peers = hash_value(trace, :peers)
        return [] unless peers.is_a?(Array)

        peers.flat_map { |peer| Array(hash_value(peer, :reasons)) }.compact.uniq
      end

      def hash_value(hash, key)
        return hash[key] if hash.key?(key)
        return hash[key.to_s] if hash.key?(key.to_s)

        nil
      end
    end
  end
end
