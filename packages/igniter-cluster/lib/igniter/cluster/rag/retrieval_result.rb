# frozen_string_literal: true

module Igniter
  module Cluster
    module RAG
      # A single result returned by KnowledgeShard#search or the Ranker.
      #
      # Carries the matched Chunk together with retrieval provenance:
      # text relevance score, source shard name, and (optionally) the
      # NodeObservation of the peer that holds the shard.
      #
      # composite_score weights the raw text score by the peer's trust
      # status and observation confidence — results from trusted, high-
      # confidence peers rank above equally-relevant but untrusted ones.
      class RetrievalResult
        attr_reader :chunk, :score, :source, :observation

        # @param chunk       [Chunk]            the matched knowledge unit
        # @param score       [Float]            raw text relevance score (0..1)
        # @param source      [String]           shard name / peer name
        # @param observation [NodeObservation, nil]  live peer snapshot (nil = local)
        def initialize(chunk:, score:, source:, observation: nil)
          @chunk       = chunk
          @score       = score.to_f
          @source      = source.to_s.freeze
          @observation = observation
          freeze
        end

        # Chunk attribute shortcuts
        def id;         @chunk.id; end
        def content;    @chunk.content; end
        def tags;       @chunk.tags; end
        def metadata;   @chunk.metadata; end
        def indexed_at; @chunk.indexed_at; end

        # Provenance accessors
        def trusted?
          @observation ? @observation.trusted? : true
        end

        def confidence
          @observation&.confidence || 1.0
        end

        # Composite score = raw_score × trust_factor × confidence
        #
        # trust_factor:
        #   trusted peer     → 1.00
        #   unknown peer     → 0.85
        #   untrusted peer   → 0.70
        def composite_score
          trust_factor = case @observation&.trust_status
                         when :trusted then 1.00
                         when nil      then 1.00  # local / no observation
                         else
                           @observation.trusted? ? 1.00 : 0.85
                         end
          (@score * trust_factor * confidence).round(6)
        end

        def to_h
          {
            id:              id,
            content:         content,
            score:           @score,
            composite_score: composite_score,
            source:          @source,
            tags:            tags,
            trusted:         trusted?,
            confidence:      confidence
          }
        end
      end
    end
  end
end
