# frozen_string_literal: true

module Igniter
  module Cluster
    module RAG
      # Typed specification for a knowledge retrieval request.
      #
      # Accepted by KnowledgeShard#search and Mesh.retrieve.
      class RetrievalQuery
        attr_reader :text, :tags, :limit, :min_score

        # @param text      [String]           free-text query
        # @param tags      [Array<Symbol>]    restrict to chunks that have ALL of these tags
        # @param limit     [Integer]          max results to return
        # @param min_score [Float]            minimum text relevance score (0..1)
        def initialize(text:, tags: [], limit: 10, min_score: 0.0)
          @text      = text.to_s.freeze
          @tags      = Array(tags).map(&:to_sym).freeze
          @limit     = [limit.to_i, 1].max
          @min_score = [min_score.to_f, 0.0].max
          freeze
        end

        def to_h
          { text: @text, tags: @tags, limit: @limit, min_score: @min_score }
        end
      end
    end
  end
end
