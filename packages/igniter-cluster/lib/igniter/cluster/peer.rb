# frozen_string_literal: true

module Igniter
  module Cluster
    class Peer
      attr_reader :name, :capabilities, :transport, :metadata

      def initialize(name:, capabilities:, transport:, metadata: {})
        raise ArgumentError, "peer transport must respond to call(request:)" unless transport.respond_to?(:call)

        @name = name.to_sym
        @capabilities = Array(capabilities).map(&:to_sym).uniq.sort.freeze
        @transport = transport
        @metadata = metadata.dup.freeze
        freeze
      end

      def supports_capabilities?(required_capabilities)
        Array(required_capabilities).all? { |capability| capabilities.include?(capability.to_sym) }
      end

      def to_h
        {
          name: name,
          capabilities: capabilities.dup,
          metadata: metadata.dup
        }
      end
    end
  end
end
