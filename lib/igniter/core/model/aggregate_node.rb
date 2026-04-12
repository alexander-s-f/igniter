# frozen_string_literal: true

module Igniter
  module Model
    # Represents a maintained aggregate node in the computation graph.
    #
    # An AggregateNode computes an aggregate value over an incremental collection
    # and updates it in O(change) time by processing only the diff (added/changed/removed
    # items) rather than iterating over the entire collection on every resolve.
    #
    # Supported built-in operators: :count, :sum, :avg, :min, :max, :group_count.
    # Custom aggregates can be defined with initial:, add:, and remove: lambdas.
    #
    # The aggregate node depends on exactly one upstream incremental collection node.
    # The compiler validates this at definition time.
    class AggregateNode < Node
      attr_reader :source_collection, :operator

      def initialize(id:, name:, source_collection:, operator:, # rubocop:disable Metrics/ParameterLists
                     path: nil, metadata: {})
        super(
          id: id,
          kind: :aggregate,
          name: name,
          path: path || name.to_s,
          dependencies: [source_collection],
          metadata: metadata
        )
        @source_collection = source_collection.to_sym
        @operator = operator
      end
    end
  end
end
