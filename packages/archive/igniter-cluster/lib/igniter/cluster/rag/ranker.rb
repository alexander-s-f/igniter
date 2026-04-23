# frozen_string_literal: true

module Igniter
  module Cluster
    module RAG
      # Merges and re-ranks RetrievalResult collections from multiple shards.
      #
      # Ranking is by composite_score, which weights raw text relevance by the
      # source peer's trust status and observation confidence. This means a
      # result from a trusted, high-confidence peer will beat an equally-
      # relevant result from an unknown peer.
      #
      # Deduplication is id-based: when the same Chunk id appears in multiple
      # shards, the highest-composite-score copy is kept.
      #
      # Entry point:
      #   ranker = Ranker.new
      #   merged = ranker.merge(local_results, remote_results_a, remote_results_b, limit: 10)
      class Ranker
        # Merge one or more RetrievalResult arrays into a single ranked list.
        #
        # @param result_arrays [Array<Array<RetrievalResult>>]
        # @param limit         [Integer, nil]   max results; nil = no cap
        # @param deduplicate   [Boolean]        remove duplicate chunk ids
        # @return [Array<RetrievalResult>]
        def merge(*result_arrays, limit: nil, deduplicate: true)
          all    = result_arrays.flatten
          all    = deduplicate(all) if deduplicate
          sorted = all.sort_by { |r| -r.composite_score }
          limit ? sorted.first(limit) : sorted
        end

        private

        def deduplicate(results)
          best = {}
          results.each do |r|
            existing = best[r.id]
            best[r.id] = r if existing.nil? || r.composite_score > existing.composite_score
          end
          best.values
        end
      end
    end
  end
end
