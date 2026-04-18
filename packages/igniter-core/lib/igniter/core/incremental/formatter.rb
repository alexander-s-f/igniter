# frozen_string_literal: true

module Igniter
  module Incremental
    # Renders an Incremental::Result as a human-readable text block.
    #
    # Example output:
    #
    #   Incremental Execution Report
    #   ─────────────────────────────────────────
    #   Recomputed:  1 node(s)
    #   Skipped:     2 node(s)  (deps unchanged)
    #   Backdated:   0 node(s)  (value unchanged)
    #
    #   CHANGED OUTPUTS (1):
    #     :converted_price  1.05 → 1.12
    #
    #   SKIPPED NODES (memoized):
    #     :tier_discount  :adjusted_price
    #
    module Formatter
      VALUE_MAX = 60
      LINE = "─" * 42

      class << self
        def format(result) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          lines = []
          lines << "Incremental Execution Report"
          lines << LINE
          lines << "Recomputed:  #{result.recomputed_count} node(s)"
          lines << "Skipped:     #{result.skipped_nodes.size} node(s)  (deps unchanged)"
          lines << "Backdated:   #{result.backdated_nodes.size} node(s)  (value unchanged)"
          lines << ""

          if result.changed_outputs.any?
            lines << "CHANGED OUTPUTS (#{result.changed_outputs.size}):"
            result.changed_outputs.each do |name, diff|
              lines << "  :#{name}  #{fmt(diff[:from])} → #{fmt(diff[:to])}"
            end
          else
            lines << "No output values changed."
          end
          lines << ""

          if result.skipped_nodes.any?
            lines << "SKIPPED (memoized, #{result.skipped_nodes.size}):"
            lines << "  #{result.skipped_nodes.map { |n| ":#{n}" }.join("  ")}"
            lines << ""
          end

          if result.backdated_nodes.any?
            lines << "BACKDATED (recomputed → same value, #{result.backdated_nodes.size}):"
            lines << "  #{result.backdated_nodes.map { |n| ":#{n}" }.join("  ")}"
            lines << ""
          end

          if result.changed_nodes.any?
            lines << "CHANGED (#{result.changed_nodes.size}):"
            lines << "  #{result.changed_nodes.map { |n| ":#{n}" }.join("  ")}"
          end

          lines.join("\n")
        end

        private

        def fmt(value) # rubocop:disable Metrics/CyclomaticComplexity
          str = case value
                when nil    then "nil"
                when String then value.inspect
                when Symbol then value.inspect
                when Hash   then "{#{value.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}}"
                when Array  then "[#{value.map(&:inspect).join(", ")}]"
                else             value.inspect
                end
          str.length > VALUE_MAX ? "#{str[0, VALUE_MAX - 3]}..." : str
        end
      end
    end
  end
end
