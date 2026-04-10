# frozen_string_literal: true

module Igniter
  module Incremental
    # Structured result of a resolve_incrementally call.
    #
    # Attributes:
    #   changed_nodes   — node names whose value_version increased (value actually changed)
    #   skipped_nodes   — node names that were stale but memoized (deps unchanged, compute skipped)
    #   backdated_nodes — node names that recomputed but produced the same value
    #   changed_outputs — Hash{ Symbol => { from: old_value, to: new_value } }
    #   recomputed_count — total number of compute calls actually executed
    class Result
      attr_reader :changed_nodes, :skipped_nodes, :backdated_nodes,
                  :changed_outputs, :recomputed_count

      def initialize(changed_nodes:, skipped_nodes:, backdated_nodes:,
                     changed_outputs:, recomputed_count:)
        @changed_nodes = changed_nodes.freeze
        @skipped_nodes = skipped_nodes.freeze
        @backdated_nodes = backdated_nodes.freeze
        @changed_outputs = changed_outputs.freeze
        @recomputed_count = recomputed_count
        freeze
      end

      # True when at least one output value changed.
      def outputs_changed?
        changed_outputs.any?
      end

      # True when every stale node was memoized — nothing actually ran.
      def fully_memoized?
        recomputed_count.zero?
      end

      # One-line summary for logging.
      def summary # rubocop:disable Metrics/AbcSize
        parts = []
        parts << "#{changed_nodes.size} node(s) changed" if changed_nodes.any?
        parts << "#{skipped_nodes.size} skipped (memoized)" if skipped_nodes.any?
        parts << "#{backdated_nodes.size} backdated (same value)" if backdated_nodes.any?
        parts << "#{recomputed_count} recomputed"
        parts.join(", ")
      end

      # Human-readable ASCII report.
      def explain
        Formatter.format(self)
      end

      alias to_s explain

      def to_h # rubocop:disable Metrics/MethodLength
        {
          changed_nodes: changed_nodes,
          skipped_nodes: skipped_nodes,
          backdated_nodes: backdated_nodes,
          changed_outputs: changed_outputs.transform_values do |diff|
            { from: diff[:from], to: diff[:to] }
          end,
          recomputed_count: recomputed_count,
          outputs_changed: outputs_changed?,
          fully_memoized: fully_memoized?
        }
      end
    end
  end
end
