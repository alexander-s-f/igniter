# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      # Returns a JSON manifest describing this peer: its name, advertised
      # capabilities, registered contracts, and its base URL.
      # Used by Igniter::Mesh::Router health-probing and peer discovery.
      class ManifestHandler < Base
        def initialize(registry, store, config: nil)
          super(registry, store)
          @config = config
        end

        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          json_ok({
                    peer_name: @config&.peer_name,
                    capabilities: (@config&.peer_capabilities || []).map(&:to_s),
                    contracts: @registry.names,
                    url: node_url
                  })
        end

        def node_url
          return nil unless @config

          "http://#{@config.host}:#{@config.port}"
        end
      end
    end
  end
end
