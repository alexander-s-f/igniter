# frozen_string_literal: true

require_relative "../application/host_adapter"

module Igniter
  module Server
    # Default host adapter for Igniter::Application.
    #
    # Keeps HTTP hosting concerns in the server layer while Application remains
    # responsible for assembling the app graph, config, and scheduler.
    class ApplicationHost < Igniter::Application::HostAdapter
      def build_config(host_config)
        Config.new.tap do |config|
          config.host                 = host_config.host
          config.port                 = host_config.port
          config.store                = host_config.store if host_config.store
          config.log_format           = host_config.log_format
          config.drain_timeout        = host_config.drain_timeout
          config.metrics_collector    = host_config.metrics_collector
          config.custom_routes        = host_config.custom_routes
          config.before_request_hooks = host_config.before_request_hooks
          config.after_request_hooks  = host_config.after_request_hooks
          config.around_request_hooks = host_config.around_request_hooks
          host_config.registrations.each do |name, klass|
            config.register(name, klass)
          end
        end
      end

      def activate_transport!
        Igniter::Server.activate_remote_adapter!
      end

      def start(config:)
        HttpServer.new(config).start
      end

      def rack_app(config:)
        RackApp.new(config)
      end
    end
  end
end
