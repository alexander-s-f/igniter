# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Result of a PlacementPlanner#place call.
      #
      # Carries the chosen node, its composite score (0..1), per-dimension
      # score breakdown, rejected candidates, and whether degraded-mode
      # fallback was triggered.
      class PlacementDecision
        attr_reader :node, :score, :dimensions, :rejected, :policy

        # @param node       [NodeObservation, nil]  chosen node; nil = no placement found
        # @param score      [Float, nil]            composite score (0..1)
        # @param dimensions [Hash]                  per-dimension score breakdown
        # @param rejected   [Array<Hash>]           losing candidates with name, score
        # @param degraded   [Boolean]               true when relaxed policy was used
        # @param policy     [PlacementPolicy]       the policy that was applied
        def initialize(node:, score:, dimensions:, rejected:, degraded:, policy:)
          @node       = node
          @score      = score
          @dimensions = Hash(dimensions).freeze
          @rejected   = Array(rejected).freeze
          @degraded   = degraded
          @policy     = policy
          freeze
        end

        def placed?
          !@node.nil?
        end

        def failed?
          @node.nil?
        end

        def degraded?
          @degraded
        end

        def url
          @node&.url
        end

        def name
          @node&.name
        end

        def to_h
          {
            placed:     placed?,
            degraded:   @degraded,
            node:       @node ? { name: @node.name, url: @node.url } : nil,
            score:      @score,
            dimensions: @dimensions,
            rejected:   @rejected,
            policy:     @policy.to_h
          }
        end
      end
    end
  end
end
