# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      # GET /v1/mesh/peers
      # Returns the merged list of static + dynamically discovered peers.
      class MeshPeersListHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          return json_ok([]) unless defined?(Igniter::Mesh)

          peers = merged_peers
          json_ok(peers.map { |p| { "name" => p.name, "url" => p.url, "capabilities" => p.capabilities.map(&:to_s) } })
        end

        def merged_peers
          static  = Igniter::Mesh.config.peers
          dynamic = Igniter::Mesh.config.peer_registry.all
          seen    = static.each_with_object({}) { |p, h| h[p.name] = true }
          static + dynamic.reject { |p| seen[p.name] }
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
