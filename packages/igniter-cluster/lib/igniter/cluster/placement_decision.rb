# frozen_string_literal: true

module Igniter
  module Cluster
    class PlacementDecision
      attr_reader :mode, :candidates, :metadata, :explanation

      def initialize(mode:, candidates:, metadata: {}, explanation: nil)
        @mode = mode.to_sym
        @candidates = Array(candidates).freeze
        @metadata = metadata.dup.freeze
        @explanation = DecisionExplanation.normalize(
          explanation,
          default_code: mode,
          metadata: @metadata
        )
        freeze
      end

      def candidate_names
        candidates.map(&:name)
      end

      def to_h
        {
          mode: mode,
          candidates: candidate_names,
          metadata: metadata.dup,
          explanation: explanation&.to_h
        }
      end
    end
  end
end
