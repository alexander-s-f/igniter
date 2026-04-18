# frozen_string_literal: true

require "igniter/core/errors"

module Igniter
  module SDK
    Capability = Struct.new(:name, :entrypoint, :allowed_layers, :provides_capabilities, keyword_init: true)

    class Error < Igniter::Error; end
    class UnknownCapabilityError < Error; end
    class LayerViolationError < Error; end

    class << self
      def register(name, entrypoint:, allowed_layers:, provides_capabilities: [])
        capability = Capability.new(
          name: name.to_sym,
          entrypoint: entrypoint.to_s,
          allowed_layers: Array(allowed_layers).map(&:to_sym).uniq.freeze,
          provides_capabilities: Array(provides_capabilities).map(&:to_sym).uniq.sort.freeze
        )

        registry[capability.name] = capability
      end

      def fetch(name)
        registry.fetch(name.to_sym)
      rescue KeyError
        available = registry.keys.sort.map(&:inspect).join(", ")
        raise UnknownCapabilityError, "Unknown SDK capability #{name.inspect} (available: #{available})"
      end

      def capabilities(layer: nil)
        values = registry.values
        return values.sort_by(&:name) unless layer

        values.select { |capability| capability.allowed_layers.include?(layer.to_sym) }.sort_by(&:name)
      end

      def activate!(*names, layer:)
        resolved_layer = layer.to_sym

        names.flatten.each do |name|
          capability = fetch(name)
          unless capability.allowed_layers.include?(resolved_layer)
            raise LayerViolationError,
                  "SDK capability #{capability.name.inspect} is not allowed for layer #{resolved_layer.inspect} " \
                  "(allowed: #{capability.allowed_layers.map(&:inspect).join(', ')})"
          end

          require capability.entrypoint
          activated_capabilities << capability.name unless activated?(capability.name)
        end

        true
      end

      def activated?(name)
        activated_capabilities.include?(name.to_sym)
      end

      def activated_capabilities
        @activated_capabilities ||= []
      end

      def reset!
        @activated_capabilities = []
      end

      def register_builtin_capabilities!
        register(:ai, entrypoint: "igniter/sdk/ai", allowed_layers: %i[app server cluster], provides_capabilities: %i[network external_api])
        register(:agents, entrypoint: "igniter/sdk/agents", allowed_layers: %i[app server cluster], provides_capabilities: [])
        register(:channels, entrypoint: "igniter/sdk/channels", allowed_layers: %i[app server cluster], provides_capabilities: %i[messaging network])
        register(:tools, entrypoint: "igniter/sdk/tools", allowed_layers: %i[app server cluster], provides_capabilities: %i[filesystem])
        register(:data, entrypoint: "igniter/sdk/data", allowed_layers: %i[core app server cluster], provides_capabilities: %i[cache database])
      end

      private

      def registry
        @registry ||= {}
      end
    end

    register_builtin_capabilities!
  end
end
