# frozen_string_literal: true

require_relative "rag/chunk"
require_relative "rag/retrieval_query"
require_relative "rag/retrieval_result"
require_relative "rag/knowledge_shard"
require_relative "rag/ranker"

module Igniter
  module Cluster
    # Phase 5: Decentralized Knowledge Plane.
    #
    # Each cluster node can maintain a local KnowledgeShard — a content-addressed
    # store of text chunks that can be searched via keyword relevance.
    #
    # v1 supports local shard retrieval with trust-aware scoring.
    # v2 will add distributed fan-out to remote `:rag`-capable peers.
    #
    # Cluster integration:
    #   Igniter::Cluster::Mesh.configure { |c| c.local_capabilities << :rag }
    #   Igniter::Cluster::Mesh.shard.add("Ruby closures bind at creation time", tags: [:ruby])
    #   results = Igniter::Cluster::Mesh.retrieve("how closures work", limit: 5)
    #
    # Standalone:
    #   shard = Igniter::Cluster::RAG::KnowledgeShard.new(name: "my-shard")
    #   shard.add("...", tags: [:topic])
    #   results = shard.search("query text", tags: [:topic], limit: 10)
    module RAG
    end
  end
end
