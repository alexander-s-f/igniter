# frozen_string_literal: true

require "json"
require "uri"

module Igniter
  module Server
    # Transport-agnostic HTTP router.
    # Receives (method, path, body_string) and returns { status:, body:, headers: }.
    # Used by both HttpServer (TCPServer) and RackApp.
    class Router
      ROUTES = [
        { method: "GET",    pattern: %r{\A/v1/live\z},                             handler: :liveness },
        { method: "GET",    pattern: %r{\A/v1/ready\z},                            handler: :readiness },
        { method: "GET",    pattern: %r{\A/v1/metrics\z},                          handler: :metrics },
        { method: "GET",    pattern: %r{\A/v1/health\z},                           handler: :health },
        { method: "GET",    pattern: %r{\A/v1/manifest\z},                         handler: :manifest },
        { method: "GET",    pattern: %r{\A/v1/mesh/peers\z},                       handler: :mesh_peers_list },
        { method: "GET",    pattern: %r{\A/v1/mesh/sd\z}, handler: :mesh_sd },
        { method: "POST",   pattern: %r{\A/v1/mesh/peers\z},                       handler: :mesh_peers_register },
        { method: "DELETE", pattern: %r{\A/v1/mesh/peers/(?<name>.+)\z},           handler: :mesh_peers_delete },
        { method: "GET",    pattern: %r{\A/v1/contracts\z},                        handler: :contracts },
        { method: "POST",   pattern: %r{\A/v1/contracts/(?<name>[^/]+)/execute\z}, handler: :execute },
        { method: "POST",   pattern: %r{\A/v1/contracts/(?<name>[^/]+)/events\z},  handler: :event },
        { method: "GET",    pattern: %r{\A/v1/executions/(?<id>[^/]+)\z},          handler: :status }
      ].freeze

      def initialize(config)
        @config = config
      end

      # Main dispatch entry point — called by both HttpServer and RackApp.
      # Records HTTP metrics when a collector is configured.
      def call(http_method, path, body_str, headers: {}, env: nil) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        started_at = Time.now.utc
        method_uc  = http_method.to_s.upcase
        normalized_path = normalize_path(path)
        body = parse_body(body_str, headers)

        custom_result = dispatch_custom_route(
          method_uc,
          normalized_path,
          body,
          headers: headers,
          env: env,
          raw_body: body_str
        )
        if custom_result
          record_http_metric(method_uc, normalized_path, custom_result[:status], started_at)
          return custom_result
        end

        ROUTES.each do |route|
          next unless route[:method] == method_uc

          match = route[:pattern].match(normalized_path)
          next unless match

          params  = match.named_captures.transform_keys(&:to_sym)
          handler = build_handler(route[:handler])
          result  = handler.call(params: params, body: body)

          record_http_metric(method_uc, normalized_path, result[:status], started_at)
          return result
        end

        result = not_found_response(normalized_path)
        record_http_metric(method_uc, normalized_path, 404, started_at)
        result
      rescue JSON::ParserError => e
        { status: 400, body: JSON.generate({ error: "Invalid JSON: #{e.message}" }), headers: json_ct }
      end

      private

      def build_handler(key) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
        registry  = @config.registry
        store     = @config.store
        node_url  = "http://#{@config.host}:#{@config.port}"
        collector = @config.metrics_collector

        case key
        when :liveness           then Handlers::LivenessHandler.new(registry, store)
        when :readiness          then Handlers::ReadinessHandler.new(registry, store)
        when :metrics            then Handlers::MetricsHandler.new(registry, store, collector: collector)
        when :health             then Handlers::HealthHandler.new(registry, store, node_url: node_url)
        when :manifest           then Handlers::ManifestHandler.new(registry, store, config: @config)
        when :mesh_peers_list    then Handlers::MeshPeersListHandler.new(registry, store)
        when :mesh_sd            then Handlers::MeshSdHandler.new(registry, store)
        when :mesh_peers_register then Handlers::MeshPeersRegisterHandler.new(registry, store)
        when :mesh_peers_delete  then Handlers::MeshPeersDeleteHandler.new(registry, store)
        when :contracts          then Handlers::ContractsHandler.new(registry, store)
        when :execute            then Handlers::ExecuteHandler.new(registry, store, collector: collector)
        when :event              then Handlers::EventHandler.new(registry, store, collector: collector)
        when :status             then Handlers::StatusHandler.new(registry, store)
        end
      end

      def dispatch_custom_route(method, path, body, headers:, env:, raw_body:)
        Array(@config.custom_routes).each do |route|
          next unless route[:method] == method

          params = match_custom_path(route[:path], path)
          next unless params

          result = route.fetch(:handler).call(
            params: params,
            body: body,
            headers: headers,
            env: env,
            raw_body: raw_body,
            config: @config
          )

          return coerce_custom_result(result)
        end

        nil
      end

      def match_custom_path(pattern, path)
        case pattern
        when String
          pattern == path ? {} : nil
        when Regexp
          match = pattern.match(path)
          match ? match.named_captures.transform_keys(&:to_sym) : nil
        else
          raise ArgumentError, "Custom route path must be a String or Regexp"
        end
      end

      def coerce_custom_result(result)
        if custom_response_hash?(result)
          {
            status: integer_or_default(result[:status] || result["status"], 200),
            body: serialize_custom_body(result[:body] || result["body"]),
            headers: (result[:headers] || result["headers"] || json_ct).transform_keys(&:to_s)
          }
        else
          { status: 200, body: serialize_custom_body(result), headers: json_ct }
        end
      end

      def custom_response_hash?(result)
        result.is_a?(Hash) && (result.key?(:status) || result.key?("status") ||
          result.key?(:body) || result.key?("body") || result.key?(:headers) || result.key?("headers"))
      end

      def serialize_custom_body(body)
        case body
        when String
          body
        when nil
          ""
        else
          JSON.generate(body)
        end
      end

      def integer_or_default(value, default)
        value.nil? ? default : value.to_i
      end

      def record_http_metric(method, path, status, started_at)
        return unless @config.metrics_collector

        duration = Time.now.utc - started_at
        @config.metrics_collector.record_http(
          method: method, path: path, status: status, duration: duration
        )
      end

      def parse_body(str, headers = {})
        return {} if str.nil? || str.strip.empty?

        case request_content_type(headers)
        when "application/x-www-form-urlencoded"
          parse_form_body(str)
        else
          JSON.parse(str)
        end
      end

      def parse_form_body(str)
        URI.decode_www_form(str).each_with_object({}) do |(key, value), memo|
          if memo.key?(key)
            memo[key] = Array(memo[key]) << value
          else
            memo[key] = value
          end
        end
      end

      def request_content_type(headers)
        headers.to_h.each do |key, value|
          next unless key.to_s.casecmp("Content-Type").zero?

          return value.to_s.split(";", 2).first.strip.downcase
        end

        nil
      end

      def normalize_path(path)
        path.to_s.split("?", 2).first
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
