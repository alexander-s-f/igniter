# frozen_string_literal: true

module Igniter
  module Provenance
    # Immutable snapshot of a single resolved node and its full dependency chain.
    #
    # The tree structure mirrors the contract's dependency graph: each NodeTrace
    # holds the traced values of all the nodes that contributed to its result.
    # Input nodes are leaves (no contributing dependencies).
    #
    # The tree may share nodes (diamond dependencies in the original graph) but
    # each shared node is memoised once by the Builder, so the same NodeTrace
    # object is referenced from multiple parents — it is NOT duplicated.
    class NodeTrace
      attr_reader :name, :kind, :value, :contributing

      # contributing: Hash{ Symbol => NodeTrace } — may be empty for leaf inputs
      def initialize(name:, kind:, value:, contributing: {})
        @name        = name.to_sym
        @kind        = kind.to_sym
        @value       = value
        @contributing = contributing.freeze
        freeze
      end

      def input?
        kind == :input
      end

      # True when this node has no dependencies that contributed to its value.
      def leaf?
        contributing.empty?
      end

      # Recursively collect all :input nodes that influenced this trace.
      # Returns Hash{ Symbol => value }.
      def contributing_inputs
        return { name => value } if input?

        contributing.each_value.with_object({}) do |dep, acc|
          acc.merge!(dep.contributing_inputs)
        end
      end

      # Does this trace transitively depend on the named input?
      def sensitive_to?(input_name)
        contributing_inputs.key?(input_name.to_sym)
      end

      # Return the ordered path of node names from this node down to the given
      # input, or nil if the input does not contribute to this node.
      def path_to(input_name)
        target = input_name.to_sym
        return [name] if name == target

        contributing.each_value do |dep|
          sub_path = dep.path_to(target)
          return [name] + sub_path if sub_path
        end

        nil
      end
    end
  end
end
