# frozen_string_literal: true

module Igniter
  module Runtime
    # Immutable delivery route for an agent node.
    class AgentRoute
      attr_reader :routing_mode, :via, :message, :url, :capability, :query, :pinned_to, :metadata

      def initialize(routing_mode:, via:, message:, url: nil, capability: nil, query: nil, pinned_to: nil, metadata: {})
        @routing_mode = routing_mode.to_sym
        @via = via&.to_sym
        @message = message&.to_sym
        @url = url&.to_s
        @capability = capability&.to_sym
        @query = query&.dup&.freeze
        @pinned_to = pinned_to&.to_s
        @metadata = metadata.dup.freeze
        freeze
      end

      def self.local(via:, message:, metadata: {})
        new(routing_mode: :local, via: via, message: message, metadata: metadata)
      end

      def self.static(via:, message:, url:, capability: nil, query: nil, pinned_to: nil, metadata: {})
        new(
          routing_mode: :static,
          via: via,
          message: message,
          url: url,
          capability: capability,
          query: query,
          pinned_to: pinned_to,
          metadata: metadata
        )
      end

      def local?
        routing_mode == :local
      end

      def remote?
        !local?
      end

      def to_h
        {
          routing_mode: routing_mode,
          via: via,
          message: message,
          url: url,
          capability: capability,
          query: query,
          pinned_to: pinned_to,
          metadata: metadata
        }.reject { |_key, value| value.nil? || value == {} }
      end
    end
  end
end
