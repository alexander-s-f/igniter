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

      # Return a structured explanation of how capability routing would resolve.
      # Does not mutate round-robin state.
      def explain_peer_for(capability)
        explain_peer_for_query({ all_of: [capability.to_sym] }, round_robin_key: capability.to_sym)
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
            query: normalized.to_h,
            explanation: explain_peer_for_query(normalized, round_robin_key: round_robin_key)
          )
        end

        url_for_round_robin(round_robin_key || normalized.to_h, top_ranked_candidates(normalized, candidates))
      end

      # Return a structured explanation of how a full capability query resolves.
      # Does not mutate round-robin state.
      def explain_peer_for_query(query, round_robin_key: nil)
        normalized = Igniter::Cluster::Replication::CapabilityQuery.normalize(query)
        peers = all_known_peers
        evaluations = peers.map { |peer| evaluate_peer(normalized, peer) }
        eligible_evaluations = evaluations.select { |entry| entry[:eligible] }
        top_tier = top_ranked_candidates(normalized, eligible_evaluations.map { |entry| entry[:peer] })
        top_tier_names = top_tier.map(&:name)
        selected_peer, round_robin_index = preview_round_robin_candidate(round_robin_key || normalized.to_h, top_tier)

        {
          routing_mode: :capability,
          query: normalized.to_h,
          peer_count: peers.size,
          matched_count: evaluations.count { |entry| entry[:matched] },
          eligible_count: eligible_evaluations.size,
          top_tier_count: top_tier.size,
          selected_url: selected_peer&.url,
          selected_peer: selected_peer&.name,
          round_robin_index: round_robin_index,
          peers: evaluations.map do |entry|
            peer = entry[:peer]
            {
              name: peer.name,
              url: peer.url,
              matched: entry[:matched],
              alive: entry[:alive],
              eligible: entry[:eligible],
              match_details: entry[:match_details],
              top_tier: top_tier_names.include?(peer.name),
              selected: selected_peer&.name == peer.name,
              ranking_fingerprint: entry[:ranking_fingerprint],
              reasons: evaluation_reasons(entry, top_tier_names, selected_peer)
            }
          end
        }
      end

      # Resolve the URL of a pinned peer by name.
      # Raises IncidentError if the peer is unknown or unreachable.
      def resolve_pinned(peer_name)
        peer = find_named_peer(peer_name)

        unless peer
          raise IncidentError.new(
            peer_name,
            "Pinned peer '#{peer_name}' is not registered in Igniter::Cluster::Mesh",
            context: { routing_trace: explain_pinned(peer_name) }
          )
        end

        unless alive?(peer)
          raise IncidentError.new(
            peer_name,
            nil,
            context: { routing_trace: explain_pinned(peer_name) }
          )
        end

        peer.url
      end

      # Return a structured explanation of pinned routing resolution.
      def explain_pinned(peer_name)
        peer = find_named_peer(peer_name)

        {
          routing_mode: :pinned,
          peer_name: peer_name.to_s,
          known: !peer.nil?,
          selected_url: peer&.url,
          reachable: peer ? alive?(peer) : false,
          reasons: pinned_reasons(peer)
        }
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

      def all_known_peers
        merge_peers(@config.peers, @config.peer_registry.all)
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
        peer, = pick_round_robin_candidate(capability, candidates)
        peer.url
      end

      def top_ranked_candidates(query, candidates)
        return candidates if candidates.empty?
        return candidates unless query.ordered? || query.decisioned?

        ranked = candidates.sort do |left, right|
          query.compare_profiles(left.profile, right.profile)
        end
        best_fingerprint = query.ranking_fingerprint(ranked.first.profile)
        ranked.select { |peer| query.ranking_fingerprint(peer.profile) == best_fingerprint }
      end

      def evaluate_peer(query, peer)
        match_details = query.explain_profile(peer.profile)
        matched = match_details[:matched]
        alive = matched ? alive?(peer) : nil
        eligible = matched && alive

        {
          peer: peer,
          matched: matched,
          alive: alive,
          eligible: eligible,
          match_details: match_details,
          ranking_fingerprint: eligible ? query.ranking_fingerprint(peer.profile) : nil
        }
      end

      def evaluation_reasons(entry, top_tier_names, selected_peer)
        return [:query_mismatch] unless entry[:matched]
        return [:unreachable] unless entry[:alive]
        return [:lower_ranked] if entry[:eligible] && !top_tier_names.include?(entry[:peer].name)
        return [:selected] if selected_peer&.name == entry[:peer].name

        [:not_selected_this_turn]
      end

      def pick_round_robin_candidate(key, candidates)
        idx = @mutex.synchronize do
          i = @round_robin[key] % candidates.size
          @round_robin[key] = i + 1
          i
        end
        [candidates[idx], idx]
      end

      def preview_round_robin_candidate(key, candidates)
        return [nil, nil] if candidates.empty?

        idx = @mutex.synchronize { @round_robin[key] % candidates.size }
        [candidates[idx], idx]
      end

      def pinned_reasons(peer)
        return [:unknown_peer] unless peer
        return [:unreachable] unless alive?(peer)

        [:selected]
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
