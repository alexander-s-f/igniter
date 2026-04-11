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
  # Self-replication capability: deploy a running Igniter instance to a
  # remote server via SSH using one of three deployment strategies.
  #
  # Usage:
  #   require "igniter/replication"
  #   ref = Igniter::Replication::ReplicationAgent.start
  #   ref.send(:replicate,
  #     host:     "10.0.0.2",
  #     user:     "deploy",
  #     strategy: :git,
  #     bootstrapper_options: { repo_url: "https://github.com/org/app" }
  #   )
  #
  module Replication
    ReplicationError = Class.new(Igniter::Error)

    BOOTSTRAPPERS = {
      git: Bootstrappers::Git,
      gem: Bootstrappers::Gem,
      tarball: Bootstrappers::Tarball
    }.freeze

    # Instantiate the bootstrapper for the given strategy.
    #
    # @param strategy [Symbol] one of :git, :gem, :tarball
    # @param options  [Hash]   forwarded to the bootstrapper constructor
    # @return [Bootstrapper]
    # @raise [ArgumentError] for unknown strategies
    def self.bootstrapper_for(strategy, **options)
      klass = BOOTSTRAPPERS.fetch(strategy.to_sym) do
        raise ArgumentError,
              "Unknown bootstrapper: #{strategy}. Available: #{BOOTSTRAPPERS.keys.join(", ")}"
      end
      klass.new(**options)
    end
  end
end
