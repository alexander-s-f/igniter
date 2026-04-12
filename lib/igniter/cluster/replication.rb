# frozen_string_literal: true

require_relative "replication/manifest"
require_relative "replication/ssh_session"
require_relative "replication/bootstrapper"
require_relative "replication/bootstrappers/git"
require_relative "replication/bootstrappers/gem"
require_relative "replication/bootstrappers/tarball"
require_relative "replication/replication_agent"
require_relative "replication/node_role"
require_relative "replication/role_registry"
require_relative "replication/network_topology"
require_relative "replication/expansion_plan"
require_relative "replication/expansion_planner"
require_relative "replication/reflective_replication_agent"

module Igniter
  module Cluster
    # Deployment and self-replication capabilities for clustered nodes.
    module Replication
      ReplicationError = Class.new(Igniter::Error) unless const_defined?(:ReplicationError, false)

      BOOTSTRAPPERS = {
        git: Bootstrappers::Git,
        gem: Bootstrappers::Gem,
        tarball: Bootstrappers::Tarball
      }.freeze unless const_defined?(:BOOTSTRAPPERS, false)

      def self.bootstrapper_for(strategy, **options)
        klass = BOOTSTRAPPERS.fetch(strategy.to_sym) do
          raise ArgumentError,
                "Unknown bootstrapper: #{strategy}. Available: #{BOOTSTRAPPERS.keys.join(", ")}"
        end
        klass.new(**options)
      end
    end
  end
end
