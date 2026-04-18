# frozen_string_literal: true

require "uri"

module Igniter
  module Frontend
    class Request
      attr_reader :method, :path, :route_params, :body, :headers, :env, :raw_body

      def initialize(method:, path:, route_params:, body:, headers:, env:, raw_body:)
        @method = method.to_s.upcase
        @path = path.to_s
        @route_params = stringify_keys(route_params)
        @body = body
        @headers = stringify_keys(headers)
        @env = env.to_h
        @raw_body = raw_body.to_s
      end

      def script_name
        env.fetch("SCRIPT_NAME", "").to_s
      end

      def query_string
        env.fetch("QUERY_STRING", "").to_s
      end

      def query_params
        @query_params ||= URI.decode_www_form(query_string).each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = value
        end
      end

      def body_params
        body.is_a?(Hash) ? stringify_keys(body) : {}
      end

      def params
        route_params.merge(query_params).merge(body_params)
      end

      def full_path
        return path if query_string.empty?

        "#{path}?#{query_string}"
      end

      def content_type
        headers["Content-Type"].to_s
      end

      private

      def stringify_keys(value)
        value.to_h.each_with_object({}) do |(key, nested), memo|
          memo[key.to_s] = nested
        end
      end
    end
  end
end
