# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Igniter
  module Cluster
    module Ownership
      class OwnerClient
        def initialize(resolver:, timeout: 10)
          @resolver = resolver
          @timeout = timeout
        end

        def request(entity_type, entity_id, method:, path:, body: nil, headers: {}, fallback_capability: nil, fallback_query: nil, deferred_result: nil)
          resolution = @resolver.resolve(
            entity_type,
            entity_id,
            fallback_capability: fallback_capability,
            fallback_query: fallback_query,
            deferred_result: deferred_result
          )

          uri = build_uri(resolution.fetch(:url), path)
          response = perform_request(uri, method.to_s.upcase, body, headers)

          {
            owner: resolution[:owner],
            claim: resolution[:claim],
            status: response.code.to_i,
            body: response.body.to_s,
            headers: response.to_hash.transform_values { |values| Array(values).join(", ") }
          }
        end

        private

        def perform_request(uri, method, body, headers)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme == "https"
          http.read_timeout = @timeout
          http.open_timeout = 5

          request = build_request(uri, method, body, headers)
          http.request(request)
        end

        def build_request(uri, method, body, headers)
          request_class = case method
                          when "GET" then Net::HTTP::Get
                          when "POST" then Net::HTTP::Post
                          when "PATCH" then Net::HTTP::Patch
                          when "PUT" then Net::HTTP::Put
                          when "DELETE" then Net::HTTP::Delete
                          else
                            raise ArgumentError, "Unsupported owner request method: #{method.inspect}"
                          end

          request = request_class.new(uri.request_uri)
          headers.each { |key, value| request[key] = value }
          if body
            request.body = body.is_a?(String) ? body : JSON.generate(body)
            request["Content-Type"] ||= "application/json"
          end
          request
        end

        def build_uri(base_url, path)
          base = base_url.to_s.sub(%r{/\z}, "")
          URI.parse("#{base}#{path}")
        end
      end
    end
  end
end
