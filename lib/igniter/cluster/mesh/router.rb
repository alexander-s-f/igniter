# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    require_relative "../replication/capability_query"

    # Thread-safe capability router with a short-lived health cache.
    #
    # Resolves the URL to call for a given routing mode:
    #   - :capability  → round-robin among alive peers that advertise the capability;
    #                    raises DeferredCapabilityError when no alive peer is found.
    #   - :pinned      → asserts the named peer is alive and returns its URL;
    #                    raises IncidentError when the peer is unknown or unreachable.
    #
    # Peer pool = static peers (Config#peers) + dynamic peers (Config#peer_registry).
    # Static peers take precedence when a name appears in both sets.
    class Router
      HEALTH_CACHE_TTL = 5 # seconds

      def initialize(config)
        @config       = config
        @health_cache = {}
        @mutex        = Mutex.new
        @round_robin  = Hash.new(0)
      end

      # Find an alive peer advertising +capability+.
      # Returns the peer URL. Raises DeferredCapabilityError when none are alive.
      def find_peer_for(capability, deferred_result)
        find_peer_for_query({ all_of: [capability.to_sym] }, deferred_result, round_robin_key: capability.to_sym)
      end

      # Find an alive peer matching a full capability query.
      # Returns the peer URL. Raises DeferredCapabilityError when none are alive.
      def find_peer_for_query(query, deferred_result, round_robin_key: nil)
        normalized = Igniter::Cluster::Replication::CapabilityQuery.normalize(query)
        candidates = all_matching_peers(normalized).select { |peer| alive?(peer) }

        if candidates.empty?
          raise DeferredCapabilityError.new(
            normalized.name || normalized.all_of.first,
            deferred_result,
            query: normalized.to_h
          )
        end

        url_for_round_robin(round_robin_key || normalized.to_h, candidates)
      end

      # Resolve the URL of a pinned peer by name.
      # Raises IncidentError if the peer is unknown or unreachable.
      def resolve_pinned(peer_name)
        peer = find_named_peer(peer_name)

        unless peer
          raise IncidentError.new(
            peer_name,
            "Pinned peer '#{peer_name}' is not registered in Igniter::Cluster::Mesh"
          )
        end

        raise IncidentError, peer_name unless alive?(peer)

        peer.url
      end

      # Expire a peer's cached health status (e.g., after a successful or failed request).
      def invalidate_health!(url)
        @mutex.synchronize { @health_cache.delete(url) }
      end

      private

      # Combined static + dynamic peer pool for capability-query lookup.
      # Static peers take precedence over same-named dynamic peers.
      def all_matching_peers(query)
        merge_peers(
          @config.peers_matching_query(query),
          @config.peer_registry.peers_matching_query(query)
        )
      end

      # Lookup peer by name across static and dynamic pools.
      def find_named_peer(name)
        @config.peer_named(name) || @config.peer_registry.peer_named(name)
      end

      # Merge static and dynamic peer lists; static names win on collision.
      def merge_peers(static, dynamic)
        seen = static.each_with_object({}) { |p, h| h[p.name] = true }
        static + dynamic.reject { |p| seen[p.name] }
      end

      def url_for_round_robin(capability, candidates)
        idx = @mutex.synchronize do
          i = @round_robin[capability] % candidates.size
          @round_robin[capability] = i + 1
          i
        end
        candidates[idx].url
      end

      def alive?(peer) # rubocop:disable Metrics/MethodLength
        @mutex.synchronize do
          entry = @health_cache[peer.url]
          return entry[:alive] if entry && (Time.now.utc - entry[:checked_at]) < HEALTH_CACHE_TTL
        end

        alive = begin
          Igniter::Server::Client.new(peer.url, timeout: 3).health
          true
        rescue Igniter::Server::Client::ConnectionError
          false
        end

        @mutex.synchronize do
          @health_cache[peer.url] = { alive: alive, checked_at: Time.now.utc }
        end

        alive
      end
    end
    end
  end
end
