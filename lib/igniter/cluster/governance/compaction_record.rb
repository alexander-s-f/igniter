# frozen_string_literal: true

module Igniter
  module Cluster
    module Governance
      # Typed result of Trail#compact!.
      #
      # Describes what happened during a compaction: how many events were
      # removed, how many were kept, and the signed Checkpoint built over
      # the crest at compaction time (when an identity was provided).
      CompactionRecord = Data.define(:checkpoint, :removed_events, :kept_events, :checkpoint_digest) do
        # True when events were actually removed.
        def compacted?
          removed_events > 0
        end

        # True when a signed Checkpoint was built alongside the compaction.
        def signed?
          !checkpoint.nil?
        end

        def to_h
          {
            compacted:         compacted?,
            removed_events:    removed_events,
            kept_events:       kept_events,
            checkpoint_digest: checkpoint_digest
          }
        end
      end
    end
  end
end
