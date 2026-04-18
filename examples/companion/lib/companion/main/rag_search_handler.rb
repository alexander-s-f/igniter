# frozen_string_literal: true

require "json"
require "igniter/cluster"

module Companion
  module Main
    # POST /v1/rag/search
    #
    # Accepts a RetrievalQuery as JSON, searches this node's local KnowledgeShard,
    # and returns ranked results. Used by FanoutRetriever on peer nodes.
    #
    # Request body (JSON):
    #   { "text": "...", "tags": ["ruby"], "limit": 10, "min_score": 0.0 }
    #
    # Response body (JSON):
    #   { "results": [...], "shard": "node-name", "count": N }
    module RagSearchHandler
      CONTENT_JSON = { "Content-Type" => "application/json" }.freeze

      def self.call(params:, body:, headers:, env:, raw_body:, config:)
        query = Igniter::Cluster::RAG::RetrievalQuery.new(
          text:      body.fetch("text",      "").to_s,
          tags:      Array(body.fetch("tags", [])).map(&:to_sym),
          limit:     [body.fetch("limit",    10).to_i, 1].max,
          min_score: body.fetch("min_score", 0.0).to_f
        )

        results = Igniter::Cluster::Mesh.shard.search(query)

        {
          status:  200,
          body:    JSON.generate({
            results: results.map(&:to_h),
            shard:   Igniter::Cluster::Mesh.config.peer_name || "local",
            count:   results.size
          }),
          headers: CONTENT_JSON
        }
      rescue StandardError => e
        {
          status:  500,
          body:    JSON.generate(error: e.message),
          headers: CONTENT_JSON
        }
      end
    end
  end
end
