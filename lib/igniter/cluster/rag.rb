# frozen_string_literal: true

require_relative "rag/chunk"
require_relative "rag/retrieval_query"
require_relative "rag/retrieval_result"
require_relative "rag/knowledge_shard"
require_relative "rag/ranker"
require_relative "rag/net_http_adapter"
require_relative "rag/fanout_retriever"

module Igniter
  module Cluster
    # Phase 5+7: Decentralized Knowledge Plane.
    #
    # Each cluster node can maintain a local KnowledgeShard — a content-addressed
    # store of text chunks that can be searched via keyword relevance.
    #
    # v1: local shard retrieval with trust-aware scoring.
    # v2: distributed fan-out to remote `:rag`-capable peers via FanoutRetriever.
    #
    # Cluster integration:
    #   Igniter::Cluster::Mesh.configure { |c| c.local_capabilities << :rag }
    #   Igniter::Cluster::Mesh.shard.add("Ruby closures bind at creation time", tags: [:ruby])
    #
    #   # Local only (default):
    #   results = Igniter::Cluster::Mesh.retrieve("how closures work", limit: 5)
    #
    #   # Distributed fan-out:
    #   results = Igniter::Cluster::Mesh.retrieve("how closures work", distributed: true)
    #
    # Standalone:
    #   shard = Igniter::Cluster::RAG::KnowledgeShard.new(name: "my-shard")
    #   shard.add("...", tags: [:topic])
    #   results = shard.search("query text", tags: [:topic], limit: 10)
    module RAG
    end
  end
end
