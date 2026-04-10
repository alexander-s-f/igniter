# frozen_string_literal: true

require "uri"

module Igniter
  module Server
    module Handlers
      # Shared helper — merges static (add_peer) and dynamic (PeerRegistry) peer pools.
      # Static entries take precedence when the same name appears in both pools.
      module MeshPeersMerger
        private

        def merged_peers
          return [] unless defined?(Igniter::Mesh)

          static  = Igniter::Mesh.config.peers
          dynamic = Igniter::Mesh.config.peer_registry.all
          seen    = static.each_with_object({}) { |p, h| h[p.name] = true }
          static + dynamic.reject { |p| seen[p.name] }
        end
      end

      # GET /v1/mesh/peers
      # Returns the merged list of static + dynamically discovered peers.
      class MeshPeersListHandler < Base
        include MeshPeersMerger

        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          json_ok(merged_peers.map do |p|
            { "name" => p.name, "url" => p.url, "capabilities" => p.capabilities.map(&:to_s) }
          end)
        end
      end

      # GET /v1/mesh/sd
      # Returns the peer list in Prometheus HTTP SD format so that Prometheus can
      # dynamically discover all igniter-server scrape targets without a static target list.
      #
      # Response shape (one object per peer):
      #   [{ "targets" => ["host:port"], "labels" => { "__meta_igniter_peer_name" => ..., ... } }]
      #
      # Usage in prometheus.yml:
      #   scrape_configs:
      #     - job_name: igniter
      #       http_sd_configs:
      #         - url: http://any-seed:4567/v1/mesh/sd
      #           refresh_interval: 30s
      #       metrics_path: /v1/metrics
      class MeshSdHandler < Base
        include MeshPeersMerger

        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          json_ok(merged_peers.map { |p| sd_entry(p) })
        end

        def sd_entry(peer)
          {
            "targets" => [host_port(peer.url)],
            "labels" => {
              "__meta_igniter_peer_name" => peer.name,
              "__meta_igniter_capabilities" => peer.capabilities.map(&:to_s).join(",")
            }
          }
        end

        def host_port(url)
          uri = URI.parse(url)
          "#{uri.host}:#{uri.port}"
        rescue URI::InvalidURIError
          url
        end
      end

      # POST /v1/mesh/peers
      # Body: { "name": "peer-name", "url": "http://host:port", "capabilities": ["a", "b"] }
      class MeshPeersRegisterHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument, Metrics/AbcSize
          return json_error("Igniter::Mesh is not loaded", status: 422) unless defined?(Igniter::Mesh)

          name = body["name"].to_s.strip
          url  = body["url"].to_s.strip
          return json_error("name is required", status: 400) if name.empty?
          return json_error("url is required",  status: 400) if url.empty?

          caps = Array(body["capabilities"]).map(&:to_sym)
          peer = Igniter::Mesh::Peer.new(name: name, url: url, capabilities: caps)
          Igniter::Mesh.config.peer_registry.register(peer)

          json_ok({ "registered" => true, "name" => name })
        end
      end

      # DELETE /v1/mesh/peers/:name
      # Idempotent — no error if the peer was not registered.
      class MeshPeersDeleteHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          return json_error("Igniter::Mesh is not loaded", status: 422) unless defined?(Igniter::Mesh)

          name = params[:name].to_s
          Igniter::Mesh.config.peer_registry.unregister(name)

          json_ok({ "unregistered" => true, "name" => name })
        end
      end
    end
  end
end
