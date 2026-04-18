# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
    # Immutable value object returned by ExpansionPlanner.
    #
    # Carries an ordered list of actions the replication system should execute
    # and a human-readable rationale explaining why each action was chosen.
    #
    # Recognised action hashes:
    #   { action: :replicate_capabilities, query: { all_of: [:local_llm] }, host: "10.0.0.2" }
    #   { action: :retire_node,            node_id: "abc",                   host: "10.0.0.1" }
    #   { action: :no_op }
    class ExpansionPlan
      attr_reader :actions, :rationale

      # @param actions   [Array<Hash>]
      # @param rationale [String, nil]
      def initialize(actions:, rationale: nil)
        @actions   = Array(actions).freeze
        @rationale = rationale
        freeze
      end

      # True when there is nothing to do.
      #
      # @return [Boolean]
      def no_op?
        @actions.all? { |a| a[:action] == :no_op }
      end

      # @return [Hash]
      def to_h
        { actions: @actions, rationale: @rationale }
      end
    end
    end
  end
end
