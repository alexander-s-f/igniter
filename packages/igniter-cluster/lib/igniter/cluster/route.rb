# frozen_string_literal: true

module Igniter
  module Cluster
    class Route
      attr_reader :peer, :mode, :metadata, :explanation

      def initialize(peer:, mode:, metadata: {}, explanation: nil)
        @peer = peer
        @mode = mode.to_sym
        @metadata = metadata.dup.freeze
        @explanation = explanation
        freeze
      end

      def to_h
        {
          peer: peer.name,
          mode: mode,
          metadata: metadata.dup,
          explanation: explanation
        }
      end
    end
  end
end
