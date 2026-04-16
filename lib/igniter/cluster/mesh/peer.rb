# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Immutable value object representing a peer in the static mesh.
    class Peer
      require_relative "../replication/capability_query"

      attr_reader :name, :url, :capabilities, :tags, :metadata

      def initialize(name:, url:, capabilities: [], tags: [], metadata: {})
        @name         = name.to_s.freeze
        @url          = url.to_s.chomp("/").freeze
        @capabilities = Array(capabilities).map(&:to_sym).freeze
        @tags         = Array(tags).map(&:to_sym).freeze
        @metadata     = Hash(metadata).transform_keys(&:to_sym).freeze
        freeze
      end

      def capable?(capability)
        @capabilities.include?(capability.to_sym)
      end

      def matches_query?(query)
        normalized = Igniter::Cluster::Replication::CapabilityQuery.normalize(query)
        normalized.matches_profile?(profile)
      end

      def profile
        Struct.new(:capabilities, :tags, keyword_init: true) do
          def capability?(capability)
            capabilities.include?(capability.to_sym)
          end

          def tag?(tag)
            tags.include?(tag.to_sym)
          end
        end.new(capabilities: @capabilities, tags: @tags)
      end
    end
    end
  end
end
