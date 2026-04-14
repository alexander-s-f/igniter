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
        server_settings = host_config.host_settings_for(:server)

        Config.new.tap do |config|
          config.host                 = server_settings.fetch(:host, "0.0.0.0")
          config.port                 = server_settings.fetch(:port, 4567)
          config.store                = host_config.store if host_config.store
          config.log_format           = server_settings.fetch(:log_format, :text)
          config.drain_timeout        = server_settings.fetch(:drain_timeout, 30)
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
