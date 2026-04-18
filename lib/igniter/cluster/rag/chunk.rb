# frozen_string_literal: true

require "digest"

module Igniter
  module Cluster
    module RAG
      # A content-addressed unit of knowledge stored in a KnowledgeShard.
      #
      # The id is derived from the first 16 hex digits of SHA256(content),
      # making adds idempotent: storing the same text twice yields the same id.
      #
      # Chunk is a frozen value object — use KnowledgeShard to build and store chunks.
      Chunk = Data.define(:id, :content, :tags, :metadata, :indexed_at) do
        # Build a Chunk from raw content. Computes the content-addressed id.
        #
        # @param content    [String]
        # @param tags       [Array<Symbol, String>]
        # @param metadata   [Hash]
        # @param indexed_at [Time]
        # @return [Chunk]
        def self.build(content, tags: [], metadata: {}, indexed_at: Time.now.utc)
          text = content.to_s
          new(
            id:         Digest::SHA256.hexdigest(text)[0, 16],
            content:    text.freeze,
            tags:       Array(tags).map(&:to_sym).freeze,
            metadata:   Hash(metadata).freeze,
            indexed_at: indexed_at
          )
        end

        def tag?(tag)
          tags.include?(tag.to_sym)
        end

        def to_h
          {
            id:         id,
            content:    content,
            tags:       tags,
            metadata:   metadata,
            indexed_at: indexed_at.iso8601
          }
        end
      end
    end
  end
end
