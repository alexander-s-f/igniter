# frozen_string_literal: true

module Igniter
  module Extensions
    module Introspection
      class PlanFormatter
        def self.to_text(execution, output_names = nil)
          new(execution, output_names).to_text
        end

        def initialize(execution, output_names = nil)
          @execution = execution
          @plan = execution.plan(output_names)
        end

        def to_text
          lines = []
          lines << "Plan #{@execution.compiled_graph.name}"
          lines << "Targets: #{format_list(@plan[:targets])}"
          lines << "Ready: #{format_list(@plan[:ready])}"
          lines << "Blocked: #{format_list(@plan[:blocked])}"
          if @plan[:agent_profiles] && @plan[:agent_profiles][:total].positive?
            lines << "Agents: total=#{@plan[:agent_profiles][:total]}, interactive=#{@plan[:agent_profiles][:interactive]}, manual=#{@plan[:agent_profiles][:manual]}, single_turn=#{@plan[:agent_profiles][:single_turn]}, streaming=#{@plan[:agent_profiles][:streaming]}, deferred=#{@plan[:agent_profiles][:deferred]}"
          end
          if @plan[:orchestration] && @plan[:orchestration][:total].positive?
            lines << "Orchestration: attention_required=#{@plan[:orchestration][:attention_required]}, resumable=#{@plan[:orchestration][:resumable]}, interactive_sessions=#{@plan[:orchestration][:interactive_sessions]}, manual_sessions=#{@plan[:orchestration][:manual_sessions]}, single_turn_sessions=#{@plan[:orchestration][:single_turn_sessions]}, deferred_calls=#{@plan[:orchestration][:deferred_calls]}, single_reply_calls=#{@plan[:orchestration][:single_reply_calls]}, delivery_only=#{@plan[:orchestration][:delivery_only]}"
            if @plan[:orchestration][:attention_nodes].any?
              lines << "Attention Nodes: #{format_list(@plan[:orchestration][:attention_nodes])}"
            end
            if @plan[:orchestration][:actions].any?
              lines << "Orchestration Actions: #{@plan[:orchestration][:actions].map { |action| "#{action[:node]}(#{action[:action]})" }.join(', ')}"
            end
          end
          lines << "Nodes:"

          @plan[:nodes].each_value do |entry|
            lines << format_node(entry)
          end

          lines.join("\n")
        end

        private

        def format_node(entry)
          line = "- #{entry[:kind]} #{entry[:path]} status=#{entry[:status]}"
          line += " ready=true" if entry[:ready]
          line += " blocked=true" if entry[:blocked]
          line += " waiting_on=#{format_list(entry[:waiting_on])}" if entry[:waiting_on].any?
          if entry[:kind] == :agent
            line += " via=#{entry[:via].inspect}"
            line += " message=#{entry[:message].inspect}"
            line += " mode=#{entry[:mode]}"
            line += " reply=#{entry[:reply_mode]}"
            line += " session_policy=#{entry[:session_policy]}" if entry[:session_policy]
            line += " tool_loop_policy=#{entry[:tool_loop_policy]}" if entry[:tool_loop_policy]
            line += " finalizer=#{entry[:finalizer].inspect}" if entry[:finalizer]
            if entry[:orchestration]
              line += " orchestration=#{entry[:orchestration][:interaction]}"
              line += " guidance=#{entry[:orchestration][:guidance].inspect}"
              line += " attention_required=true" if entry[:orchestration][:attention_required]
              line += " resumable=true" if entry[:orchestration][:resumable]
              line += " allows_continuation=true" if entry[:orchestration][:allows_continuation]
              line += " requires_explicit_completion=true" if entry[:orchestration][:requires_explicit_completion]
              line += " auto_finalization=#{entry[:orchestration][:auto_finalization]}"
            end
          end

          dependency_summary = entry[:dependencies].map do |dependency|
            "#{dependency[:name]}(#{dependency[:status]})"
          end
          line += " deps=#{dependency_summary.join(',')}" if dependency_summary.any?
          line
        end

        def format_list(values)
          array = Array(values)
          return "none" if array.empty?

          array.join(",")
        end
      end
    end
  end
end
