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
          nodes: summarize_nodes,
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
        lines << format_outputs(report[:outputs])
        lines << format_nodes(report[:nodes])
        lines << format_errors(report[:errors])
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
        lines << "- Outputs: #{inline_hash(report[:outputs])}"
        lines << "- Nodes: total=#{report[:nodes][:total]}, succeeded=#{report[:nodes][:succeeded]}, failed=#{report[:nodes][:failed]}, stale=#{report[:nodes][:stale]}"
        lines << "- Events: total=#{report[:events][:total]}, latest=#{report[:events][:latest_type] || 'none'}"

        unless report[:errors].empty?
          lines << ""
          lines << "## Errors"
          report[:errors].each do |error|
            lines << "- `#{error[:node_name]}`: #{error[:message]}"
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
        return :stale if execution.cache.values.any?(&:stale?)

        :succeeded
      end

      def serialize_errors
        execution.cache.values.filter_map do |state|
          next unless state.failed?

          {
            node_name: state.node.name,
            type: state.error.class.name,
            message: state.error.message,
            context: state.error.respond_to?(:context) ? state.error.context : {}
          }
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
        return { error: state.error.message, status: state.status } if state.failed?

        if output_node.composition_output?
          return serialize_output_from_child(output_node, state.value)
        end

        serialize_value(state.value)
      end

      def serialize_output_from_child(output_node, child_result)
        return nil unless child_result.is_a?(Runtime::Result)

        child_errors = child_result.execution.cache.values.select(&:failed?)
        return { error: child_errors.first.error.message, status: :failed } unless child_errors.empty?

        child_result.public_send(output_node.child_output_name)
      end

      def summarize_nodes
        states = execution.states

        {
          total: states.size,
          succeeded: states.values.count { |state| state[:status] == :succeeded },
          failed: states.values.count { |state| state[:status] == :failed },
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

      def format_nodes(nodes)
        line = "Nodes: total=#{nodes[:total]}, succeeded=#{nodes[:succeeded]}, failed=#{nodes[:failed]}, stale=#{nodes[:stale]}"
        return line if nodes[:failed_nodes].empty?

        failures = nodes[:failed_nodes].map { |node| "#{node[:node_name]}(#{node[:error]})" }.join(", ")
        "#{line}\nFailed Nodes: #{failures}"
      end

      def format_errors(errors)
        return "Errors: none" if errors.empty?

        "Errors: #{errors.map { |error| "#{error[:node_name]}=#{error[:type]}" }.join(', ')}"
      end

      def format_events(events)
        "Events: total=#{events[:total]}, latest=#{events[:latest_type] || 'none'}"
      end

      def inline_hash(hash)
        hash.map { |key, value| "#{key}=#{value.inspect}" }.join(", ")
      end

      def serialize_value(value)
        case value
        when Runtime::Result
          value.to_h
        when Array
          value.map { |item| serialize_value(item) }
        else
          value
        end
      end
    end
  end
end
