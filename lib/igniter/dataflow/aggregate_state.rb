# frozen_string_literal: true

module Igniter
  module Dataflow
    # Mutable state for a maintained aggregate node.
    #
    # Stores per-item contributions so that the aggregate can be updated
    # incrementally using only the diff (added/changed/removed) from the upstream
    # incremental collection — not the full item set.
    #
    # One AggregateState instance lives on the Execution (keyed by node name) and
    # persists across update_inputs calls for the lifetime of the contract execution.
    #
    # == Update semantics
    #
    #   added   → contribute! (project + add into @accum)
    #   removed → retract!    (subtract from @accum using stored contribution)
    #   changed → retract!(old) then contribute!(new) — true differential update
    #   unchanged → no-op
    #
    class AggregateState
      def initialize(operator)
        @operator      = operator
        @contributions = {} # key => contribution (what the item "contributes")
        @accum         = operator.initial
      end

      # Apply a diff from an IncrementalCollectionResult, updating the aggregate
      # state in O(changed + added + removed) time.
      #
      # @param diff              [Igniter::Dataflow::Diff]
      # @param collection_result [Igniter::Dataflow::IncrementalCollectionResult]
      def apply_diff!(diff, collection_result)
        diff.changed.each do |key|
          retract!(key)
          contribute!(key, collection_result[key])
        end
        diff.added.each   { |key| contribute!(key, collection_result[key]) }
        diff.removed.each { |key| retract!(key) }
      end

      # Current aggregate value (finalized from accumulated state).
      def value
        if @operator.recompute
          @operator.finalize.call(nil, @contributions)
        else
          @operator.finalize.call(@accum, @contributions.size)
        end
      end

      # Number of items currently tracked in the aggregate.
      def item_count
        @contributions.size
      end

      private

      def contribute!(key, item)
        contribution = @operator.project.call(item)
        return if contribution.nil?

        @contributions[key] = contribution
        return if @operator.recompute

        @accum = @operator.add.call(@accum, contribution)
      end

      def retract!(key)
        old_contribution = @contributions.delete(key)
        return unless old_contribution
        return if @operator.recompute

        @accum = @operator.remove.call(@accum, old_contribution)
      end
    end
  end
end
