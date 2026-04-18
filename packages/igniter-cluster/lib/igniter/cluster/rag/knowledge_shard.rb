# frozen_string_literal: true

module Igniter
  module Cluster
    module RAG
      # Thread-safe, in-memory knowledge shard.
      #
      # A shard is a named collection of content-addressed Chunks.
      # Adding the same content twice is idempotent (same id → same slot).
      #
      # Keyword search algorithm:
      #   1. Tokenize query into words (≥ 2 chars, alphanumeric).
      #   2. Count how many query words appear anywhere in chunk.content.
      #   3. text_score = hits / total_query_words.
      #   4. tag_bonus  = 0.1 × (tags in query that appear on chunk).
      #   5. raw_score  = text_score + tag_bonus   (capped at 1.0).
      #
      # Entry points:
      #   shard = KnowledgeShard.new(name: "node-a")
      #   chunk = shard.add("Ruby closures bind their env at creation time", tags: [:ruby])
      #   results = shard.search("how do closures work in Ruby", limit: 5)
      #   Igniter::Cluster::Mesh.shard.search("...")   # via Mesh entry point
      class KnowledgeShard
        attr_reader :name

        def initialize(name: "local")
          @name   = name.to_s.freeze
          @chunks = {}
          @mutex  = Mutex.new
        end

        # Add content to the shard and return the resulting Chunk.
        # Adding identical content is idempotent.
        #
        # @param content  [String]
        # @param tags     [Array<Symbol, String>]
        # @param metadata [Hash]
        # @return [Chunk]
        def add(content, tags: [], metadata: {})
          chunk = Chunk.build(content.to_s, tags: tags, metadata: metadata)
          @mutex.synchronize { @chunks[chunk.id] = chunk }
          chunk
        end

        # Retrieve a chunk by its content-addressed id.
        #
        # @return [Chunk, nil]
        def get(id)
          @mutex.synchronize { @chunks[id.to_s] }
        end

        # Remove a chunk by id.
        #
        # @return [Chunk, nil] the removed chunk, or nil if not found
        def remove(id)
          @mutex.synchronize { @chunks.delete(id.to_s) }
        end

        # All chunks in insertion order (thread-safe snapshot).
        #
        # @return [Array<Chunk>]
        def all
          @mutex.synchronize { @chunks.values.dup }
        end

        def size
          @mutex.synchronize { @chunks.size }
        end

        def empty?
          size.zero?
        end

        def clear
          @mutex.synchronize { @chunks.clear }
          self
        end

        # Keyword search over all chunks in this shard.
        #
        # @param query_or_text [RetrievalQuery, String]
        # @param tags          [Array<Symbol>]  (used only when query_or_text is a String)
        # @param limit         [Integer]
        # @param min_score     [Float]
        # @return [Array<RetrievalResult>]
        def search(query_or_text, tags: [], limit: 10, min_score: 0.0)
          query = coerce_query(query_or_text, tags: tags, limit: limit, min_score: min_score)
          return [] if query.text.strip.empty? && query.tags.empty?

          chunks = @mutex.synchronize { @chunks.values.dup }
          chunks = filter_by_tags(chunks, query.tags) if query.tags.any?

          scored = chunks
            .map    { |c| [c, compute_score(c, query)] }
            .select { |_, s| s >= query.min_score }
            .sort_by { |_, s| -s }
            .first(query.limit)

          scored.map { |chunk, s| RetrievalResult.new(chunk: chunk, score: s, source: @name) }
        end

        private

        def coerce_query(query_or_text, tags:, limit:, min_score:)
          return query_or_text if query_or_text.is_a?(RetrievalQuery)

          RetrievalQuery.new(
            text:      query_or_text.to_s,
            tags:      tags,
            limit:     limit,
            min_score: min_score
          )
        end

        def filter_by_tags(chunks, tags)
          chunks.select { |c| tags.all? { |t| c.tag?(t) } }
        end

        def compute_score(chunk, query)
          return 0.0 if query.text.strip.empty?

          words = tokenize(query.text)
          return 0.0 if words.empty?

          content_lower = chunk.content.downcase
          hits = words.count { |w| content_lower.include?(w) }
          text_score = hits.to_f / words.size

          tag_bonus = query.tags.count { |t| chunk.tag?(t) } * 0.1

          [text_score + tag_bonus, 1.0].min.round(6)
        end

        def tokenize(text)
          text.downcase.scan(/[a-z0-9]+/).uniq.select { |w| w.size >= 2 }
        end
      end
    end
  end
end
