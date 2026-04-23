# frozen_string_literal: true

module Igniter
  module Dataflow
    # Mutable state for an incremental collection node.
    #
    # Stores fingerprints of previous items and their resolved CollectionResult::Items
    # so the resolver can skip unchanged items on subsequent updates.
    #
    # One DiffState instance lives on the Execution (keyed by node name) and persists
    # across update_inputs calls for the lifetime of the contract execution.
    class DiffState
      attr_reader :cached_items

      def initialize
        @snapshots    = {}  # key => fingerprint string
        @cached_items = {}  # key => Runtime::CollectionResult::Item
      end

      # Compute a Diff between the current normalized items and the previous state.
      #
      # @param current_items [Array<Hash>] normalized item input hashes
      # @param key_fn        [Proc]        extracts the item key from an item hash
      # @return [Diff]
      def compute_diff(current_items, key_fn)
        current_keys = current_items.to_h { |i| [key_fn.call(i), i] }
        added, changed, unchanged = partition_items(current_items, key_fn)
        removed = @snapshots.keys.reject { |k| current_keys.key?(k) }
        build_diff(added, removed, changed, unchanged, key_fn)
      end

      # Record a resolved item (after running its child contract).
      def update!(key, item_inputs, collection_result_item)
        @snapshots[key]    = fingerprint(item_inputs)
        @cached_items[key] = collection_result_item
      end

      # Remove a previously tracked item (on removal from the input).
      def retract!(key)
        @snapshots.delete(key)
        @cached_items.delete(key)
      end

      # Returns the cached CollectionResult::Item for a key, or nil.
      def cached_item_for(key)
        @cached_items[key]
      end

      private

      def partition_items(items, key_fn)
        items.each_with_object([[], [], []]) do |item, (added, changed, unchanged)|
          k = key_fn.call(item)
          if !@snapshots.key?(k)
            added << item
          elsif @snapshots[k] != fingerprint(item)
            changed << item
          else
            unchanged << item
          end
        end
      end

      def build_diff(added, removed, changed, unchanged, key_fn)
        Diff.new(
          added: added.map { |i| key_fn.call(i) },
          removed: removed,
          changed: changed.map { |i| key_fn.call(i) },
          unchanged: unchanged.map { |i| key_fn.call(i) }
        )
      end

      # Stable fingerprint for change detection — order-independent for Hash items.
      def fingerprint(item)
        return item.hash.to_s unless item.is_a?(Hash)

        item.sort_by { |k, _| k.to_s }.map { |k, v| "#{k}:#{v.inspect}" }.hash.to_s
      end
    end
  end
end
