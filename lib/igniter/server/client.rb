# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Igniter
  module Server
    # HTTP client for calling remote igniter-stack nodes.
    # Uses only stdlib (Net::HTTP + JSON), no external gems required.
    class Client # rubocop:disable Metrics/ClassLength
      class Error < Igniter::Server::Error; end
      class ConnectionError < Error; end
      class RemoteError < Error; end

      def initialize(base_url, timeout: 30)
        @base_url = base_url.chomp("/")
        @timeout  = timeout
      end

      # Execute a contract on the remote node synchronously.
      #
      # Returns a symbolized hash:
      #   { status: :succeeded, execution_id: "uuid", outputs: { result: 42 } }
      #   { status: :failed,    execution_id: "uuid", error: { message: "..." } }
      #   { status: :pending,   execution_id: "uuid", waiting_for: ["event"] }
      def execute(contract_name, inputs: {})
        response = post(
          "/v1/contracts/#{uri_encode(contract_name)}/execute",
          { inputs: inputs }
        )
        symbolize_response(response)
      end

      # Deliver an event to a pending distributed workflow on the remote node.
      def deliver_event(contract_name, event:, correlation:, payload: {})
        response = post(
          "/v1/contracts/#{uri_encode(contract_name)}/events",
          { event: event, correlation: correlation, payload: payload }
        )
        symbolize_response(response)
      end

      # Fetch execution status by ID.
      def status(execution_id)
        symbolize_response(get("/v1/executions/#{uri_encode(execution_id)}"))
      end

      # Check remote node health.
      def health
        get("/v1/health")
      end

      # Fetch peer manifest: peer_name, capabilities, contracts, url.
      def manifest
        response = get("/v1/manifest")
        {
          peer_name: response["peer_name"],
          capabilities: (response["capabilities"] || []).map(&:to_sym),
          tags: (response["tags"] || []).map(&:to_sym),
          metadata: response["metadata"] || {},
          contracts: response["contracts"] || [],
          url: response["url"]
        }
      end

      # Fetch the list of all peers known to the remote node.
      # Returns an Array of hashes with :name, :url, :capabilities (Array<Symbol>).
      def list_peers
        Array(get("/v1/mesh/peers")).map do |p|
          {
            name: p["name"],
            url: p["url"],
            capabilities: Array(p["capabilities"]).map(&:to_sym),
            tags: Array(p["tags"]).map(&:to_sym),
            metadata: p["metadata"] || {}
          }
        end
      end

      # Register this node as a peer on the remote node.
      def register_peer(name:, url:, capabilities: [], tags: [], metadata: {})
        post("/v1/mesh/peers",
             {
               "name" => name,
               "url" => url,
               "capabilities" => capabilities.map(&:to_s),
               "tags" => tags.map(&:to_s),
               "metadata" => metadata
             })
      end

      # Remove a peer registration from the remote node. Best-effort.
      def unregister_peer(name)
        delete_request("/v1/mesh/peers/#{uri_encode(name)}")
      end

      private

      def post(path, body)
        uri  = build_uri(path)
        http = build_http(uri)
        req  = Net::HTTP::Post.new(uri.path, json_headers)
        req.body = JSON.generate(body)
        parse_response(http.request(req))
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout => e
        raise ConnectionError, "Cannot connect to #{@base_url}: #{e.message}"
      end

      def get(path)
        uri  = build_uri(path)
        http = build_http(uri)
        req  = Net::HTTP::Get.new(uri.path, json_headers)
        parse_response(http.request(req))
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout => e
        raise ConnectionError, "Cannot connect to #{@base_url}: #{e.message}"
      end

      def delete_request(path)
        uri  = build_uri(path)
        http = build_http(uri)
        req  = Net::HTTP::Delete.new(uri.path, json_headers)
        parse_response(http.request(req))
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout => e
        raise ConnectionError, "Cannot connect to #{@base_url}: #{e.message}"
      end

      def build_uri(path)
        URI.parse("#{@base_url}#{path}")
      end

      def build_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl      = uri.scheme == "https"
        http.read_timeout = @timeout
        http.open_timeout = 10
        http
      end

      def json_headers
        { "Content-Type" => "application/json", "Accept" => "application/json" }
      end

      def parse_response(response)
        body = begin
          JSON.parse(response.body.to_s)
        rescue JSON::ParserError
          {}
        end
        raise RemoteError, "Remote error #{response.code}: #{body["error"]}" unless response.is_a?(Net::HTTPSuccess)

        body
      end

      def symbolize_response(hash)
        {
          status: hash["status"]&.to_sym,
          execution_id: hash["execution_id"],
          outputs: symbolize_keys(hash["outputs"] || {}),
          waiting_for: hash["waiting_for"] || [],
          error: hash["error"]
        }
      end

      def symbolize_keys(hash)
        return hash unless hash.is_a?(Hash)

        hash.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v }
      end

      def uri_encode(str)
        URI.encode_uri_component(str.to_s)
      end
    end
  end
end
