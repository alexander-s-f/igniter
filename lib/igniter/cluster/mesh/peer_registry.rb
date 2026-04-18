# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Thread-safe registry for dynamically discovered peers.
    #
    # Stores peers indexed by name so that registering the same peer twice
    # (e.g. from two different seeds) is idempotent and the latest wins.
    class PeerRegistry
      def initialize
        @peers = {}
        @mutex = Mutex.new
      end

      # Register (or update) a peer. Thread-safe.
      def register(peer)
        @mutex.synchronize { @peers[peer.name] = peer }
      end

      # Remove a peer by name. No-op if not registered.
      def unregister(name)
        @mutex.synchronize { @peers.delete(name.to_s) }
      end

      # All currently registered peers (snapshot).
      def all
        @mutex.synchronize { @peers.values.dup }
      end

      # Peers that advertise a given capability.
      def peers_with_capability(capability)
        all.select { |p| p.capable?(capability) }
      end

      # Peers matching a capability query.
      def peers_matching_query(query)
        all.select { |p| p.matches_query?(query) }
      end

      # Find a peer by name. Returns nil if not found.
      def peer_named(name)
        @mutex.synchronize { @peers[name.to_s] }
      end

      # Remove all registered peers. Useful in tests.
      def clear
        @mutex.synchronize { @peers.clear }
      end

      # Number of registered peers.
      def size
        @mutex.synchronize { @peers.size }
      end

      # NodeObservation for a peer by name at the given point in time.
      # Returns nil if the peer is not registered.
      def observation_for(name, now: Time.now.utc)
        peer_named(name)&.to_observation(now: now)
      end

      # All peers as NodeObservation snapshots at the given point in time.
      def observations(now: Time.now.utc)
        all.map { |p| p.to_observation(now: now) }
      end

      # Observations matching a capability query.
      def observations_matching_query(query, now: Time.now.utc)
        normalized = Igniter::Cluster::Replication::CapabilityQuery.normalize(query)
        observations(now: now).select { |obs| normalized.matches_profile?(obs) }
      end
    end
    end
  end
end
