# frozen_string_literal: true

module Igniter
  module Dataflow
    # Built-in operator strategies for AggregateNode.
    #
    # Each operator is an Operator struct with:
    #   initial_fn  – Proc returning a fresh initial accumulator value
    #   project     – Proc(item) → contribution  (what the item "contributes")
    #   add         – Proc(acc, contribution) → new_acc  (nil when recompute: true)
    #   remove      – Proc(acc, contribution) → new_acc  (nil when recompute: true)
    #   finalize    – Proc(acc, contributions_or_count) → public value
    #   recompute   – Boolean: when true, finalize receives the full @contributions Hash
    #                 instead of @accum (used for min/max which aren't O(1)-retractable)
    #
    # == Built-ins
    #
    #   count(filter: nil)       — total items, optionally filtered
    #   sum(projection:)         — sum a numeric value extracted per item
    #   avg(projection:)         — running arithmetic mean
    #   min(projection:)         — current minimum (O(n) on retraction)
    #   max(projection:)         — current maximum (O(n) on retraction)
    #   group_count(projection:) — {group_key => item_count}
    #   custom(initial:, add:, remove:) — user-supplied retractable logic
    #
    module AggregateOperators
      # Internal struct. Fields are callables (Proc) or primitives.
      Operator = Struct.new(
        :initial_fn, :project, :add, :remove, :finalize, :recompute,
        keyword_init: true
      ) do
        # Returns a fresh initial accumulator for a new AggregateState.
        def initial
          initial_fn.call
        end
      end

      # Count items, optionally filtered by a predicate.
      #
      # @param filter [Proc, nil]  ->(item) { true/false }; nil = count all
      def self.count(filter: nil)
        Operator.new(
          initial_fn: -> { 0 },
          project: ->(item) { filter.nil? || filter.call(item) ? 1 : 0 },
          add: ->(acc, v) { acc + v },
          remove: ->(acc, v) { acc - v },
          finalize: ->(acc, _) { acc },
          recompute: false
        )
      end

      # Sum a numeric value extracted from each item.
      #
      # @param projection [Proc]  ->(item) { item.result.value.to_f }
      def self.sum(projection:)
        Operator.new(
          initial_fn: -> { 0 },
          project: ->(item) { projection.call(item).to_f },
          add: ->(acc, v) { acc + v },
          remove: ->(acc, v) { acc - v },
          finalize: ->(acc, _) { acc },
          recompute: false
        )
      end

      # Running arithmetic mean.
      #
      # @param projection [Proc]  ->(item) { numeric }
      def self.avg(projection:) # rubocop:disable Metrics/AbcSize
        Operator.new(
          initial_fn: -> { { sum: 0.0, count: 0 } },
          project: ->(item) { projection.call(item).to_f },
          add: ->(acc, v) { { sum: acc[:sum] + v, count: acc[:count] + 1 } },
          remove: ->(acc, v) { { sum: acc[:sum] - v, count: acc[:count] - 1 } },
          finalize: ->(acc, _) { acc[:count].zero? ? 0.0 : acc[:sum] / acc[:count] },
          recompute: false
        )
      end

      # Current minimum (O(n) rescan on item removal — n = window size).
      #
      # @param projection [Proc]  ->(item) { numeric }
      def self.min(projection:)
        Operator.new(
          initial_fn: -> { nil },
          project: ->(item) { projection.call(item) },
          add: nil,
          remove: nil,
          finalize: ->(_acc, contribs) { contribs.values.min },
          recompute: true
        )
      end

      # Current maximum (O(n) rescan on item removal — n = window size).
      #
      # @param projection [Proc]  ->(item) { numeric }
      def self.max(projection:)
        Operator.new(
          initial_fn: -> { nil },
          project: ->(item) { projection.call(item) },
          add: nil,
          remove: nil,
          finalize: ->(_acc, contribs) { contribs.values.max },
          recompute: true
        )
      end

      # Group items by a key and count members per group.
      # Returns a Hash {group_key => count}.
      #
      # @param projection [Proc]  ->(item) { group_key }
      def self.group_count(projection:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        remove_fn = lambda do |acc, gk|
          count = (acc[gk] || 1) - 1
          count <= 0 ? acc.reject { |k, _| k == gk } : acc.merge(gk => count)
        end
        Operator.new(
          initial_fn: -> { {} },
          project: ->(item) { projection.call(item) },
          add: ->(acc, gk) { acc.merge(gk => (acc[gk] || 0) + 1) },
          remove: remove_fn,
          finalize: ->(acc, _) { acc },
          recompute: false
        )
      end

      # Custom retractable aggregate with user-supplied logic.
      #
      # Both +add+ and +remove+ receive the full CollectionResult::Item so that
      # users can reference +item.result.field+ in both lambdas.
      #
      # @param initial [Object]  initial accumulator value (cloned on each new Execution)
      # @param add     [Proc]    ->(acc, item) { new_acc }
      # @param remove  [Proc]    ->(acc, item) { new_acc }
      def self.custom(initial:, add:, remove:)
        Operator.new(
          initial_fn: -> { initial },
          project: ->(item) { item },
          add: ->(acc, item) { add.call(acc, item) },
          remove: ->(acc, item) { remove.call(acc, item) },
          finalize: ->(acc, _) { acc },
          recompute: false
        )
      end
    end
  end
end
