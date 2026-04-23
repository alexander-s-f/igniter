# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/dataflow", replacement: "a contracts pack that registers incremental collection node kinds and runtime handlers")
require "igniter"
require "igniter/core/dataflow"

# Activates incremental dataflow support for all contracts.
#
# After requiring this file:
#
#   - `collection` DSL accepts `mode: :incremental` and `window:` options.
#   - Contracts gain `#feed_diff` — push event-style diffs instead of full arrays.
#   - Contracts gain `#collection_diff` — inspect what changed after the last resolve.
#
# == Usage
#
#   require "igniter/extensions/dataflow"
#
#   class SensorPipeline < Igniter::Contract
#     define do
#       input :readings, type: :array
#
#       collection :processed,
#                  with: :readings,
#                  each: SensorContract,
#                  key: :sensor_id,
#                  mode: :incremental,
#                  window: { last: 500 }
#
#       output :processed
#     end
#   end
#
#   contract = SensorPipeline.new(readings: initial_readings)
#   contract.resolve_all
#
#   # Push new events without replacing the full array
#   contract.feed_diff(:readings, add: [new_reading], remove: [:sensor_old])
#   contract.resolve_all
#
#   # Inspect what changed
#   diff = contract.collection_diff(:processed)
#   diff.added     # => [:sensor_42]
#   diff.removed   # => [:sensor_old]
#   diff.changed   # => []
#   diff.unchanged # => [:sensor_1, :sensor_2, ...]
#
module Igniter
  module Extensions
    module Dataflow
      module InstanceMethods
        # Push a diff to a collection input without replacing the full array.
        #
        # Automatically finds the incremental collection node that uses +input_name+
        # as its source dependency, uses its key_name to merge the diff into the
        # current input array, then calls update_inputs.
        #
        # @param input_name [Symbol, String]  the contract input holding the collection
        # @param add        [Array<Hash>]     new items to append
        # @param remove     [Array]           keys or Hash items to remove (matched by key_name)
        # @param update     [Array<Hash>]     updated versions of existing items (replace by key)
        # @return [self]
        #
        # @raise [ArgumentError] if no incremental collection node uses the given input
        def feed_diff(input_name, add: [], remove: [], update: [])
          sym      = input_name.to_sym
          key_name = _incremental_node_for(sym).key_name
          current  = execution.inputs[sym].dup || []
          items    = _apply_diff(current, key_name, add: add, remove: remove, update: update)
          execution.update_inputs(sym => items)
          self
        end

        # Returns the Diff from the last resolve for a named collection node.
        #
        # @param collection_name [Symbol, String]  the collection node name
        # @return [Igniter::Dataflow::Diff, nil]  nil if not yet resolved or not incremental
        def collection_diff(collection_name)
          state = execution.cache.fetch(collection_name.to_sym)
          value = state&.value
          value.respond_to?(:diff) ? value.diff : nil
        end

        private

        def _apply_diff(items, key_name, add:, remove:, update:)
          remove_keys = Array(remove).map { |e| e.is_a?(Hash) ? e.fetch(key_name) : e }.to_set
          result = items.reject { |item| remove_keys.include?(item.fetch(key_name)) }
          _apply_updates(result, key_name, update)
          result.concat(Array(add))
        end

        def _apply_updates(items, key_name, updates)
          Array(updates).each do |updated|
            k   = updated.fetch(key_name)
            idx = items.index { |item| item.fetch(key_name) == k }
            idx ? items[idx] = updated : items << updated
          end
        end

        def _incremental_node_for(input_name)
          node = execution.compiled_graph.nodes.find do |n|
            n.kind == :collection &&
              n.mode == :incremental &&
              n.source_dependency == input_name
          end
          return node if node

          raise ArgumentError,
                "No incremental collection node found for input '#{input_name}'. " \
                "Ensure the collection is declared with mode: :incremental."
        end
      end
    end
  end
end

Igniter::Contract.include(Igniter::Extensions::Dataflow::InstanceMethods)
