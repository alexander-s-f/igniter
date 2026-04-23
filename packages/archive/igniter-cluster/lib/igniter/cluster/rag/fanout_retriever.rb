# frozen_string_literal: true

module Igniter
  module Cluster
    module RAG
      # Fans out a RetrievalQuery to all :rag-capable peers discovered via the
      # PeerRegistry, merges remote results with the local shard through the
      # trust-aware Ranker.
      #
      # Fan-out is parallel (one Thread per peer) with a configurable timeout.
      # Any peer that fails or times out silently returns [] — the local shard
      # always contributes regardless of remote availability.
      #
      # Usage:
      #   retriever = FanoutRetriever.new(
      #     registry:    Igniter::Cluster::Mesh.config.peer_registry,
      #     local_shard: Igniter::Cluster::Mesh.shard,
      #     adapter:     RAG::NetHttpAdapter.new(timeout: 3)
      #   )
      #   results = retriever.retrieve("how closures work in Ruby", tags: [:ruby], limit: 10)
      #
      # Or via the Mesh convenience entry point:
      #   Igniter::Cluster::Mesh.retrieve("closures", distributed: true)
      class FanoutRetriever
        DEFAULT_TIMEOUT    = 5
        DEFAULT_REQUIRE_TRUST = true

        # @param registry      [PeerRegistry]             live peer registry
        # @param local_shard   [KnowledgeShard, nil]      local shard (nil = skip local)
        # @param adapter       [#call(url, query, observation:)]  HTTP adapter
        # @param now           [Time]
        # @param timeout       [Numeric]                  seconds per remote call
        # @param require_trust [Boolean]                  skip untrusted peers
        def initialize(registry:, local_shard: nil, adapter: nil, now: Time.now.utc,
                       timeout: DEFAULT_TIMEOUT, require_trust: DEFAULT_REQUIRE_TRUST)
          @registry      = registry
          @local_shard   = local_shard
          @adapter       = adapter || NetHttpAdapter.new(timeout: timeout)
          @now           = now
          @require_trust = require_trust
        end

        # Run local + distributed retrieval and return merged results.
        #
        # @param query_or_text [RetrievalQuery, String]
        # @param tags          [Array<Symbol>]   used only when query_or_text is a String
        # @param limit         [Integer]
        # @param min_score     [Float]
        # @return [Array<RetrievalResult>]
        def retrieve(query_or_text, tags: [], limit: 10, min_score: 0.0)
          query = coerce_query(query_or_text, tags: tags, limit: limit, min_score: min_score)

          local_results = @local_shard ? @local_shard.search(query) : []

          remote_peers = discover_rag_peers
          remote_groups = fan_out(remote_peers, query)

          Ranker.new.merge(local_results, *remote_groups, limit: query.limit)
        end

        private

        def coerce_query(query_or_text, tags:, limit:, min_score:)
          return query_or_text if query_or_text.is_a?(RetrievalQuery)

          RetrievalQuery.new(text: query_or_text.to_s, tags: tags, limit: limit, min_score: min_score)
        end

        def discover_rag_peers
          obs = Igniter::Cluster::Mesh::ObservationQuery.new(
            @registry.observations(now: @now)
          ).with(:rag)
          obs = obs.trusted if @require_trust
          obs.to_a
        end

        def fan_out(peers, query)
          return [] if peers.empty?

          threads = peers.map do |observation|
            Thread.new do
              @adapter.call(observation.url, query, observation: observation)
            rescue StandardError
              []
            end
          end

          threads.map { |t| t.value rescue [] }
        end
      end
    end
  end
end
