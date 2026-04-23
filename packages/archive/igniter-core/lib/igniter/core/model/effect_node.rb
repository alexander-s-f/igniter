# frozen_string_literal: true

module Igniter
  module Model
    # Represents a side-effect node in the computation graph.
    #
    # An EffectNode wraps an Igniter::Effect adapter class. It participates
    # in topological ordering, dependency resolution, saga compensations,
    # and execution reporting like any other node — but is explicitly typed
    # as a side effect for visibility and audit purposes.
    class EffectNode < Node
      attr_reader :adapter_class

      def initialize(id:, name:, dependencies:, adapter_class:, path: nil, metadata: {}) # rubocop:disable Metrics/ParameterLists
        super(
          id: id,
          kind: :effect,
          name: name,
          path: path || name,
          dependencies: dependencies,
          metadata: metadata
        )
        @adapter_class = adapter_class
      end

      # @return [Symbol] e.g. :database, :http, :cache, :generic
      def effect_type
        adapter_class.effect_type
      end

      # @return [Boolean]
      def idempotent?
        adapter_class.idempotent?
      end
    end
  end
end
