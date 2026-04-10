# frozen_string_literal: true

require "igniter"
require "json"

# Define the top-level Server module and Error class first,
# so subfiles can inherit from Igniter::Server::Error.
module Igniter
  module Server
    class Error < Igniter::Error; end
  end
end

require_relative "server/registry"
require_relative "server/server_logger"
require_relative "server/config"
require_relative "server/router"
require_relative "server/http_server"
require_relative "server/rack_app"
require_relative "server/client"
require_relative "server/handlers/base"
require_relative "server/handlers/health_handler"
require_relative "server/handlers/contracts_handler"
require_relative "server/handlers/execute_handler"
require_relative "server/handlers/event_handler"
require_relative "server/handlers/status_handler"
require_relative "server/handlers/liveness_handler"
require_relative "server/handlers/readiness_handler"
require_relative "server/handlers/metrics_handler"

module Igniter
  module Server
    class << self
      def config
        @config ||= Config.new
      end

      def configure
        yield config
        self
      end

      # Start the built-in HTTP server (blocking).
      def start(**options)
        apply_options!(options)
        HttpServer.new(config).start
      end

      # Return a Rack-compatible application for use with Puma/Unicorn/etc.
      def rack_app
        RackApp.new(config)
      end

      # Reset configuration (useful in tests).
      def reset!
        @config = nil
      end

      private

      def apply_options!(options) # rubocop:disable Metrics/AbcSize
        config.port  = options[:port]  if options[:port]
        config.host  = options[:host]  if options[:host]
        config.store = options[:store] if options[:store]
        return unless options[:contracts].is_a?(Hash)

        options[:contracts].each { |name, klass| config.register(name.to_s, klass) }
      end
    end
  end
end
