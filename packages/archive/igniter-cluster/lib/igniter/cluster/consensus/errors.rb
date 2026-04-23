# frozen_string_literal: true

module Igniter
  module Cluster
    module Consensus
    # Base class for all consensus errors.
    class Error < Igniter::Error; end

    # Raised when no leader is available — cluster may be electing or lacks quorum.
    class NoLeaderError < Error; end

    # Raised when the cluster loses quorum mid-operation.
    class QuorumLostError < Error; end
    end
  end
end
