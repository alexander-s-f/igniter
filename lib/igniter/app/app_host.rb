# frozen_string_literal: true

require_relative "host_adapter"

module Igniter
  class App
    # Default server-backed host adapter for Igniter::App.
    #
    # This class belongs to the application layer's host model. It happens to be
    # implemented on top of Igniter::Server today, but the host decision is now
    # expressed explicitly from the application side.
    class AppHost < HostAdapter
      def build_config(host_config)
        app_settings = host_config.host_settings_for(:app)

        Igniter::Server::Config.new.tap do |config|
          config.host                 = app_settings.fetch(:host, "0.0.0.0")
          config.port                 = app_settings.fetch(:port, 4567)
          config.store                = host_config.store if host_config.store
          config.log_format           = app_settings.fetch(:log_format, :text)
          config.drain_timeout        = app_settings.fetch(:drain_timeout, 30)
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
        Igniter::Server::HttpServer.new(config).start
      end

      def rack_app(config:)
        Igniter::Server::RackApp.new(config)
      end
    end
  end
end
