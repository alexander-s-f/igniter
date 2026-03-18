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
    end
  end
end
