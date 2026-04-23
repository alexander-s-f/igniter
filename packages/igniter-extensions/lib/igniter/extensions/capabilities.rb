# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/capabilities", replacement: "contracts-side validation or diagnostics packs instead of patching CompiledGraph globally")
require "igniter/core/capabilities"

# Patches CompiledGraph with capability introspection methods.
# The Resolver integration is handled via guard-claused hooks in resolver.rb.
module Igniter
  module Compiler
    class CompiledGraph
      # Returns a Hash of { node_name => [capabilities] } for every compute/effect
      # node whose executor declares at least one capability.
      def required_capabilities
        (nodes + outputs).each_with_object({}) do |node, memo|
          caps = node_capabilities(node)
          memo[node.name] = caps unless caps.empty?
        end
      end

      # Returns declared capabilities for a single node by name.
      def capabilities_for(node_name)
        sym    = node_name.to_sym
        target = (nodes + outputs).find { |n| n.name == sym }
        return [] unless target

        node_capabilities(target)
      end

      private

      def node_capabilities(node)
        callable = node.respond_to?(:callable) ? node.callable : nil
        callable ||= node.respond_to?(:adapter_class) ? node.adapter_class : nil
        return [] unless callable.is_a?(Class) && callable <= Igniter::Executor

        callable.declared_capabilities
      end
    end
  end
end
