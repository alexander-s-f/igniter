# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Igniter
  module Channels
    class Webhook < Base
      DEFAULT_OPEN_TIMEOUT = 10
      DEFAULT_READ_TIMEOUT = 30
      BODY_METHODS = %i[post put patch].freeze

      effect_type :webhook
      channel_name :webhook

      def initialize(url: nil, method: :post, headers: {}, params: nil,
                     open_timeout: DEFAULT_OPEN_TIMEOUT, read_timeout: DEFAULT_READ_TIMEOUT,
                     basic_auth: nil)
        @url = url
        @method = method.to_sym
        @headers = (headers || {}).dup.freeze
        @params = params
        @open_timeout = open_timeout
        @read_timeout = read_timeout
        @basic_auth = basic_auth
      end

      private

      def deliver_message(message)
        uri = build_uri(message)
        request = build_request(message, uri)
        response = perform_request(uri, request)

        unless response.is_a?(Net::HTTPSuccess)
          raise DeliveryError.new(
            "Webhook delivery failed with HTTP #{response.code}",
            context: {
              channel: self.class.channel_name,
              recipient: message.to || @url,
              status_code: response.code.to_i,
              response_body: response.body.to_s[0, 300]
            }
          )
        end

        DeliveryResult.new(
          status: delivery_status_for(response),
          provider: self.class.channel_name,
          recipient: message.to || @url,
          external_id: response["x-request-id"] || response["x-correlation-id"],
          payload: {
            status_code: response.code.to_i,
            headers: response.to_hash,
            body: parse_response_body(response.body)
          }
        )
      rescue URI::InvalidURIError => e
        raise DeliveryError.new(
          "Invalid webhook URL: #{e.message}",
          context: { channel: self.class.channel_name, recipient: message.to || @url }
        )
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise DeliveryError.new(
          "Cannot deliver webhook: #{e.message}",
          context: { channel: self.class.channel_name, recipient: message.to || @url }
        )
      end

      def build_uri(message)
        destination = message.to || @url
        raise ArgumentError, "Webhook destination URL is required" if destination.nil? || destination.to_s.empty?

        uri = URI.parse(destination)
        merged_query = merge_query(uri.query, params_for(message))
        uri.query = merged_query unless merged_query.nil? || merged_query.empty?
        uri
      end

      def params_for(message)
        default_params = @params || {}
        message_params = message.metadata[:params] || {}
        return nil if default_params.empty? && message_params.empty?

        default_params.merge(message_params)
      end

      def build_request(message, uri)
        request = request_class_for(method_for(message)).new(uri.request_uri)
        resolved_headers(message).each { |key, value| request[key] = value }
        apply_basic_auth(request, basic_auth_for(message))

        return request unless BODY_METHODS.include?(method_for(message))

        encoded_body = encode_body(message)
        request.body = encoded_body unless encoded_body.nil?
        request
      end

      def method_for(message)
        (message.metadata[:method] || @method).to_sym
      end

      def resolved_headers(message)
        headers = @headers.merge(message.metadata[:headers] || {})
        return headers unless content_type_header_needed?(headers)

        inferred = inferred_content_type(message)
        inferred ? headers.merge("Content-Type" => inferred) : headers
      end

      def content_type_header_needed?(headers)
        headers.keys.none? { |key| key.downcase == "content-type" }
      end

      def inferred_content_type(message)
        case message.content_type
        when :json
          "application/json"
        when :form
          "application/x-www-form-urlencoded"
        when :html
          "text/html"
        when :binary
          "application/octet-stream"
        when :text
          message.body.is_a?(Hash) || message.body.is_a?(Array) ? "application/json" : "text/plain"
        else
          nil
        end
      end

      def encode_body(message)
        body = message.body
        return nil if body.nil?

        case content_type_for(message)
        when "application/x-www-form-urlencoded"
          raise ArgumentError, "Form webhook body must be a Hash" unless body.is_a?(Hash)

          URI.encode_www_form(body)
        when "application/json"
          body.is_a?(String) ? body : JSON.generate(body)
        else
          body.respond_to?(:read) ? body.read : body.to_s
        end
      end

      def content_type_for(message)
        explicit = resolved_headers(message).find { |key, _| key.downcase == "content-type" }
        explicit ? explicit.last : inferred_content_type(message)
      end

      def basic_auth_for(message)
        message.metadata[:basic_auth] || @basic_auth
      end

      def apply_basic_auth(request, credentials)
        return unless credentials

        username, password = case credentials
                             when Array then credentials
                             when Hash then [credentials[:username] || credentials["username"],
                                             credentials[:password] || credentials["password"]]
                             else
                               raise ArgumentError, "basic_auth must be an Array or Hash"
                             end
        request.basic_auth(username.to_s, password.to_s)
      end

      def perform_request(uri, request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = @open_timeout
        http.read_timeout = @read_timeout
        http.request(request)
      end

      def request_class_for(method)
        case method
        when :get then Net::HTTP::Get
        when :post then Net::HTTP::Post
        when :put then Net::HTTP::Put
        when :patch then Net::HTTP::Patch
        when :delete then Net::HTTP::Delete
        else
          raise ArgumentError, "Unsupported webhook HTTP method: #{method.inspect}"
        end
      end

      def merge_query(existing_query, extra_params)
        return existing_query if extra_params.nil? || extra_params.empty?

        existing = existing_query ? URI.decode_www_form(existing_query) : []
        extra = URI.encode_www_form(extra_params).split("&").map { |pair| pair.split("=", 2) }
        URI.encode_www_form(existing + extra)
      end

      def parse_response_body(body)
        JSON.parse(body.to_s)
      rescue JSON::ParserError
        body.to_s
      end

      def delivery_status_for(response)
        return :queued if response.code.to_i == 202

        :delivered
      end
    end
  end
end
