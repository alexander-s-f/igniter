# frozen_string_literal: true

module Igniter
  module Dataflow
    # A CollectionResult that carries a Diff describing what changed in the last resolve.
    #
    # Inherits all CollectionResult behaviour (successes, failures, summary, to_h, etc.)
    # and adds:
    #
    #   result.diff          → Igniter::Dataflow::Diff
    #   result.diff.added    → keys added in the last update
    #   result.diff.removed  → keys removed in the last update
    #   result.diff.changed  → keys whose item content changed
    #   result.diff.unchanged → keys that were identical — no child contract was re-run
    #
    class IncrementalCollectionResult < Runtime::CollectionResult
      attr_reader :diff

      def initialize(items:, diff:)
        super(items: items, mode: :incremental)
        @diff = diff
      end

      # Extends the base summary with incremental diff counters.
      def summary
        super.merge(
          added: diff.added.size,
          removed: diff.removed.size,
          changed: diff.changed.size,
          unchanged: diff.unchanged.size
        )
      end

      def as_json(*)
        super.merge(diff: diff.to_h)
      end
    end
  end
end
