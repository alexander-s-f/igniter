# frozen_string_literal: true

require "json"

module Igniter
  module Server
    # Transport-agnostic HTTP router.
    # Receives (method, path, body_string) and returns { status:, body:, headers: }.
    # Used by both HttpServer (TCPServer) and RackApp.
    class Router
      ROUTES = [
        { method: "GET",  pattern: %r{\A/v1/health\z}, handler: :health },
        { method: "GET",  pattern: %r{\A/v1/contracts\z},                             handler: :contracts },
        { method: "POST", pattern: %r{\A/v1/contracts/(?<name>[^/]+)/execute\z},      handler: :execute },
        { method: "POST", pattern: %r{\A/v1/contracts/(?<name>[^/]+)/events\z},       handler: :event },
        { method: "GET",  pattern: %r{\A/v1/executions/(?<id>[^/]+)\z},               handler: :status }
      ].freeze

      def initialize(config)
        @config = config
      end

      # Main dispatch entry point — called by both WEBrick and Rack adapters.
      def call(http_method, path, body_str) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        method_uc = http_method.to_s.upcase
        ROUTES.each do |route|
          next unless route[:method] == method_uc

          match = route[:pattern].match(path)
          next unless match

          params = match.named_captures.transform_keys(&:to_sym)
          body   = parse_body(body_str)

          handler = build_handler(route[:handler])
          return handler.call(params: params, body: body)
        end

        not_found_response(path)
      rescue JSON::ParserError => e
        { status: 400, body: JSON.generate({ error: "Invalid JSON: #{e.message}" }), headers: json_ct }
      end

      private

      def build_handler(key)
        registry = @config.registry
        store    = @config.store
        node_url = "http://#{@config.host}:#{@config.port}"

        case key
        when :health     then Handlers::HealthHandler.new(registry, store, node_url: node_url)
        when :contracts  then Handlers::ContractsHandler.new(registry, store)
        when :execute    then Handlers::ExecuteHandler.new(registry, store)
        when :event      then Handlers::EventHandler.new(registry, store)
        when :status     then Handlers::StatusHandler.new(registry, store)
        end
      end

      def parse_body(str)
        return {} if str.nil? || str.strip.empty?

        JSON.parse(str)
      end

      def not_found_response(path)
        { status: 404, body: JSON.generate({ error: "Not found: #{path}" }), headers: json_ct }
      end

      def json_ct
        { "Content-Type" => "application/json" }
      end
    end
  end
end
