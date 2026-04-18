# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Igniter
  module Cluster
    module RAG
      # Production HTTP adapter: POSTs a RetrievalQuery to a remote node's
      # /rag/search endpoint and deserialises the response into RetrievalResult
      # objects, attaching the caller's NodeObservation for composite scoring.
      #
      # Wire format (request body, JSON):
      #   { "text": "...", "tags": [...], "limit": N, "min_score": 0.0 }
      #
      # Wire format (response body, JSON):
      #   { "results": [ { "id", "content", "score", "source", "tags", ... }, ... ] }
      #
      # Any non-200 or network error returns [] — graceful degradation.
      class NetHttpAdapter
        DEFAULT_TIMEOUT = 5

        def initialize(timeout: DEFAULT_TIMEOUT)
          @timeout = timeout
        end

        # @param base_url    [String]             peer URL (e.g. "http://node-a:4567")
        # @param query       [RetrievalQuery]
        # @param observation [NodeObservation, nil]  attached to each result for composite scoring
        # @return [Array<RetrievalResult>]
        def call(base_url, query, observation: nil)
          uri     = URI.parse("#{base_url.to_s.chomp("/")}/rag/search")
          http    = build_http(uri)
          request = build_request(uri, query)
          resp    = http.request(request)

          return [] unless resp.code == "200"

          data = JSON.parse(resp.body)
          deserialize(data["results"], observation: observation)
        rescue StandardError
          []
        end

        private

        def build_http(uri)
          http              = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = @timeout
          http.read_timeout = @timeout
          http.use_ssl      = uri.scheme == "https"
          http
        end

        def build_request(uri, query)
          req = Net::HTTP::Post.new(uri.path.empty? ? "/rag/search" : uri.path,
                                    "Content-Type" => "application/json",
                                    "Accept"       => "application/json")
          req.body = JSON.generate(query.to_h)
          req
        end

        def deserialize(raw_results, observation:)
          Array(raw_results).filter_map do |r|
            content  = r["content"].to_s
            next if content.empty?

            tags     = Array(r["tags"]).map(&:to_sym)
            metadata = {}
            Array(r["metadata"]).each { |k, v| metadata[k.to_sym] = v } if r["metadata"].is_a?(Hash)

            chunk = Chunk.build(content, tags: tags, metadata: metadata)
            RetrievalResult.new(
              chunk:       chunk,
              score:       r["score"].to_f,
              source:      r["source"].to_s,
              observation: observation
            )
          end
        end
      end
    end
  end
end
