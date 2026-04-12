# frozen_string_literal: true

module Igniter
  module Incremental
    # Subscribes to execution events and records which nodes were changed,
    # skipped (memoized), or backdated during an incremental resolve pass.
    #
    # Takes a pre-snapshot of value_versions before the resolve pass and compares
    # after to detect what changed, rather than relying on event payloads alone.
    class Tracker
      def initialize(execution)
        @execution = execution
        @skipped_nodes = []
        @backdated_nodes = []
        @recomputed_nodes = []
        @pre_node_vv = {}
        @pre_output_values = {}
      end

      def start!
        snapshot_pre_state!
        @execution.events.subscribe(self)
      end

      # Called by Events::Bus for every event.
      def call(event)
        case event.type
        when :node_skipped
          @skipped_nodes << event.node_name
        when :node_backdated
          @backdated_nodes << event.node_name
        when :node_succeeded
          kind = fetch_node_kind(event.node_name)
          @recomputed_nodes << event.node_name if %i[compute effect].include?(kind)
        end
      end

      def build_result # rubocop:disable Metrics/MethodLength
        # Deduplicate (events may fire multiple times across execution passes)
        skipped   = @skipped_nodes.uniq
        backdated = @backdated_nodes.uniq
        # recomputed = node_succeeded minus skipped (skipped also fires node_succeeded)
        recomputed = @recomputed_nodes.uniq - skipped

        changed = detect_changed_nodes
        changed_outputs = detect_changed_outputs

        Result.new(
          changed_nodes: changed,
          skipped_nodes: skipped,
          backdated_nodes: backdated,
          changed_outputs: changed_outputs,
          recomputed_count: recomputed.size
        )
      end

      private

      def snapshot_pre_state! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @execution.compiled_graph.nodes.each do |node|
          state = @execution.cache.fetch(node.name)
          @pre_node_vv[node.name] = state&.value_version
        end

        @execution.compiled_graph.outputs.each do |output_node|
          src_state = @execution.cache.fetch(output_node.source_root)
          @pre_output_values[output_node.name] = {
            value: src_state&.value,
            value_version: src_state&.value_version
          }
        end
      end

      def detect_changed_nodes
        @execution.compiled_graph.nodes.each_with_object([]) do |node, memo|
          pre_vv = @pre_node_vv[node.name]
          current_vv = @execution.cache.fetch(node.name)&.value_version
          # Changed = value_version advanced AND it's a compute/effect node
          next unless %i[compute effect].include?(node.kind)
          next unless current_vv && current_vv != pre_vv

          memo << node.name
        end
      end

      def detect_changed_outputs
        @execution.compiled_graph.outputs.each_with_object({}) do |output_node, memo|
          pre = @pre_output_values[output_node.name]
          next unless pre

          src_state = @execution.cache.fetch(output_node.source_root)
          current_vv = src_state&.value_version

          next if pre[:value_version] == current_vv

          memo[output_node.name] = { from: pre[:value], to: src_state&.value }
        end
      end

      def fetch_node_kind(node_name)
        return nil unless node_name
        return nil unless @execution.compiled_graph.node?(node_name)

        @execution.compiled_graph.fetch_node(node_name).kind
      end
    end
  end
end
