# frozen_string_literal: true

module Igniter
  module Model
    class ComputeNode < Node
      attr_reader :callable

      def initialize(id:, name:, dependencies:, callable:, metadata: {})
        super(
          id: id,
          kind: :compute,
          name: name,
          path: name,
          dependencies: dependencies,
          metadata: metadata
        )
        @callable = callable
      end

      def callable_name
        case callable
        when Proc
          "proc"
        when Symbol, String
          callable.to_s
        when Class
          callable.name || "AnonymousClass"
        else
          callable.class.name || "AnonymousCallable"
        end
      end

      def executor_label
        metadata[:label]
      end

      def executor_category
        metadata[:category]
      end

      def executor_tags
        Array(metadata[:tags]).freeze
      end
    end
  end
end
