# frozen_string_literal: true

module Igniter
  module Mesh
    # Thread-safe capability router with a short-lived health cache.
    #
    # Resolves the URL to call for a given routing mode:
    #   - :capability  → round-robin among alive peers that advertise the capability;
    #                    raises DeferredCapabilityError when no alive peer is found.
    #   - :pinned      → asserts the named peer is alive and returns its URL;
    #                    raises IncidentError when the peer is unknown or unreachable.
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
        candidates = @config.peers_with_capability(capability).select { |p| alive?(p) }

        raise DeferredCapabilityError.new(capability, deferred_result) if candidates.empty?

        url_for_round_robin(capability, candidates)
      end

      # Resolve the URL of a pinned peer by name.
      # Raises IncidentError if the peer is unknown or unreachable.
      def resolve_pinned(peer_name)
        peer = @config.peer_named(peer_name)

        unless peer
          raise IncidentError.new(
            peer_name,
            "Pinned peer '#{peer_name}' is not registered in Igniter::Mesh"
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
