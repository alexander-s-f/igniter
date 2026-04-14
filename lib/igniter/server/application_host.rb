# frozen_string_literal: true

require_relative "../application/host_adapter"

module Igniter
  module Server
    # Default host adapter for Igniter::Application.
    #
    # Keeps HTTP hosting concerns in the server layer while Application remains
    # responsible for assembling the app graph, config, and scheduler.
    class ApplicationHost < Igniter::Application::HostAdapter
      def build_config(app_config)
        app_config.to_server_config
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
