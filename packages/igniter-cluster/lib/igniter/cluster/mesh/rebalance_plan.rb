# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Immutable result of a RebalancePlanner#plan call.
      #
      # Carries a list of ownership transfer recommendations ordered from
      # highest-impact to lowest. Each transfer hash has the shape:
      #
      #   {
      #     action:      :transfer_ownership,
      #     entity_type: String,
      #     entity_id:   String,
      #     from_owner:  String,
      #     to_owner:    String
      #   }
      #
      # Call #to_routing_plans to convert transfers into routing plan hashes
      # compatible with RoutingPlanExecutor.
      class RebalancePlan
        attr_reader :transfers, :rationale, :skew

        # @param transfers [Array<Hash>]   ordered transfer recommendations
        # @param rationale [String]        human-readable explanation
        # @param skew      [Integer]       entity count imbalance (max - min across eligible nodes)
        def initialize(transfers:, rationale:, skew:)
          @transfers = Array(transfers).map(&:freeze).freeze
          @rationale = rationale.to_s
          @skew      = skew.to_i
          freeze
        end

        def balanced?
          @transfers.empty?
        end

        def size
          @transfers.size
        end

        # Convert transfers to routing plan hashes consumable by RoutingPlanExecutor.
        def to_routing_plans
          @transfers.map do |t|
            {
              action:            :transfer_ownership,
              scope:             :ownership_placement,
              automated:         true,
              requires_approval: false,
              params: {
                entity_type: t[:entity_type],
                entity_id:   t[:entity_id],
                from_owner:  t[:from_owner],
                to_owner:    t[:to_owner]
              }
            }
          end
        end

        def to_h
          { transfers: @transfers, rationale: @rationale, skew: @skew }
        end
      end
    end
  end
end
