# frozen_string_literal: true

require_relative "mesh/errors"
require_relative "mesh/peer_metadata"
require_relative "mesh/peer_identity_envelope"
require_relative "mesh/peer"
require_relative "mesh/peer_registry"
require_relative "mesh/config"
require_relative "mesh/router"
require_relative "mesh/announcer"
require_relative "mesh/poller"
require_relative "mesh/discovery"
require_relative "mesh/gossip"

module Igniter
  module Cluster
    # Mesh routing for remote nodes inside the cluster layer.
    #
    # Phase 1 — Static Mesh:
    #   Declare peer topology via add_peer. capability: and pinned_to: routing
    #   modes select alive peers at resolution time.
    #
    # Phase 2 — Dynamic Discovery:
    #   Configure seed URLs and call start_discovery!. The local node announces
    #   itself to seeds and polls them for the current peer list in the background.
    module Mesh
      class << self
        def config
          @config ||= Config.new
        end

        def configure
          yield config
          self
        end

        def router
          @router ||= Router.new(config)
        end

        def start_discovery!
          discovery.start
          self
        end

        def stop_discovery!
          @discovery&.stop
          @discovery = nil
          self
        end

        def discovery
          @discovery ||= Discovery.new(config)
        end

        def trust_admission_plan(peer_name, label: nil)
          Igniter::Cluster::Trust::AdmissionPlanner.new(config: config).plan(peer_name, label: label)
        end

        def admit_trusted_peer!(peer_name, approve: false, label: nil)
          plan = trust_admission_plan(peer_name, label: label)
          Igniter::Cluster::Trust::AdmissionRunner.new(config: config).run(plan, approve: approve)
        end

        def execute_routing_plan!(plan, approve: false, peer_name: nil, label: nil)
          Igniter::Cluster::RoutingPlanExecutor.new(config: config).run(
            plan,
            approve: approve,
            peer_name: peer_name,
            label: label
          )
        end

        def reset!
          stop_discovery!
          @config = nil
          @router = nil
        end
      end
    end
  end
end
