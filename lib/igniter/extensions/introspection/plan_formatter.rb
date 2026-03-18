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
