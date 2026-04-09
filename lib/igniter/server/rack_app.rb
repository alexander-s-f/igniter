# frozen_string_literal: true

module Igniter
  module Server
    # Rack-compatible application adapter.
    # Allows igniter-server to run under any Rack-compatible server (Puma, Unicorn, etc.).
    #
    # Usage in config.ru:
    #   require "igniter/server"
    #   Igniter::Server.configure { |c| c.register "MyContract", MyContract }
    #   run Igniter::Server.rack_app
    class RackApp
      def initialize(config)
        @router = Router.new(config)
      end

      def call(env) # rubocop:disable Metrics/MethodLength
        method   = env["REQUEST_METHOD"]
        path     = env["PATH_INFO"]
        body_str = env["rack.input"].read

        result = @router.call(method, path, body_str)

        [
          result[:status],
          result[:headers].merge("Content-Length" => result[:body].bytesize.to_s),
          [result[:body]]
        ]
      rescue StandardError => e
        error_body = JSON.generate({ error: "Internal server error: #{e.message}" })
        [500, { "Content-Type" => "application/json" }, [error_body]]
      end
    end
  end
end
