# frozen_string_literal: true

module Igniter
  module Model
    class ComputeNode < Node
      attr_reader :callable

      def initialize(id:, name:, dependencies:, callable:, path: nil, metadata: {})
        super(
          id: id,
          kind: :compute,
          name: name,
          path: (path || name),
          dependencies: dependencies,
          metadata: metadata
        )
        @callable = callable
      end

      def callable_name
        return "const" if const?
        return "guard" if guard?

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

      def executor_key
        metadata[:executor_key] || executor_metadata[:key]
      end

      def executor_label
        metadata[:label] || executor_metadata[:label]
      end

      def executor_category
        metadata[:category] || executor_metadata[:category]
      end

      def executor_tags
        Array(metadata[:tags] || executor_metadata[:tags]).freeze
      end

      def executor_summary
        metadata[:summary] || executor_metadata[:summary]
      end

      def type
        metadata[:type] || executor_metadata[:type]
      end

      def const?
        metadata[:kind] == :const
      end

      def guard?
        metadata[:guard] == true || metadata[:kind] == :guard
      end

      private

      def executor_metadata
        return {} unless callable.is_a?(Class) && callable <= Igniter::Executor

        callable.executor_metadata
      end
    end
  end
end
