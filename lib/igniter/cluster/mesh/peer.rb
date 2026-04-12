# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Immutable value object representing a peer in the static mesh.
    class Peer
      attr_reader :name, :url, :capabilities

      def initialize(name:, url:, capabilities: [])
        @name         = name.to_s.freeze
        @url          = url.to_s.chomp("/").freeze
        @capabilities = Array(capabilities).map(&:to_sym).freeze
        freeze
      end

      def capable?(capability)
        @capabilities.include?(capability.to_sym)
      end
    end
    end
  end
end
