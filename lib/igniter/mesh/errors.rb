# frozen_string_literal: true

module Igniter
  module Mesh
    # Raised when a capability-routed remote node has no alive peers.
    # Inherits from PendingDependencyError so the resolver transitions
    # the node to :pending (same as await/distributed workflow nodes).
    class DeferredCapabilityError < Igniter::PendingDependencyError
      attr_reader :capability

      def initialize(capability, deferred_result, message = nil)
        @capability = capability
        super(deferred_result, message || "No alive peer with capability :#{capability}")
      end
    end

    # Raised when a pinned_to peer is unavailable.
    # Inherits from ResolutionError so the resolver transitions the node
    # to :failed and surfaces it as an operational incident requiring
    # manual intervention.
    class IncidentError < Igniter::ResolutionError
      attr_reader :peer_name

      def initialize(peer_name, message = nil, context: {})
        @peer_name = peer_name
        super(message || "Pinned peer '#{peer_name}' is unreachable — manual intervention required",
              context: context)
      end
    end
  end
end
