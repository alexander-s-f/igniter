# frozen_string_literal: true

module Igniter
  module Server
    # Rack-compatible application adapter.
    # Allows igniter-stack to run under any Rack-compatible server (Puma, Unicorn, etc.).
    #
    # Usage in config.ru:
    #   require "igniter/server"
    #   Igniter::Server.configure { |c| c.register "MyContract", MyContract }
    #   run Igniter::Server.rack_app
    class RackApp
      def initialize(config)
        config.logger ||= ServerLogger.new(format: config.log_format)
        @router = Router.new(config)
      end

      def call(env) # rubocop:disable Metrics/MethodLength
        method   = env["REQUEST_METHOD"]
        path     = env["PATH_INFO"]
        body_str = env["rack.input"].read

        result = @router.call(method, path, body_str, headers: request_headers(env), env: env)

        if result[:stream]
          return [
            result[:status],
            result[:headers],
            result[:body]
          ]
        end

        [
          result[:status],
          result[:headers].merge("Content-Length" => result[:body].bytesize.to_s),
          [result[:body]]
        ]
      rescue StandardError => e
        error_body = JSON.generate({ error: "Internal server error: #{e.message}" })
        [500, { "Content-Type" => "application/json" }, [error_body]]
      end

      private

      def request_headers(env)
        env.each_with_object({}) do |(key, value), memo|
          case key
          when /\AHTTP_(.+)\z/
            name = Regexp.last_match(1).split("_").map(&:capitalize).join("-")
            memo[name] = value
          when "CONTENT_TYPE"
            memo["Content-Type"] = value
          when "CONTENT_LENGTH"
            memo["Content-Length"] = value
          end
        end
      end
    end
  end
end
