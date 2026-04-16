# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
    # Announces this node's identity to seed nodes at startup and withdraws
    # the registration on graceful shutdown.
    #
    # All network errors are swallowed — a seed being temporarily down must
    # not prevent the local node from starting. The background Poller will
    # re-register once the seed recovers.
    class Announcer
      def initialize(config)
        @config = config
      end

      # POST self-manifest to every configured seed. No-op if peer_name or
      # local_url are not configured.
      def announce_all
        return unless announceable?

        @config.seeds.each { |url| announce_to(url) }
      end

      # DELETE self from every configured seed. Best-effort — errors are ignored.
      def deannounce_all
        return unless @config.peer_name

        @config.seeds.each { |url| deannounce_from(url) }
      end

      private

      def announceable?
        @config.peer_name && !@config.peer_name.to_s.strip.empty? &&
          @config.local_url && !@config.local_url.to_s.strip.empty?
      end

      def announce_to(seed_url)
        Igniter::Server::Client.new(seed_url, timeout: 5).register_peer(
          name: @config.peer_name,
          url: @config.local_url,
          capabilities: @config.local_capabilities,
          tags: @config.local_tags,
          metadata: PeerMetadata.authoritative(@config.local_metadata, origin: @config.peer_name)
        )
      rescue Igniter::Server::Client::ConnectionError
        nil
      end

      def deannounce_from(seed_url)
        Igniter::Server::Client.new(seed_url, timeout: 5).unregister_peer(@config.peer_name)
      rescue Igniter::Server::Client::ConnectionError
        nil
      end
    end
    end
  end
end
