# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Igniter
  module LedgerClient
    module Transports
      class RemoteHTTP
        attr_reader :uri, :open_timeout, :read_timeout

        def initialize(endpoint, open_timeout: 1.0, read_timeout: 2.0, write_timeout: nil, headers: {})
          @uri = normalize_endpoint(endpoint)
          @open_timeout = open_timeout
          @read_timeout = read_timeout
          @write_timeout = write_timeout
          @headers = headers
        end

        def dispatch(envelope)
          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          @headers.each { |key, value| request[key.to_s] = value }
          request.body = JSON.generate(envelope)

          response = http.request(request)
          raise TransportError, "ledger HTTP #{uri} returned #{response.code}" unless response.code.to_i.between?(200, 299)

          JSON.parse(response.body, symbolize_names: true)
        rescue JSON::ParserError => e
          raise TransportError, "invalid ledger HTTP response: #{e.message}"
        end

        private

        def http
          Net::HTTP.new(uri.host, uri.port).tap do |client|
            client.use_ssl = uri.scheme == "https"
            client.open_timeout = open_timeout if open_timeout
            client.read_timeout = read_timeout if read_timeout
            client.write_timeout = @write_timeout if @write_timeout && client.respond_to?(:write_timeout=)
          end
        end

        def normalize_endpoint(endpoint)
          parsed = URI(endpoint.to_s)
          parsed.path = "/v1/dispatch" if parsed.path.nil? || parsed.path.empty? || parsed.path == "/"
          parsed
        end
      end
    end
  end
end
